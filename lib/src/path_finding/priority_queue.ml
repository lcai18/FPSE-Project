open Core

(* Define the location type *)
type location = {
  location_name : string;
  lat : float;
  long : float;
}

(* Define the heap element type *)
type heap_element = float * location

(* Comparison function for heap elements (max-heap based on float) *)
let compare_heap_elements (f1, _) (f2, _) =
  Float.compare f1 f2  (* Inverted for descending order *)

(* Create a new empty priority queue *)
let create () =
  Pairing_heap.create ~cmp:compare_heap_elements ()

(* Add an element to the priority queue *)
let add_element heap element =
  Pairing_heap.add heap element

(* Extract the maximum element from the priority queue *)
let extract_max heap =
  Pairing_heap.pop heap
