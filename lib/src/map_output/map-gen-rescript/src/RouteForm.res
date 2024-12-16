@react.component
let make = (~onSubmit : ReactEvent.Form.t => unit) => {
  let handleSubmit = evt => {
    evt->ReactEvent.Form.preventDefault // Prevent form refresh
    onSubmit(evt) // Trigger the parent's onSubmit handler
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
