###
Ray Class.

Written by Bryce Summers on 1 - 6 - 2017.

Purpose: 
###

class BDS.Ray


    constructor: (point, @dir) ->

        @dir = @dir.normalize()

        # Useful data for splitting lines by rays.
        @p1 = point
        @p2 = @p1.add(@dir)


    getPoint: () ->
        return @p1.clone()

    # Gurantted to return a normalized direction vector.
    getDirection: () ->
        return @dir.normalize();

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



    line_side_test: (c) ->
        return (@p2.x - @p1.x)*(c.y - @p1.y) - (@p2.y - @p1.y)*(c.x - @p1.x)

