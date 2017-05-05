###
Polyline class (also represents polygons)

Written by Bryce Summers on 1 - 4 - 2017.

Note: Closed Polylines are polygons...
 - So we will put all of our polygon code into this class.

Note: this class assumes that it contains at least 1 point for collision tests.

Note: Polyline <--> polyline intersection tests assume that the polyline is not self intersecting.

FIXME: Return proper point in polyline tests for complemented filled polylines.

###

class BDS.Polyline

    # FIXME: Maybe I should use BDS.Point_info's instead.
    # BDS.Point[], bool
    constructor: (@_isClosed, points_in, @_isFilled) ->
        if @_isClosed == undefined
            @_isClosed = false

        # Stores whether this polyline is really a polygon and contains its inner area.
        if @_isFilled == undefined
            @_isFilled = @_isClosed

        @_points = []

        if points_in
            @appendPoints(points_in)

        ###
        # These are commented out to save memory for applications that don't need these.
        @_boundingbox = null
        @_lineBVH = null
        @_obj # Associated Obj.
        @_times # List of parameter values that associated point for point.
        ###

    ###
    setFilled: (isFilled) ->
        @_isFilled = isFilled
    ###

    clone: () ->
        return new BDS.Polyline(@_isClosed, @_points, @_isFilled)

    appendPoints: (array) ->

        for p in array
            @addPoint(p)

        return

    addPoint: (p) ->

        if isNaN(p.x) or isNaN(p.y) or isNaN(p.z)
            debugger

        @_points.push(p)

        # Expand the bounding box if it is defined.
        if @_boundingbox
            @_boundingbox.expandByPoint(p)

        return

    removeLastPoint: () ->
        return @_points.pop()

    getLastPoint: () ->
        return @_points[@_points.length - 1]

    getLastDirection: () ->
        return @_points[@_points.length - 2].directionTo(@_points[@_points.length - 1])

    getFirstDirection: () ->
        return @_points[1].directionTo(@_points[0])

    getFirstPoint: () ->
        return @_points[0]

    getPoint: (index) ->
        return @_points[index]

    size: () ->
        return @_points.length

    isClosed: () ->
        return @_isClosed

    isFilled: () ->
        return @_isFilled

    computeLength: () ->

        out = 0.0

        for i in [0...(@_points.length - 1)]
            p0 = @_points[i]
            p1 = @_points[i + 1]

            out += p0.distanceTo(p1)
        return out


    getLastSegmentDistance: () ->
        len = @_points.length

        # No distance for no segment.
        if len < 2
            return 0

        p1 = @_points[len - 2]
        p2 = @_points[len - 1]

        return p1.distanceTo(p2)

    # Assumes points.length > 1
    getLastSegmentDirection: () ->

        len = @_points.length

        if len <= 1
            throw new Error("Don't ever call this function when polyline.size() <= 1")

        p1 = @_points[len - 2]
        p2 = @_points[len - 1]

        return p1.directionTo(p2)

    # Returns the last segment of this polyline.
    getLastSegment: () ->
        
        len = @_points.length

        if len <= 1
            throw new Error("Don't ever call this function when polyline.size() <= 1")

        p1 = @_points[len - 2]
        p2 = @_points[len - 1]

        return new BDS.Polyline(false, [p1, p2])

    computeCumulativeLengths: () ->

        # Cumulative summation.
        sum = 0.0
        out = [] # partial length outputs.
        out.push(sum)

        for i in [0...(@_points.length - 1)] by 1
            p0 = @_points[i]
            p1 = @_points[i + 1]

            sum += p0.distanceTo(p1)
            out.push(sum)

        return out

    # Returns float[], where the ith entry is the direction of the segment
    # from point i to i + 1.
    # output is of length |points| - 1
    computeTangentAngles: () ->

        out = []

        for i in [0...(@_points.length - 1)] by 1
            p0 = @_points[i]
            p1 = @_points[i + 1]

            angle = Math.atan2(p1.y - p0.y, p1.x - p0.x)
            out.push(angle)
        return out

    # Returns a |point - 1| length list of unit tangent vectors starting at each point.
    computeUnitTangents: () ->

        out = []

        for i in [0...@_points.length - 1] by 1
            p0 = @_points[i]
            p1 = @_points[i + 1]

            tangent = p1.sub(p0).normalize()
            out.push(tangent)

        return out

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

        return -area / 2.0

    # -> bool
    isComplemented: () -> 
        
        return @computeArea() <= 0.0000001

    ensureBoundingBox: () ->
        if @_boundingbox == undefined
            @generateBoundingBox()

        return @_boundingbox

    generateBoundingBox: (polygon) ->
        @_boundingbox = new BDS.Box()

        for pt in @_points
            @_boundingbox.expandByPoint(pt)
            if isNaN(@_boundingbox.min.x)
                debugger

        return @_boundingbox

    getBoundingBox: () -> @_boundingbox


    setAssociatedData: (obj) ->
        @_obj = obj
        return

    getAssociatedData: () ->
        return @_obj

    # Associates a list of times with each point on this polyline.
    setTimes: (times) ->
        if times.length != @_points.length
            debugger
            err = new Error()
            console.log(err.stacktrace())
            throw err

        @_times = times

    getTimes: (times) ->
        return @_times

    ###
    getBVH: () ->
        return @_lineBVH()
    ###

    # Returns a list of Polylines, representing all of this polyline's line segments.
    # Returns them in halfedge order, with each segment is stored at the same index as its originating point.
    # output array is optional.
    toPolylineSegments: (output) ->
        
        if output == undefined
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

        # First we copy the points array.
        points = @_points.slice(0)

        len = points.length
        for i in [0...len - 1] by 1
            line = new BDS.Line(i, i + 1, points)
            line.p1_index
            line.p2_index
            output.push(line)

        # Add the last point.
        if @_isClosed
            line = new BDS.Line(len - 1, 0, points)
            line.p1_index
            line.p2_index
            output.push(line)

        return output

    toPoints: () ->

        out = []

        for pt in @_points
            out.push(pt)

        return out

    toRays: (output) ->

        if output == undefined
            output = []

        len = @_points.length
        for i in [0...len - 1]
            p0 = @_points[i]
            p1 = @_points[i + 1]
            dir = p1.sub(p0)
            output.push(new BDS.Ray(p0, dir))

        # Add the last point.
        if @_isClosed
            p0 = @_points[len - 1]
            p1 = @_points[0]
            dir = p1.sub(p0)
            output.push(new BDS.Ray(p0, dir))

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

        segments = @_toLineSegments()
        for segment in segments

            if ray.detect_intersection_with_line(segment)
                odd = not odd

        return odd

    detect_intersection_with_box: (box) ->

        # We will want bounding boxes at this point.
        if @_boundingbox == undefined
            @generateBoundingBox()

        # No intersection if the bounding box doesn't intersect the input box.
        if not box.intersects_box(@_boundingbox)
            return false

        # Filled polyline and contains entire box.
        if @isFilled() and @containsPoint(box.min)
            return true

        # Filled box that contains entire polyline.
        if box.isFilled() and box.containsPoint(@_points[0])
            return true

        # No perform a polyline <---> polyline intersection test.
        polyline = box.toPolyline()

        return @detect_intersection_with_polyline(polyline)

    # Returns true iff there is an intersection between a line segment in this polyline
    # and a line segment in the input polyline.
    # We are currently reducing this to line segment set intersection detection. O((smaller + larger)*log(smaller + larger))
    # We may be able to do better if we test the smaller polyline's segments against the larger's bvh. O(smaller*log(larger))
    detect_intersection_with_polyline: (polyline) ->

        # Convert both polylines to line segments.
        lines1 = @_toLineSegments()
        lines2 = polyline._toLineSegments()

        all_lines = lines1.concat(lines2)

        intersector = new BDS.Intersector()

        return intersector.detect_intersection_line_segments_partitioned(all_lines)

    # Returns a list of intersection information objects.
    # {point:point_of_intersection, index:first indice of intersected segment}
    # second indice will be index + 1.
    # Returns the indices within this polyline that the intersections occur.
    report_intersections_with_polyline: (polyline) ->
        
        # Convert both polylines to line segments.
        lines1 = @_toLineSegments()
        lines2 = polyline._toLineSegments()

        all_lines = lines1.concat(lines2)

        intersector = new BDS.Intersector()
        intersector.intersectLineSegments(all_lines)

        out = []

        # Now we read off the intersection locations.
        for i in [0...lines1.length]
            line = lines1[i]
            pts = line.getAllIntersectionPoints()

            # Transcribe locations to data objects.
            for pt in pts
                out_data = {point:pt, index:i}
                out.push(out_data)

        return out

    # Reverses the points.
    reverse: () ->

        temp = []
        len  = @_points.length
        for i in [0...len] by 1
            temp.push(@_points.pop())
        
        @_points = temp

    # Splits this polyline into 2 parts after the given index.
    # [first part will have the given pt at the end,
    #  the second part will have the given pt at the beginning]
    # split_index is optional and will default to 0.
    # Assumes this polyline
    splitPolyline: (pt, split_index) ->

        if split_index == undefined
            split_index = 0

        left  = []
        right = []

        for i in [0..split_index]
            left.push(@_points[i])

        # Push the splitting point to the end of the end of the left partition
        # and the beginning of the right partition.
        left.push(pt)
        right.push(pt)

        for i in [split_index + 1 ...@_points.length]
            right.push(@_points[i])

        left_out  = new Polyline(false, left)
        right_out = new Polyline(false, right)

        return [left_out, right_out]

    @newCircle: (x, y, radius) ->
        pts = []
        for i in [0...Math.PI*2] by Math.PI/100
        
            cx     = x
            cy     = y

            pts.push(new BDS.Point(cx + radius*Math.cos(i), cy + radius*Math.sin(i)))

        return new BDS.Polyline(true, pts, true)

    # {x:, y:, w:, h:}
    @newRectangle: (dim) ->
        pts = []
        pts.push(new BDS.Point(dim.x, dim.y))
        pts.push(new BDS.Point(dim.x + dim.w, dim.y))
        pts.push(new BDS.Point(dim.x + dim.w, dim.y + dim.h))
        pts.push(new BDS.Point(dim.x,         dim.y + dim.h))

        return new BDS.Polyline(true, pts, true)