###
Polyline class (also represents polygons)

Written by Bryce Summers on 1 - 4 - 2017.

Note: Closed Polylines are polygons...
 - So we will put all of our polygon code into this class.

###

class BDS.Polyline

    # FIXME: Maybe I should use BDS.Point_info's instead.
    # BDS.Point[], bool
    constructor: (@_isClosed, points_in) ->
        if @_isClosed == undefined
            @_isClosed = false

        @_points = []

        if points_in
            @appendPoints(points_in)

        ###
        # These are commented out to save memory for applications that don't need these.
        @_boundingbox = null
        @_lineBVH = null
        @_obj # Associated Obj.
        ###

    appendPoints: (array) ->

        for p in array
            @addPoint(p)

        return

    addPoint: (p) ->
        @_points.push(p)
        return

    removeLastPoint: () ->
        return @_points.pop()


    getPoint: (index) ->
        return @_points[index]

    size: () ->
        return @_points.length

    isClosed: () ->
        return @_isClosed

    ###
    * http://math.blogoverflow.com/2014/06/04/greens-theorem-and-area-of-polygons/
    * Computes the area of a 2D polygon directly from the polygon's coordinates.
    * The area will be positive or negative depending on the
    * clockwise / counter clockwise orientation of the points.
    * Also see: https://brycesummers.wordpress.com/2015/08/24/a-proof-of-simple-polygonal-area-via-greens-theorem/
    * Note: This function interprets this polyline as closed.
    #  -> float
    ###
    computeArea: () ->

        len = @_points.length
        p1  = @_points[len - 1]

        area = 0.0

        # Compute based on Green's Theorem.
        for i in [0...len] by 1
        
            p2 = @_points[i]
            area += (p2.x + p1.x)*(p2.y - p1.y)
            p1 = p2 #/ Shift p2 to p1.

        return area / 2.0

    # -> bool
    isComplemented: () -> 
        
        return@computeArea() > 0

    generateBoundingBox: (polygon) ->
        @_boundingbox = new BDS.Box()

        len = polygon.size()
        for i in [0...len]
            pt = polygon.getPoint(i)
            @_boundingbox.expandByPoint(pt)

        return @_boundingbox

    getBoundingBox: () -> @_boundingbox

    # Generates a BVH for this polyline.
    # () -> BDS.BVH2D
    generateBVH: () ->
        segments = @toPolylineSegments();
        @_lineBVH = new BDS.BVH2(segments);

    setAssociatedData: (obj) ->
        @_obj = obj

    getAssociatedData: () ->
        return @_obj

    ###
    getBVH: () ->
        return @_lineBVH()
    ###

    # Returns a list of Polylines, representing all of this polyline's line segments.
    toPolylineSegments: () ->
        output = []

        len = @_points.length
        for i in [0...len - 1]
            p0 = @_points[i]
            p1 = @_points[i + 1]
            output.push(new BDS.Polyline(false, [p0, p1]))

        # Add the last point.
        if @_isClosed
            p0 = @_points[len - 1]
            p1 = @_points[0]
            output.push(new BDS.Polyline(false, [p0, p1]))

        return output

    # Returns a list of line segments for intersection tests.
    _toLineSegments: () ->
        output = []

        len = @_points.length
        for i in [0...len - 1]
            output.push(new BDS.Line(i, i + 1, @_points))

        # Add the last point.
        if @_isClosed
            output.push(new BDS.Line(len - 1, 0, @_points))

        return output

    # Performs a point in Polygon test.
    # Assumes this is a closed polygon.
    # Accelerates this query using the polyline's bvh if present.
    # BDS.Point -> bool
    containsPoint: (pt) ->

        # E[O(log(n))]
        if @_lineBVH
            throw new ERROR("Implement me Please!")
        else
            # O(n).
            return @_point_in_polygon_test(pt)
    
    _point_in_polygon_test: (pt) ->
        
        ray = new BDS.Ray(pt, BDS.newDirection(1.0, 0))


        # A Point is inside of a polygon if an arbitrary ray,
        # originating at that point crosses the boundary an even number of times.
        odd = false

        #count = 0

        segments = @_toLineSegments()
        for segment in segments

            if ray.detect_intersection_with_line(segment)
                odd = not odd
                #count++

        return odd