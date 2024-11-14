

(** Represents a location with a name and geographic coordinates (latitude and longitude). 
    > If it is a landmark, the name will be the name of the landmark.
    > If it is part of a path, it will be labeled as Node_ID, where ID is a string of numbers (corresponding to the actual Node ID on Overpass Turbo). *)
type location = {
    location_name : string;
    lat : float;
    long : float;
}

(** Represents a path connecting two locations, and also contains information about path length
    > In Overpass Turbo, "ways" (path-equivalents) are defined using lists of nodes. We aim to implement some algorithms that can make the Overpass "way" work as an "edge" in our case.
    > This is in order to reduce the cost of computing a shortest path -- instead of considering all the intermediary nodes in a path, we just consider the whole "edge" path in entirety. *)
type path = {
    loc1 : location;
    loc2 : location;
    distance : float;
}

(** Module types to be used in adjacency list for [map]. [map] definition below. *)
module type LocationKey = sig
  type t = location
  val compare : t -> t -> int
end

module type LocationMap = sig
    type key = location
    type 'a t
    val empty : 'a t
    val add : key -> 'a -> 'a t -> 'a t
    val find : key -> 'a t -> 'a
    val remove : key -> 'a t -> 'a t
    val mem : key -> 'a t -> bool
end

module LocationMap : LocationMap

(** Represents a map with a name, description, a set of locations, and paths. Represents adjacent locations (connected by paths) using an adjacency list. *)
type map = {
    map_name : string;
    map_description : string;
    locations : location list;
    paths : path list;
    adj_list : location list LocationMap.t;
}

(** Represents a route with a list of directions (locations in order) and its total length after executing pathfinding algorithms. *)
type route = {
    directions : location list;
    length : float;
}

(* --- MODULE SIGNATURES --- *)

module type Map = sig
    
  (** [generate_map center radius] generates a map around the [center] location with the given [radius] in meters, fetching location and path data using Overpass Turbo API *)
  val generate_map : location -> float -> map option

  (** [get_shortest_path m loc1 loc2] returns a [route] representing the shortest path between [loc1] and [loc2] on map [m]. If no path exists, returns [None] *)
  val get_shortest_path : map -> location -> location -> route option

  (** [locations_to_json locs] converts a list of locations [locs] to a JSON format *)
  val locations_to_json : location list -> Yojson.Safe.t

  (** [json_to_locations json] parses JSON data [json] into a list of locations *)
  val json_to_locations : Yojson.Safe.t -> location list option

end

module type Location = sig

  (** [create_location name lat long] creates a new location with [name], [lat], and [long] *)
  val create_location : string -> float -> float -> location

end

module type Path = sig
  (** [create_path loc1 loc2] creates a path connecting [loc1] and [loc2]. Computes path length prior to creation. *)
  val create_path : location -> location -> path
end

(* --- FUNCTION SIGNATURES --- *)

(** [coordinates_and_radius_to_locations_json lat long radius] generates JSON data
    representing all locations within a specified radius around given [lat] and [long] *)
val coordinates_and_radius_to_locations_json : float -> float -> float -> Yojson.Safe.t option

(** [locations_json_to_parsed_locations location_json] parses the JSON data from API call into a list of 'location' objects as defined earlier *)
val locations_json_to_parsed_locations : Yojson.Safe.t option -> location list

(** [coordinates_and_radius_to_ways_json lat long radius] generates JSON data
    representing all paths ("ways") within a specified radius around given [lat] and [long] *)
val coordinates_and_radius_to_ways_json : float -> float -> float -> Yojson.Safe.t option

(** [ways_json_to_ways_list ways_json] uses JSON data generated from previous step and parses it into lists of locations. 
    > Each 'way' in Overpass is represented as a list of nodes which comprise the way.
    > So, for each 'way', comprised of nodes, we need to parse these into a path, which happens in following functions. *)
val ways_json_to_ways_list : Yojson.Safe.t option -> location list list

(** [way_node_list_to_path way_node_list] converts the nodes, which are all a part of an Overpass 'way', into a 'path' object as defined earlier.
    > Overpass does not give us the list of nodes in order... so while we know what nodes are in the path and each of their locations, we still need to "put them in order" ourselves.
    > We *are* given the 'starting' and 'ending' nodes of the path
    > So our tentative algorithm for devising the order was to start from the starting node, and keep finding the next nearest node to add to the ordered chain.
    > This is n^2 which is not ideal... so we will investigate this idea further before committing to an implementation *)
val way_node_list_to_path : location list -> path

(** [paths_to_connected_graph path_list] creates a tentative initial graph only using the paths we generated from previous functions.
    > This involves connecting paths with other paths. We are currently operating under the assumption that every two physically connected paths (in real life) also have at least one common node on Overpass.
    > We came to this conclusion after manual inspection of Overpass data from Homewood campus, but may have to adjust in case this is not always true.
    > We expect the graph created from this operation to be fully connected. For Homewood this will be true, but some failsafes may be added to pathfinding algorithms since this will not be true for all maps. *)
val paths_to_connected_graph : path list -> map

(** [connect_graph location] takes a map and creates a connected graph where each location is connected to nodes on the same way id
    > This will finalize the map object and ensure that it is fully ready for pathfinding algorithms. *)
val connect_graph : map -> location list -> map option

(** [map_to_json map] will create a json file from a completed map from [locations_and_paths_to_map]. *)
val json_of_map : map -> Yojson.Safe.t

(** [map_of_json json] will parse [json] into a [map] structure as described earlier. Returns [Some m] if [json] is validly formatted, or [None] if not. *)
val map_of_json : Yojson.Safe.t -> map option

(** [location_to_map center radius] generates a [map] structure based on [center] lat/long location and [radius] in meters, fetching location and path data *)
val location_to_map : location -> float -> map option





