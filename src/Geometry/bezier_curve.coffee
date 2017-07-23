#
#
# Bryce Summer's Spline Class.
#
# Written on 2 - 28 - 2017
#
# Purpose: This class implements Bezier interpolation.
class BDS.aBezier_Curve # extends BDS.Hermite_Curve

    # Takes in 4 BDS.Point Bezier Control points.
    # FIXME: I might allow this to take in any number of control points.
    constructor: (c0, c1, c2, c3) ->



        #super()