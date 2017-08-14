###

BDS.Triangle class.

Written by Bryce Summers on July.23.2017.

Purpose: This class represents a single triangle in 3D space
         along with associated metrics and data.

Geometric Specification:
    3 points: .a, .b, and .c:  BDS.Point

Derived Geometric Values:
    Normal direction: .normal: BDS.Point (direction vector)
    center_point:     .center:   BDS.Point (Center point defined for this triangle)
    axis aligned bounding box: .aabb: BDS.Box

Topology:
    faceLink: BDS.FaceLinkData, We bidirectionally link to the faceLinkData objects, so as to keep the faceLink objects pure connectivity objects.

###
class BDS.Triangle extends BDS.RayQueryable

    constructor: (a, b, c) ->

        @a = a.clone()
        @b = b.clone()
        @c = c.clone()

        @a_index = undefined
        @b_index = undefined
        @c_index = undefined

        # @_obj # Associated Data.
        # @_normal

    @from_abc_triangle: (tri) ->
        return new BDS.Triangle(tri.a, tri.b, tri.c)

    setAssociatedData: (obj) ->
        @_obj = obj
        return

    getAssociatedData: () ->
        return @_obj

    setIndices: (i1, i2, i3) ->
        @a_index = i1
        @b_index = i2
        @c_index = i3

    normal: () ->
        if @_normal
            return @_normal

        ac = @c.clone().sub(@a)
        ab = @b.clone().sub(@a)
        @_normal = ac.cross(ab)

        return @_normal

    computeCentroid: () ->
        return @a.clone().add(@b).add(@c).divideScalar(3)

    ensureBoundingBox: () ->
        if @aabb == null
            @generateBoundingBox()

        return @_aabb

    generateBoundingBox: () ->
        @_aabb = new BDS.Box()

        @_aabb.expandByPoint(@a)
        @_aabb.expandByPoint(@b)
        @_aabb.expandByPoint(@c)

        return @_aabb

    getBoundingBox: () ->
        return @_aabb

    # Updates the rayQuery with an intersection with this triangle if found.
    rayQueryMin: (rayQuery) ->
        ray = rayQuery.ray
        result = @_isect_ray(ray)
        return false if result is null

        new_time = result.time

        if new_time < rayQuery.min_time
            rayQuery.min_time = new_time
            rayQuery.time = new_time
            rayQuery.obj  = @
            return true

        return false

    # Adds to the given rayQuery all intersections and times that are found.
    rayQueryAll: (rayQuery) ->
        ray = rayQuery.ray
        result = @_isect_ray(ray)
        return false if result is null

        rayQuery.times.push(result.time)
        rayQuery.objs.push(@)

        return true

    # Updates rayQuery.time value if true,
    # true if time found.
    rayQueryTime: (rayQuery) ->
        ray = rayQuery.ray
        result = @_isect_ray(ray)
        return false if result is null

        rayQuery.time = result.time
        return true

    # Adds any intersection times to the rayQuery.times[] value if true,
    # true if at least 1 time is found.
    rayQueryTimes: (rayQuery) ->
        ray = rayQuery.ray
        result = @_isect_ray(ray)
        return false if result is null

        rayQuery.times.push(result.time)
        return true


    # Möller–Trumbore intersection algorithm.
    # https://en.wikipedia.org/wiki/M%C3%B6ller%E2%80%93Trumbore_intersection_algorithm
    # INPUT: BDS.Ray
    # OUTPUT: {time: time_along ray, u:, v: barycentric coordinates of 
    # intersection location along this triangle.
    _isect_ray: (ray) ->

        origin = ray.getPoint()
        dir    = ray.getDirection()

        v0 = @a
        v1 = @b
        v2 = @c

        e1 = v1.sub(v0)
        e2 = v2.sub(v0)

        # Calculate planes normal vector
        pvec = dir.cross(e2)
        det  = e1.dot(pvec)

        # Ray is parallel to plane
        if det < 1e-8 and det > -1e-8
            return null

        inv_det = 1 / det
        tvec = origin.sub(v0)

        # 1st barycentric coordinate.
        u = tvec.dot(pvec) * inv_det

        # u out triangle bounds on plane.
        if u < 0 or u > 1
            return null

        qvec = tvec.cross(e1)
        v = dir.dot(qvec) * inv_det
        if v < 0 or u + v > 1
            return null

        time = e2.dot(qvec) * inv_det
        return {time:time, u:u, v:v}