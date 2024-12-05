[@@@warning "-33"]
[@@@warning "-34"]
[@@@warning "-26"]
[@@@warning "-32"]
[@@@warning "-37"]
[@@@warning "-69"]
[@@@warning "-27"]
open Core
open Json_utils
open Graph
open Types
(*

to execute this: dune exec _build/default/lib/src/path_finding/path_find.exe

*)




(**Example usage *)
let () =
  (* Initialize an empty heap *)
  let heap = Priority_queue.create () in

  (* Define some locations *)
  let loc1 = { location_name = "Location A"; lat = 34.05; long = -118.25 } in
  let loc2 = { location_name = "Location B"; lat = 40.71; long = -74.00 } in
  let loc3 = { location_name = "Location C"; lat = 37.77; long = -122.42 } in

  (* Insert elements into the heap *)
  let heap = Priority_queue.add_element heap (50.0, loc1) in
  let heap = Priority_queue.add_element heap (75.0, loc2) in
  let heap = Priority_queue.add_element heap (60.0, loc3) in

  (* Extract the maximum element *)
  match Priority_queue.extract_min heap with
  | Some ((max_float, max_loc), pq) ->
      Printf.printf "Max Float: %f, Location: %s\n" max_float max_loc.location_name
  | None ->
      Printf.printf "Heap is empty.\n"
      
(*
let () =
  let elements = nodes_request ~radius:200 |> request_body_to_yojson |> yojson_list_to_element_list in
  match elements with
  | Some elems -> 
     (
      List.iter ~f:(fun elem ->
        print_element elem
      ) elems;
     );
     let location_list = elems |> element_list_to_locations in
     let loc_map = location_list |> locations_to_id_map in
     let base_graph = location_list |> locations_to_map in
     let ways_list = elems |> element_list_to_ways in
     let (_, connections) = ways_and_base_map_to_full_map ways_list base_graph loc_map in
     Printf.printf "Graph successfully constructed.\n%s Nodes\n%s connections made\n" (string_of_int (Map.length loc_map)) (string_of_int connections);
  | None -> Printf.printf "No locations found.\n"
  *)



  