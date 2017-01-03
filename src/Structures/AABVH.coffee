#
# Axis Aliged Bounding Volume Hiearchy.
# Written by Bryce Summers on 12/6/2016.
#
# Purpose: This set partitioning structure may be used to speed up
#          certain geometric queries, such as collisions between polygonal
#          objects and point scene intersection queries.
#          If may also be used to rapidly detect non-collisions.
#
# FIXME: Instead of using Mesh lists, I think that I should use triangle lists.
# FIXME: I should probably commit to making this a 2D AABB, and bumb it up to 3D later if needed.
#
# Note: I've decided to make this a 2D BVH supporting class only.
#

class TSAG.S_AABVH

    # Contructed from the tree rooted at the given THREE.Object3D node.
    # Obj can alternatively be a list of Triangles with pointers to their mesh objects.
    # xyz = {val: 'x', 'y', or 'z', dim = 2 or 3}
    # FIXME: In hindsite, this xyz thing is silly, since we should just use the minnimizing axis.
    constructor: (obj, xyz) ->
       
        # Array of THREE.mesh objects.
        @_leafs = []
        @_leaf_node = false

        if obj instanceof THREE.Object3D
            triangle_list       = @_extract_triangle_list(obj)
        else
            triangle_list = obj

        # Ensure that all of these triangles have bounding boxes.
        @_ensure_bounding_boxes(triangle_list)
        @_AABB = @_compute_AABB(triangle_list)

        # Base case, less than 4 triangles get put into a collection of leaf nodes.
        if triangle_list.length < 100
            @_leaf_node = true
            for i in [0...triangle_list.length]
                @_leafs.push(triangle_list[i])
            return

        if xyz.dim == 2
            @_AABB.min.z = -1
            @_AABB.max.z = +1

        triangle_list = @_sort_triangle_list(triangle_list, xyz)
        [left_partition, right_partition] = @_partition_by_SA(triangle_list)

        xyz.val = @_nextXYZ(xyz)
        @_left  = new TSAG.S_AABVH(left_partition,  xyz)
        @_right = new TSAG.S_AABVH(right_partition, xyz)

    # returns the Triangle T at the given location on the 2D plane.
    # T.mesh returns the mesh. T.model returns the M_xxx object representing information for this particular triangle.
    # T.mesh.element returns the E_xxx element object.
    # returns null otherwise.
    # It is advisable that any meshes used for queries be used with ways of getting
    # to the classes that you are interested in, such as a @model attribute.
    query_point: (x, y) ->
        ray = new THREE.Ray(new THREE.Vector3(x, y, 10), new THREE.Vector3(0, 0, 1))
        return @query_ray(ray)

    query_ray: (ray) ->

        if ray.intersectsBox(@_AABB) == null
            return null

        if @_leaf_node
            for i in [0...@_leafs.length]
                triangle = @_leafs[i]
                a = triangle.a
                b = triangle.b
                c = triangle.c

                # No backface culling.
                intersection = ray.intersectTriangle(a, b, c, false)
                if intersection != null
                    return triangle
        else
            output = @_left.query_ray(ray)
            if output != null then return output

            output = @_right.query_ray(ray)
            if output != null then return output

        # No Intersection.
        return null

    # Returns a list of THREE.js renderable meshes.
    toVisual : (material) ->

        # Create a list of all line goemetries.
        geometries = []
        @get_AABB_geometries(geometries)

        output = new THREE.Object3D();
        for geom in geometries
            line = new THREE.Line( geom, material )
            output.add(line)

        return output
        

    # Appends to the given list Line Geometries representing the all of the bounding boxes for this AABB hierarchy.
    get_AABB_geometries : (output) ->

        # First create a geometry for this node's box.
        min = @_AABB.min
        max = @_AABB.max

        min_x = min.x
        min_y = min.y

        max_x = max.x
        max_y = max.y

        geometry = new THREE.Geometry();
        geometry.vertices.push(
            new THREE.Vector3( min_x, min_y, 0 ),
            new THREE.Vector3( max_x, min_y, 0 ),
            new THREE.Vector3( max_x, max_y, 0 ),
            new THREE.Vector3( min_x, max_y, 0 ),
            new THREE.Vector3( min_x, min_y, 0 ) # Closure.
        )

        output.push(geometry)

        # If we are not a leaf node, add left and right child nodes.
        if not @_leaf_node
            @_left.get_AABB_geometries(output)
            @_right.get_AABB_geometries(output)

        return


    ###
     - Private Construction Methods. -----------------------
    ###

    # converts a THREE.Object3D into a list of Triangle objects with pointers to their mesh objects.
    _extract_triangle_list: (obj) ->
        mesh_list = @_extract_mesh_list(obj)
        triangle_list = []

        for mesh in mesh_list
            geometry = mesh.geometry
            vertices = geometry.vertices
            faces    = geometry.faces

            # Matrix Transform form local meshes to world positions.
            localToWorld = mesh.matrixWorld

            for face in faces
                a = vertices[face.a].clone()
                b = vertices[face.b].clone()
                c = vertices[face.c].clone()

                a.applyMatrix4(localToWorld)
                b.applyMatrix4(localToWorld)
                c.applyMatrix4(localToWorld)

                triangle = new THREE.Triangle(a, b, c)

                # Set a pointer to this triangle's mesh.
                triangle.mesh = mesh

                triangle_list.push(triangle)

        return triangle_list


    # Converts a THREE.Object3D into a list of Mesh objects.
    _extract_mesh_list: (obj) ->
        
        output = []

        add_output =
            (o) -> if o.geometry then output.push(o)

        obj.traverse(add_output)

        return output

    # Sorts the given triangle list by centroid x position.
    _sort_triangle_list: (triangle_list, xyz) ->
        centroid_index_list = @_centroid_index_list(triangle_list)

        sort_function = 
            (a, b) ->
                switch xyz.val
                    when 'x' then return a.centroid.x - b.centroid.x
                    when 'y' then return a.centroid.y - b.centroid.y
                    when 'z' then return a.centroid.z - b.centroid.z
                debugger
                console.log("xyz is malformed.")

        centroid_index_list.sort(sort_function)

        output = []
        len = triangle_list.length
        for i in [0...len]
            triangle_index = centroid_index_list[i].index
            output.push(triangle_list[triangle_index])

        return output

    _nextXYZ: (xyz) ->

        if xyz.dim == 2
            switch xyz.val
                when 'x' then return 'y'
                when 'y' then return 'x'
                when 'z' then console.log("xyz is malformed.")
            debugger
            console.log("xyz is malformed.")

        else if xyz.dim == 3
            switch xyz
                when 'x' then return 'y'
                when 'y' then return 'z'
                when 'z' then return 'x'

        debugger
        console.log("Case not handled.")


    # Converts a triangle list into a centroid node list that contains indices.
    _centroid_index_list: (triangle_list) ->
        output = []
        len = triangle_list.length
        for i in [0...len]
            centroid_index_node = {}
            centroid_index_node.index = i
            centroid_index_node.centroid = @_computeCentroid(triangle_list[i])
            output.push(centroid_index_node)

        return output

    # Computes the centroid of the the vertices in the given THREE.js geometry.
    _computeCentroid: (triangle) ->
        centroid = new THREE.Vector3(0, 0, 0)

        centroid.add(triangle.a)
        centroid.add(triangle.b)
        centroid.add(triangle.c)

        centroid.divideScalar(3)

        return centroid


    # Returns [left_AABB, right_AABB],
    # where the split is detemined by minimizing the surface area heuristic.
    # ASSUMPTION: mesh_list.length >= 1
    _partition_by_SA: (triangle_list) ->
        
        # Declare minnimization values.
        # We are going to minimize the maximum surface area.
        min_sah   = Number.MAX_VALUE
        min_index = -1


        # Left starts out including the 1st item.
        left = [triangle_list[0]]

        # We populate the right partition in backwards order,
        # so that we can sequentially pop/push items to the left.
        # This saves us array movement time.
        right = []
        i0 = triangle_list.length - 1
        for i in [i0..1] #2 dots imply inclusive of 0.
            right.push(triangle_list[i])

        for i in [1..i0] # [1, len-1] All possible partitions.
            left_AABB = @_compute_AABB(left)
            sah_left  = @_compute_SA(left_AABB)

            right_AABB = @_compute_AABB(right)
            sah_right  = @_compute_SA(right_AABB)

            sah = Math.max(sah_left, sah_right)

            if sah < min_sah
                min_sah   = sah
                min_index = i

            # Iterate partition choice.
            left.push(right.pop())

        # Now we will populate to the minnimum partition.
        # ASSUMPTION: min_index >= 1
        left  = []
        right = []

        for i in [0...min_index] # [0,min_index)
            left.push(triangle_list[i])
        for i in [min_index..i0] # [min_index, len]
            right.push(triangle_list[i])

        return [left, right]

    # Ensures that all meshes have valid computed bounding boxes.
    _ensure_bounding_boxes: (triangle_list) ->
        
        len = triangle_list.length
        for i in [0...len]
            triangle = triangle_list[i]

            if not triangle
                debugger

            if not triangle.boundingBox
                @_computeBoundingBox(triangle)

    _computeBoundingBox: (triangle) ->
        AABB = new THREE.Box3()

        AABB.expandByPoint(triangle.a)
        AABB.expandByPoint(triangle.b)
        AABB.expandByPoint(triangle.c)

        triangle.boundingBox = AABB

    # Computes the axis aligned bounding box minnimally bounding the given
    # list of meshes.
    # Output will be represented by {min: THREE.Vector3, max: THREE.Vector3}
    _compute_AABB: (triangle_list) ->

        # THREE.Box3
        output = new THREE.Box3()

        for i in [0...triangle_list.length]
            triangle     = triangle_list[i]
            AABB = triangle.boundingBox
            output.union(AABB)

        return output

    # Returns the surface area for the given bounding box.
    _compute_SA: (AABB) ->
        min = AABB.min
        max = AABB.max

        dx = max.x - min.x
        dy = max.y - min.y
        dz = max.z - min.z

        sxy = dx*dy
        sxz = dx*dz
        syz = dy*dz

        return sxy + sxz + syz
