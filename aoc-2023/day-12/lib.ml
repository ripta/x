(****************)
(* my libraries *)
(****************)

(* [>>]: syntactic sugar for forward operator *)
(* val fwd : ('a -> 'b) -> ('b -> 'c) -> 'a -> 'c *)
let fwd f g x = g (f x) ;;
let ( >> ) = fwd ;;

(* [eq_intlist]: check if two lists are equal *)
(* val eq_intlist : 'a list -> 'a list -> bool *)
let eq_intlist lst = List.compare (fun a b -> if a = b then 0 else 1) lst >> ((=) 0) ;;

(* [split_on]: splits a list into a list of lists by a predicate function *)
(* val split_on : ('a -> bool) -> 'a list -> 'a list list *)
let split_on pred lst =
  let rec split' = function
    | [] -> split' [[]]
    | (acc :: accs) -> function
      | [] -> List.rev (acc :: accs) (* rev to maintain relative ordering of elements *)
      | x :: xs -> split' (if pred x then [] :: (List.rev acc) :: accs else (x :: acc) :: accs) xs
  in split' [] lst
;;

(* [combi]: combinations of elements of 'a list of size sz *)
(* val combi : int -> 'a list -> 'a list list *)
let rec combi sz lst =
  if sz = 0 then
    [[]]
  else
    (* val combi' : 'a list list list -> 'a list -> 'a list list list *)
    let rec combi' acc = function
      | []      -> List.rev acc
      | x :: xs -> combi' ((List.map (fun rest -> x :: rest) (combi (sz - 1) xs)) :: acc) xs
    in
      List.concat (combi' [] lst)
;;
