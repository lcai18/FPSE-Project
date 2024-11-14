# OCamaps: A maps service built in OCaml

### Purpose of project
Our application will be a map service, similar to Google Maps, local to Homewood Campus. Users will be able to:

- Search for locations on Campus
- Search for directions from locations within the map
- Freely examine areas of the map

The main objective of our project will revolve around the algorithms we use to both: process a lot of map information from an API call made to Overpass Turbo into OCaml-readable information, and derive the shortest-path algorithms between locations. Minimally, we will implement these two functionalities to be able to be used in a CLI. We aim to additionally create a frontend to make map and path visualizations more useful to users afterwards.

While we intend on demonstrating this by mapping Homewood campus, we want this project to be more generalizable and scalable by creating a library allowing users to generate such maps anywhere in the world. More information on these specifics will be discussed in our project implementation.


### Mock demonstration

This demonstration will be divided into two parts: a workflow that describes how a purely CLI-based version of this app would work, as well as a figma showing what our intended GUI would look like.

#### Application basics: CLI interactivity

Workflow can be separated into two major components:

##### Map generation
Before users can find shortest paths on a map, they need to “create” one first by providing a (latitude, longitude) coordinate pair, and a desired radius in meters from that point. An Overpass Turbo API call is then made to get all location and path information from the circle defined with a center and radius at the given coordinate pair and inputted radius respectively.

`$ dune exec ./src/map_gen/map_gen.exe <name> <description> <lat> <long> <radius>`

JSON output may look something like:
```
{
    "locations": [
        "loc1", "loc2", ...
    ],
    
    "paths": {
        "path1": ["loc1", "loc3", ...]
        "path2": ...
    },

    "connections": {
        "loc1": [loc3, loc7, ...],
        "loc2": [loc9, loc8, ...],
        "loc3": [loc1, loc4, ...]
    }
}
```

This JSON output will be able to be re-used, as we wil also write function that can parse valid JSON into a map that can be manipulated using our OCaml code. This functionality will be possible through a function that is able to parse the JSON. More information re. this in our module type declarations.

Sample command: `$ dune exec ./src/map_path/map_gen.exe "Homewood map" "A map of Homewood campus at Johns Hopkins" "39.33" "-76.6204" "500"`

##### Pathfinding
Once users have generated a map, they can specify two locations on the map, and see a list of path nodes that they would have to follow. The list by itself is not as practical since the path nodes are specific to the graph we created using Overpass, but this executable's functionality is more important to us as an intermediary step to ensure that our algorithms are working, and to make testing them a little more straightforward. We would then use the executable functionality in our frontend to create informative visualizations for users.

`$ dune exec ./src/map_path/map_path.exe <path_to_map> <from_location> <to_location>`

Sample command: `$ dune exec ./src/map_path/map_path.exe ./maps/homewood_map.json "FFC" "Hackerman Hall"`

``` ["loc1" ; "loc3" ; ... ]```

##### Error handling

A lot of input or algorithmic errors are possible such as:
- User does not input args correctly (missing args, badly formatted args, etc.)
- User tries to pathfind with locations not existent in the map
- A route cannot be found due to two locations existing in separate, disconnected graphs

... amongst many more. These errors will be thought of thoroughly during implementation and handled gracefully to avoid any unexpected thrown exceptions.

#### User interactivity: GUI Interactivity

Our Figma for our frontend concept: https://www.figma.com/design/lymHYOxwt07CWWN6l9actL/Untitled?node-id=0-1&t=Nb3YCVrkfvsoEvwv-1

Please note that this Figma is UX/aesthetic-wise likely not what our final product will likely look like, but should give a good idea of what we expect to implement on the frontend.

Additionally, in the Figma, we provide a demonstration that would grab a visual result from Overpass Turbo after pathfinding. We are not entirely sure if this is practical/possible -- in our actual implementation, it is possible that this 'screencap map' concept is replaced with a map that we try making ourselves out of ReScript (React) components.

### List of libraries
- Core: For basic data structures and algorithms
- Stdio: For CLI interactivity
- Dream/Lwt: For making API calls to Overpass Turbo
- Yojson (or Jsonaf): For processing JSON provided by Overpass API, as well as for constructing JSON objects as map-generation outputs
    - A test for this is provided in `/demo`. Installing via `opam install yojson` then running `dune build` and `dune exec` on the executable should demonstrate this.
    -  Both of us have tested this library on our development machines and were successful in getting it to work.
- Rescript: For frontend GUI

### Module type declarations
Can be found in `/lib/src/utils.mli`. These function signatures are not exhaustive, but provide a high level overview of how our code will work.


### Implementation plan

Nov. 13 to Nov. 20: Start working on gathering/processing data + writing algorithms to be used for map

Nov. 20 to Nov. 27: Implement path-finding algorithms and start testing core functionalities

Nov. 27 to Dec. 4: Coverage testing and bug-fixing, take care of executable + code cleanliness (e.g. input sanitization) to prepare for code checkpoint. Start working on frontend.

Dec. 4 to Dec. 11: Finish UI and start testing project in entirety

Dec. 11 to Dec. 18: Make any necessary fixes or interesting additions (not planned yet), and prepare presentation for demo day

This is a pretty loose plan since we expect some needed flexibility (if especially some parts end up being much more difficult/easier than expected), but it is our rough plan regarding how we plan to tackle this.