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

class BDS.Mesh

    # Meshes may be built from one of several representations.
    # ASSUMPTION: The inputs contain private allocated data?
    # INPUT: A parameter object indicating any of the following input representations:
    # 1. INPUT: {.vertices, .face_indices}, BDS.Point[] (size n), int[] (size 3n)
    # 2. INPUT: {.triangles} BDS.Triangle[] (triangles should ideally contain face index information)
    # Data Structure Parameters. {type:default_values}
    # {soup:true, bvh:false, faceLink:false, halfedge:false, triangles:false}
    constructor: (params) ->

        # -- Initialize all data structure fields.

        # Polygon Soup. (Optionally we keep these guys around.)
        # Good for static rendering, not as good for dynamically modifiable meshes.
        @_vertices     = null
        @_face_indices = null
        @_triangles    = null

        # Bounding Volume Hiearchy
        @_bvh = null

        # faceLink structure.
        @_faceLink = null


        if params.soup
            # Indexed mesh, polygon soup.
            @_vertices     = params.vertices
            @_face_indices = params.face_indices

        if params.bvh
            triangles = params.triangles
            triangles = @_triangles if not triangles
            if not triangles
                vertices  = params.vertices
                faces     = params.face_indices
                triangles = BDS.Mesh.construct_triangles(params.vertices, params.face_indices)

            @_bvh = new BDS.BVH(triangles)


    # INPUT: BDS.Point[], int[] (int's index into vert array,
    #   every 3 represents a triangular face)
    # OUTPUT: BDS.Triangle[]
    @construct_triangles: (vertices, face_indices) ->
