open Types
open RouteForm

type response
@val external fetch: string => promise<response> = "fetch"
@send external json: response => promise<'a> = "json"


@react.component
let make = () => {

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


  // let styles = Reac.Style.make(
  //   ~display="flex", 
  //   ~flexDirection="column",
  //   ~alignItems="center", 
  //   ~justifyContent="center", 
  //   ~height="100vh", 
  //   ~margin="0",  
  //   ()
  // )

  <div>
    <h1 style={ReactDOM.Style.make(~color="#444444", ~fontSize="68px", ~alignItems="center",())}> {React.string("OCamaps")} </h1>
    <h2 style={ReactDOM.Style.make(~color="#444444", ~fontSize="20px", ~fontStyle="italic", ())}> {React.string("@ Johns Hopkins")} </h2>
    <div style={ReactDOM.Style.make(
        ~display="flex",
        ~flexDirection="row",
        ())}>
    <RouteForm onSubmit={create_map} />
      {queried ? createMap() : <></>}
    </div>
  </div>
}
