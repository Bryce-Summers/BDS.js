#
# BDS.RayQuery Structure
# Written on July.23.2017
#
# Purpose: Stores the results of different types of queries.
# Any technical information about queries in the BDS library can be relocated to this file.
#
# - .ray # the ray performing the query.
#          Typically this will be used to feed the ray into BVH and other query structures.
# - .isects, {obj:, time:} # the results of a query.
#
# Standard names and behaviors for ray query calls:
#  -bool rayQueryMin(rayQuery) :  updates .min_time, .isect_obj, and .time, if a closer intersection is found,
#                                 returns true iff an update has been made.
#  -bool rayQueryTime(rayQuery) : stores the time of earliest intersection in .time, returns true iff an intersection was found.
#
# Future:
# bool rayQueryTimes(rayQuery): .time = float[]
# bool rayQueryAll(rayQuery): pushes isects and times for all intersections between the ray and the object, returns true if any were found.

class BDS.RayQuery

    constructor: (ray) ->

        @initialize(ray)

    initialize: (ray) ->
        @ray = ray
        @isects = []
        @min_time = Number.MAX_VALUE

        @time = undefined

    # Given an intersection time, @min_time is updated.
    updateMinTime: (new_time) ->

        if new_time < @min_time
            @min_time = new_time

    hasIntersection: () ->
        return @isects.length > 0 or @min_time < Number.MAX_VALUE

    ###
    TODO: Add isect adding and updating functions.

    ###

    ###
    # Pops the latest isect_obj to be found.
    popNewest: () ->
        return @isects.pop()

    # Pops the oldest isect_obj that was found.
    popOldest: () ->
        output = @isects[0]
        @isects.slice(1)
        return output
    ###

    # Sorts all of the isects and associated times from near to far
    # by least to greatest time value.
    # This allows users to post sort values after they have received them.
    sortByTime: () ->

        debugger
        console.log("Rayquery: Implement Me Please!")