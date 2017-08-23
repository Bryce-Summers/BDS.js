#
# BDS.Mesh
# Written on July.23.2017
#
# Represents an indexed set of triangles.
# or a boundary representation (b-rep)
# of discrete manifold with or without boundary.
#
# Supports various data structure representations:
#   - Polygon Soup representation for rendering.
#
# If the Mesh is a manifold Boundary Representation, then:
#
# Coming Soon:
#
#   - BDS.BVH3D building for efficient ray - mesh intersection.
#   - FaceLink structure for A* search on center points.
#   - Halfedge structure, for mesh processing.

class BDS.Mesh extends BDS.RayQueryable

    # Meshes may be built from one of several representations.
    # ASSUMPTION: The inputs contain private allocated data?
    # INPUT: A parameter object indicating any of the following input representations:
    # 1. INPUT: {.vertices, .face_indices}, BDS.Point[] (size n), int[] (size 3n)
    # 2. INPUT: {.triangles} BDS.Triangle[] (triangles should contain face index information)
    # 3. INPUT: {.abc_triangles, .face_indices} {.a, .b, .c}[] (triangle objects), int[] (size 3n)
    # Data Structure Parameters. {type:default_values}
    # {soup:true, bvh:false, faceLink:false, halfedge:false, triangle_list:false}
    constructor: (params) ->

        # -- Initialize all data structure fields.

        # Polygon Soup. (Optionally we keep these guys around.)
        # Good for static rendering, not as good for dynamically modifiable meshes.
        @_vertices     = null
        @_face_indices = null
        @_triangles    = null # Somewhat necessary for bvh's, faceLinks, ...

        # Bounding Volume Hiearchy
        @_bvh = null

        # faceLink structure.
        @_faceLink = null

        # Keep around the Polygon soup if so desired.
        if params.soup
            # Indexed mesh, polygon soup.
            @_vertices     = params.vertices
            @_face_indices = params.face_indices

        # Generate a Bounding Volume Hierarchy.
        if params.bvh
            
            triangles = @_getInputTriangles(params)
            @_bvh = new BDS.BVH3D(triangles)

        # Halfedge Mesh.
        if params.halfedge

            triangles = @_getInputTriangles(params)
            @_halfedgeMesh = new BDS.HalfedgeMesh(triangles)

        # FaceLinkGraph.
        if params.faceLink
            @_faceLink = new BDS.FaceLinkGraph(params.face_indices)

        # Ensure that the triangle list is generated if prompted.
        if params.triangle_list
            @_triangles = @_getInputTriangles(params)

    ###
    Public Interface
    ###

    getFaceLink: () ->
        return @_faceLink

    getTriangles: () ->
        return @_triangles

    ###
    Private Helper Functions.
    ###

    # Returns a set of triangles, that can be used to facillitate constructing the input.
    _getInputTriangles: (params) ->
        # Set triangles.
        triangles = @_triangles
        triangles = params.triangles if not triangles

        # Convert a list of abc triangle sets into a list of Bryce Data Structure Triangles.
        # Face indices are required, because abc triangles are assumed to not be BDS.Triangles.
        if not triangles and params.abc_triangles and params.face_indices
            triangles = []
            len = params.abc_triangles.length
            for i in [0...len]
                tri = params.abc_triangles[i]
                triangle = BDS.Triangle.from_abc_triangle(tri)

                index_a = params.face_indices[3*i + 0]
                index_b = params.face_indices[3*i + 1]
                index_c = params.face_indices[3*i + 2]

                triangle.setIndices(index_a, index_b, index_c)
                triangles.push(triangle)

        if not triangles
            vertices  = params.vertices
            faces     = params.face_indices
            triangles = BDS.Mesh.construct_triangles(params.vertices, params.face_indices)

        # Store triangles for later.
        @_triangles = triangles
        return triangles


    # INPUT: BDS.Point[], int[] (int's index into vert array,
    #   every 3 represents a triangular face)
    # OUTPUT: BDS.Triangle[]
    @construct_triangles: (vertices, face_indices) ->
        output = []
        for i in [0...face_indices.length] by 3

            # Vertex Indices.
            # Assumed to be in a consistant orientation.
            i1 = face_indices[i]
            i2 = face_indices[i + 1]
            i3 = face_indices[i + 2]

            # Vertices.
            v1 = vertices[i1]
            v2 = vertices[i2]
            v3 = vertices[i3]

            triangle = new BDS.Triangle(v1, v2, v3)
            triangle.setIndices(i1, i2, i3)
            output.push(triangle)

        return output
 
    # See BDS.RayQueryable

    ensure_bvh: () ->
        return true if @_bvh 


        if @_triangles
            @_bvh = new BDS.BVH3D(triangles)
            return true

        console.error("BDS.Mesh: Queries not supported without BVH generation. No triangles found to fix the problem.")
        return false


    rayQueryMin: (rayQuery) ->

        # We use BVH's for efficiency.
        @ensure_bvh()
        return @_bvh.rayQueryMin(rayQuery)

    rayQueryAll: (rayQuery) ->

        # We use BVH's for efficiency.
        @ensure_bvh()
        return @_bvh.rayQueryAll(rayQuery)

    rayQueryTime: (rayQuery) ->
        @ensure_bvh()

        # Utilize an empty query so as to avoid culling
        # due to minnimization.
        local_query = rayQuery.initialize(rayQuery.ray)

        if @_bvh.rayQueryMin(local_query)
            rayQuery.time = local_query.min_time
            return true
        return false


    # Adds intersection times to rayQuery.times[] value if true,
    # true if at least 1 time is found.
    rayQueryTimes: (rayQuery) ->

        @ensure_bvh()

        # Utilize an empty query so as to avoid culling
        # due to minnimization.
        local_query = rayQuery.initialize(rayQuery.ray)

        if @_bvh.rayQueryAll(local_query)
            for time in local.query_times
                rayQuery.times.push(time)
            return true
        return false