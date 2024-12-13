open OUnit2
open Graph
open Json_utils
open Core

(* JSON parsing test that walks through process of map generation *)
let request_body_to_yojson_test _ =
  let response = "{  
    \"elements\": [  
      {  
        \"type\": \"node\",  
        \"id\": 1,  
        \"lat\": 0.0,  
        \"lon\": 0.0  
      },  
      {  
        \"type\": \"node\",  
        \"id\": 2,  
        \"lat\": 0.0,  
        \"lon\": 1.0
      },  
      {  
        \"type\": \"node\",  
        \"id\": 3,  
        \"lat\": 1.0,  
        \"lon\": 0.0  
      },  
      {  
        \"type\": \"node\",  
        \"id\": 4,  
        \"lat\": 1.0,  
        \"lon\": 1.0  
      },  
      {  
        \"type\": \"way\",  
        \"id\": 100,  
        \"nodes\": [  
          1,
          2  
        ]  
      },  
      {  
        \"type\": \"way\",  
        \"id\": 101,  
        \"nodes\": [  
          2,  
          4  
        ]  
      },  
      {  
        \"type\": \"way\",  
        \"id\": 102,  
        \"nodes\": [  
          1,  
          3  
        ]  
      },  
      {  
        \"type\": \"way\",  
        \"id\": 103,  
        \"nodes\": [  
          3,  
          4  
        ]  
      }  
    ]  
  }" in
  let yojson_output = request_body_to_yojson (Some(response)) in
  match yojson_output with
  | None -> failwith "expected yojson output"
  | Some output -> 
    assert_equal (List.length output) 8;
    let element_list = yojson_list_to_element_list yojson_output in
    match element_list with
    | None -> failwith "expected yojson to successfully convert to element list"
    | Some lst ->
      assert_equal (List.length lst) 8;
      let ways = element_list_to_ways lst in
      let locs = element_list_to_locations lst in
      assert_equal (List.length ways) 4;
      assert_equal(List.length locs) 4;
      let loc_id_map = locations_to_id_map locs in
      let graph = locations_to_map locs in
      let (full_graph, connections) = ways_and_base_map_to_full_map ways graph loc_id_map in
      assert_equal connections 4;
      assert_equal (Map.length full_graph) 4;
      Map.iteri full_graph ~f:(fun ~key:_ ~data ->
        assert_equal (Set.length data) 2
        );
      let sexp_graph = Sexp.to_string (graph_to_sexp full_graph) in
      print_endline sexp_graph


[@@@warning "-8"]
let get_request_test _ =
  let response = nodes_request ~radius:1 in
  match response with
  | None -> failwith "expected a response from get request"
  | Some res ->
    let expected = "{  
      \"version\": 0.6,  
      \"generator\": \"Overpass API 0.7.62.4 2390de5a\",  
      \"osm3s\": {  
        \"timestamp_osm_base\": \"2024-12-06T21:53:35Z\",  
        \"copyright\": \"The data included in this document is from www.openstreetmap.org. The data is made available under ODbL.\"  
      },  
      \"elements\": [  
        {  
          \"type\": \"node\",  
          \"id\": 244453413,  
          \"lat\": 39.3302974,  
          \"lon\": -76.6205155  
        },  
        {  
          \"type\": \"node\",  
          \"id\": 244453417,  
          \"lat\": 39.3304853,  
          \"lon\": -76.6205287  
        },  
        {  
          \"type\": \"node\",  
          \"id\": 244453418,  
          \"lat\": 39.3301071,  
          \"lon\": -76.6205020  
        },  
        {  
          \"type\": \"node\",  
          \"id\": 244453419,  
          \"lat\": 39.3298574,  
          \"lon\": -76.6204882  
        },  
        {  
          \"type\": \"node\",  
          \"id\": 244453421,  
          \"lat\": 39.3294736,  
          \"lon\": -76.6204598  
        },  
        {  
          \"type\": \"node\",  
          \"id\": 4519817452,  
          \"lat\": 39.3305569,  
          \"lon\": -76.6205307  
        },  
        {  
          \"type\": \"way\",  
          \"id\": 22770712,  
          \"bounds\": {  
            \"minlat\": 39.3294736,  
            \"minlon\": -76.6205307,  
            \"maxlat\": 39.3305569,  
            \"maxlon\": -76.6204598  
          },  
          \"nodes\": [  
            4519817452,  
            244453417,  
            244453413,  
            244453418,  
            244453419,  
            244453421  
          ],  
          \"geometry\": [  
            { \"lat\": 39.3305569, \"lon\": -76.6205307 },  
            { \"lat\": 39.3304853, \"lon\": -76.6205287 },  
            { \"lat\": 39.3302974, \"lon\": -76.6205155 },  
            { \"lat\": 39.3301071, \"lon\": -76.6205020 },  
            { \"lat\": 39.3298574, \"lon\": -76.6204882 },  
            { \"lat\": 39.3294736, \"lon\": -76.6204598 }  
          ],  
          \"tags\": {  
            \"highway\": \"footway\",  
            \"motor_vehicle\": \"permit\",  
            \"smoothness\": \"excellent\",  
            \"surface\": \"paving_stones\"  
          }  
        }  
      ]  
    }" in
    let res_yojson = request_body_to_yojson @@ Some(res) in
    let exp_yojson = request_body_to_yojson @@ Some(expected) in
    match (res_yojson, exp_yojson) with
    | (Some r, Some e) -> 
      match List.for_all2 ~f:Yojson.Basic.equal r e with
      | Ok true -> assert_equal 1 1;
      | Ok false -> failwith "expected yojson lists to be the same"
      | _ -> failwith "error with List.for_all2"


(* Map generation + 'way' connection tests *)


(* Executable tests (just checking for non-failure) *)

let suite = "suite" >:::  ["map generation tests" >:: request_body_to_yojson_test;
                           "get request test" >:: get_request_test
]

let () = run_test_tt_main suite