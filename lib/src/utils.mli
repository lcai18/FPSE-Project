

(** Represents a location with a name and geographic coordinates (latitude and longitude) if it is a landmark the name will be a landmark, if it is part of a path it will be a Node_ID*)
type location = {
    location_name : string;
    lat : float;
    long : float;
}



(** Represents a path connecting two locations *)
type path = {
    loc1 : location;
    loc2 : location;
}

(** Represents a map with a name, description, a set of locations, and paths *)
type map = {
    map_name : string;
    map_description : string;
    locations : location list;
    paths : path list;
}

(** Represents a route with a list of directions (locations in order) and its total length *)
type route = {
    directions : location list;
    length : float;
}

(* --- MODULE SIGNATURES --- *)

(** Module signature for a Map *)
module type Map = sig
  (** [generate_map center radius] generates a map around the [center] location
      with the given [radius] in meters, fetching location and path data using
      Overpass Turbo API *)
  val generate_map : location -> float -> map option

  (** [get_shortest_path m loc1 loc2] returns a [route] representing the shortest path
      between [loc1] and [loc2] on map [m]. If no path exists, returns [None] *)
  val get_shortest_path : map -> location -> location -> route option

  (** [locations_to_json locs] converts a list of locations [locs] to a JSON format *)
  val locations_to_json : location list -> Yojson.Safe.t

  (** [json_to_locations json] parses JSON data [json] into a list of locations *)
  val json_to_locations : Yojson.Safe.t -> location list option
end

(** Module signature for a Location *)
module type Location = sig
  (** [create_location name lat long] creates a new location with [name], [lat], and [long] *)
  val create_location : string -> float -> float -> location

end

(** Module signature for a Path *)
module type Path = sig
  (** [create_path loc1 loc2] creates a path connecting [loc1] and [loc2] *)
  val create_path : location -> location -> path

  (** [path_length p] returns the length of path [p] *)
  val path_length : path -> float
end

(** Map Functor: A parameterized module to create a map given a location and radius *)
module MakeMap : functor (Loc : Location) -> Map with type location := Loc.location

(* --- FUNCTION SIGNATURES --- *)

(** [coordinates_and_radius_to_locations_json lat long radius] generates JSON data
    representing all locations within a specified radius around given [lat] and [long] *)
val coordinates_and_radius_to_locations_json : float -> float -> float -> Yojson.Safe.t option

(** [coordinates_and_radius_to_ways_json lat long radius] generates JSON data
    representing all paths ("ways") within a specified radius around given [lat] and [long] *)
val coordinates_and_radius_to_ways_json : float -> float -> float -> Yojson.Safe.t option

(** [location_to_map center radius] generates a [map] structure based on center [lat/long] 
    location and radius [in meters], fetching location and path data *)
val location_to_map : location -> float -> map option

(** [connect_graph location] takes a map and creates a connected graph where each location is connected to nodes on the same way id *)
val connect_graph : location list -> map option



