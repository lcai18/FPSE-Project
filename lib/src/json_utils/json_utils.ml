(* api_call.ml *)

open Core
open Lwt
open Cohttp
open Cohttp_lwt_unix
open Yojson.Basic.Util
open Types



let get_request ~(uri: string) : string option Lwt.t =
  Client.get (Uri.of_string uri) >>= fun (response, body) ->
    let status = Response.status response in
    if Code.is_success (Code.code_of_status status) then
      Cohttp_lwt.Body.to_string body >|= fun body_str -> Some body_str
    else
      Lwt.return_none

let nodes_request ~(radius: int) : string option =
  let rad_string = string_of_int radius in
  let uri_base = "https://overpass-api.de/api/interpreter" in
  let uri_data = "?data=%5Bout%3Ajson%5D%5Btimeout%3A25%5D%3B%0Anode%28around%3A"^rad_string^"%2C39.3299%2C-76.6205%29%3B%20%0Away%28around%3A"^rad_string^"%2C39.3299%2C-76.6205%29%5B%22highway%22~%22footway|steps%22%5D%3B%0A%28._%3B%3E%3B%29%3B%0Aout%20body%20geom%3B" in
  let uri = uri_base ^ uri_data in
  let request_body = Lwt_main.run (get_request ~uri) in
  request_body

let request_body_to_yojson (body: string option) : Yojson.Basic.t list option =
  match body with
  | Some body_str ->
    (try
        let node_list_raw =
          body_str
          |> Yojson.Basic.from_string
          |> member "elements"
          |> to_list
        in
        Some node_list_raw
      with Yojson.Json_error msg ->
        Printf.printf "JSON parse error: %s\n" msg;
        None)
  | None -> None

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
    let way_nodes = json_elem |> member "nodes" |> to_list |> List.map ~f:(fun elem -> elem |> to_int |> string_of_int) in
    Some (Way way_nodes)
  | _ -> None

let yojson_list_to_element_list (yojson_list: Yojson.Basic.t list option) : element list option =
  match yojson_list with
  | Some valid_list ->
    Some (List.filter_map valid_list ~f:json_elem_to_location_or_way)
  | None -> None
  [@@@coverage off]
let print_element (e: element) : unit =
  match e with
  | Location loc -> Printf.printf "Location: %s, Lat: %.4f, Long: %.4f\n" loc.location_name loc.lat loc.long
  | Way node_list ->
    let node_list_str = node_list |> String.concat ~sep:", " in
    Printf.printf "List of nodes in Way: %s\n" node_list_str
  [@@@coverage on]