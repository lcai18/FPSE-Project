# OCamaps 🗺️
- A map-generation and pathfinding tool built in OCaml
- Lawrence Cai, Spencer Huang

## Summary
Our project is a map application designed to both construct map-typed values in OCaml, and find the shortest path between locations.

![OCamaps demo showing path between the Academy and Hackerman](./static/ocamaps_demo.png)

### Map generation 🔨
We designed a small map generation library designed to be able to create map-typed objects in OCaml, using information from Overpass Turbo. Overpass Turbo is a free-to-use and open-sourced map wiki, and using it, we parsed node and path information to construct a graph centered at a specific point with a given radius. For the purpose of the demo, we built a map centered approximately in the middle of Homewood Campus, with a radius of 600 meters.

After making the appropriate API calls and parsing the information from Overpass, we implemented a number of algorithms to convert the returned json to a map-typed value, which is represented as an adjacency list of nodes mapped to a set of (node, distance) tuples consisting of neighbors.

We then implemented a simple persistence model by writing functions to convert the map-typed value to an s-expression, then write it to a text file. To use the same map for future calls, such as when pathfinding, we also wrote functions to decode the sexp-containing text files to recreate the map without repeating API calls to Overpass.

Overpass Turbo returned node labels as "ids", which were entirely numerical (e.g. 837291986). Since these were not very human-readable, we implemented a small mechanism to import node labels to a map, making locations such as "amr 1" or "hackerman hall" valid user input. We had to hardcode these values for Homewood campus, which was an unfortunate last resort. Overpass Turbo does not always provide building names, so we could not generalize this solution given our resources at hand. Using other certain paid map APIs (instead of Overpass) could be a possible solution to this.

### Pathfinding 🔍
OCamaps also includes a 'directions' service, allowing users to input two locations, and see the shortest path between them. We implemented Dijkstra's algorithm by using distance between nodes as path costs, calculated using the Haversine formula (which accounts for the curvature of the Earth). Doing so would allow us to get path weights through only the knowledge of latitude and longitude represented in degrees.

In an efficient implementation of Dijkstra's algorithm, a priority queue is used to keep track of the min-cost path. But, since Core's heap was not a functional data struture, we decided to implement from scratch a functional priority queue. To do this we implemented a binomial heap which supports logarithmic insertion and deletion operations. The binomial heap also inherently supports the concept of a functional data struture.

After constructing our map and building our Dijkstra's with a custom Priority Queue, we were finally able to construct a list of nodes detailing the shortest paths between two locations. The list of nodes is then processed into JSON data, and is able to be retrieved through our frontend via a GET request.

### UI/UX 🖌️
We implemented a simple frontend using Rescript to allow users to interact with a live map, visually seeing the shortest path returned by our algorithms.

We used the Leaflet map library to display our map, allowing us to plot points and draw lines given a list of coordinates.

We then wired our frontend to our Dream-powered backend by making a GET request which included information about start and destination nodes. After receiving JSON which included all necessary information to construct a path, we parsed the object appropriately and used Leaflet to render our outputs.

## Usage guide 

### Dependencies
To install opam dependencies, run the following from the root directory:

`$ opam install . --deps-only`

Then, run the following commands to install the necessary frontend packages:

```
$ cd ./lib/src/map_output/map-gen-rescript
$ npm install
```

### Running the backend
```
$ dune build
$ dune exec ./lib/src/api/ocamaps_api.exe
```
This should be running on port 5432.

### Running the frontend
`cd` to the frontend directory (if not there already):
```
$ cd ./lib/src/map_output/map-gen-rescript
```

Then start the vite project as usual:
```
$ npm run dev
```

#### Changes Since the Demo
After our demo today, we received some feedback and have decided to implement some changes.

These changes are as follows:
- An error message that pops up when a user types in an invalid building name. 
- More complex Dijkstra's algorithm test cases.


<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />

# (everything below is old)

### Code checkpoint progress report: 12/6
So far, we have implemented a number of key algorithms, and have begun testing using Hopkins campus and some small replica graphs.

#### Map generation
The first challenge was parsing data from Overpass Turbo into `location` and `way` records. In json_utils.ml, we wrote the code that made the appropriate GET request to Overpass, hardcoding the latitude/longitude for the center of Homewood campus. Once we were able to parse the string into a Yojson-typed object, we further manipulated it to identify the nodes and paths returned by the API. Lastly, we went through all of the "way" (i.e. path) elements to connect the locations together. The result of these operations is a `graph` object, which is an adjacency list representation, mapping locations to sets of connected locations. During this step, we also calculated path costs using the Haversine formula (accounting for the curvature of the Earth), and stored these weights in the graph as well.

#### Dijkstras implementation
Using the graph object, we then implemented Dijkstra's algorithm to find the shortest path between two nodes. To do this, we needed a priority queue, but the one provided by Core used mutation. To keep our codebase entirely functional, we implemented our own functional priority queue using a BST. We then ran some simple tests on the generated graph centered at Hopkins campus to confirm the correctness of the algorithm. 

#### Testing
We wrote some simple tests, trying to cover all core functionalities. A coverage report in `_coverage/index.html` is included in this repository showing our current coverage over all our libraries.

#### Next steps
We currently have a way to represent a graph, and a way to generate a list of locations representing a shortest path between two points. The next major part of our project will be to implement a frontend. We plan on doing this using Rescript, but are exploring other options as well. Through doing this, we will also need to add some API endpoints to our current code as to allow our frontend to communicate with our algorithms.

Some other things we want to have in the final implementation:
- Feature to save graphs in a sexp-format, allowing you to load previously-constructed graphs (as opposed to making the API call and parsing the output every time)
- Create a way to add in paths between nodes manually, in the event that for certain cases, our algorithms don't connect certain nodes adequately




    