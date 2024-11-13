### Purpose of project
Our application will be a map service, similar to Google Maps, local to Homewood Campus. Users will be able to:

- Search for locations on Campus
- Search for directions from locations within the map
- Freely examine areas of the map

The main objective of our project will revolve around the algorithms we use to both: process a lot of map information from an API call made to Overpass Turbo into OCaml-readable information, and derive the shortest-path algorithms between locations. Minimally, we will implement these two functionalities to be able to be used in a CLI. We aim to additionally create a frontend to make map and path visualizations more useful to users afterwards.

While we intend on demonstrating this by mapping Homewood campus, we want this project to be more generalizable and scalable by creating a library allowing users to generate such maps anywhere in the world. More information on these specifics will be discussed in our project implementation.


### Mock demonstration

This demonstration will be divided into two parts: a workflow that describes how a purely CLI-based version of this app would work, as well as a figma showing what our intended GUI would look like.

Application basics: CLI interactivity
	
	Workflow can be separated into two major components:

Map generation: Before users can find shortest paths on a map, they need to “create” one first by providing a (latitude, longitude) coordinate pair, and a desired radius in meters from that point. An Overpass Turbo API call is then made to get all location and path information from the circle defined with a center and radius at the given coordinate pair and inputted radius respectively.

`$ dune exec ./src/map_gen/map_gen.exe <lat> <long> <radius>`

< SHOW CLI OUTPUTS HERE >

Pathfinding: Once users have generated a map, they can specify two locations on the map, and see a list of path nodes that they would have to follow. This kind of interface is not as practical since the path nodes are specific to the graph we created using Overpass, but this functionality is more important to us as an intermediary step to ensure that our algorithms are working, and to make testing them a little more straightforward.

`$ dune exec ./src/map_path/map_path.exe <path_to_map> <from_location> <to_location>`

< SHOW CLI OUTPUTS HERE >


In combination, a single executable to do both of these steps in one command will be implemented as follows:

`$ dune exec ./src/map_path/map_path.exe <path_to_map> <from_location> <to_location> <optional: map_gen_lat> <optional: map_gen_long> <optional: map_gen_radius>`

If path_to_map is not specified, the executable will first run map_gen.exe using the optional parameters, if provided (error thrown otherwise). 

< maybe show some possible errors? since we should be able to handle them gracefully >


User interactivity: GUI Interactivity

https://www.figma.com/design/lymHYOxwt07CWWN6l9actL/Untitled?node-id=0-1&t=Nb3YCVrkfvsoEvwv-1

### List of libraries
Core: For basic data structures and algorithms
Stdio: For CLI interactivity
Dream/Lwt: For making API calls to Overpass Turbo
Yojson (or Jsonaf): For processing JSON provided by Overpass API, as well as for constructing JSON objects as map-generation outputs
    - A test for this is provided in /demo
Rescript: For frontend GUI

### Module type declarations
Can be found in _____


### Implementation plan

Nov. 13 - Nov. 20: Start working on gathering/processing data + writing algorithms to be used for map

Nov. 20 to Nov. 27: Implement path-finding algorithms and start testing core functionalities

Nov. 27 to Dec. 4: Coverage testing and bug-fixing, take care of executable + code cleanliness (e.g. input sanitization) to prepare for code checkpoint. Start working on frontend.

Dec. 4 to Dec. 11: Finish UI and start testing project in entirety

Dec. 11 to Dec. 18: Make any necessary fixes or interesting additions (not planned yet), and prepare presentation for demo day
