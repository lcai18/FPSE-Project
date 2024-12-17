open Types
open RouteForm

type response
@val external fetch: string => promise<response> = "fetch"
@send external json: response => promise<'a> = "json"


@react.component
let make = () => {
  // let n1 = {id: "244453411", lat: 39.2910, lon: -76.6120}
  // let n2 = {id: "244453412", lat: 39.2920, lon: -76.6130}
  let (nodes, setNodes) = React.useState(_ => [])
  let (queried, setQueried) = React.useState(_ => false)


  React.useEffect(() => {
    if (Array.length(nodes) != 0) {
      setQueried(_prev => true)
    }
    None
  }, [nodes]); 


  let create_map = (start, destination) => {
    let generate_endpoint = (s, d) => {
      "http://localhost:5432/directions/" ++ s ++ "/" ++ d 
    }

    let endpoint = generate_endpoint(start, destination)
    Js.log("Endpoint: " ++ endpoint)

    let _ = fetch(endpoint)
      ->Promise.then(response => {
        response->json
      })
      ->Promise.then(json => {

        let extractList = (json: Js.Json.t) => {
          Js.Json.decodeObject(json)
          ->Belt.Option.flatMap(dict => Js.Dict.get(dict, "path"))
          ->Belt.Option.flatMap(Js.Json.decodeArray)
        }

        switch extractList (json) {
          | Some (list) => {
            let new_nodes = list ->  Array.map(json => {
              switch Js.Json.decodeObject(json) {
                | Some (obj) => {
                  let id = Js.Dict.get(obj, "id") -> Belt.Option.flatMap(Js.Json.decodeString) -> Belt.Option.getWithDefault("");
                  let lat = Js.Dict.get(obj, "lat") -> Belt.Option.flatMap(Js.Json.decodeString)-> Belt.Option.flatMap(Belt.Float.fromString) -> Belt.Option.getWithDefault(0.0);
                  let lon = Js.Dict.get(obj, "long") -> Belt.Option.flatMap(Js.Json.decodeString)-> Belt.Option.flatMap(Belt.Float.fromString) -> Belt.Option.getWithDefault(0.0);
                  {id, lat, lon}
                }
                | None => {id: "", lat:0.0, lon:0.0}
              }
            });
            Js.log(json)
        
            setNodes(_prev => new_nodes)
            Js.log("Successfully updated nodes");
          }
          | None => {
            Js.log("Failed to get list")
          }

        }
        Promise.resolve(json)
      })
      ->Promise.catch(error => {
        Js.log2("Error:", error)
        Promise.resolve(Js.Json.null)
      })
  }

  let createMap = () => {
    <Create_map nodes={nodes}/>
  }


  <>
    <h1> {React.string("Welcome to OCamaps")} </h1>
    <RouteForm onSubmit={create_map} />
    <div>
      {queried ? createMap() : <></>}
    </div>
  </>
}
