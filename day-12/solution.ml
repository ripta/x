open Containers

(* [>>]: syntactic sugar for forward operator *)
(* val fwd : ('a -> 'b) -> ('b -> 'c) -> 'a -> 'c *)
let fwd f g x = g (f x) ;;
let ( >> ) = fwd ;;

let repeat sz lst =
  let rec repeat' acc = function
    | 0 -> acc
    | num -> repeat' (lst @ acc) (num - 1)
  in repeat' lst (sz - 1)
;;

(********************)
(** start solution **)
(********************)

type state =
  | Ok
  | Bad
  | Que
;;

(* val state_of_char : char -> state *)
let state_of_char = function
  | '.' -> Ok
  | '#' -> Bad
  | '?' -> Que
  | _   -> failwith "unknown"
;;

(* val char_of_state : state -> char *)
let char_of_state = function
  | Ok  -> '.'
  | Bad -> '#'
  | Que -> '?'
;;

(* val int_of_state : state -> int *)
let int_of_state = function
  | Ok  -> 0
  | Bad -> 1
  | Que -> 2
;;

(* [is_state]: sad manual function without polymorphic (=) *)
(* val is_state : state -> state -> bool *)
let is_state s t = (int_of_state s) = (int_of_state t) ;;

(* val parse : string -> state list * int list *)
let parse line =
  let
    [@warning "-8"] (* [partial-match]: boldly assume input is well-fmt'd *)
    [rlocs; rgroups] = String.split_on_char ' ' line
  in
    let
      locs = rlocs |> String.to_seq |> Seq.map state_of_char |> List.of_seq
      and groups = rgroups |> String.split_on_char ',' |> List.map int_of_string
    in
      (locs, groups)
;;

type induction =
  | BaseCase
  | StepCase of int
;;

(* val string_of_induction : induction -> string *)
let string_of_induction = function
  | BaseCase -> "BaseCase"
  | StepCase n -> Printf.sprintf "StepCase %d" n
;;

(* val is_empty : 'a list -> bool *)
let is_empty lst = List.compare_length_with lst 0 = 0 ;;

(* val key_of_solver : state list -> int list -> induction -> string *)
let key_of_solver locs groups step =
  let
    locs' = List.map char_of_state locs |> List.to_seq |> String.of_seq
    and groups' = List.map string_of_int groups |> String.concat ";"
    and step' =
      match step with
        | BaseCase -> "~"
        | StepCase n -> string_of_int n
  in
    String.concat ":" [locs'; groups'; step']
;;

let solver scene =
  let h = Hashtbl.create 12 in
  let rec solver' locs groups step =
    let key = key_of_solver locs groups step in
    match Hashtbl.find_opt h key with
      | Some v -> v
      | None -> (
          let res = match groups, step with
            | [], BaseCase -> if List.exists (is_state Bad) locs then 0 else 1
            | _, _ ->
                match locs, step with
                  | [], BaseCase   -> if is_empty groups then 1 else 0
                  | [], StepCase 0 -> if is_empty groups then 1 else 0
                  | [], _          -> 0
                  | Que :: ls, BaseCase   -> (
                      match groups with
                        | []      -> (solver' ls groups BaseCase)
                        | g :: gs -> (solver' ls groups BaseCase) + (solver' locs gs (StepCase g))
                      )
                  | Que :: ls, StepCase 0 -> solver' ls groups BaseCase
                  | Que :: ls, StepCase n -> solver' ls groups (StepCase (n - 1))
                  | Bad :: ls, BaseCase   -> (
                      match groups with
                        | []      -> solver' locs groups (StepCase 0)
                        | g :: gs -> solver' locs gs (StepCase g)
                      )
                  | Bad :: ls, StepCase 0 -> 0
                  | Bad :: ls, StepCase n -> solver' ls groups (StepCase (n - 1))
                  | Ok  :: ls, BaseCase   -> solver' ls groups BaseCase
                  | Ok  :: ls, StepCase 0 -> solver' ls groups BaseCase
                  | Ok  :: ls, StepCase n -> 0
          in
            Hashtbl.add h key res;
            res
      )
  in let (locs, groups) = scene
  in
    solver' locs groups BaseCase
;;

(* val mass_solver : (state list * int list) list -> int list *)
let mass_solver = List.map solver ;;

(* val answer : (state list * int list) list -> int *)
let answer = mass_solver >> List.fold_left (+) 0 ;;

(* val clone_scene : int -> ('a list * 'b list) list -> ('a list * 'b list) list *)
let clone_scene sz = List.map (fun (locs, groups) -> (repeat sz locs, repeat sz groups)) ;;

let () =
  let lines   = IO.read_lines_l stdin in
  let scenes  = List.map parse lines in
  let scenes2 = clone_scene 5 scenes in
  Printf.printf "Result: %d\n" (answer scenes);
  Printf.printf "Result pt2: %d\n" (answer scenes2)
;;
