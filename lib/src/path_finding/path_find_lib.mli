open Types

(** Module representing a map with string keys. *)
module StringMap : sig
    type 'a t
  end

(** Type alias for a map of node labels. *)
type node_label_map = string StringMap.t

(** Load a node label map from a file. 

    @param filepath The path to the file containing the node label map in S-expression format.
    @return A map from node labels to node IDs.
*)
val load_node_label_map : filepath:string -> node_label_map

(** Convert a location label to its corresponding node ID.

    @param label The location label to convert.
    @return An option containing the node ID, or [None] if not found.
*)
val location_label_to_id : string -> string option

(** Convert a location label to a node ID, returning the label itself if no mapping exists.

    @param label The location label to convert.
    @return The corresponding node ID if found, otherwise the original label.
*)
val location_label_to_id_if_specified : string -> string

(** Retrieve a graph and ID map, either from a file or by creating a new graph.

    @param graph_path The optional path to a file containing a serialized graph.
    @return An option containing the graph and ID map, or [None] if the graph could not be created.
*)
val get_graph : string option -> (Graph.graph * Graph.id_map) option

(** Find and print the shortest path between two locations.

    @param loc_name_1 The name or ID of the starting location.
    @param loc_name_2 The name or ID of the destination location.
    @param graph_path The optional path to a file containing a serialized graph.
*)
val find_shortest_path_lib : string -> string -> string option -> (location list * float) option

val shortest_path_to_json : location list * float -> Yojson.Basic.t

val api_get_path : string -> string -> path:string option -> Yojson.Basic.t option