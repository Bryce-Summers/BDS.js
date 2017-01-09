###

Circle Class
Written by Bryce Summers on 1 - 6 - 2017.

###

class BDS.Circle

    # BDS.Point, float
    constructor: (@_center, @_radius, @filled) ->
        if @filled == undefined
            @filled = false

        ###
        @_boundingbox, stored the bounding box.
        ###

    isFilled: () -> @filled

    setPosition: (x, y) ->
        @_center.x = x
        @_center.y = y

    getPosition: () -> @_center.clone()

    getRadius: () -> @_radius

    #detect_intersection_with_ray: (ray) ->

    # Returns the minnimum positive time that this circle intersects the given ray.
    # BDS.Ray -> float or null if their is no intersection.
    minnimum_time_of_intersection_with_ray: (ray) ->

        # BDS.Point's
        o = ray.getPoint()
        l = ray.getDirection()
        
        # BDS.Point.        
        o_sub_c = o.sub(@_center)

        # floats.
        o_sub_c_sqr = o_sub_c.dot(o_sub_c)

        # If the circle is filled, then their is a collision immediatly if the ray originates within the circle.
        return 0 if @filled and Math.sqrt(o_sub_c_sqr) < @_radius

        loc = o_sub_c.dot(l);# Projection. l needs to be normalized.
        det_sqr = loc*loc - o_sub_c_sqr + @_radius*@_radius

        # No intersection.
        return null if (det_sqr < 0)
        
        # float       
        det = Math.sqrt(det_sqr)

        #Compute the two solutions to the quadratic formula.
        # float's
        time1 = -loc + det
        time2 = -loc - det

        # Try the lesser solution first.
        return time2 if (time2 > 0)
        return time1 if (time1 > 0)

        # All intersections are on the line, but not the ray.
        return null

    
    #detect_intersection with line segment
    detect_intersection_with_line: (line) ->

        in1 = @containsPoint(line.p1)
        in2 = @containsPoint(line.p1)

        # Filled, intersection if either point is in the circle.
        return true if @filled and (in1 or in2)

        # in1 xor in2
        return (in1 and not in2) or
               (not in1 and in2)

    # BDS.Point
    containsPoint: (pt) ->

        diff = pt.sub(@_center)
        dist = diff.norm()
        return dist < @_radius

    generateBoundingBox: () ->

        @_boundingbox = new BDS.Box()

        min    = @_center.clone()
        min.x -= @_radius
        min.y -= @_radius

        max    = @_center.clone()
        max.x += @_radius
        max.y += @_radius

        @_boundingbox.expandByPoint(min)
        @_boundingbox.expandByPoint(max)

        return @_boundingbox

    getBoundingBox: () ->
        return @_boundingbox