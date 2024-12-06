open OUnit2



let suite = "suite" >:::  [
  Map_utils_test.suite;
  Priority_queue_test.suite;
  Dijkstra_test.suite;
]

let () = run_test_tt_main suite