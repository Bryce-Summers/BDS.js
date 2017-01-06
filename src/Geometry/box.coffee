###
Box.

Written by Bryce Summers on 1 - 5 - 2017
###

class BDS.Box

    # BDS.Point, BDS.Point
    constructor : (@min, @max) ->

        if not @min
            @min = new BDS.Point(Number.MAX_VALUE, Number.MAX_VALUE, Number.MAX_VALUE)

        if not @max
            @max = new BDS.Point(Number.MIN_VALUE, Number.MIN_VALUE, Number.MIN_VALUE)

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