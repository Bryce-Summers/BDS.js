###
Point.

Written by Bryce Summers on 1 - 2 - 2017.

Implements Arithmetic.

add, sub, multScalar
###
BDS.newDirection = (x, y, z) -> new BDS.Point(x, y, z)
class BDS.Point

    constructor : (@x, @y, @z) ->

        if @x == undefined or isNaN(@x)
            debugger

        if @y == undefined or isNaN(@y)
            debugger

        if !@z
            @z = 0.0

    clone: () ->
        return new BDS.Point(@x, @y, @z)

    copyFrom: (pt) ->
        @x = pt.x
        @y = pt.y
        @z = pt.z

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

    toArray: () ->
        return [@x, @y, @z]

    toString: () ->
        output = "Point(" + @x + ", " + @y

        if @z
            output += ", " + @z

        output += ")"

        return output

    # Returns the euclidean distance from this point to the given point.
    distanceTo: (pt) ->
        return pt.sub(@).norm()

    directionTo: (pt) ->
        return pt.sub(@).normalize()

    # Converts radians to a unit direction vector.
    @directionFromAngle: (angle) ->
        return new BDS.Point(Math.cos(angle), Math.sin(angle), 0)

    angle: () ->
        return Math.atan2(@y, @x)

    angleTo: (pt) ->
        return pt.sub(@).angle()

    # Treats this and the given pt as direction vectors.
    angleBetween: (pt) ->
        dot = @dot(pt)

        cosA = dot /(@norm() * pt.norm())

        return Math.acos(cosA)

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

    # Returns this cross other.
    # i.e. the direction perpendicular to the place including this and the other directions
    # in the orientation dictated by the right hand rule.
    cross: (o) ->
        return new BDS.Point(@y*o.z - @z*o.y, @z*o.x - @x*o.z, @x*o.y - @y*o.x)

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