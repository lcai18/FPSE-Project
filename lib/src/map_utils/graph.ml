open Core
open Types
open Sexplib


[@@@coverage off]
module LocationKey = struct
  type t = location [@@deriving sexp, compare]
end


module LocationSetKey = struct
  type t = location * float [@@deriving sexp, compare]
end
[@@@coverage on]

module LocationMap = Map.Make(LocationKey)

module LocationSet = Set.Make(LocationSetKey)

type graph = LocationSet.t LocationMap.t

let empty_loc_set = LocationSet.empty
let empty_graph = LocationMap.empty

(* step 1: load all Locations into a map *)

(* Get all the Location nodes from received elements *)
let element_list_to_locations (list: element list) : location list =
  List.fold ~init:[] ~f: (fun accum elem ->
      match elem with
      | Location l -> l :: accum
      | Way _ -> accum
    ) list

(* Create a map that maps node id to Location *)
module StringMap = Map.Make(String)
type id_map = location StringMap.t
let empty_id_map = StringMap.empty

let locations_to_id_map (loc_list: location list) : id_map =
  List.fold ~init:empty_id_map ~f:(fun accum elem -> 
      accum |> Map.set ~key:elem.location_name ~data:elem
    ) loc_list

(* Adds all nodes to the graph, all mapped to empty lists. *)
let locations_to_map (loc_list: location list) : graph = 
  List.fold ~init:empty_graph ~f:(fun accum elem ->
      accum
      |> Map.set ~key:elem ~data:empty_loc_set
    ) loc_list


(* step 2: look through all Ways and add all adjacencies to map *)

  
(* Gets all Ways from received elements *)
let element_list_to_ways (list: element list) : string list list =
  List.fold ~init:[] ~f:(fun accum elem ->
      match elem with
      | Way w -> w :: accum
      | Location _ -> accum
    ) list

(* acos(sin(lat1)sin(lat2) + cos(lat1)cos(lat2)cos(lon2-lon1)) *    6371 *)
let nodes_to_path_cost (n1: location) (n2: location) : float =
  let deg_to_rad degrees = degrees *. (Float.pi /. 180.) in
  let n1_lat_rad = deg_to_rad n1.lat in
  let n1_long_rad = deg_to_rad n1.long in
  let n2_lat_rad = deg_to_rad n2.lat in
  let n2_long_rad = deg_to_rad n2.long in
  let earth_rad = 6371. in
    Float.acos(Float.sin(n1_lat_rad) *. Float.sin(n2_lat_rad) +. Float.cos(n1_lat_rad) *. Float.cos(n2_lat_rad) *. Float.cos(n2_long_rad -. n1_long_rad)) *. earth_rad

(* Takes list of ways, a base graph of just locations mapped to empty sets, and a map from node ids to nodes, and creates the full adjacency list representation *)
let ways_and_base_map_to_full_map (ways: string list list) (base_graph: graph) (node_ids: id_map) : (graph * int) =
  let rec process_way_list ((g, connections): (graph * int)) (way: string list) : (graph * int) =
    match way with
    | hd1 :: hd2 :: tl ->
      let hd1_node = hd1 |> Map.find_exn node_ids in
      let hd2_node = hd2 |> Map.find_exn node_ids in
      let hd1_set = hd1_node |> Map.find_exn g in
      let hd2_set = hd2_node |> Map.find_exn g in
      let path_cost = nodes_to_path_cost hd1_node hd2_node in
      let new_graph = 
        g 
        |> Map.set ~key:hd1_node ~data:(Set.add hd1_set (hd2_node, path_cost)) 
        |> Map.set ~key:hd2_node ~data:(Set.add hd2_set (hd1_node, path_cost))
        
      in
      process_way_list (new_graph, connections + 1) (hd2 :: tl)
    | [_] | _ -> (g, connections)
  in
  List.fold ~init:(base_graph, 0) ~f:(fun accum elem ->
      process_way_list accum elem
    ) ways



(* SEXP CONVERSION METHODS *)
[@@@warning "-32"]
let sexp_of_graph (g: graph) : Sexp.t =
  (* [graph] key is a location, data is a set of (location * float) tuples *)
  let list_of_sexps = Map.fold ~init:[] ~f:(
    fun ~key ~data accum -> 
      let sexp_neighbors_shell = Set.fold ~init:[] ~f:(
        fun accum (loc, distance) ->
          let sexp_neighbor_inner_shell = Sexp.List [
            Sexp.List [Sexp.Atom "loc-id"; Sexp.Atom loc.location_name];
            Sexp.List [Sexp.Atom "dist" ;  Sexp.Atom (string_of_float distance)]
          ] in
          sexp_neighbor_inner_shell :: accum
      ) data
      in 
      let sexp_shell = Sexp.List [
        Sexp.List [Sexp.Atom "loc-id" ; Sexp.Atom key.location_name];
        Sexp.List [Sexp.Atom "lat" ; Sexp.Atom (string_of_float key.lat)]; 
        Sexp.List [Sexp.Atom "long" ; Sexp.Atom (string_of_float key.long)];
        Sexp.List [Sexp.Atom "adj-list" ; Sexp.List sexp_neighbors_shell]
      ] in sexp_shell :: accum
  ) g 
  in
  let sexp_list_of_sexps = Sexp.List list_of_sexps in
  Sexp.List [Sexp.Atom "graph" ; sexp_list_of_sexps]

  
