
@module("leaflet")
external leafletMap: (Dom.element, Js.Dict.t<Js.Json.t>) => 'map = "map"

@module("leaflet")
external tileLayer: (string, {"maxZoom": int}) => 'tilelayer = "tileLayer"

@module("leaflet")
external marker: array<float> => 'marker = "marker"

@module("leaflet")
external addTo: ('a, 'b) => 'a = "addTo"

@send
external setView: ('map, array<float>, int) => 'map = "setView"

@send
external bindPopup: ('marker, string) => 'marker = "bindPopup"
