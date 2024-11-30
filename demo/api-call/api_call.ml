open Core
open Lwt
open Cohttp
open Cohttp_lwt_unix
open Yojson.Basic
open Yojson.Basic.Util

[@@warning "-33"]

type location = {
    location_name : string;
    lat : float;
    long : float;
}

let get_request ~(radius: int) : location list option Lwt.t =
  let rad_string = string_of_int radius in
  let uri_base = "https://overpass-api.de/api/interpreter" in
  let uri_data = "?data=[out:json];(node%5B%22amenity%22%5D(around%3A"^rad_string^"%2C39.3299%2C-76.6205);way%5B%22amenity%22%5D(around%3A"^rad_string^"%2C39.3299%2C-76.6205);relation%5B%22amenity%22%5D(around%3A"^rad_string^"%2C39.3299%2C-76.6205););out+center;" in
  let uri = Uri.of_string (uri_base ^ uri_data) in
  Client.get uri >>= fun (response, body) ->
    let status = Response.status response in
    Printf.printf "Response status: %s\n" (Code.string_of_status status);
    body
    |> Cohttp_lwt.Body.to_string
    >|= fun body_str ->
      try
        let node_list_raw = 
          body_str
          |> from_string
          |> member "elements"
          |> to_list
        in
        let location_list = List.fold ~init:[] ~f:
          (fun accum elem -> 
            {
              location_name = (elem |> member "id" |> to_int |> string_of_int);
              lat = (elem |> member "lat" |> to_float);
              long = (elem |> member "lon" |> to_float); 
            }
            :: accum            
           ) node_list_raw in
        Some location_list
      with Yojson.Json_error msg ->
        Printf.printf "JSON parse error: %s\n" msg;
        None

let () =
  let locations = Lwt_main.run (get_request ~radius:50) in
  match locations with
  | Some locs -> 
      List.iter ~f:(fun loc ->
        Printf.printf "Location: %s, Lat: %.4f, Long: %.4f\n" loc.location_name loc.lat loc.long
      ) locs
  | None -> Printf.printf "No locations found.\n"
