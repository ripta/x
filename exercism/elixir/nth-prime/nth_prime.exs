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
  @spec primes :: Enumerable.t
  def primes do
    Stream.unfold(candidates, &next_stream_for/1)
  end

  @doc """
  Generate a stream of prime candidates (integers from 2)
  """
  @spec candidates :: Enumerable.t
  def candidates do
    # &({&1, &1 + 1}) isn't very readable IMO
    Stream.unfold(2, fn n -> {n, n + 1} end)
  end

  @spec sieve_for(Enumerable.t, integer) :: Enumerable.t
  defp sieve_for(stream, n) do
    stream |> Stream.filter(&(rem(&1, n) != 0))
  end

  @spec next_stream_for(Enumerable.t) :: {integer, Enumerable.t}
  defp next_stream_for(stream) do
    next_prime = Enum.at(stream, 0)
    next_stream = stream |> sieve_for(next_prime)

    {next_prime, next_stream}
  end

end
