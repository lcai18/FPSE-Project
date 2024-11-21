open Lwt
open Cohttp
open Cohttp_lwt_unix

let get_request =
  let uri = Uri.of_string "https://overpass-api.de/api/interpreter?data=[out:json][timeout:25];
  (
    node[\"name\"](39.3268,-76.624,39.3344,-76.614);
  );
  out body;
  >;
  out skel qt;
  " 
  in
    Client.get uri >>= fun (response, body) ->
      let status = Response.status response in 
      Printf.printf "response status: %s\n" (Code.string_of_status status);
      body |> Cohttp_lwt.Body.to_string >|= fun body_str ->
        Printf.printf "Response body:\n%s\n" body_str


let () = 
  Lwt_main.run (get_request)