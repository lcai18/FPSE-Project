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

@module("leaflet")
external polyline: Js.Array.t<Js.Array.t<float>> => 'polyline = "polyline"

@send
external off: ('map, string, unit => unit) => unit = "off";

@send
external remove: ('map) => unit = "remove";

@react.component
let make = (~nodes: array<node>) => {
  let mapRef = useRef(Nullable.null)
  let mapInstanceRef = useRef(Nullable.null)
  let initialized = React.useRef(false)
  useEffect(() => {
      switch mapRef.current {
      | Null | Undefined => (Js.log("here"))
      | Value(el) =>
        
        switch mapInstanceRef.current {
        | Value(existingMap) =>
            Js.log("Cleaning up map instance...");
            off(existingMap, "click", () => ()); /* Example: unbinding 'click' listeners */
            remove(existingMap);
        | Null | Undefined => ()
        };

        // Initialize the Leaflet map
        let map = leafletMap(el, Js.Dict.empty())
        mapInstanceRef.current = Nullable.fromOption(Some(map));
        setView(map, [39.3285, -76.62039], 16)
        let layer = tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {"maxZoom": 19})
        addTo(layer, map)

        // add markers for start and end nodes
        let Some(start_node) = nodes[0];
        let Some(end_node) = nodes[Array.length(nodes) - 1];

        let start_node_marker = marker([start_node.lat, start_node.lon]);
        let end_node_marker = marker([end_node.lat, end_node.lon]);
        addTo(start_node_marker, map)
        addTo(end_node_marker, map)
        let path_points = [];
        Array.forEach(nodes, node => {
          path_points->Array.push([node.lat, node.lon])
        })

        let polylineOptions = Js.Dict.empty()
        Js.Dict.set(polylineOptions, "color", Js.Json.string("blue"))
        Js.Dict.set(polylineOptions, "weight", Js.Json.number(Belt.Int.toFloat(5)))

        let path = polyline(path_points)
        addTo(path, map)
        

        Js.log(mapRef)
      }


    None
  }, [nodes])

  <div ref={ReactDOM.Ref.domRef(mapRef)} style={ReactDOM.Style.make(~width="50%", ~height="50vh", ~marginLeft="auto", ~marginRight="10%", ())} />
}
