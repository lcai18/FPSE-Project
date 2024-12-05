open Types

(* Perform a GET request to a given URI *)
val get_request : uri:string -> string option Lwt.t

(* Fetch all nodes and ways within a given radius *)
val nodes_request : radius:int -> string option

(* Convert a request body string into a list of Yojson elements *)
val request_body_to_yojson : string option -> Yojson.Basic.t list option

(* Convert a Yojson element to a `location` or `way` element *)
val json_elem_to_location_or_way : Yojson.Basic.t -> element option

(* Convert a list of Yojson elements to a list of `element`s *)
val yojson_list_to_element_list : Yojson.Basic.t list option -> element list option

(* Print an `element` for debugging *)
val print_element : element -> unit
