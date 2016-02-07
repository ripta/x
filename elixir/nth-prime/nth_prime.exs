defmodule Prime do

  @doc """
  Generates the nth prime with complexity O(n log log n)
  """
  @spec nth(non_neg_integer) :: non_neg_integer
  def nth(count) when count > 0 do
    primes |> Stream.drop(count - 1) |> Enum.at(0)
  end

  @doc """
  Generates a stream of primes that are lazily computed
  """
  def primes do
    Stream.unfold(candidates, &take_and_drop_multiples/1)
  end

  @doc """
  Generate a stream of prime candidates (integers from 2)
  """
  @spec candidates :: Enumerable.t
  def candidates do
    # &({&1, &1 + 1}) isn't very readable IMO
    Stream.unfold(2, fn n -> {n, n + 1} end)
  end

  defp drop_multiples_of(stream, n) do
    stream |> Stream.filter(&(rem(&1, n) != 0))
  end

  defp take_and_drop_multiples(stream) do
    n = Enum.at(stream, 0)
    {n, drop_multiples_of(stream, n)}
  end

end
