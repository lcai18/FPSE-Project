open Utils

let () = 
  Dream.run ~port:5432 
  @@ Dream.logger
  @@ Dream.router [
    
    Dream.get "/"
      (fun _ -> Dream.html "hello world!");

    Dream.get "/directions/:start/:destination"
      (fun request -> 
        let api_get_res = get_path (Dream.param request "start") (Dream.param request "destination") in
        Dream.json (Yojson.Basic.to_string api_get_res)
      )
  ]
  
