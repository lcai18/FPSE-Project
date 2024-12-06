open OUnit2
open Types
open Priority_queue
(* Helper function to create a location *)
let create_location location_name lat long = { location_name; lat; long } (* Adjust if the location type differs *)

let test_create _ =
  let pq = create () in
  match extract_min pq with
  | None -> ()
  | Some _ -> assert_failure "Expected empty priority queue"

let test_add_and_extract_single _ =
  let pq = create () in
  let location = create_location "place1" 0.0 0.0 in
  let pq = add_element pq (1.0, location) in
  match extract_min pq with
  | Some ((priority, loc), new_pq) ->
    assert_equal priority 1.0;
    assert_equal loc location;
    assert_equal (extract_min new_pq) None
  | None -> assert_failure "Expected an element in the priority queue"

let test_add_and_extract_multiple _ =
  let pq = create () in
  let locations = [create_location "place1" 1.0 1.0; create_location  "place2" 2.0 2.0; create_location "place3" 3.0 3.0] in
  let elements = [(3.0, List.nth locations 0); (1.0, List.nth locations 1); (2.0, List.nth locations 2)] in
  let pq = List.fold_left add_element pq elements in
  let check_priority pq expected_priority =
    match extract_min pq with
    | Some ((priority, _), new_pq) ->
      assert_equal priority expected_priority;
      new_pq
    | None -> assert_failure "Expected an element in the priority queue"
  in
  let pq = check_priority pq 1.0 in
  let pq = check_priority pq 2.0 in
  let pq = check_priority pq 3.0 in
  assert_equal (extract_min pq) None

let test_add_duplicate_priorities _ =
  let pq = create () in
  let location1 = create_location "place1" 1.0 1.0 in
  let location2 = create_location "place2" 2.0 2.0 in
  let pq = add_element pq (1.0, location1) in
  let pq = add_element pq (1.0, location2) in
  match extract_min pq with
  | None -> assert_failure "Expected an element in the priority queue"
  | Some ((priority1, loc1), pq) ->
    assert_equal priority1 1.0;
    assert_bool "Expected one of the locations" (loc1 = location1 || loc1 = location2);
    match extract_min pq with
    | None -> assert_failure "Expected a second element"
    | Some ((priority2, loc2), new_pq) ->
      assert_equal priority2 1.0;
      assert_bool "Expected the other location" (loc2 = location1 || loc2 = location2);
      assert_equal (extract_min new_pq) None
    
  

let suite =
  "Tests" >::: [
    "test_create" >:: test_create;
    "test_add_and_extract_single" >:: test_add_and_extract_single;
    "test_add_and_extract_multiple" >:: test_add_and_extract_multiple;
    "test_add_duplicate_priorities" >:: test_add_duplicate_priorities;
  ]

let () = run_test_tt_main suite
