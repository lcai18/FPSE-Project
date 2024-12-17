open Types

(** Module representing a map with string keys. *)
module StringMap : sig
    type 'a t
  end

(** Type alias for a map of node labels. *)
type node_label_map = string StringMap.t

(** Load a node label map from [filepath]. Returns a map which maps custom node labels to their Overpass IDs. *)
val load_node_label_map : filepath:string -> node_label_map

(** Convert a location [label] to its corresponding node ID. *)
val location_label_to_id : string -> string option

(** Convert a location [label] to a node ID, returning the label itself if no such mapping is found. *)
val location_label_to_id_if_specified : string -> string

(** Retrieve a graph and ID map, either from a [graph_path] or by creating a new graph. *)
val get_graph : string option -> (Graph.graph * Graph.id_map) option

(** Find and print the shortest path between two locations: [loc_name_1] and [loc_name_2]. Returns a [graph_path], a list of locations which compose the optimal path,
    and a total [distance] of the path. *)
val find_shortest_path_lib : string -> string -> string option -> (location list * float) option

val shortest_path_to_json : location list * float -> Yojson.Basic.t

val api_get_path : string -> string -> path:string option -> Yojson.Basic.t option