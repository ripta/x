defmodule Frequency do
  @doc """
  Count word frequency in parallel.

  Returns a dict of characters to frequencies.

  The number of worker processes to use can be set with 'workers'.
  """
  @spec frequency([String.t], pos_integer) :: Dict.t
  def frequency([], _workers), do: []
  def frequency(texts, workers) do
    {:ok, pids} = start_workers(workers)
    handle_supervise(texts, pids)
  end

  defp assign_work(pid, []), do: []
  defp assign_work(pid, [h|t]) do
    send(pid, {:work, self(), h})
    t
  end

  defp broadcast(pids, message) when is_list(pids) do
    pids |> Enum.map(fn pid -> send(pid, message) end)
  end

  defp finished?(workloads, pids) do
    if Enum.empty?(workloads) do
      pids |> broadcast({:stop, self()})
      true
    else
      false
    end
  end

  defp handle_supervise(workloads, pids) do
    workloads_left = Enum.reduce(pids, workloads, &assign_work/2)
    finished?(workloads_left, pids)
    handle_supervise(%{}, workloads_left, pids)
  end

  defp handle_supervise(prev_results, workloads, pids) do
    receive do
      {:result, child, child_results} ->
        unless finished?(workloads, pids), do: child |> assign_work(workloads)
        Map.merge(prev_results, child_results, &merge_results/3) |> handle_supervise(workloads, pids)
      {:stopped} ->
        if Enum.any?(pids, &Process.alive?/1) do
          prev_results |> handle_supervise(workloads, pids)
        end
    end

    prev_results
  end

  defp handle_work do
    receive do
      {:work, supervisor, work} ->
        send supervisor, {:result, self(), perform_work(work)}
      {:stop, supervisor} ->
        send supervisor, {:stopped}
        true
    end
  end

  defp perform_work(work) do
    %{load: 1}
  end

  defp merge_results(_key, v1, v2) do
    v1 + v2
  end

  @spec start_workers(integer) :: [pid]
  defp start_workers(n) when n > 0 do
    pids = 1..n |> Enum.map(fn _ -> spawn(fn -> handle_work end) end)
    {:ok, pids}
  end
end
