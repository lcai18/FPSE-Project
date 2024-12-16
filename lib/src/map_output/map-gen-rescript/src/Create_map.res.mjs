// Generated by ReScript, PLEASE EDIT WITH CARE

import * as React from "react";
import * as Leaflet from "leaflet";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as JsxRuntime from "react/jsx-runtime";

function Create_map(props) {
  var nodes = props.nodes;
  var mapRef = React.useRef(null);
  var initialized = React.useRef(false);
  React.useEffect((function () {
          if (!initialized.current) {
            initialized.current = true;
            var el = mapRef.current;
            if (el === null || el === undefined) {
              console.log("here");
            } else {
              var map = Leaflet.map(el, {});
              map.setView([
                    39.2904,
                    -76.6122
                  ], 13);
              var layer = Leaflet.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
                    maxZoom: 19
                  });
              layer.addTo(map);
              nodes.forEach(function (node) {
                    var m = Leaflet.marker([
                          node.lat,
                          node.lon
                        ]);
                    m.addTo(map);
                    m.bindPopup("Node ID: " + node.id.toString());
                  });
              console.log(mapRef);
            }
          }
          
        }), []);
  return JsxRuntime.jsx("div", {
              ref: Caml_option.some(mapRef),
              style: {
                height: "50vh",
                marginRight: "10%",
                marginLeft: "auto",
                width: "50%"
              }
            });
}

var make = Create_map;

export {
  make ,
}
/* react Not a pure module */
