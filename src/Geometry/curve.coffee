#
# Bryce Summer's Spline Class.
#
# Written on 11/29/2016.
#
# Purpose: Extends the THREE.js spline classes with better features.
#
# Planned:
# 1. Offset Curves.
# 2. Inset Curves.
# 3. Maximum-length interval discretizations for producing renderable line segments.
#
# Currently we are implementing this as a reduction to THREE.CatmullRomCurve3, but we may remove the dependancy if we have time and go sufficiently beyond it.
# FIXME: Sandardize the curve class and instantiate it from interfacial curves.
class TSAG.S_Curve

    constructor: () ->

        # A spline that dynamically parameterizes itself to between 0 and 1.
        @_spline = new THREE.CatmullRomCurve3()

        # A list of points in the discretization.
        @_point_discretization = []

    # p : THREE.Vector3.
    addPoint: (p) ->
        @_spline.points.push(p)

    numPoints: (p) ->
        return @_spline.points.length

    getPointAtIndex: (i) ->
        return @_spline.points[i]

    getLastPoint: () ->
        return @getPointAtIndex(@numPoints() - 1)

    removeLastPoint: () ->
        return @_spline.points.pop()

    position: (t) ->
        return @_spline.getPoint(t)

    tangent: (t) ->
        return @_spline.getTangent(t)

    offset: (t, amount) ->

        tan = @tangent(t)
        tan.setLength(amount);
        
        # Perpendicularlize the vector.
        x = tan.x;
        y = tan.y;
        tan.x =  y;
        tan.y = -x;
        
        return @position(t).add(tan);



    # Returns a list of points representing this spline.
    # They will be no more than max_length apart.
    # They will be as sparse as is practical. # FIXME: Do some studying of this.
    # See: https://github.com/Bryce-Summers/Bryce-Summers.github.io/blob/master/p5/Physics/Visuals/visual_conservation_of_energy.js
    # This is more efficient than the built in THREE.js version, because it does the binary searches for all of the points at the same time.
    # It may produce up to 2 times as many points though...
    # FIXME: Do an analysis of differnt spline discretization techniques.
    # I believe I will compensate for this algorithms problems, by designing my user interactions such that when they click near the original spline, that is a signal to go back.
    getDiscretization: (max_length) ->
        return @_discretization

    updateDiscretization: (max_length) ->
        output = []
        p0 = @_spline.getPoint(0)
        output.push(p0)

        S = [] # Stack.
        S.push(1.0)
        
        low   = 0
        p_low = @_spline.getPoint(low)

        # The stack stores the right next upper interval.
        # The lower interval starts at 0 and is set to the upper interval
        # every time an interval is less than the max_length, subdivision is terminated.

        # Left to right subdivision loop. Performs a binary search across all intervals.
        while S.length != 0
        
            high   = S.pop()
            p_high = @_spline.getPoint(high)
        
            # Subdivision is sufficient, move on to the next point.
            while p_low.distanceTo(p_high) > max_length
                # Otherwise subdivide the interval and keep going.
                S.push(high)
                high   = (low + high)/2.0
                p_high = @_spline.getPoint(high)
        
            output.push(p_high)
            low   = high
            p_low = p_high
            continue

        @_discretization = output

    # max_length:float, maximum length out output segment.
    # amount: the distance the offset curve is away from the main curve. positive or negative is fine.
    # time_output (optional) will be populated with the times for the output points.
    getOffsets: (max_length, amount, times_output) ->

        o0 = @offset(0, amount)
        output = []
        output.push(o0)
        times_output.push(0) if times_output

        S = []; # Stack.
        S.push(1.0)
        low = 0
        p_low = @offset(low, amount)

        # The stack stores the right next upper interval.
        # The lower interval starts at 0 and is set to the upper interval.
        # every time an interval is terminated after subdivision is sufficient.

        # Left to right subdivision loop.
        while S.length != 0
        
            high   = S.pop()
            p_high = @offset(high, amount)

            # Subdivision is sufficient, move on to the next point.
            while p_low.distanceTo(p_high) > max_length
            
                # Otherwise subdivide the interval and keep going.
                S.push(high)
                high = (low + high)/2.0
                p_high = @offset(high, amount)
            

            output.push(p_high)
            times_output.push(high) if times_output
            low = high
            p_low = p_high
            continue
        
        return output
