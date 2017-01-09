###
Geometry Super Class
Written by Bryce Summers on 1 - 9 - 2017.

This class abstract away many common procedures and specifies a common interface for algorithms on geometries.
###

class BDS.Geometry

    constructor: (@closed, @filled) ->

    generateBoundingBox: () ->

    # Returns true if this geometry strictly contains the given pt.
    # BDS.Point -> bool
    containsPoint: (pt) ->


    detect_intersection_with_polyline: (polyline) ->

        throw new Error("Please Override Me!");

        return;