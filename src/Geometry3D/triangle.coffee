###

BDS.Triangle class.

Written by Bryce Summers on July.23.2017.

Purpose: This class represents a single triangle in 3D space
         along with associated metrics and data.

Geometric Specification:
    3 points: .a, .b, and .c:  BDS.Point

Derived Geometric Values:
    Normal direction: .normal: BDS.Point (direction vector)
    center_point: .center:   BDS.Point (Center point defined for this triangle)
    axis aligned bounding box: .aabb

Topology:
    faceLink: BDS.FaceLinkData, We bidirectionally link to the faceLinkData objects, so as to keep the faceLink objects pure connectivity objects.

###
class BDS.Triangle

    constructor: (a, b, c) ->

        @a = a.clone()
        @b = b.clone()
        @c = c.clone()

    computeCentroid: () ->
        return @a.clone.add(@b).add(@c).divideScalar(3)

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

    # Adds to the given rayQuery all intersections and times that are found.
    rayQueryAll: (rayQuery) ->

    # Updates rayQuery.time value if true,
    # true if time found.
    rayQueryTime: (rayQuery) ->

    # Updates rayQuery.times[] value if true,
    # true if at least 1 time is found.
    rayQueryTimes: (rayQuery) ->
