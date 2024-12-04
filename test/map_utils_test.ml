open OUnit2

let my_test _ = 
  assert_equal (1 + 1) 2


let suite = "suite" >:::  ["test1" >:: my_test]

let () = run_test_tt_main suite