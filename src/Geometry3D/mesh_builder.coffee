###

Triangle Set Constructors
Written by Bryce Summers on Aug.22.2017

###

class BDS.Mesh_Builder

    constructor: () ->

    # Returns a set of indexed triangles representing a cube
    # spanning [0, 0, 0] and [1, 1, 1].
    # the cube will be transformed by the given 4 by 4 transform matrix.
    #
    # BDS.Matrix -> BDS.Triangle[]
    @new_cube: (transform) ->

        #         /^\
        #        / . \
        #       +  .  +
        #       |\. ./|
        # \+    |.\ /.|    /+
        #  y    +  |  +   x
        #   \-   \ | /   /-
        #         \+/
        #      (0, 0, 0)
        #
        #          |+
        #          z
        #          |-

        # FIXME: Multiply each of these by the transform.

        #ptxyz, 8 points total, 1 for every cube corner.
        pt000 = new BDS.Point(0, 0, 0) # 0 index.
        pt001 = new BDS.Point(0, 0, 1) # 1 index.
        pt010 = new BDS.Point(0, 1, 0) # 2
        pt011 = new BDS.Point(0, 1, 1) # 3
        pt100 = new BDS.Point(1, 0, 0) # 4
        pt101 = new BDS.Point(1, 0, 1) # 5
        pt110 = new BDS.Point(1, 1, 0) # 6
        pt111 = new BDS.Point(1, 1, 1) # 7

        pts = [pt000, pt001, pt010, pt011, pt100, pt101, pt110, pt111]

        # Triangleabc (a = index0, b = index1, c = index2) Named by index.
        
        ###
        051
        045
        012
        132
        236
        376
        467
        475
        024
        264
        153
        357
        ###
        # Determines faces.
        indices = [0, 5, 1,
                   0, 4, 5,
                   0, 1, 2,
                   1, 3, 2,
                   2, 3, 6,
                   3, 7, 6,
                   4, 6, 7,
                   4, 7, 5,
                   0, 2, 4,
                   2, 6, 4,
                   1, 5, 3,
                   3, 5, 7]

        # Construct a triangle set with the pts and face indices.
        return BDS.Mesh.construct_triangles(pts, indices)