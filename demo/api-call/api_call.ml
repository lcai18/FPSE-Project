open Core
open Lwt
open Cohttp
open Cohttp_lwt_unix
(* open Yojson.Basic *)
open Yojson.Basic.Util

[@@@warning "-33"]
[@@@warning "-26"]
[@@@warning "-32"]
[@@@warning "-37"]

type location = {
    location_name : string;
    lat : float;
    long : float;
}


(* When processing elements from the API call, we want to handle 'node' types differently from 'way' types, so this is how we will differentiate mid-parsing*)
type element = Location of location | Way of location list

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
  | "way" -> None (* <-- TODO: THIS IS TEMPORARY, will be replaced with helper methods for this soon *)
  | _ -> None (* this should never happen! *)


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
  let uri_data = "?data=[out:json];(node%5B%22amenity%22%5D(around%3A"^rad_string^"%2C39.3299%2C-76.6205);way%5B%22amenity%22%5D(around%3A"^rad_string^"%2C39.3299%2C-76.6205);node(w););out+body;" in
  let uri = uri_base ^ uri_data in
  let request_body = Lwt_main.run (get_request ~uri) in
  request_body
  
(* Attempts to convert a request body to JSON. Returns a list of Yojson objects if successful, or None if not. *)
let request_body_to_yojson (body: string option) : Yojson.Basic.t list option =
  match body with
  | Some body_str ->
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

(* Converts a list of Yojson objects to a list of locations. Utilizes [json_elem_to_location_or_way] to parse each JSON element *)
let yojson_list_to_location_list (yojson_list: Yojson.Basic.t list option) : element list option =
  match yojson_list with
  | Some valid_list ->
    Some (List.fold ~init:[] ~f: (fun accum elem ->
      match (json_elem_to_location_or_way elem) with
      | Some res -> res :: accum
      | None -> accum          
      ) valid_list)
  | None -> None
  
(* Executable func: Gets nodes, converts them to json, converts json into location list *)
let () =
  let locations = nodes_request ~radius:200 |> request_body_to_yojson |> yojson_list_to_location_list in
  match locations with
  | Some locs -> 
      List.iter ~f:(fun loc ->
        match loc with
        | Location loc -> Printf.printf "Location: %s, Lat: %.4f, Long: %.4f\n" loc.location_name loc.lat loc.long;
        | _ -> print_endline "Not a 'location'!"
      ) locs
  | None -> Printf.printf "No locations found.\n"
