(** JSONUtils.mli *)
open Yojson.Basic


(** [coordinates_and_radius_to_locations_json lat long radius] generates JSON data
    representing all locations within a specified radius around given [lat] and [long] *)
val coordinates_and_radius_to_locations_json : float -> float -> float -> Yojson.Basic.t option

(** [locations_json_to_parsed_locations location_json] parses the JSON data from API call into a list of 'location' objects as defined earlier *)
val locations_json_to_parsed_locations : Yojson.Basic.t option -> Utils.location list

(** [coordinates_and_radius_to_ways_json lat long radius] generates JSON data
    representing all paths ("ways") within a specified radius around given [lat] and [long] *)
val coordinates_and_radius_to_ways_json : float -> float -> float -> Yojson.Basic.t option

(** [ways_json_to_ways_list ways_json] uses JSON data generated from previous step and parses it into lists of locations. 
    > Each 'way' in Overpass is represented as a list of nodes which comprise the way.
    > So, for each 'way', comprised of nodes, we need to parse these into a path, which happens in following functions. *)
val ways_json_to_ways_list : Yojson.Basic.t option -> location list list

(** [map_to_json map] will create a json file from a completed map from [locations_and_paths_to_map]. *)
val json_of_map : map -> Yojson.Basic.t
    
(** [map_of_json json] will parse [json] into a [map] structure as described earlier. Returns [Some m] if [json] is validly formatted, or [None] if not. *)
val map_of_json : Yojson.Basic.t -> map option
