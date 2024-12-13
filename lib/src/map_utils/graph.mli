open Core
open Types


module LocationKey : sig
  type t = location [@@deriving sexp, compare]
end

module LocationSetKey : sig
  type t = location * float [@@deriving sexp, compare]
end

module LocationMap : Map.S with type Key.t = LocationKey.t

module LocationSet : Set.S with type Elt.t = LocationSetKey.t

type graph = LocationSet.t LocationMap.t

(* Constants *)
val empty_loc_set : LocationSet.t
val empty_graph : graph

(* Functions *)

module StringMap : sig
  include Map.S with type Key.t = string
end

type id_map = location StringMap.t
val empty_id_map : id_map

val locations_to_id_map : location list -> id_map
val locations_to_map : location list -> graph
val element_list_to_ways : element list -> string list list
val element_list_to_locations : element list -> location list
val nodes_to_path_cost : location -> location -> float

val ways_and_base_map_to_full_map : 
  string list list -> 
  graph -> 
  id_map -> 
  graph * int

val graph_to_sexp: graph -> Sexp.t
