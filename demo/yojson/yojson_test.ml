let json_string = {|
  {"number" : 42,
   "string" : "yes",
   "list": ["for", "sure", 42]}|}
(* val json_string : string *)

let json = Yojson.Safe.from_string json_string
(* val json : Yojson.Safe.t *)

let () = Format.printf "Parsed to %a\n" Yojson.Safe.pp json