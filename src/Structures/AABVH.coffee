#
# 2D Axis Aliged Bounding Volume Hiearchy.
# Written by Bryce Summers on 12/6/2016.
# Adapted, simplified, and improved by Bryce on 1 - 5 - 2017.
#
# Purpose: This set partitioning structure may be used to speed up
#          certain geometric queries, such as collisions between polygonal
#          objects and point scene intersection queries.
#          If may also be used to rapidly detect non-collisions.
#

class BDS.BVH2D

    # Contructed from the tree rooted at the given THREE.Object3D node.
    # polygons is a BDS.Polyline()
    # xy = {val: 'x' or 'y'}
    # FIXME: In hindsite, this xyz thing is silly, since we should just use the minnimizing axis.
    constructor: (polygons, xy) ->

        if not xy
            xy = {val: 'x'}

        # Array of THREE.mesh objects.
        #@_leafs = []
        @_leaf_node = false

        # Ensure that all of these polygons have bounding boxes.
        @_ensure_bounding_boxes(polygons)
        @_AABB = @_compute_AABB(polygons)

        # Base case, less than 4 polygons get put into a collection of leaf nodes.
        if polygons.length < 4
            @_leaf_node = true
            @_leafs = []
            for i in [0...polygons.length]
                @_leafs.push(polygons[i])
            return

        if xy.dim == 2
            @_AABB.min.z = -1
            @_AABB.max.z = +1

        polygons = @_sort_polygon_list(polygons, xy)
        [left_partition, right_partition] = @_partition_by_SA(polygons)

        xy.val = @_nextXY(xy)
        @_left  = new BDS.BVH2D(left_partition,  xy)
        @_right = new BDS.BVH2D(right_partition, xy)

    ###
     - Private Construction Methods. -----------------------
    ###

    # Sorts the given polygon list by centroid x position.
    _sort_polygon_list: (polygon_list, xy) ->
        centroid_index_list = @_centroid_index_list(polygon_list)

        sort_function = 
            (a, b) ->
                switch xy.val
                    when 'x' then return a.centroid.x - b.centroid.x
                    when 'y' then return a.centroid.y - b.centroid.y
                debugger
                console.log("xy is malformed.")

        centroid_index_list.sort(sort_function)

        output = []
        len = polygon_list.length
        for i in [0...len]
            polygon_index = centroid_index_list[i].index
            output.push(polygon_list[polygon_index])

        return output

    _nextXY: (xy) ->

        
        switch xy.val
            when 'x' then return 'y'
            when 'y' then return 'x'
        debugger
        console.log("xy is malformed.")

        debugger
        console.log("Case not handled.")


    # Converts a polygon list into a centroid node list that contains indices.
    _centroid_index_list: (polygon_list) ->
        output = []
        len = polygon_list.length
        for i in [0...len]
            centroid_index_node = {}
            centroid_index_node.index = i
            centroid_index_node.centroid = @_computeCentroid(polygon_list[i])
            output.push(centroid_index_node)

        return output

    # Computes the centroid of the the vertices in the given THREE.js geometry.
    _computeCentroid: (polygon) ->
        centroid = new BDS.Point(0, 0)

        len = polygon.size()
        for i in [0...len]
            point = polygon.getPoint(i)
            centroid = centroid.add(point)

        return centroid.divScalar(len)


    # Returns [left_AABB, right_AABB],
    # where the split is detemined by minimizing the surface area heuristic.
    # ASSUMPTION: mesh_list.length >= 1
    _partition_by_SA: (polygon_list) ->
        
        # Declare minnimization values.
        # We are going to minimize the maximum surface area.
        min_sah   = Number.MAX_VALUE
        min_index = -1


        # Left starts out including the 1st item.
        left = [polygon_list[0]]

        # We populate the right partition in backwards order,
        # so that we can sequentially pop/push items to the left.
        # This saves us array movement time.
        right = []
        i0 = polygon_list.length - 1
        for i in [i0..1] #2 dots imply inclusive of 0.
            right.push(polygon_list[i])

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
            left.push(polygon_list[i])
        for i in [min_index..i0] # [min_index, len]
            right.push(polygon_list[i])

        return [left, right]

    # Ensures that all polygons have a current valide Bounding Box.
    _ensure_bounding_boxes: (polygon_list) ->
        
        for polygon in polygon_list
            polygon.generateBoundingBox()

    # Computes the axis aligned bounding box minnimally bounding the given
    # list of meshes.
    # Output will be represented by {min: THREE.Vector3, max: THREE.Vector3}
    _compute_AABB: (polygon_list) ->

        # BDS.Box
        output = new BDS.Box()

        for i in [0...polygon_list.length]
            polygon = polygon_list[i]
            AABB = polygon.getBoundingBox()
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

    # Returns the first closed polygon that is found.
    # ignores unclosed polylines.
    # returns null otherwise.
    # It is advisable that any meshes used for queries be used with ways of getting
    # to the classes that you are interested in, such as a @model attribute.
    query_point: (pt) ->

        # Check leaf nodes, narrow-phase collision detection.
        if @_leaf_node
            for polygon in @_leafs
                if polygon.isClosed() and polygon.containsPoint(pt)
                    return polygon
            return null

        # Check children.
        if @_AABB.containsPoint(pt)
            result = @_left.query_point(pt)
            return result if result != null

            result = @_right.query_point(pt)
            return result

        # Broad phase no-collision.
        return null

    # returns a list of all closed polygons at the given location on the 2D plane.
    # ignores unclosed polylines.
    # returns null otherwise.
    # It is advisable that any meshes used for queries be used with ways of getting
    # to the classes that you are interested in, such as a @model attribute.
    query_point_all: (pt, output_list) ->

        if output_list == undefined
            output_list = []

        # Check leaf nodes, narrow-phase collision detection.
        if @_leaf_node
            for polygon in @_leafs
                if polygon.isClosed() and polygon.containsPoint(pt)
                    output_list.push(polygon)
            return output_list

        # Check children.
        if @_AABB.containsPoint(pt)
            @_left.query_point_all(pt, output_list)
            @_right.query_point_all(pt, output_list)

        return output_list


    # Returns all BDS.polylines that intersect the given box.
    # output_list is optional.
    query_box_all: (query_box, output_list) ->

        if output_list == undefined
            output_list = []

        if @_leaf_node
            for polygon in @_leafs

                # Output the polygon if it intersects the given box.
                if polygon.detect_intersection_with_box(query_box)
                    output_list.push(polygon)
                continue
            return output_list # Base Case.

        # Check children.
        if @_AABB.intersects_box(query_box)
            @_left.query_box_all(query_box,  output_list)
            @_right.query_box_all(query_box, output_list)

        return  output_list

    # query_circle_all --> reduces to query box all, then filter via narrow pass.

    # Returns a complete list of Polylines, representing the bounding boxes of this Bounding Volume Hiearchy.
    # () -> BDS.Polyline[]
    toPolylines : () ->

        # Create a list of all line geometries.
        polylines = []
        @_toPolylines(polylines)
        return polylines


    # Appends to the given list Line Geometries representing the all of the bounding boxes for this AABB hierarchy.
    _toPolylines : (output) ->

        # First create a geometry for this node's box.
        min = @_AABB.min
        max = @_AABB.max

        min_x = min.x
        min_y = min.y

        max_x = max.x
        max_y = max.y

        p0 = new BDS.Point( min_x, min_y, 0 )
        p1 = new BDS.Point( max_x, min_y, 0 )
        p2 = new BDS.Point( max_x, max_y, 0 )
        p3 = new BDS.Point( min_x, max_y, 0 )

        polyline = new BDS.Polyline(true, [p0, p1, p2, p3])# Closed Polygon.

        output.push(polyline)

        # If we are not a leaf node, add left and right child nodes.
        if not @_leaf_node
            @_left._toPolylines(output)
            @_right._toPolylines(output)

        return