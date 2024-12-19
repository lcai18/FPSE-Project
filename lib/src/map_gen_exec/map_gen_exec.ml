open Core
open Graph
open Json_utils
let () =
  let elements = nodes_request ~radius:600 |> request_body_to_yojson |> yojson_list_to_element_list in
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
     let (full_graph, connections) = ways_and_base_map_to_full_map ways_list base_graph loc_map in
     Printf.printf "Graph successfully constructed.\n%s Nodes\n%s connections made\n" (string_of_int (Map.length loc_map)) (string_of_int connections);
     (* Calculating how many nodes in the graph have nonempty adjacency sets *)
     let connected_nodes = Map.fold ~init:0 ~f:
      (fun ~key:_ ~data:d accum:int ->
        if Set.is_empty d then
          accum
        else
          accum + 1
      ) full_graph in
      Printf.printf "Nodes with nonempty adjacency sets: %s\n" (string_of_int connected_nodes);
      save_graph full_graph "./map_sexp_files/homewood_map.txt"
  | None -> Printf.printf "No locations found.\n"