open Core

type location = {
  location_name : string;
  lat : float;
  long : float;
} [@@deriving sexp, compare]

type element = 
  | Location of location 
  | Way of string list
