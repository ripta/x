defmodule Frequency do
  @doc """
  Count word frequency in parallel.

  Returns a dict of characters to frequencies.

  The number of worker processes to use can be set with 'workers'.
  """
  @spec frequency([String.t], pos_integer) :: Dict.t
  def frequency([], _num_workers), do: []
  def frequency(texts, num_workers) do
    num_workers
    |> start_workers
    |> handle_supervise(texts)
  end

  defp handle_supervise(pids, workloads), do: handle_supervise(pids, workloads, %{})
  defp handle_supervise(pids, _workloads, prev_results) when length(pids) == 0, do: prev_results
  defp handle_supervise(pids, workloads, prev_results) do
    receive do
      {:ready, child} when length(workloads) > 0 ->
        [assigned | rest] = workloads
        send child, {:work, self, assigned}
        handle_supervise(pids, rest, prev_results)
      {:ready, child} ->
        send child, {:stop, self}
        handle_supervise(pids, workloads, prev_results)

      {:stopped, child} ->
        handle_supervise(List.delete(pids, child), workloads, prev_results)

      {:result, child, child_results} ->
        results = Map.merge(prev_results, child_results, &merge_results/3)
        handle_supervise(pids, workloads, results)
    end
  end

  defp handle_work(scheduler) do
    send scheduler, {:ready, self}

    receive do
      {:work, supervisor, work} ->
        send supervisor, {:result, self, perform_work(work)}
        handle_work(supervisor)
      {:stop, supervisor} ->
        send supervisor, {:stopped, self}
        exit(:normal)
    end
  end

  defp perform_work(work) do
    work
    |> String.downcase
    |> String.graphemes
    |> List.foldl(%{}, fn (grapheme, acc) -> Map.update(acc, grapheme, 1, &(&1 + 1)) end)
  end

  defp merge_results(_key, v1, v2) do
    v1 + v2
  end

  @spec start_workers(integer) :: [pid]
  defp start_workers(n) when n > 0 do
    me = self()
    1..n |> Enum.map(fn _ -> spawn(fn -> handle_work(me) end) end)
  end
end
