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


[@@@warning "-8"]
let graph_of_sexp ((Sexp.List [_ ; Sexp.List lst]): Sexp.t) : (graph * id_map) option = (* [lst] is a list of sexp shells *)
  let id_map_opt = List.fold ~init:(Some empty_id_map) ~f:
    (fun accum_opt elem ->
      match elem with
      | Sexp.List [Sexp.List [_; Sexp.Atom loc_name]; Sexp.List [_ ; Sexp.Atom lat_string] ; Sexp.List [_ ; Sexp.Atom long_string] ; Sexp.List [_ ; _]] ->
        let lat_f_opt = float_of_string_opt lat_string in (* i.e. if the data in the sexp is not a floating point number *)
        if Option.is_none lat_f_opt then
          None
        else
        let long_f_opt = float_of_string_opt long_string in (* i.e. if the data in the sexp is not a floating point number *)
        if Option.is_none long_f_opt then
          None
        else
        let Some lat_f = lat_f_opt in
        let Some long_f = long_f_opt in
        let cur_loc : location = {location_name=loc_name; lat=lat_f; long = long_f} in
        let Some accum = accum_opt in
        Some (accum|> Map.set ~key:cur_loc.location_name ~data:cur_loc)
      | Sexp.Atom _ | _ -> print_endline "improperly formatted sexp -- does not match graph format. elem is not a sexp.list."; None
    ) lst
  in
  let graph_res = Option.bind id_map_opt ~f:(fun id_map ->
    List.fold ~init:(Some empty_graph) ~f:
      (* In this fold, [elem] contains all information about a particular node *)
      (fun accum_opt elem ->
        Option.bind accum_opt ~f:(fun accum -> 
          match elem with
          | Sexp.List [Sexp.List [_; Sexp.Atom loc_name]; Sexp.List [_ ; Sexp.Atom _] ; Sexp.List [_ ; Sexp.Atom _] ; Sexp.List [_ ; Sexp.List neighbor_list]] ->
            let cur_loc = Map.find_exn id_map loc_name in

            (* In this fold, [elem] contains all information about a particular node's neighbor (while [neighbor_list] is the list of neighbor info) *)
            let created_neighbor_list_opt = List.fold ~init:(Some empty_loc_set) ~f:(
              fun neighbor_set_accum_opt elem ->
                (* print_endline (Sexp.to_string elem); *) (* debug line *)
                Option.bind neighbor_set_accum_opt ~f:(fun neighbor_set_accum -> 
                  match elem with
                  | Sexp.List [Sexp.List [_; Sexp.Atom neighbor_id] ; Sexp.List [_; Sexp.Atom neighbor_distance_string]] ->
                    let neighbor_distance_opt = float_of_string_opt neighbor_distance_string in
                    if Option.is_none neighbor_distance_opt then (* i.e. if the data in the sexp is not a floating point number *)
                      None
                    else
                    let neighbor_loc_object = Map.find_exn id_map neighbor_id in
                    let Some neighbor_distance = neighbor_distance_opt in
                    let neighbor_tuple = (neighbor_loc_object, neighbor_distance) in
                    Option.return (Set.add neighbor_set_accum neighbor_tuple)
                  | Sexp.Atom _ -> print_endline "neighbor is a sexp.atom"; None | _ -> print_endline "improperly formatted sexp -- does not match graph format. neighbor is not a sexp.list."; None
                )
            ) neighbor_list in
            let Some created_neighbor_list = created_neighbor_list_opt in
            Option.return (accum |> Map.set ~key:cur_loc ~data:created_neighbor_list)
          | Sexp.Atom _ | _ -> print_endline "improperly formatted sexp -- does not match graph format. elem is not a sexp.list in second loop. "; None
      )
    ) lst)
    in
    match (graph_res, id_map_opt) with
    | (Some graph, Some node_map) -> Some (graph, node_map)
    | _ -> None
      
let save_sexp_to_file ~(filename: string) (sexp: Sexp.t) : unit=
  let sexp_string = Sexp.to_string sexp in
  Out_channel.write_all filename ~data:sexp_string

let save_graph (g: graph) (filename: string): unit =
  g
  |> sexp_of_graph
  |> save_sexp_to_file ~filename

let load_sexp_from_file ~(filename: string) : Sexp.t =
  let sexp_string = In_channel.read_all filename in
  Sexp.of_string sexp_string

let load_graph ~(filename: string) : (graph * id_map) option =
  let loaded_sexp = load_sexp_from_file ~filename in
  graph_of_sexp loaded_sexp

