###
Box.

Written by Bryce Summers on 1 - 5 - 2017
###

class BDS.Box extends BDS.RayQueryable

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
     Here are some top of the brain approaches:
     - Raycast all 6 quad faces.
     - Raycast 12 triangle faces.
     - Since we are axis aligned, we could the ray reletive to center of box space, 
       then prune faces that the ray won't hit. This seems to be the major win for Axis-Alignment.

     I looked online and found a better quadrant based approach and modified it to find the exit point for the box as well.

    ###

    # Updates the rayQuery with an intersection with this triangle if found.
    rayQueryMin: (rayQuery) ->

        new_time = @_isect_ray(rayQuery.ray)      
        if 0 <= new_time and new_time < rayQuery.min_time
            rayQuery.time     = new_time
            rayQuery.min_time = new_time
            rayQuery.obj      = @
            return true
        return false

    # Adds to the given rayQuery all intersections and times that are found.
    rayQueryAll: (rayQuery) ->

        # Reduction to times query.
        if @rayQueryTimes(rayQuery)
            rayQuery.objs.push(@)
            return true

        return false


    # Updates rayQuery.time value if true,
    # true if time found.
    rayQueryTime: (rayQuery) ->
        new_time = @_isect_ray(rayQuery.ray)
        if 0 <= new_time
            rayQuery.time = new_time
            return true
        return false

    # Adds intersection times to rayQuery.times[] value if true,
    # true if at least 1 time is found.
    rayQueryTimes: (rayQuery) ->

        enter_time = @_isect_ray(rayQuery.ray)

        # No intersections.
        if enter_time < 0
            return false

        # NOTE: if enter_time == 0,
        # then the ray starts in the box and we treat the start as the enter time.

        # Find the exit time.
        exit_search = @_opposite_ray(rayQuery.ray, new_time)
        exit_ray  = exit_search.ray
        exit_time = exit_search.origin_time - @_isect_ray(exit_ray)

        # Two times, 1 object.
        rayQuery.times.push(enter_time)
        rayQuery.times.push(exit_time)

        return false


    # INPUT:  ray, time ray enters this box.
    # OUTPUT: # {ray: origin_time:}
    # - ray travelling in the opposite direction of the input
    # - time along input ray that the output ray's start point is at.
    # with an origin point at the indicated origin_time on the input ray.
    # The origin_time is chosen to be greater than the time the original ray would exit the box,
    # in fact its purpose is to find the exit location.
    # FIXME: Special case for infinite boxes?
    _exit_ray: (ray, enter_time) ->
        max_distance_in_box_lower_bound = @_manhattanDiagonal()

        new_time  = enter_time + max_distance_in_box_lower_bound
        origin    = ray.getPointAtTime(new_time)
        direction = ray.getDirection.mult(-1)

        new_ray = new BDS.Ray(origin, direction)
        return {ray: new_ray, time:new_time}

    # An overestimate and upper bound on the minnimum distance a ray can travel
    # through the box and be guranteed to have gone through the entire box.
    # This is useful in determining an exit query ray's start position.
    _manhattanDiagonal : () ->
        return  @max.x - @min.x + 
                @max.y - @min.y + 
                @max.z - @min.z


    # FIXME: Determine whether the bounding box is filled or unfilled.
    # At the moment a ray starting within a box assumes filled and returns its starting point.

    # OUTPUT: time
    _isect_ray: (ray) ->

        # We convert all relevant fields into arrays to more
        # efficiently iterate through all of the cases.

        # Define side enum.
        NUMDIM = 3
        [RIGHT, LEFT, MIDDLE] = [0..NUMDIM]


        # Box.
        minB = @min.toArray()
        maxB = @max.toArray()
        
        # Ray.
        origin = ray.getPoint().toArray()
        dir    = ray.getDirection().toArray()

        inside = true
   
        quadrant = [BDS.Box.LEFT, BDS.Box.LEFT, BDS.Box.LEFT]
        i = 0 # Used a lot.

        # Max times in each dimension.
        maxT = [0, 0, 0]

        # the coordinates of the 3 axis-aligned planes
        # that we may check for intersections.
        candidatePlane = [0, 0, 0]

        # The Intersection Location.
        coord = [0, 0, 0]

        # Determine which quadrant our origin is in.
        # This dictates the planes that it could potentially intersect.
        for i in [0...NUMDIM] by 1

            # LEFT, minBoxCoord, MIDDLE, maxBoxCoord, RIGHT
            if origin[i] < minB[i]
                quadrant[i] = LEFT
                candidatePlane[i] = minB[i]
                inside = false
            else if origin[i] > maxB[i]
                quadrant[i] = RIGHT
                candidatePlane[i] = maxB[i]
                inside = false
            else
                quadrant[i] = MIDDLE


        # Ray origin inside bounding box
        # Filled implies intersection is at origin.
        if inside
            #location = origin
            return 0

        # Calculate time distances to candidate planes.
        for i in [0...NUMDIM] by 1

            # ray cannot intersect x planes if it doesn't change in the x direction
            # or if in middle an intersection would be behind another plane or imply 
            # the ray travels off in space without hitting the box.
            if quadrant[i] != MIDDLE && dir[i] != 0
                maxT[i] = (candidatePlane[i] - origin[i]) / dir[i]
            else
                maxT[i] = -1

        # Get largest of the maxT's for final choice of intersection
        # Some smaller intersections may be premature, if the maximum is not on the box,
        # then the ray has skipped past the box, since
        # we are only checking candidate planes, rather than
        whichPlane = 0
        for i in [1...NUMDIM] by 1 # (i = 1; i < NUMDIM; i++)
            if maxT[whichPlane] < maxT[i]
                whichPlane = i

        # Check if the final candidate is actually inside box
        if maxT[whichPlane] < 0
            # No plane is intersected.
            return -1

        for i in [0...NUMDIM] # i = 0; i < NUMDIM; i++)
            if whichPlane != i
                coord[i] = origin[i] + maxT[whichPlane]*dir[i]

                # No intersectionn if the intersection point is off of the bounding box.
                if coord[i] < minB[i] or coord[i] > maxB[i]
                    return false
            else
                # Set coordinate exactly on the plane.
                coord[i] = candidatePlane[i]

        return maxT[whichPlane] # ray hits box