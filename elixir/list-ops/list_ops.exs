defmodule ListOps do
  # Please don't use any external modules (especially List) in your
  # implementation. The point of this exercise is to create these basic functions
  # yourself.
  #
  # Note that `++` is a function from an external module (Kernel, which is
  # automatically imported) and so shouldn't be used either.

  # named `count` instead of `length` here, due to Kernel.length/1 import conflicts
  @spec count(list) :: non_neg_integer
  def count([]), do: 0
  def count([_h|t]), do: count(t) + 1

  @spec reverse(list) :: list
  def reverse(l), do: reverse(l, [])
  def reverse([], acc), do: acc
  def reverse([h|t], acc), do: reverse(t, [h|acc])

  @spec map(list, (any -> any)) :: list
  def map([], _f), do: []
  def map([h|t], f), do: [f.(h) | map(t, f)]

  @spec filter(list, (any -> as_boolean(term))) :: list
  def filter([], _f), do: []
  def filter([h|t], f) do
    if f.(h) do
      [h | filter(t, f)]
    else
      filter(t, f)
    end
  end

  @type acc :: any
  @spec reduce(list, acc, ((any, acc) -> acc)) :: acc
  def reduce([], acc, _f), do: acc
  def reduce([h|t], acc, f) do
    reduce(t, f.(h, acc), f)
  end

  @spec append(list, list) :: list
  def append([], b), do: b
  def append([h|t], b) do
    [h|append(t, b)]
  end

  @spec concat([[any]]) :: [any]
  def concat([]), do: []
  def concat([h|t]) do
    append(h, concat(t))
  end

  @spec take(list, integer) :: list
  def take(_, 0), do: []
  def take([], _), do: []
  def take([h|t], n), do: [h | take(t, n - 1)]

  @spec drop(list, integer) :: list
  def drop(l, 0), do: l
  def drop([], _), do: []
  def drop([_h|t], n), do: drop(t, n - 1)

  @spec split(list, integer) :: {list, list}
  def split(l, n) when n >= 0, do: {take(l, n), drop(l, n)}
  def split(l, n) do
    # or simply `split(l, count(l) + n)` if you want to use length()
    {t, d} = split(reverse(l), -n)
    {reverse(d), reverse(t)}
  end

  @spec dedup_by(list, (any -> any)) :: list
  def dedup_by([], f) when is_function(f, 1), do: []
  def dedup_by([h|t], f) when is_function(f, 1), do: [h | do_dedup_by(t, f, h)]
  defp do_dedup_by([], _, _), do: []
  defp do_dedup_by([h|t], f, v) do
    v2 = f.(h)
    if v2 === v do
      do_dedup_by(t, f, v2)
    else
      [h | do_dedup_by(t, f, v2)]
    end
  end

  @spec dedup(list) :: list
  def dedup(l), do: dedup_by(l, &(&1))
end
