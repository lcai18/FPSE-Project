// Generated by ReScript, PLEASE EDIT WITH CARE

import * as React from "react";
import * as BuildingsList from "./BuildingsList.res.mjs";
import * as JsxRuntime from "react/jsx-runtime";

function AvailableBuildings(props) {
  var match = React.useState(function () {
        return false;
      });
  var setShowBuildings = match[1];
  return JsxRuntime.jsxs("div", {
              children: [
                JsxRuntime.jsx("button", {
                      children: "List of Available Buildings",
                      style: {
                        backgroundColor: "blue",
                        border: "none",
                        color: "white",
                        cursor: "pointer",
                        marginTop: "20px",
                        padding: "10px 20px",
                        borderRadius: "5px"
                      },
                      onClick: (function (param) {
                          setShowBuildings(function (prev) {
                                return !prev;
                              });
                        })
                    }),
                match[0] ? JsxRuntime.jsxs("div", {
                        children: [
                          JsxRuntime.jsx("h3", {
                                children: "Available Buildings:"
                              }),
                          JsxRuntime.jsx("ul", {
                                children: BuildingsList.buildingList.map(function (b) {
                                      return JsxRuntime.jsx("li", {
                                                  children: b.name
                                                }, b.name);
                                    }),
                                style: {
                                  border: "1px solid black",
                                  listStyleType: "none",
                                  margin: "0",
                                  padding: "10px",
                                  paddingLeft: "20px"
                                }
                              })
                        ],
                        style: {
                          marginTop: "10px"
                        }
                      }) : JsxRuntime.jsx(JsxRuntime.Fragment, {})
              ]
            });
}

var make = AvailableBuildings;

export {
  make ,
}
/* react Not a pure module */
