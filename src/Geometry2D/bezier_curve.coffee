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
class BDS.Bezier_Curve

    constructor: (pt1, tan1, pt2, tan2, input_coefs) ->

        # Optional boolean may be used to set inputs to A, B, C, D
        if input_coefs != undefined and input_coefs == true
            @_A = pt1.clone()
            @_B = tan1.clone()
            @_C = pt2.clone()
            @_D = tan2.clone()
            return

        # otherwise use point, tangent input convention.

        # Compute the Coefficients of the Cubic Polynomial.
        @_A = pt1.multScalar( 2).sub(pt2.multScalar(2)).add(tan1).add(tan2)
        @_B = pt1.multScalar(-3).add(pt2.multScalar(3)).sub(tan1.multScalar(2)).sub(tan2)
        @_C = tan1.clone()
        @_D = pt1.clone()

    # Returns a Bezier Curve representing this curve from the earliest time bound to the latest time bound.
    subCurve: (t1, t2) ->

        # x in [0, 1]
        # Original curve f(x) = Ax^3 + Bx^2 + Cx + D
        # Sub curve g(x) = f(lerp(t1, t2, x))
        # g(x) = A[-t1^3 + t2^3 - 3t1*t2^2 + 3t1^2*t2] x^3 +
        #        A[        t1^3 + 3t1*t2^2 - 6t1^2*t2] x^2 +
        #        B[              t1^2 + t2^2 - 2t1*t2] x^2 +
        #        A[-3t1^3 + 3t1^2*t2] x   + 
        #        B[  -2t1^2 + 2t1*t2] x   +
        #        C[          t2 - t1] x   +
        #        A[t1^3] +
        #        B[t1^2] +
        #        C[t1] +
        #        D

        t1_2 = t1*t1
        t1_3 = t1*t1*t1
        t2_2 = t2*t2
        t2_3 = t2*t2*t2

        # A
        scale_a = -t1_3 + t2_3 - 3*t1*t2_2 + 3*t1_2*t2
        A_new = @_A.multScalar(scale_a)

        # B
        scale_a = t1_3 + 3*t1*t2_2 - 6*t1_2*t2
        scale_b = t1_2 + t2_2 - 2*t1*t2
        B_new = @_A.multScalar(scale_a).add(@_B.multScalar(scale_b))

        # C
        scale_a = -3*t1_3 + 3*t1_2*t2
        scale_b = -2*t1_2 + 2*t1*t2
        scale_c = t2 - t1
        C_new = @_A.multScalar(scale_a).add(@_B.multScalar(scale_b)).add(@_C.multScalar(scale_c))

        # D
        scale_a = t1_3
        scale_b = t1_2
        scale_c = t1
        scale_d = 1
        D_new = @_A.multScalar(scale_a).add(@_B.multScalar(scale_b)).add(@_C.multScalar(t1)).add(@_D)

        output = new BDS.Bezier_Curve(A_new, B_new, C_new, D_new, true)

        return output

    # At^3 + Bt^2 + Ct + D
    position: (t) ->
        return @_A.multScalar(t).add(@_B).multScalar(t).add(@_C).multScalar(t).add(@_D)

    # 3At^2 + 2Bt + C
    tangent: (t) ->
        return @_A.multScalar(3*t).add(@_B.multScalar(2)).multScalar(t).add(@_C)

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
    toPolyline: (max_length_per_segment, times_output) ->

        output = []
        p0 = @position(0)
        output.push(p0)
        times_output.push(0) if times_output

        S = [] # Stack.
        S.push(1.0)
        
        low   = 0
        p_low = @position(low)

        # The stack stores the right next upper interval.
        # The lower interval starts at 0 and is set to the upper interval
        # every time an interval is less than the max_length, subdivision is terminated.

        # Left to right subdivision loop. Performs a binary search across all intervals.
        while S.length != 0
        
            high   = S.pop()
            p_high = @position(high)
        
            # Subdivision is sufficient, move on to the next point.
            while p_low.distanceTo(p_high) > max_length_per_segment
                # Otherwise subdivide the interval and keep going.
                S.push(high)
                high   = (low + high)/2.0
                p_high = @position(high)
        
            output.push(p_high)
            times_output.push(high) if times_output
            low   = high
            p_low = p_high
            continue

        return new BDS.Polyline(false, output)

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
