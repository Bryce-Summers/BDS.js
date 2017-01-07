###
Point.

Written by Bryce Summers on 1 - 2 - 2017.

Implements Arithmetic.

add, sub, multScalar
###
BDS.newDirection = (x, y, z) -> new BDS.Point(x, y, z)
class BDS.Point

    constructor : (@x, @y, @z) ->

        if !@z
            @z = 0.0

    clone: () ->
        return new BDS.Point(@x, @y, @z)

    add: (pt) ->
        out = @clone()
        out.x += pt.x
        out.y += pt.y
        out.z += pt.z
        return out

    sub: (pt) ->
        out = @clone()
        out.x -= pt.x
        out.y -= pt.y
        out.z -= pt.z
        return out

    multScalar: (s) ->
        out = @clone()
        out.x *= s
        out.y *= s
        out.z *= s
        return out

    divScalar: (s) ->
        out = @clone()
        out.x /= s
        out.y /= s
        out.z /= s
        return out

    toString: () ->
        output = "Point(" + @x + ", " + @y

        if @z
            output += ", " + @z

        output += ")"

        return output

    magnitude: () ->
        return @norm()

    # Euclidean Norm.
    norm: () ->
        return Math.sqrt(@norm2())

    # Square of the Euclidean norm.
    norm2: () ->
        return @x*@x + @y*@y + @z*@z

    min: (pt) ->
        out = @clone()
        out.x = Math.min(@x, pt.x)
        out.y = Math.min(@y, pt.y)
        out.z = Math.min(@z, pt.z)
        return out

    max: (pt) ->
        out = @clone()
        out.x = Math.max(@x, pt.x)
        out.y = Math.max(@y, pt.y)
        out.z = Math.max(@z, pt.z)
        return out

    normalize: () ->
        return @divScalar(@norm())

    dot: (pt) ->
        return pt.x*@x + pt.y*@y + pt.z*@z

    # returns true iff this point is less than the input point on every dimension.
    lessThan: (pt) ->
        return @x < pt.x and @y < pt.y and @z < pt.z

    lessThanOrEqual: (pt) ->
        return @x <= pt.x and @y <= pt.y and @z <= pt.z

    # returns true iff this point is greater than the input point on ever dimension.
    greaterThan: (pt) ->
        return @x > pt.x and @y > pt.y and @z > pt.z

    greaterThanOrEqual: (pt) ->
        return @x >= pt.x and @y >= pt.y and @z >= pt.z