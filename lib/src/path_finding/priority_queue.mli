open Types

(** A purely functional priority queue of (float * location) pairs. 
    The queue is a min-priority queue, with extract_min returning the smallest float. *)

type t

(** Create an empty priority queue *)
val create : unit -> t

(** Add an element to the priority queue *)
val add_element : t -> (float * location) -> t

(** Extract the minimum element from the priority queue, 
    returning None if the queue is empty or Some (elem, new_queue) otherwise. *)
val extract_min : t -> ((float * location) * t) option
