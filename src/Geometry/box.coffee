###
Box.

Written by Bryce Summers on 1 - 5 - 2017
###

class BDS.Box

    # BDS.Point, BDS.Point, bool
    constructor : (@min, @max, @_isFilled) ->

        if not @min
            @min = new BDS.Point(Number.MAX_VALUE, Number.MAX_VALUE, Number.MAX_VALUE)

        if not @max
            @max = new BDS.Point(Number.MIN_VALUE, Number.MIN_VALUE, Number.MIN_VALUE)

        # Whether the box contains its area or not.
        if not @_isFilled
            @_isFilled = true

    clone: () ->
        return new BDS.Box(@min.clone(), @max.clone())

    isFilled: () ->
        return @_isFilled

    expandByPoint: (p) ->

        @min = @min.min(p)
        @max = @max.max(p)

    union: (box) ->
        
        out = @clone()
        out.min = @min.min(box.min)
        out.max = @max.max(box.max)
        return out

    # Returns the intersection of this box and the other box.
    intersect: (box) ->

        out = @clone()
        out.min = @min.max(box.min)
        out.max = @max.min(box.max)
        return out

    containsPoint: (pt) ->

        return pt.greaterThanOrEqual(@min) and pt.lessThanOrEqual(@max)

    getRandomPointInBox: () ->
        range = @max.sub(@min)

        x = @min.x + Math.random()*range.x
        y = @min.y + Math.random()*range.y
        z = @min.z + Math.random()*range.z

        return new BDS.Point(x, y, z)

    area: () ->
        diff = @max.sub(@min)

        area = Math.abs(diff.x*diff.y)

        # Invert area if necessary.
        if diff.x < 0 or diff.y < 0
            area = -area

        return area

    # True iff this box intersects the given box.
    intersects_box: (box) ->
        intersection = @intersect(box)

        # Intersection exists if the intersection has a positive area.
        # Or if we are intersecting a box that acts as an axis aligned line, which would have 0 area.
        return intersection.area() >= 0

    toPolyline: () ->

        p0 = @min.clone()

        p1 = @min.clone()
        p1.x = @max.x

        p2 = @max.clone()

        p3 = @min.clone()
        p3.y = @max.y

        points = [p0, p1, p2, p3]

        # Closed, potentially filled polyline, with the coordinates of this box.
        polyline = new BDS.Polyline(true, points, @_isFilled)
        return polyline

    ###
    Ray Queries
    ###

    # Updates the rayQuery with an intersection with this triangle if found.
    rayQueryMin: (rayQuery) ->

    # Adds to the given rayQuery all intersections and times that are found.
    rayQueryAll: (rayQuery) ->

    # Updates rayQuery.time value if true,
    # true if time found.
    rayQueryTime: (rayQuery) ->

    # Updates rayQuery.times[] value if true,
    # true if at least 1 time is found.
    rayQueryTimes: (rayQuery) ->
