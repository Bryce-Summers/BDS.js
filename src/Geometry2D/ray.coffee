###
Ray Class.

Written by Bryce Summers on 1 - 6 - 2017.

Purpose: 
###

class BDS.Ray

    # Originating location, the direction the ray is going.
    # And an option time scale factor that may be used in various applications that want to compute intersections over a bounded area
    # or care about the distance a ray has travelled.
    constructor: (point, @dir, @_time_scale) ->

        if @_time_scale == undefined
            # By default, the user probably cares most about the magnitude of the orignal ray.
            @_time_scale = @dir.norm()

            # If we do this then to save time, we compute the normalized direction without recomputing the euclidean norm.
            @dir = @dir.divScalar(@_time_scale)
        else
            @dir = @dir.normalize()

        # Useful data for splitting lines by rays.
        @p1 = point
        @p2 = @p1.add(@dir)


    getPoint: () ->
        return @p1.clone()

    # Gurantted to return a normalized direction vector.
    getDirection: () ->
        return @dir

    # Returns the right Perpendicular.
    getRightPerpendicularDirection: () ->
        return new BDS.Point(-@dir.y, @dir.x, @dir.z)

    getLeftPerpendicularDirection: () ->
        return new BDS.Point(@dir.y, -@dir.x, @dir.z)

    getTimeScale: () ->
        return @_time_scale

    # BDS.Line -> bool
    detect_intersection_with_line: (line) ->

        side1 = @line_side_test(line.p1)
        side2 = @line_side_test(line.p2)

        normal = line.getNormal(@p1)

        # Ray shoots through the line, rather than away form it.
        # the line normal and ray direction should be going in opposition.
        correct_direction = normal.dot(@dir) < 0

        # intersection if the ray goes towards the line segment and is on the proper side.
        return side1*side2 <= 0 and correct_direction


    # Returns >0 if c is to the right.
    # Returns =0 if c is on the ray.
    # Returns <0 if c is on the left.
    line_side_test: (c) ->
        return (@p2.x - @p1.x)*(c.y - @p1.y) - (@p2.y - @p1.y)*(c.x - @p1.x)

    getAngle: () ->
        return Math.atan2(@p2.y - @p1.y, @p2.x - @p1.x)

    # Returns the pt of intersection or null if none exists.
    intersect_ray: (other) ->

        # Find the intersection point.

        ###
        u = ((bs.y - as.y) * bd.x - (bs.x - as.x) * bd.y) / (bd.x * ad.y - bd.y * ad.x)
        v = ((bs.y - as.y) * ad.x - (bs.x - as.x) * ad.y) / (bd.x * ad.y - bd.y * ad.x)
        Factoring out the common terms, this comes to:

        dx = bs.x - as.x
        dy = bs.y - as.y
        det = bd.x * ad.y - bd.y * ad.x
        u = (dy * bd.x - dx * bd.y) / det
        v = (dy * ad.x - dx * ad.y) / det
        ###

        # Extract the relevant points.
        # s = source, d is direction.
        as = @p1
        bs = other.p1
        ad = @dir
        bd = other.dir

        # floats.
        dx = bs.x - as.x
        dy = bs.y - as.y
        det = bd.x * ad.y - bd.y * ad.x
        u = (dy * bd.x - dx * bd.y) / det
        v = (dy * ad.x - dx * ad.y) / det

        # Elliminate all collisions that are in the negative portion of one of the rays.
        ###
        if u < 0 or v < 0
            return null
        ###

        #, then the two lines are collinear.
        if det == 0
            return null

        intersection_point = as.add(ad.multScalar(u))

        # Sanity Check?
        if isNaN(intersection_point.x)
            debugger
            return null

        return intersection_point