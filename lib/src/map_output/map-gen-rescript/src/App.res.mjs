// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Create_map from "./Create_map.res.mjs";
import * as JsxRuntime from "react/jsx-runtime";

function App(props) {
  var nodes = [
    {
      id: 244453411,
      lat: 39.2910,
      lon: -76.6120
    },
    {
      id: 244453412,
      lat: 39.2920,
      lon: -76.6130
    }
  ];
  return JsxRuntime.jsx("div", {
              children: JsxRuntime.jsx(Create_map.make, {
                    nodes: nodes
                  })
            });
}

var make = App;

export {
  make ,
}
/* Create_map Not a pure module */