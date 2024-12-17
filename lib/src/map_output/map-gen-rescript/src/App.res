open Types
open RouteForm

@react.component
let make = () => {
  let create_map = (start, destination) => {
    Js.log("Start: " ++ start)
    Js.log("Destination: " ++ destination)
    // You can now use `start` and `destination` variables here
  }

  let n1 = {id: 244453411, lat: 39.2910, lon: -76.6120}
  let n2 = {id: 244453412, lat: 39.2920, lon: -76.6130}
  let nodes = [
    n1,
    n2,
  ]

  <>
    <h1> {React.string("Welcome to OCamaps")} </h1>
    <RouteForm onSubmit={create_map} />
    <div>
      <Create_map nodes />
    </div>
  </>
}
