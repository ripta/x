defmodule DNA do
  @nucleotides [?A, ?C, ?G, ?T]

  @doc """
  Counts individual nucleotides in a DNA strand.

  ## Examples

  iex> DNA.count('AATAA', ?A)
  4

  iex> DNA.count('AATAA', ?T)
  1
  """
  @spec count([char], char) :: non_neg_integer
  def count(strand, nucleotide) do
    cond do
      valid_nucleotide?(nucleotide) -> strand |> histogram |> Map.get(nucleotide)
      true -> raise ArgumentError
    end
  end

  def empty_histogram do
    # Uses Map.new/2 available in elixir 1.2+
    Map.new(@nucleotides, &{&1, 0})
  end

  @doc """
  Returns a summary of counts by nucleotide.

  ## Examples

  iex> DNA.histogram('AATAA')
  %{?A => 4, ?T => 1, ?C => 0, ?G => 0}
  """
  @spec histogram([char]) :: Dict.t
  def histogram(strand) do
    strand |> Enum.reduce(empty_histogram, &nucleotide_counter/2)
  end

  defp nucleotide_counter(nucleotide, hist) do
    cond do
      valid_nucleotide?(nucleotide) -> %{hist | nucleotide => hist[nucleotide] + 1}
      true -> raise ArgumentError
    end
  end

  defp valid_nucleotide?(nucleotide) do
    Enum.member?(@nucleotides, nucleotide)
  end
end
