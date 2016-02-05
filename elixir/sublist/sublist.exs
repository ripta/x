defmodule Sublist do
  @doc """
  Returns whether the first list is a sublist or a superlist of the second list
  and if not whether it is equal or unequal to the second list.
  """
  def compare([], []), do: :equal
  def compare([], _), do: :sublist
  def compare(_, []), do: :superlist

  def compare(a, a), do: :equal

  def compare(a, b) when length(a) < length(b) do
    case compare(b, a) do
      :sublist   -> :superlist
      :superlist -> :sublist
      other      -> other
    end
  end

  def compare([h|t] = a, b) do
  end
end
