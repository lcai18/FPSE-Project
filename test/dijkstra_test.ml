(* test_dijkstra.ml *)
open OUnit2
open Core
open Types
open Graph

(* Helper to create a location *)
let make_location name lat long = { location_name = name; lat; long }

(* Build a small test graph:
   We create a few locations:
   A, B, C, D, E
   Suppose we have ways connecting them as follows:

   A -- B
   |    |
   C -- D
   and E isolated

   Distances are based on nodes_to_path_cost, but since lat/long are small,
   we can just rely on correct shortest_path logic. We don't necessarily need
   exact distances if we trust the cost function, but we can check for path
   correctness if lat/long are chosen consistently.
*)

let loc_a = make_location "A" 0.0 0.0
let loc_b = make_location "B" 0.0 0.1
let loc_c = make_location "C" 0.1 0.0
let loc_d = make_location "D" 0.1 0.1
let loc_e = make_location "E" 1.0 1.0 (* isolated node *)

(* Create elements to form a graph. We have locations and ways. *)
let elements = [
  Location loc_a; Location loc_b; Location loc_c; Location loc_d; Location loc_e;
  Way ["A"; "B"];
  Way ["A"; "C"];
  Way ["B"; "D"];
  Way ["C"; "D"];

]

let test_graph =
  let loc_list = element_list_to_locations elements in
  let base_map = locations_to_map loc_list in
  let id_map = locations_to_id_map loc_list in
  let ways = element_list_to_ways elements in
  fst (ways_and_base_map_to_full_map ways base_map id_map)

let location_equal l1 l2 =
  String.equal l1.location_name l2.location_name &&
  Float.equal l1.lat l2.lat &&
  Float.equal l1.long l2.long

let location_list_equal l1 l2 =
  List.length l1 = List.length l2 &&
  List.for_all2_exn l1 l2 ~f:location_equal


let test_direct_connection _ =
  (* shortest_path between A and B should return [A; B] *)
  match Dijkstra.shortest_path test_graph ~start:loc_a ~dest:loc_b with
  | None -> assert_failure "Expected a path from A to B"
  | Some (path, dist) ->
    (* The path should be exactly A->B *)
    assert_equal ~msg:"Path should be [A; B]" [loc_a; loc_b] path;
    assert_bool "Distance should be positive" (Float.compare dist 0.0 > 0)

let test_no_path _ =
  (* shortest_path between A and E should return None since E is isolated *)
  match Dijkstra.shortest_path test_graph ~start:loc_a ~dest:loc_e with
  | None -> () (* correct *)
  | Some _ -> assert_failure "Expected no path from A to E"

let test_simple_rectangle _ =
  (* shortest_path from A to D could be either A->B->D or A->C->D. 
     We'll check that the path found is one of these two. *)
  match Dijkstra.shortest_path test_graph ~start:loc_a ~dest:loc_d with
  | None -> assert_failure "Expected a path from A to D"
  | Some (path, dist) ->
    let expected_paths = [[loc_a; loc_b; loc_d]; [loc_a; loc_c; loc_d]] in
    (* Check that path is one of the expected shortest paths *)
    let path_is_expected = List.exists expected_paths ~f:(fun p -> location_list_equal p path) in
    assert_bool "Path should be A->B->D or A->C->D" path_is_expected;
    assert_bool "Distance should be positive" (Float.compare dist 0.0 > 0)



let test_start_equals_dest _ =
  (* shortest_path from A to A should just be [A] with distance 0 *)
  match Dijkstra.shortest_path test_graph ~start:loc_a ~dest:loc_a with
  | None -> assert_failure "Expected a path from A to A"
  | Some (path, dist) ->
    assert_equal ~msg:"Path should be [A]" [loc_a] path;
    assert_equal ~msg:"Distance should be 0" 0.0 dist

(* Extended graph setup *)
let loc_a = make_location "A" 0.0 0.0
let loc_b = make_location "B" 0.0 0.1
let loc_c = make_location "C" 0.1 0.0
let loc_d = make_location "D" 0.1 0.1
let loc_e = make_location "E" 1.0 1.0 (* isolated node *)
let loc_f = make_location "F" 0.2 0.2
let loc_g = make_location "G" 0.3 0.3

(* Create elements to form a more complex graph. *)
let elements = [
  Location loc_a; Location loc_b; Location loc_c; Location loc_d; Location loc_e; Location loc_f; Location loc_g;
  Way ["A"; "B"];
  Way ["A"; "C"];
  Way ["B"; "D"];
  Way ["C"; "D"];
  Way ["D"; "F"];
  Way ["F"; "G"];
  Way ["A"; "G"];
  Way ["G"; "F"];
]

let test_graph =
  let loc_list = element_list_to_locations elements in
  let base_map = locations_to_map loc_list in
  let id_map = locations_to_id_map loc_list in
  let ways = element_list_to_ways elements in
  fst (ways_and_base_map_to_full_map ways base_map id_map)

let location_equal l1 l2 =
  String.equal l1.location_name l2.location_name &&
  Float.equal l1.lat l2.lat &&
  Float.equal l1.long l2.long

let location_list_equal l1 l2 =
  List.length l1 = List.length l2 &&
  List.for_all2_exn l1 l2 ~f:location_equal

(* Test a path with multiple possible routes *)
let test_multiple_routes _ =
  match Dijkstra.shortest_path test_graph ~start:loc_a ~dest:loc_f with
  | None -> assert_failure "Expected a path from A to F"
  | Some (path, dist) ->
    let expected_paths = [[loc_a; loc_b; loc_d; loc_f]; [loc_a; loc_c; loc_d; loc_f]] in
    let path_is_expected = List.exists expected_paths ~f:(fun p -> location_list_equal p path) in
    assert_bool "Path should be A->B->D->F or A->C->D->F" path_is_expected;
    assert_bool "Distance should be positive" (Float.compare dist 0.0 > 0)

(* Test a disconnected node *)
let test_disconnected_node _ =
  match Dijkstra.shortest_path test_graph ~start:loc_a ~dest:loc_e with
  | None -> () (* correct *)
  | Some _ -> assert_failure "Expected no path from A to E"

(* Test a longer path *)
let test_longer_path _ =
  match Dijkstra.shortest_path test_graph ~start:loc_a ~dest:loc_g with
  | None -> assert_failure "Expected a path from A to G"
  | Some (path, dist) ->
    let expected_path = [loc_a; loc_g;] in
    assert_equal ~msg:"Path should be A->G" expected_path path;
    assert_bool "Distance should be positive" (Float.compare dist 0.0 > 0)

(* Test invalid start or destination node *)
let test_invalid_nodes _ =
  let invalid_loc = make_location "Z" 10.0 10.0 in
  match Dijkstra.shortest_path test_graph ~start:invalid_loc ~dest:loc_a with
  | None -> () (* correct *)
  | Some _ -> assert_failure "Expected no path for invalid start node"

let suite =
  "Dijkstra tests" >::: [
    "test_direct_connection" >:: test_direct_connection;
    "test_no_path" >:: test_no_path;
    "test_simple_rectangle" >:: test_simple_rectangle;
    "test_start_equals_dest" >:: test_start_equals_dest;
    "test_multiple_routes" >:: test_multiple_routes;
    "test_disconnected_node" >:: test_disconnected_node;
    "test_longer_path" >:: test_longer_path;
    "test_invalid_nodes" >:: test_invalid_nodes;
  ]



