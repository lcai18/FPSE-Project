open OUnit2
open Types
open Priority_queue
(* Helper function to create a location *)
let create_location location_name lat long = { location_name; lat; long }

(* testing empty pq behaves as expected *)
let test_create _ =
  let pq = create () in
  match extract_min pq with
  | None -> ()
  | Some _ -> assert_failure "Expected empty priority queue"
(* testing basic add and extract *)
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
(* testing multiple add and extract *)
let test_add_and_extract_multiple _ =
  let pq = create () in
  let locations = [create_location "place1" 1.0 1.0; create_location  "place2" 2.0 2.0; create_location "place3" 3.0 3.0; create_location "place4" 4.0 4.0] in
  let elements = [(3.0, List.nth locations 0); (1.0, List.nth locations 1); (2.0, List.nth locations 2); (0.5, List.nth locations 3)] in
  let pq = List.fold_left add_element pq elements in
  let check_priority pq expected_priority =
    match extract_min pq with
    | Some ((priority, _), new_pq) ->
      assert_equal priority expected_priority;
      new_pq
    | None -> assert_failure "Expected an element in the priority queue"
  in
  let pq = check_priority pq 0.5 in
  let pq = check_priority pq 1.0 in
  let pq = check_priority pq 2.0 in
  let pq = check_priority pq 3.0 in
  assert_equal (extract_min pq) None

(* testing edge case of same weights*)
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
 

(* This test aims to insert elements in strictly decreasing priority order. *)
let test_decreasing_priority_inserts _ =
  let pq = create () in
  (* Insert elements with decreasing priority *)
  let elems = [
    (10.0, create_location "loc10" 10.0 10.0);
    (9.0, create_location "loc9" 9.0 9.0);
    (8.0, create_location "loc8" 8.0 8.0);
    (7.0, create_location "loc7" 7.0 7.0);
    (6.0, create_location "loc6" 6.0 6.0);
    (5.0, create_location "loc5" 5.0 5.0);
    (4.0, create_location "loc4" 4.0 4.0);
    (3.0, create_location "loc3" 3.0 3.0);
    (2.0, create_location "loc2" 2.0 2.0);
    (1.0, create_location "loc1" 1.0 1.0);
  ] in
  let pq = List.fold_left add_element pq elems in

  (* Extracting should now cause merges internally to reorder the heap. 
     We'll just ensure it returns the correct minimum each time,
     which indirectly tests the merging logic. *)
  let rec extract_all pq expected =
    match expected with
    | [] -> 
       (* All extracted, should be empty now *)
       assert_equal None (extract_min pq)
    | (exp_prio, _)::tl ->
      match extract_min pq with
      | Some ((p, _), new_pq) ->
        assert_equal exp_prio p;
        extract_all new_pq tl
      | None -> assert_failure "Expected more elements"
  in

  (* We inserted from high to low priority, so extraction should yield ascending order of priorities *)
  let sorted_by_priority = List.sort (fun (p1,_) (p2,_) -> Float.compare p1 p2) elems in
  extract_all pq sorted_by_priority

  (* This test aims to insert elements in strictly decreasing priority order. *)
let test_increasing_priority_inserts _ =
  let pq = create () in
  (* Insert elements with decreasing priority *)
  let elems = [
    (1.0, create_location "loc10" 10.0 10.0);
    (2.0, create_location "loc9" 9.0 9.0);
    (3.0, create_location "loc8" 8.0 8.0);
    (4.0, create_location "loc7" 7.0 7.0);
    (5.0, create_location "loc6" 6.0 6.0);
    (6.0, create_location "loc5" 5.0 5.0);
    (7.0, create_location "loc4" 4.0 4.0);
    (8.0, create_location "loc3" 3.0 3.0);
    (9.0, create_location "loc2" 2.0 2.0);
    (10.0, create_location "loc1" 1.0 1.0);
  ] in
  let pq = List.fold_left add_element pq elems in

  (* Extracting should now cause merges internally to reorder the heap. 
     We'll just ensure it returns the correct minimum each time,
     which indirectly tests the merging logic. *)
  let rec extract_all pq expected =
    match expected with
    | [] -> 
       (* All extracted, should be empty now *)
       assert_equal None (extract_min pq)
    | (exp_prio, _)::tl ->
      match extract_min pq with
      | Some ((p, _), new_pq) ->
        assert_equal exp_prio p;
        extract_all new_pq tl
      | None -> assert_failure "Expected more elements"
  in

  (* We inserted from high to low priority, so extraction should yield ascending order of priorities *)
  let sorted_by_priority = List.sort (fun (p1,_) (p2,_) -> Float.compare p1 p2) elems in
  extract_all pq sorted_by_priority

let suite =
  "Tests" >::: [
    "test_create" >:: test_create;
    "test_add_and_extract_single" >:: test_add_and_extract_single;
    "test_add_and_extract_multiple" >:: test_add_and_extract_multiple;
    "test_add_duplicate_priorities" >:: test_add_duplicate_priorities;
    "test_decreasing_priority_inserts" >:: test_decreasing_priority_inserts;
    "test_increasing_priority_inserts" >:: test_increasing_priority_inserts;
  ]

