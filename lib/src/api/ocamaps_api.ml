open Utils

let () =
  Dream.run ~port:5432
  @@ Dream.logger
  @@ Dream.router [
    Dream.get "/" (fun _ -> Dream.html "hello world!");
    Dream.get "/directions/:start/:destination" (fun request ->
      let start = Dream.param request "start" in
      let destination = Dream.param request "destination" in
      let api_get_res = get_path start destination in
      let headers = [
        ("Content-Type", "application/json");
        ("Access-Control-Allow-Origin", "*");
        ("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        ("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Requested-With")
      ] in
      let body = Yojson.Basic.to_string api_get_res in
      Dream.respond ~headers:headers body
    )
  ]
