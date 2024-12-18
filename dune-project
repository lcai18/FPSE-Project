(lang dune 3.16)
(generate_opam_files true)
(authors "Spencer Huang" "Lawrence Cai")
(maintainers "shuan126@jh.edu" "lcai18@jh.edu")
(package
  (name OCamaps) 
  (allow_empty)
  (synopsis "An OCaml web application to find the shortest paths anywhere on the hopkins campus")
  (description "Through the use of Overpass Turbo and OpenStreetMap, we were able to construct a adjacency list representing the paths on the Hopkins campus. Then with Dijkstra's algorithm we created a way to find the shortet paths between any building on campus. Finally we utilized Rescript to build an interactive web app showing the map of our campus and the shortest path given a user input for the start and destination.")
  (depends
  (ounit2 (>= 2.2.7)) ; for each opam dependency list the version
  (core (>= 0.17.1)) ; `opam list core` will display which version of core you have
  (yosjon (>= 2.2.2))
  (cohttp-lwt-unix (>= 6.0.0))
  (lwt (>= 5.9.0))
  (dream (>= 1.0.0~alpha7))
  (ppx_inline_test (>= 0.17.0))
  (ppx_jane (>= 0.17.0))
  (bisect_ppx (>= 2.8.3))
  (core_kernel (>= 0.17.0))
  )

)

(source
 (github lcai18/FPSE-Project))


(license LICENSE)

(documentation https://url/to/documentation)
; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
