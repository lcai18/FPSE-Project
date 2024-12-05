(* Define the location type *)
type location = {
  location_name : string;
  lat : float;
  long : float;
}

(* Define the heap element type *)
type heap_element = float * location

(* Create a new empty priority queue *)
val create : unit -> (float * location) Pairing_heap.t

(* Add an element to the priority queue *)
val add_element : (float * location) Pairing_heap.t -> heap_element -> unit

(* Extract the maximum element from the priority queue *)
val extract_max : (float * location) Pairing_heap.t -> heap_element option
