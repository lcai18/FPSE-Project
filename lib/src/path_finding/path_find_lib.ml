[@@@warning "-33"]
[@@@warning "-34"]
[@@@warning "-26"]
[@@@warning "-32"]
[@@@warning "-37"]
[@@@warning "-69"]
[@@@warning "-27"]
[@@@warning "-11"]
open Core
open Json_utils
open Graph
open Types
open Dijkstra
open Yojson.Basic
(*

to execute this: dune exec _build/default/lib/src/path_finding/path_find.exe

*)


(* FOR NOW, IF GRAPH_PATH IS NOT SPECIFIED, IT WILL JUST MAKE A 200M RAD GRAPH AROUND HOMEWOOD CAMPUS
   todo: add graph creating params to function header and implement 
*)


module StringMap = Map.Make(String)

type node_label_map = string StringMap.t
let empty_stringmap = StringMap.empty

let load_node_label_map ~(filepath: string) : node_label_map =
     let sexp_string = In_channel.read_all filepath in
     let sexp_obj = Sexp.of_string sexp_string in
     match sexp_obj with
     | Sexp.Atom _ -> failwith "Invalid node label map -- topmost sexp layer should be a Sexp.List";
     | Sexp.List lst ->
        List.fold ~init:empty_stringmap ~f:(
            fun accum elem ->
                match elem with
                | Sexp.List [Sexp.List [Sexp.Atom "name" ; Sexp.Atom name]; Sexp.List [Sexp.Atom "node_id" ; Sexp.Atom id]] ->
                    accum |> Map.set ~key:name ~data:id
                | _ -> failwith "Invalid node label map formatting"

        ) lst

let location_label_to_id (label: string) : string option =
    let node_label_map = load_node_label_map ~filepath:"map_name_mappings_sexp_files/homewood_mappings.txt" in
    Map.find node_label_map label

let location_label_to_id_if_specified (label: string) : string =
    match location_label_to_id label with
    | None -> label
    | Some id -> Printf.printf "Found mapping for label %s: '%s'\n" label id; id

let get_graph (graph_path: string option): (graph * id_map) option =
    match graph_path with
    | None ->
        (
        let elements = nodes_request ~radius:600 |> request_body_to_yojson |> yojson_list_to_element_list in
        match elements with
        | None -> Printf.printf "No locations found.\n"; None
        | Some elems ->
            List.iter ~f:(fun elem -> print_element elem) elems;
            let location_list = elems |> element_list_to_locations in
            let loc_map = location_list |> locations_to_id_map in
            let base_graph = location_list |> locations_to_map in
            let ways_list = elems |> element_list_to_ways in
            let (g, _) = ways_and_base_map_to_full_map ways_list base_graph loc_map in
            Some (g, loc_map)
        )
    | Some path ->
        load_graph ~filename:path
        

(* eventually want this to return 'string list option' *)
[@@@warning "-8"]
let find_shortest_path_lib (loc_name_1: string) (loc_name_2: string) (graph_path: string option) : (location list * float) option =
    let graph_opt = get_graph graph_path in
    match graph_opt with
    | None -> failwith "Graph creation failed!"
    | Some (g, node_map) ->

        let loc_1_id = location_label_to_id_if_specified loc_name_1 in
        let loc_2_id = location_label_to_id_if_specified loc_name_2 in

        let loc1_opt = Map.find node_map loc_1_id and loc2_opt = Map.find node_map loc_2_id in
        match (loc1_opt, loc2_opt) with
        | (Some loc1, Some loc2) -> shortest_path g ~start:loc1 ~dest:loc2 
        | (None, _) | (_, None) | _ -> print_endline "No inputted locations, or locations not found. Maybe check the map radius?"; None

let shortest_path_to_json ((list, distance): location list * float) : Yojson.Basic.t =
  let location_list_to_yojson_string_list (l: location list) : Yojson.Basic.t =
    `List (List.map ~f:(fun loc -> 
      `Assoc [
        ("id", `String loc.location_name);
        ("lat", `String (string_of_float loc.lat));
        ("long", `String (string_of_float loc.long));
      ]
      ) l)
  in
  `Assoc [
    ("distance", `Float distance);
    ("path", (location_list_to_yojson_string_list list))
  ]

let api_get_path (start: string) (dest: string) ~(path: string option) : Yojson.Basic.t option =
  let res_opt = find_shortest_path_lib start dest path in
  match res_opt with
  | None -> None
  | Some res -> Some (shortest_path_to_json res)
