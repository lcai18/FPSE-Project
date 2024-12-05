open Core
open Priority_queue
(*

to execute this: dune exec _build/default/lib/src/path_finding/path_find.exe

*)

[@@@warning "-34"]
[@@@warning "-26"]
[@@@warning "-32"]
[@@@warning "-37"]
[@@@warning "-69"]


(* Example usage *)
let () =
  (* Initialize an empty heap *)
  let heap = Priority_queue.create () in

  (* Define some locations *)
  let loc1 = { location_name = "Location A"; lat = 34.05; long = -118.25 } in
  let loc2 = { location_name = "Location B"; lat = 40.71; long = -74.00 } in
  let loc3 = { location_name = "Location C"; lat = 37.77; long = -122.42 } in

  (* Insert elements into the heap *)
  Priority_queue.add_element heap (50.0, loc1);
  Priority_queue.add_element heap (75.0, loc2);
  Priority_queue.add_element heap (60.0, loc3);

  (* Extract the maximum element *)
  match extract_max heap with
  | Some (max_float, max_loc) ->
      Printf.printf "Max Float: %f, Location: %s\n" max_float max_loc.location_name
  | None ->
      Printf.printf "Heap is empty.\n"



  