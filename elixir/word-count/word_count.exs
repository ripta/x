defmodule Words do
  @spec count([String.t]) :: map()
  def count(words) when is_list(words) do
    words |> Enum.reduce(%{}, &count_helper/2)
  end

  @doc """
  Count the number of words in the sentence.

  Words are compared case-insensitively.
  """
  @spec count(String.t) :: map()
  def count(sentence) do
    sentence |> String.split |> count
  end

  @spec count_helper(String.t, map()) :: map()
  def count_helper(word, acc) do
    # Map.update(dict, key, initial, fun) :: new_dict
    Map.update(acc, String.downcase(word), 1, &(&1 + 1))
  end
end
