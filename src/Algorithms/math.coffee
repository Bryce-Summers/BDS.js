###
BDS.Math.Coffee
Written by Bryce Summers on 2 - 27 - 2017.
Purpose: Provides useful functions, such as Lerping.
###

BDS.Math = {}

# Linear Interpolation for numbers, floats, etc.
BDS.Math.lerp = (from, to, percentage) ->
    return from*(1 - percentage) + to*percentage

BDS.Math.sign = (c) ->
    if c < 0
        return -1
    if c > 0
        return 1

    return 0