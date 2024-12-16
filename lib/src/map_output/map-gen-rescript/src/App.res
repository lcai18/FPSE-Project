// App.res
open Types
@react.component
let make = () => {
  let n1 = {id: 244453411, lat: 39.2910, lon: -76.6120}
  let n2 = {id: 244453412, lat: 39.2920, lon: -76.6130}
  let nodes = [
    n1,
    n2
  ]

   <div>
    <Create_map nodes />
  </div>
}
