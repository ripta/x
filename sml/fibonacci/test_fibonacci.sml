use "fibonacci.sml";

val test_cases = [
    (  1, 1 ),
    (  2, 1 ),
    (  3, 2 ),
    ( 10, 55 ),
    ( 30, 832040 )
];

fun run_tests [] = []
  | run_tests ((n, expected)::ts) =
       (fibonacci n = expected) :: run_tests ts

val allTestsPass = List.foldl (fn (x,y) => x andalso y) true (run_tests test_cases)
