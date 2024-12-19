open BuildingsList


@react.component
let make = () => {
  let (showBuildings, setShowBuildings) = React.useState(_ => false);


  <div>
    <button
      style={
        ReactDOM.Style.make(
          ~marginTop="20px",
          ~backgroundColor="blue",
          ~color="white",
          ~border="none",
          ~padding="10px 20px",
          ~borderRadius="5px",
          ~cursor="pointer",
          ()
        )
      }
      onClick={_ => setShowBuildings(prev => !prev)}>
      {React.string("List of Available Buildings")}
    </button>

    {
      showBuildings ? (
        <div style={ReactDOM.Style.make(~marginTop="10px", ())}>
          <h3>{React.string("Available Buildings:")}</h3>
          <ul
            style={
              ReactDOM.Style.make(
                ~border="1px solid black",
                ~padding="10px",
                ~listStyleType="none",
                ~margin="0",
                ~paddingLeft="20px",
                ()
              )
            }>
            {React.array(buildingList->Array.map(b =>
              <li key=b["name"]>{React.string(b["name"])}</li>
            ))}
          </ul>
        </div>
      ) : <></>
    }
  </div>;
};
