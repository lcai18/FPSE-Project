[@@@warning "-32"]
open Core
open Types
open Priority_queue
open Graph
module LocationMap = Map.Make(LocationKey)

(* Helper function to reconstruct the path from the 'prev' map. 
   'prev' maps a location to its predecessor on the shortest path. *)
let rec reconstruct_path prev_map current accum =
  match Map.find prev_map current with
  | None -> current :: accum
  | Some predecessor -> reconstruct_path prev_map predecessor (current :: accum)

(* Dijkstra's to find shortest distance only *)
let shortest_distance (graph: graph) ~(start: location) ~(dest: location) : float option =
  (* dist : location -> float *)
  let dist = LocationMap.singleton start 0.0 in
  (* visited : location -> bool *)
  let visited = LocationMap.empty in
  (* Priority queue holds (distance, location) *)
  let pq = create () in
  let pq = add_element pq (0.0, start) in

  let rec loop pq dist visited =
    match extract_min pq with
    | None -> None
    | Some ((curr_dist, u), pq) ->
      if Map.mem visited u then
        (* Already visited this node, skip *)
        loop pq dist visited
      else
        let visited = Map.set visited ~key:u ~data:true in
        if String.equal u.location_name dest.location_name then
          Some curr_dist
        else
          let neighbors = Map.find_exn graph u in
          let (pq, dist) =
            Set.fold neighbors ~init:(pq, dist) ~f:(fun (pq, dist) (v, cost) ->
              if Map.mem visited v then (pq, dist)
              else
                let alt = curr_dist +. cost in
                let current_v_dist = Option.value (Map.find dist v) ~default:Float.infinity in
                if Float.compare alt current_v_dist < 0 then
                  let dist = Map.set dist ~key:v ~data:alt in
                  let pq = add_element pq (alt, v) in
                  (pq, dist)
                else
                  (pq, dist)
            )
          in
          loop pq dist visited
  in
  loop pq dist visited

(* Dijkstra's to find shortest path and distance *)
let shortest_path (graph: graph) ~(start: location) ~(dest: location) : (location list * float) option =
  (* dist : location -> float *)
  let dist = LocationMap.singleton start 0.0 in
  (* prev : location -> location *)
  let prev = LocationMap.empty in
  (* visited : location -> bool *)
  let visited = LocationMap.empty in
  let pq = create () in
  let pq = add_element pq (0.0, start) in

  let rec loop pq dist prev visited =
    match extract_min pq with
    | None -> None  (* No path found *)
    | Some ((curr_dist, u), pq) ->
      if Map.mem visited u then
        loop pq dist prev visited
      else
        let visited = Map.set visited ~key:u ~data:true in
        if String.equal u.location_name dest.location_name then
          (* Reconstruct path *)
          let path = reconstruct_path prev u [] in
          Some (path, curr_dist)
        else
          let neighbors = Map.find_exn graph u in
          let (pq, dist, prev) =
            Set.fold neighbors ~init:(pq, dist, prev) ~f:(fun (pq, dist, prev) (v, cost) ->
              if Map.mem visited v then (pq, dist, prev)
              else
                let alt = curr_dist +. cost in
                let current_v_dist = Option.value (Map.find dist v) ~default:Float.infinity in
                if Float.compare alt current_v_dist < 0 then
                  let dist = Map.set dist ~key:v ~data:alt in
                  let prev = Map.set prev ~key:v ~data:u in
                  let pq = add_element pq (alt, v) in
                  (pq, dist, prev)
                else
                  (pq, dist, prev))
          in
          loop pq dist prev visited
  in
  loop pq dist prev visited