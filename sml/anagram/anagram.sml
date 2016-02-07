
(* val ascending = fn : char * char -> bool *)
val ascending = fn (x : char, y : char) => x > y;

(* val normalize = fn : string -> string *)
fun normalize word = String.implode (ListMergeSort.sort ascending (String.explode word));

(* val areAnagrams = fn : string -> string -> bool *)
fun areAnagrams word candidate = normalize word = normalize candidate;

(* List.filter : ('a -> bool) -> 'a list -> 'a list *)
fun anagram word candidateList = List.filter (areAnagrams word) candidateList;
