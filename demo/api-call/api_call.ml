open Core
open Lwt
open Cohttp
open Cohttp_lwt_unix
(* open Yojson.Basic *)
open Yojson.Basic.Util

(*

to execute this: dune exec _build/default/demo/api-call/api_call.exe

*)

(*
  RELEVANT API CALLS



to get everything:

[out:json][timeout:25];
node(around:200,39.3299,-76.6205); 
way(around:200,39.3299,-76.6205)["highway"="footway"];
(._;>;);
out body geom;





to get info for a way's node at an index:

[out:json][timeout:25];
way(id:<WAY ID>)["highway"="footway"]->.paths;
node(w.paths:<INDEX>)->.nodes;
(.nodes;);
out body;

to get info for all nodes in a way:

[out:json][timeout:25];
way(id:<WAY ID>)["highway"="footway"]->.paths;
node(w.paths)->.nodes;
(.nodes;);
out body;


WAY json:
-   type: way -> "nodes" : list of ints

*)

[@@@warning "-33"]
[@@@warning "-26"]
[@@@warning "-32"]
[@@@warning "-37"]

type location = {
    location_name : string;
    lat : float;
    long : float;
} [@@deriving sexp, compare]


(* When processing elements from the API call, we want to handle 'node' types differently from 'way' types, so this is how we will differentiate mid-parsing *)
(* < my idea is that we will temporarily represent a Way as a list of integers, being Node IDs. then we use these lists to connect the nodes later. > *)

(* "Way" tuple is (start, end, intermediate nodes list) *)
type element = Location of location | Way of string list

(* Generic method to get the response body from an API call. Returns Some/None depending on if API call was successful *)
let get_request ~(uri: string) : string option Lwt.t =
  Client.get (Uri.of_string uri) >>= fun (response, body) ->
    let status = Response.status response in
    if Code.is_success (Code.code_of_status status) then
      Cohttp_lwt.Body.to_string body >|= fun body_str -> Some body_str
    else
      Lwt.return_none

(* Given a radius in meters, will make an API call to Overpass Turbo and return a response body (currently centered at Hopkins campus) consisting of all 'node's, 'way's, and all nodes on the 'way's.

TODO: Make the lat/long center of the circle a function parameter *)
let nodes_request ~(radius: int) : string option =
  let rad_string = string_of_int radius in
  let uri_base = "https://overpass-api.de/api/interpreter" in
  let uri_data = "?data=%5Bout%3Ajson%5D%5Btimeout%3A25%5D%3B%0Anode%28around%3A"^rad_string^"%2C39.3299%2C-76.6205%29%3B%20%0Away%28around%3A"^rad_string^"%2C39.3299%2C-76.6205%29%5B%22highway%22%3D%22footway%22%5D%3B%0A%28._%3B%3E%3B%29%3B%0Aout%20body%20geom%3B" in
  let uri = uri_base ^ uri_data in
  let request_body = Lwt_main.run (get_request ~uri) in
  request_body
  
(* Attempts to convert a request body to JSON. Returns a list of Yojson objects if successful, or None if not. *)
let request_body_to_yojson (body: string option) : Yojson.Basic.t list option =
  match body with
  | Some body_str ->
    (* print_endline body_str; *)
    (try
        let node_list_raw =
          body_str
          |> Yojson.Basic.from_string
          |> Yojson.Basic.Util.member "elements"
          |> Yojson.Basic.Util.to_list
        in
        Some node_list_raw
      with Yojson.Json_error msg ->
        Printf.printf "JSON parse error: %s\n" msg;
        None)
  | None -> None

(* Helper function to convert Yojson 'element' objects into either Locations or Ways *)
let json_elem_to_location_or_way (json_elem: Yojson.Basic.t) : element option =
  let elem_type = json_elem |> member "type" |> to_string in
  match elem_type with
  | "node" -> 
    let loc = {
      location_name = (json_elem |> member "id" |> to_int |> string_of_int);
      lat = (json_elem |> member "lat" |> to_float);
      long = (json_elem |> member "lon" |> to_float); 
    } in
    Some (Location loc)
  | "way" ->
    (* Extract "nodes" from 'way' attribute *)
    let way_nodes = json_elem |> member "nodes" |> to_list |> List.map ~f:(fun elem -> elem |> to_int |> string_of_int) in Some (Way way_nodes)
  | _ -> None (* this should never happen! *)

(* Converts a list of Yojson objects to a list of locations. Utilizes [json_elem_to_location_or_way] to parse each JSON element *)
let yojson_list_to_element_list (yojson_list: Yojson.Basic.t list option) : element list option =
  match yojson_list with
  | Some valid_list ->
    Some (List.fold ~init:[] ~f: (fun accum elem ->
      match (json_elem_to_location_or_way elem) with
      | Some res -> res :: accum
      | None -> accum          
      ) valid_list)
  | None -> None

let print_element (e: element) : unit =
  match e with
  | Location loc -> Printf.printf "Location: %s, Lat: %.4f, Long: %.4f\n" loc.location_name loc.lat loc.long;
  | Way node_list ->
    let node_list_str = node_list |> String.concat ~sep:", " in
    Printf.printf "List of nodes in Way: %s\n"  node_list_str

(* Parse element list into adjacency list representation *)

(* step 0: type definitions for map *)

module LocationKey = struct
  type t = location [@@deriving sexp, compare]
end

module LocationMap = Map.Make(LocationKey)

module LocationSet = Set.Make(LocationKey)

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


(* THIS WONT WORK UNTIL WE HAVE A MAP FROM NODE ID TO NODE*)
let ways_and_base_map_to_full_map (ways: string list list) (base_graph: graph) (node_ids: id_map) : graph =
  let rec process_way_list (way: string list) (g: graph) : graph =
    match way with
    | hd1 :: hd2 :: tl ->
      let hd1_node = hd1 |> Map.find_exn node_ids in
      let hd2_node = hd2 |> Map.find_exn node_ids in
      let hd1_set = hd1_node |> Map.find_exn g in
      let hd2_set = hd2_node |> Map.find_exn g in
      let new_graph = 
        g 
        |> Map.set ~key:hd1_node ~data:(Set.add hd1_set hd2_node) 
        |> Map.set ~key:hd2_node ~data:(Set.add hd2_set hd1_node)
      in
      process_way_list (hd2 :: tl) new_graph
    | [_] | _ -> g
  in
  List.fold ~init:base_graph ~f:(fun accum elem ->
      process_way_list elem accum
    ) ways


(* Executable func: Gets nodes, converts them to json, converts json into location list *)
let () =
  let elements = nodes_request ~radius:200 |> request_body_to_yojson |> yojson_list_to_element_list in
  match elements with
  | Some elems -> 
     (
      List.iter ~f:(fun elem ->
        print_element elem
      ) elems;
     )
  | None -> Printf.printf "No locations found.\n"