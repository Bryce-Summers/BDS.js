#
# 3D Axis Aliged Bounding Volume Hiearchy.
# Adapted by Bryce Summers on July.21.2017 from 2D version, BDS.BVH2D
# Adapted in earnest       on July.23.2017
#
# Work only with BDS.Triangle objects, FIXME: Support Quads if ever practical.
#
# Purpose: This set partitioning structure may be used to speed up
#          certain geometric queries, such as:
#        - ray - triangle mesh intersection.
#        - Point inside manifold mesh test.
#        - 3D Collision detection.
#
# FIXME: Implement Tree rebalancing functions: optimize () ->

class BDS.BVH3D extends BDS.RayQueryable

    @MAX_OBJECTS_PER_LEAF = 4

    # FIXME:  Use minnimizing axis, stop using x, y, and z.
    # INPUT:  BDS.Triangle, {val: 'x', 'y', 'z'}
    # ASSUMPTION: triangles have been allocated for the exclusive use of this BVH class.
    # Triangles will contain pointers to the external data nodes that they represent.
    # In other words, these triangles represent collision geometry, which will be translated
    # back to application specific objects upon successful queries.
    constructor: (triangles, xyz) ->

        if not triangles
            triangles = []

        if not xyz
            xyz = {val: 'x'}

        # Array of THREE.mesh objects.
        @_leafs = []
        @_leaf_node = false
        @_size = triangles.length

        # Ensure that all of these triangles have bounding boxes.
        @_ensure_bounding_boxes(triangles)
        @_AABB = @_compute_AABB(triangles)

        # Base case, less than 4 triangles get put into a collection of leaf nodes.
        if triangles.length < BDS.BVH3D.MAX_OBJECTS_PER_LEAF
            @_leaf_node = true
            @_leafs = []
            for i in [0...triangles.length]
                @_leafs.push(triangles[i])
            return

        triangles = @_sort_triangle_list(triangles, xyz)
        [left_partition, right_partition] = @_partition_by_SA(triangles)

        xyz.val = @_nextXYZ(xyz)
        @_left  = new BDS.BVH3D(left_partition,  xyz)
        @_right = new BDS.BVH3D(right_partition, xyz)

    toBoundingBox: () ->
        return @_AABB.clone()

    # Used in things like tree compression and rebalancing.
    # BDS.BVH3D -> copies all fields into this node.
    _copy_from: (bvh) ->
        @_leaf_node = bvh._leaf_node
        @_size      = bvh._size
        @_AABB      = bvh._AABB
        @_leafs     = bvh._leafs
        @_left      = bvh._left
        @_right     = bvh._right

    ###
     - Private Construction Methods. -----------------------
    ###

    # INPUT: BDS.Triangle[]
    # OUTPUT: Sorted list by centroid x, y, or z position.
    _sort_triangle_list: (triangle_list, xyz) ->

        # List of {.centroid, .index} objects.
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

        
        switch xyz.val
            when 'x' then return 'y'
            when 'y' then return 'z'
            when 'z' then return 'x'
        debugger
        console.log("xyz is malformed.")

        debugger
        console.log("Case not handled.")


    # Converts a triangle list into a list of
    # {.centroid, .index} objects.
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
        
        return triangle.computeCentroid()


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
        for i in [i0..1] #[len-1, 1] 2 dots imply inclusive of 0.
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

    # Ensures that all triangles have a current valid Bounding Box.
    _ensure_bounding_boxes: (triangle_list) ->
        
        for triangle in triangle_list
            # Generate is used instead of ensure, because the triangles are assumed to be 
            # dedicated bvh geometries without pre-allocated bounding boxes.
            triangle.generateBoundingBox()

    # INPUT: BDS.Triangle[]
    # OUTPUT: BDS.Box minnimally bounding the given set of triangles.
    _compute_AABB: (triangle_list) ->

        # BDS.Box
        output = new BDS.Box()

        for i in [0...triangle_list.length]
            triangle = triangle_list[i]
            AABB = triangle.getBoundingBox()
            output = output.union(AABB)

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

        return sxy + sxz + syz # Note: There is not need to multiply this by 2 for a heuristic measure.


    ###

    Modification functions.
     - add and remove triangles,
     - optimize: rebalance the bvh tree to ensure quick query times.
    
    Future:
     - union, merge two bvh trees, this may deffer or speed up construction time.
     - intersection
     - difference
    ###

    # BVH dynamic editing functions.
    # Optimizes the bvh by rebalancing the tree.
    optimize: () ->
        # FIXME: Rebalance the tree.

    # Adds the given polyline to the bvh.
    add: (polyline) ->

        polyline.ensureBoundingBox()

        # BASE CASE:
        # Add the polyline to a leaf node.
        if @_leaf_node
            @_leafs.push(polyline)
            @_AABB = @_AABB.union(polyline.getBoundingBox())
            @_size++
            return
        
        # Compute the potential bounding boxes that this polyline will create.
        potential_bb_left  = @_left._AABB.union(polyline.getBoundingBox())
        potential_bb_right = @_right._AABB.union(polyline.getBoundingBox())

        # Determine which side the polyline may enter that will create the smallest disturbance.
        sa_diff_left  = @_compute_SA(potential_bb_left)  - @_compute_SA(@_left._AABB)
        sa_diff_right = @_compute_SA(potential_bb_right) - @_compute_SA(@_right._AABB)

        # Recursion.
        if sa_diff_left < sa_diff_right
            @_left.add(polyline)
        else
            @_right.add(polyline)

        # Update the bounding box for this node.
        @_AABB = @_left._AABB.union(@_right._AABB)

        # Update the size variable.
        @_size++

        return

    # Removes the given polyline from the bvh.
    # BDS.Polyline -> bool
    # Return indicates whether the polyline has been successfully removed.
    remove: (polyline) ->

        polyline.ensureBoundingBox()
        polyline_bb = polyline.getBoundingBox()

        # Skip this branch, because the polyline is not in its bounding box.
        if not polyline_bb.intersects_box(@_AABB)
            return false

        # BASE CASE:
        # Add the polyline to a leaf node.
        if @_leaf_node

            # Rebuild this leaf node, shirinking it to not include the removed polyline.
            @_AABB = new BDS.Box()

            old_lines = @_leafs
            @_leafs = []

            removed = false

            for old_line in old_lines

                # Don't add the polyline to be removed.
                if polyline == old_line
                    removed = true
                    @_size-- # Decrease this node's size.
                    continue

                @_AABB = @_AABB.union(old_line.getBoundingBox())
                @_leafs.push(old_line)

            return removed

        # Try left.
        removed = @_left.remove(polyline)

        # Try right, if necessary.
        removed = @_right.remove(polyline) if not removed

        # No change.
        if not removed
            return false


        # From here on out, we assume that a polyline has been removed.


        # Reduce this node's size.
        @_size--

        # Both left and right are depleted.
        # This could happen if this is the root of the tree and the very last object has been removed.
        if @_size == 0
            @_leaf_node = true
            @_leafs = []
            @_left  = undefined
            @_right = undefined
            return removed
            
        # Left node is depleted, compress the right branch onto this node.
        if @_left._size == 0
            # Compress the right branch onto this node.
            @_copy_from(@_right)

            # Note: after this point this could now be a leaf node.
            return true

        # right node is depleted, compress the left branch onto this node.
        if @_right._size == 0
            
            @_copy_from(@_left)

            # Note: after this point this could now be a leaf node.
            return true

        # If neither branch is depleted, then we update this parent node's bounding box.
        @_AABB = @_left._AABB.union(@_right._AABB)

        return true

    ###

    Geometric Queries,
        the point of the BVH3D data structure is to make these queries as fast as possible.
        all queries return one of the BVH's triangles, representing collision geometry, which may then have associated data.

     -- Ray queries, ray's can start anywhere, even inside of a box and head off in any direction.

     - rayQueryMin(rQ), rQ will contain the first triangle that this ray intersects,
       returns true iff a triangle was found.
     - rayQueryAll(rQ), rQ will contain all of the triangles that this ray intersects.
       returns true iff a triangle was found.

    Future: These function can be used without disrubing the rQ's isect object values.
        and when simple queries such as determining the number of isects for pt in/out is all that is needed.
     - rayQueryTime(rq), rQ will contain .time with the nearest intersection time
       returns true iff an intersection was found.
     - rayQueryTimes(rQ), rQ will contain .times[] with all of the intersection times.
       return true iff at least 1 intersection was found.

    Future
     - query_box_all, returns all triangles with bounding boxes intersecting a given box.
    ###


    # BDS.Ray_Query -> BDS.Triangle
    # OUTPUT: Nearest Intersection Triangle,
    # Null if no closer triangle was found than the 1 if any in the rayQuery.
    # rayQuery is updated with useful information.
    # This method is called recursively.
    # External call should contain a fresh initialized rayQuery.
    rayQueryMin: (rayQuery) ->

        # Check leaf nodes, narrow-phase collision detection.
        if @_leaf_node
            found = false
            for triangle in @_leafs

                if triangle.rayQueryMin(rayQuery)
                    found = true

            return found # null or a triangle.

        # Check children.
        left_AABB  = @_left._AABB
        right_AABB = @_right._AABB

        # We check AABB's precall to avoid duplicated checks.
        # This means that the root node doesn't get checked, 
        # but this will result in at most 1 extra check for rays that miss the entire bounding volume hiearchy.

        min_time = rayQuery.min_time

        # Default values for no intersection.
        enter_left  = Number.MAX_VALUE
        enter_right = Number.MAX_VALUE

        # find the entrance and exit times for the bvh's
        # QueryTime, rather than QueryMin checks aabb without 
        # disturbing the triangle return value.
        if left_AABB.rayQueryTime(rayQuery)
            enter_left = rayQuery.time

        if right_AABB.rayQueryTime(rayQuery)
            enter_right = rayQuery.time


        # -- Broad-phase collision detection, try to prune branches.

        # Min time is before this branch.
        return false if min_time < enter_left and min_time < enter_right

        # Prune right branch.
        if min_time < enter_right
            return @_left.rayQueryMin(rayQuery) # Recursion.

        # Prune left branch.
        if min_time < enter_left
            return @_right.rayQueryMin(rayQuery) # Recursion.

        # Sort nodes and transverse from closer to furthest.
        if enter_left < enter_right
            near_node = @_left
            far_node  = @_right
            enter_near = enter_left
            enter_far  = enter_right
        else
            # Swap.
            near_node  = @_right
            far_node   = @_left
            enter_near = enter_right
            enter_far  = enter_left


        # Search near.
        found_near = false
        if near_node.rayQueryMin(rayQuery)
            found_near = true

            # prune far node if it is further than
            if rayQuery.min_time < enter_far
                return true

        # Search far.
        if far_node.rayQueryMin(rayQuery) # Recursion.
            return true

        # if we didn't find a minnimal intersection in far.
        # we return whether we found an intersection in near.
        return found_near

    #rayQueryAll(rQ), rQ will contain all of the triangles that this ray intersects.
    #OUTPUT: true iff a triangle was found, rayQuery stores all intersections and times.
    rayQueryAll: (rayQuery) ->
        
        # Check leaf nodes, narrow-phase collision detection.
        if @_leaf_node
            found = false
            for triangle in @_leafs

                if triangle.rayQueryAll(rayQuery)
                    found = true

            return found # null or a triangle.

        # Broad-phase collision detection,
    
        # Early out if ray doesn't intersect this AABB.
        if not @_AABB.rayQueryTimes(rayQuery)# times, to save on unneccesary minimization.
            return false

        found = false
        if @_left.rayQueryAll(rayQuery)
            found = true
        if @_right.rayQueryAll(rayQuery)
            found = true

        return found

    # Returns all BDS.polylines that intersect the given box.
    # output_list is optional.
    query_box_all: (query_box, output_list) ->
        console.log("BDS.BVH3D: query_box_all, not yet implemented.")