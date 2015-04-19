
fun accumulate l f = foldr (fn (x, acc) => (f x) :: acc) [] l
