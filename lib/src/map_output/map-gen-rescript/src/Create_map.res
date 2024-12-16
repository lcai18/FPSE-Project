open React
open Types

@module("leaflet")
external leafletMap: (Dom.element, Js.Dict.t<Js.Json.t>) => 'map = "map"

@module("leaflet")
external tileLayer: (string, {"maxZoom": int}) => 'tilelayer = "tileLayer"

@module("leaflet")
external marker: array<float> => 'marker = "marker"

@send
external addTo: ('a, 'map) => 'a = "addTo"

@send
external setView: ('map, array<float>, int) => 'map = "setView"

@send
external bindPopup: ('marker, string) => 'marker = "bindPopup"

@react.component
let make = (~nodes: array<node>) => {
  let mapRef = useRef(Nullable.null)
  let initialized = React.useRef(false)
  useEffect(() => {
    if (!initialized.current) {
      initialized.current = true
      switch mapRef.current {
      | Null | Undefined => (Js.log("here"))
      | Value(el) =>
        
        // Initialize the Leaflet map
        let map = leafletMap(el, Js.Dict.empty())
        setView(map, [39.2904, -76.6122], 13)
        let layer = tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {"maxZoom": 19})
        addTo(layer, map)
        // Add markers for each node
        Array.forEach(nodes, node => {
          let m = marker([node.lat, node.lon])
          addTo(m, map)
          bindPopup(m, "Node ID: " ++ Int.toString(node.id))
        })
        Js.log(mapRef)
      }
    }

    None
  }, [])

  // Render a div that will hold the Leaflet map
  
  <div ref={ReactDOM.Ref.domRef(mapRef)} style={ReactDOM.Style.make(~width="100%", ~height="100vh", ())} />

}
