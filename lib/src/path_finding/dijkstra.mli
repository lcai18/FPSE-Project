open Types
open Graph 
(* Given a graph, a start location, and a destination location,
   return the shortest distance between them using Dijkstra's algorithm 
val shortest_distance : graph -> start:location -> dest:location -> float option*)

(* Given a graph, a start location, and a destination location,
   return the shortest path (sequence of locations) between them and the total cost.
   If no path exists, return None. *)
val shortest_path : graph -> start:location -> dest:location -> (location list * float) option
