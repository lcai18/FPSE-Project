open Core
open Types
(*binomial heap*)

type element = float * location

type tree = {
  rank : int;
  root : element;
  children : tree list;
}

(* A binomial heap is a list of trees, sorted by rank *)
type t = tree list

(* Comparison function for elements (min-heap on float) *)
let compare_elements (f1, _) (f2, _) = Float.compare f1 f2

let create () : t = []

(* Link two trees of the same rank: the one with the smaller root becomes the parent. *)
let link t1 t2 =
  (* allowing the smaller root to be the parent allows logn removals as we only need to check the top node for each binomial tree in the heap*)
  if compare_elements t1.root t2.root <= 0 then
    { t1 with children = t2 :: t1.children; rank = t1.rank + 1 }
  else
    { t2 with children = t1 :: t2.children; rank = t2.rank + 1 }

(* Insert a tree into a binomial heap *)
let rec insert_tree t (heap : t) =
  match heap with
  | [] -> [t]
  | hd :: tl ->
    if t.rank < hd.rank then
      t :: hd :: tl
    else if t.rank = hd.rank then
      insert_tree (link t hd) tl
    else (* case occurs in removal if the tree we removed from is larger than all the other trees in the heap*)
      hd :: insert_tree t tl
      
      


let add_element (heap : t) (elem : element) : t =
  let single_tree = {rank = 0; root = elem; children = []} in
  insert_tree single_tree heap

(* Merge two heaps *)
let rec merge h1 h2 =
  match (h1, h2) with
  | h, [] -> h
  | [], h -> h
  | t1 :: r1, t2 :: r2 ->
    if t1.rank < t2.rank then
      t1 :: merge r1 h2
    else if t2.rank < t1.rank then
      t2 :: merge h1 r2
    else
      insert_tree (link t1 t2) (merge r1 r2)

(* Remove the minimum tree from the heap.
   Returns (the minimum tree, the heap without that tree). *)
let rec remove_min_tree h =
  match h with
  | [] -> failwith "Cannot remove from empty heap"
  | [t] -> (t, [])
  | t :: ts ->
    let (t_min, ts_min) = remove_min_tree ts in
    (* if we find a new min, the heap without the current tree is the remaining heap *)
    if compare_elements t.root t_min.root <= 0 then (t, ts) else (t_min, t :: ts_min) 

let extract_min (heap : t) : ((float * location) * t) option =
  match heap with
  | [] -> None
  | _ ->
    let (min_tree, rest) = remove_min_tree heap in
    (* The children of min_tree form a heap, but in reverse rank order.
       Reverse them to restore correct order and merge with rest. *)
    let reversed_children = List.map ~f:(fun c -> {c with children = c.children}) min_tree.children in
    let new_heap = merge (List.rev reversed_children) rest in
    Some (min_tree.root, new_heap)

