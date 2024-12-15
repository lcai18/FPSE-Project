// Assume we have a list of nodes with id, lat, and lon
type node = {
  id: int,
  lat: float,
  lon: float,
}

let nodes = [
  {id: 244453411, lat: 39.2910, lon: -76.6120},
  {id: 244453412, lat: 39.2920, lon: -76.6130}
]

// Generate the markers JavaScript from the nodes
let generateMarkers = (nodes: list<node>): string => {
  nodes
  ->List.map(n => {
    Js.String.make({
|js|L.marker([${Float.toString(n.lat)}, ${Float.toString(n.lon)}]).addTo(map).bindPopup("Node ID: ${Int.toString(n.id)}");|js
    })
  })
  ->String.concat("\n")
}

// Full HTML template for the map
let generateHtml = (markersJs: string) => {
  {j|
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>My Map</title>

<!-- Leaflet CSS -->
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-sA+2YUyJD0vxW3YJ/Rb52EkyKZAXpgy26+Q2MZj0fEM=" crossorigin=""/>

<style>
  #mapid { height: 600px; width: 100%; }
</style>

</head>
<body>

<div id="mapid"></div>

<!-- Leaflet JS -->
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-vF0wgIoT/DcY3N7m2Kh3zlYL5u9xx2hEM0yOmJf3C6A=" crossorigin=""></script>

<script>
  // Initialize map
  var map = L.map('mapid').setView([39.2904, -76.6122], 13);

  // Add OpenStreetMap tiles
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19
  }).addTo(map);

  // Add markers
  $markersJs
</script>

</body>
</html>
|j}
}

// Now we write the file using Node's fs
@module("fs")
external writeFileSync: (string, string) => unit = "writeFileSync"

let () =
  let markersJs = generateMarkers(nodes)
  let html = generateHtml(markersJs)
  writeFileSync("map.html", html)
  Js.log("map.html generated successfully!")
