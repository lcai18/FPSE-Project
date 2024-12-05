open Core
open Types
open Priority_queue  (* Assuming your priority queue code is in a file named priority_queue.ml *)
open Graph

module LocationMap = Map.Make(LocationKey)
module LocationSet = Set.Make(LocationSetKey)

(* Helper function to reconstruct the path after Dijkstra completes *)
let rec reconstruct_path prev_map current accum =
  match Map.find prev_map current with
  | None -> current :: accum
  | Some predecessor -> reconstruct_path prev_map predecessor (current :: accum)


let shortest_path (graph: graph) ~(start:location) ~(dest:location) : (location list * float) option =
  (* Distances map: location -> float *)
  let dist =  Map.set ~key:start ~data:0.0 LocationMap.empty in
  (* Predecessor map: location -> location *)
  let prev = LocationMap.empty in
  (* Visited set *)
  let visited = LocationMap.empty in
  (* Priority queue: (distance, location) *)
  let pq = Priority_queue.create () in
  let pq = Priority_queue.add_element pq (0.0, start) in

  let rec explore_current_closest priority_queue currently_visited prev_map =
    match extract_min priority_queue with
    | None -> None (*done traversing*)
    | Some ((edge_weight, node), pq) ->
      

