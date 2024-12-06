[@@@warning "-33"]
[@@@warning "-34"]
[@@@warning "-26"]
[@@@warning "-32"]
[@@@warning "-37"]
[@@@warning "-69"]
[@@@warning "-27"]
[@@@warning "-11"]
open Core
open Json_utils
open Graph
open Types
open Dijkstra
(*

to execute this: dune exec _build/default/lib/src/path_finding/path_find.exe

*)



let () =
  let elements = nodes_request ~radius:200 |> request_body_to_yojson |> yojson_list_to_element_list in
  match elements with
  | None -> Printf.printf "No locations found.\n"
  | Some elems ->
      List.iter ~f:(fun elem -> print_element elem) elems;
      let location_list = elems |> element_list_to_locations in
      let loc_map = location_list |> locations_to_id_map in
      let base_graph = location_list |> locations_to_map in
      let ways_list = elems |> element_list_to_ways in
      let (g, connections) = ways_and_base_map_to_full_map ways_list base_graph loc_map in

      let n1 = {location_name = "244357719"; lat = 39.3307065; long= -76.619923 } in
      let n2 = {location_name = "8942020496"; lat = 39.3286664; long = -76.6203471} in
      match shortest_path g ~start:n1 ~dest:n2 with
      | Some (path, dist) ->
          Printf.printf "Shortest distance: %f\n" dist;
          List.iter ~f:(fun loc -> Printf.printf "%s -> " loc.location_name) path;
          print_endline "done!"
      | None -> Printf.printf "No path found.\n"
  



  



  