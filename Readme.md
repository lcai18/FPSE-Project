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