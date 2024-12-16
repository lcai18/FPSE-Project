@react.component
let make = (~onSubmit: (string, string) => unit) => {
  // Define state for the form inputs
  let (start, setStart) = React.useState(() => "")
  let (destination, setDestination) = React.useState(() => "")

  let handleSubmit = evt => {
    evt->ReactEvent.Form.preventDefault // Prevent form refresh

    // Check if the values are empty
    if (start == "" || destination == "") {
      Js.log("Error: Both Start and Destination must be filled!")
    } else {
      // Pass the values to the parent's onSubmit handler
      onSubmit(start, destination)
    }
  }

  <form
    onSubmit={handleSubmit}
    style={ReactDOM.Style.make(
      ~display="flex",
      ~flexDirection="column",
      ~alignItems="flex-start",
      ~border="1px solid black",
      ~padding="10px",
      ~borderRadius="5px",
      ~maxWidth="300px",
      ~margin="10px",
      ()
    )}
  >
    <label>
      {React.string("Start:")}
      <input
        type_="text"
        value=start
        onChange={evt => setStart(ReactEvent.Form.target(evt)["value"])}
        style={ReactDOM.Style.make(
          ~display="block",
          ~marginBottom="10px",
          ~width="100%",
          ~padding="8px",
          ~border="1px solid black",
          ~borderRadius="3px",
          ()
        )}
      />
    </label>
    <label>
      {React.string("Destination:")}
      <input
        type_="text"
        value=destination
        onChange={event => setDestination(ReactEvent.Form.target(event)["value"])}
        style={ReactDOM.Style.make(
          ~display="block",
          ~marginBottom="10px",
          ~width="100%",
          ~padding="8px",
          ~border="1px solid black",
          ~borderRadius="3px",
          ()
        )}
      />
    </label>
    <button
      type_="submit"
      style={ReactDOM.Style.make(
        ~marginTop="10px",
        ~padding="8px 16px",
        ~backgroundColor="#007bff",
        ~color="white",
        ~border="none",
        ~borderRadius="5px",
        ~cursor="pointer",
        ()
      )}
    >
      {React.string("Start")}
    </button>
  </form>
}
