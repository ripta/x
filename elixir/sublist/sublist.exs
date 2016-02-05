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

  def compare(a, b) do
    cond do
      sublist?(a, b) -> :sublist
      sublist?(b, a) -> :superlist
      true           -> :unequal
    end
  end

  defp heads?([], _), do: true
  defp heads?([h|t1], [h|t2]), do: heads?(t1, t2)
  defp heads?(_a, _b), do: false

  defp sublist?([], _), do: true
  defp sublist?(_, []), do: false
  # defp sublist?(a, b) when length(a) > length(b), do: false
  defp sublist?(a, [_|t] = b) do
    heads?(a, b) && sublist?(a, t)
  end
end
