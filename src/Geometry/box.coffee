###
Box.

Written by Bryce Summers on 1 - 5 - 2017
###

class BDS.Box

    # BDS.Point, BDS.Point, bool
    constructor : (@min, @max, @isClosed) ->

        if not @min
            @min = new BDS.Point(Number.MAX_VALUE, Number.MAX_VALUE, Number.MAX_VALUE)

        if not @max
            @max = new BDS.Point(Number.MIN_VALUE, Number.MIN_VALUE, Number.MIN_VALUE)

        # Whether the box contains its area or not.
        if not @isClosed
            @isClosed = true

    clone: () ->
        return new BDS.Box(@min.clone(), @max.clone())

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

    intersects_box: (box) ->
        intersection = @intersect(box)

        # Intersection exists if the intersection has a positive area.
        return intersection.area() > 0