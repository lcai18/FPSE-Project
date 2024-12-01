open Core
open Lwt
open Cohttp
open Cohttp_lwt_unix
(* open Yojson.Basic *)
open Yojson.Basic.Util

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




*)

[@@@warning "-33"]
[@@@warning "-26"]
[@@@warning "-32"]
[@@@warning "-37"]

type location = {
    location_name : string;
    lat : float;
    long : float;
}


(* When processing elements from the API call, we want to handle 'node' types differently from 'way' types, so this is how we will differentiate mid-parsing *)
(* < my idea is that we will temporarily represent a Way as a list of integers, being Node IDs. then we use these lists to connect the nodes later. > *)

(* "Way" tuple is (start, end, intermediate nodes list) *)
type element = Location of location | Way of (int * int * int list)



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

  let yojson_list_to_int_list (yojson_list: Yojson.Basic.t list option) : int list option =
    match yojson_list with
    | Some valid_list ->
      Some (List.fold ~init:[] ~f: (fun accum elem ->
        let id = elem |> member "id" |> to_int in
        id :: accum         
        ) valid_list)
    | None -> None

(* Gets the request body from getting all nodes in a 'way'. Note that the request body does not order the nodes... we need to do this ourselves *)
let way_request_all_nodes ~(way_id: int) : string option =
  let uri_base = "https://overpass-api.de/api/interpreter" in
  let uri_data = "?data=[out%3Ajson%5D%5Btimeout%3A25%5D%3Bway%28id%3A"^(way_id |> string_of_int)^"%29%5B%22highway%22%3D%22footway%22%5D-%3E.paths%3Bnode%28w.paths%29-%3E.nodes%3B%28.nodes%3B%29%3Bout%20body%3B" in
  let uri = uri_base ^ uri_data in
  let request_body = Lwt_main.run (get_request ~uri) in
  request_body

(* Set 'index' to '1' to get the FIRST node in the way. Set it to '-1' to get the LAST node in the way. *)
let way_request_node_id ~(way_id: int) ~(index: int) : string option =
  let uri_base = "https://overpass-api.de/api/interpreter" in
  let uri_data = "?data=[out%3Ajson%5D%5Btimeout%3A25%5D%3Bway%28id%3A"^(way_id |> string_of_int)^"%29%5B%22highway%22%3D%22footway%22%5D-%3E.paths%3Bnode%28w.paths%3A"^(index |> string_of_int)^"%29-%3E.nodes%3B%28.nodes%3B%29%3Bout%20body%3B" in
  let uri = uri_base ^ uri_data in
  let request_body = Lwt_main.run (get_request ~uri) in
  request_body

(* Parse JSON from getting a single Node into its ID (helper method for getting info re. starting and ending nodes in a 'way')*)
let way_node_id_response_to_node_id (way_node_id_response: string option) : int option =
  match way_node_id_response with
  | Some response ->
    (try
      let node_list_raw =
        response
        |> Yojson.Basic.from_string
        |> Yojson.Basic.Util.member "elements"
        |> Yojson.Basic.Util.to_list
      in
      match List.hd node_list_raw with
      | Some node -> Some (node |> member "id" |> to_int)
      | None -> None
    with Yojson.Json_error msg ->
      Printf.printf "JSON parse error: %s\n" msg;
      None)
  | None -> None 


let build_way ~(way_id: int) : element option =
  (* Get the beginning and ending nodes in the 'way' *)
  let start_node_id = 
    way_request_node_id ~way_id ~index:1 |> way_node_id_response_to_node_id
  in
  let end_node_id = 
    way_request_node_id ~way_id ~index:(-1) |> way_node_id_response_to_node_id
  in
  match (start_node_id, end_node_id) with
| (Some s_id, Some e_id) ->
    (* Both start and end nodes are Some, proceed with getting intermediary nodes *)
    let node_id_list_op = way_request_all_nodes ~way_id |> request_body_to_yojson |> yojson_list_to_int_list in
    (match node_id_list_op with
     | Some valid_list -> Some (Way (s_id, e_id, valid_list))
     | None -> None)
| (None, _) | (_, None) -> 
    print_endline "one of the start/end nodes is corrupted";
    (* Either start_node_id or end_node_id is None, so handle the case accordingly *)
    None

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
    (* print_endline "FOUND A WAY!"; *)
    let way_id = json_elem |> member "id" |> to_int in
    (* Printf.printf "%s\n" (way_id |> string_of_int); *)
    build_way ~way_id
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
  | Way (s, e, m) ->
    let s_str = string_of_int s in
    let e_str = string_of_int e in
    let m_str = List.map ~f:string_of_int m |> String.concat ~sep:", " in
    Printf.printf "Starting node: %s\nEnding node: %s\nAll nodes in between (inc): %s\n" s_str e_str m_str
  
(* Executable func: Gets nodes, converts them to json, converts json into location list *)
let () =
  let elements = nodes_request ~radius:200 |> request_body_to_yojson |> yojson_list_to_element_list in
  match elements with
  | Some elems -> 
     (
      List.iter ~f:(fun elem ->
        print_element elem
      ) elems;

      (* just a test to see if we can correctly parse a 'way' *)
      (* let way_start_node_test_body = build_way ~way_id:22770711 in
      match way_start_node_test_body with
      | Some Way(s, e, m) -> 
        let s_str = s |> string_of_int in
        let e_str = e |> string_of_int in
        let m_str = List.map m ~f:(fun elem -> string_of_int elem) |> String.concat ~sep:", " in
        Printf.printf "Starting node: %s\nEnding node: %s\nAll nodes inbetween (inc): %s\n" s_str e_str m_str;
      | Some _ | None -> Printf.printf "Something went wrong when building the example way :("; *)
     )
  | None -> Printf.printf "No locations found.\n"



