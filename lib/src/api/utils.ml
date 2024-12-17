open Path_find_lib

let api_error (message: string) : Yojson.Basic.t =
  `Assoc [
    "Error", `String message
  ]


(* filepath to saved graph is None -- when we turn in, it will probably be hardcoded bc. not enough time to flesh out *)
let get_path (start: string) (dest: string) : Yojson.Basic.t =
  let api_get_res_opt = api_get_path start dest ~path:(Some "map_sexp_files/homewood_map.txt") in
  match api_get_res_opt with
  | None -> api_error "Failed to get a path"
  | Some api_get_res -> api_get_res
