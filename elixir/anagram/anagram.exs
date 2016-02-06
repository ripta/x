defmodule Anagram do
  @doc """
  Returns all candidates that are anagrams of, but not equal to, 'base'.
  """
  @spec match(String.t, [String.t]) :: [String.t]
  def match(base, candidates) do
    nbase = normalize(base)
    candidates
     |> Enum.filter(&(normalize(&1) == nbase))
  end

  defp normalize(word) do
    word |> String.downcase |> String.graphemes |> Enum.sort
  end
end
