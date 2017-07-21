###

Written by Bryce Summers on July.11.2017

Abstracts high level A Star functionality.

-Base class for specific search strategies.

Requires the use of data nodes n that have three fields availible:
    v.dist_to_start = Infinity
    v.dist_to_goal  = Infinity
    v.previous      = null

    We will reference this as the Node type.
###

# Classes representing spaces that may be searched by the AStarSearcher
class BDS.SearchGraph

    constructor: () ->

    _error: () -> console.log("Implement Me in A* child classs!")

    # -- Child Methods that are required for A* search.
    # This is narrowed down to
    # 1. Projection onto the graph.
    # 2. A distance metric on the graph.
    # 3. A neighbor relationship on the graph.

    # World location to node location. Usually the nearest node.
    # THREE.Vector3 --> Node.
    #getNodeNearPosition: (start_position) -> @_error() # Implement this in a child class!

    # Returns an admissible and consistent heuristic over the search space.
    # NODE, NODE --> Float.
    heuristic: (loc, goal) -> @_error() # Implement this in a child class!

    # Returns all of the orthogonal neighbors to the given node.
    neighbors: (node) -> @_error() # Implement this in a child class!

class BDS.AStarSearcher

    constructor: (search_graph) ->

        @_search_graph = search_graph

        # A maintained set of used nodes,
        # so we can clear the used nodes at the end.
        @_node_set = new Set()

    setSearchGraph: (search_graph) ->
        @_search_graph = search_graph

    # Using A* search, finds a path from position1 to position2
    # INPUT: THREE.Vector3, THREE.Vector3
    # OUTPUT: A list of positions at and connected by the nodes in the search space.
    # The first position will be the on given, the last will be the end position given.
    a_star_search: (start_node, end_node) ->

        start = start_node
        goal  = end_node

        @_node_set.add(start)
        @_node_set.add(goal)

        start.dist_to_start = 0
        start.dist_to_goal  = @_search_graph.heuristic(start, goal)
        #start.previous     = null

        goal.dist_to_goal = 0

        frontier = new BDS.Heap([start], (a, b) -> a.dist_to_start + a.dist_to_goal <= b.dist_to_start + b.dist_to_goal)

        while frontier.size() > 0

            node = frontier.dequeue()

            if node == goal
                node_path = @_tracePathBack(node)
                @_clearNodeSearchData()
                
                pts = []

                # Points found at graph locations.
                for node in node_path
                    pts.push(node.position.clone())

                return pts

            neighbors = @_search_graph.neighbors(node)

            for n in neighbors

                # add distance from node to this neighbor.
                new_dist = node.dist_to_start + @_search_graph.heuristic(node, n)
                @_node_set.add(n)

                # Expand the neighbor if a shorter path does not already exist to it.
                # Goals are always expanded.
                if new_dist < n.dist_to_start
                    n.dist_to_start = Math.min(n.dist_to_start, new_dist)
                    n.dist_to_goal  = @_search_graph.heuristic(start, goal) # FIXME: This may not need to be recomputed.
                    n.previous = node
                    frontier.add(n)


        # No legal path was found.
        ###
        console.log("WARNING: No Path was found between ")
        console.log(start)
        console.log(" and ")
        console.log(goal)
        ###
        @_clearNodeSearchData()
        return []


    # Genaric helper functions.

    # {previous:} --> [node, node, etc.]
    # terminates when pervious = null.
    _tracePathBack: (node) ->
    
        reversed_path = []
        while true
            reversed_path.push(node)
            node = node.previous
            break unless node != null


        path = []
        while reversed_path.length > 0
            path.push(reversed_path.pop())

        return path

    # Reverts all of the voxels to their initial search states.
    _clearNodeSearchData: () ->

        @_node_set.forEach (n) =>
            n.dist_to_start = Infinity
            n.dist_to_goal  = Infinity
            n.previous      = null

        @_node_set.clear()
        return