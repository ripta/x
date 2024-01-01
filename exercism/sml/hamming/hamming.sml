
exception NonEqualLengthStringsFound;

fun hammingList [] [] = 0
  | hammingList _ [] = raise NonEqualLengthStringsFound
  | hammingList [] _ = raise NonEqualLengthStringsFound
  | hammingList (h1::t1) (h2::t2) = (if h1 = h2 then 0 else 1) + (hammingList t1 t2);

fun hamming (s1, s2) = hammingList (String.explode s1) (String.explode s2);
