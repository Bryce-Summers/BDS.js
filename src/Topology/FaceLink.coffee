###

FaceLink Data Structure.
Written by Bryce Summers on July.10.2017

Purpose: Low memory data structure for storing the linkages between the triangles in a manifold mesh.
         BDS.FaceLinkGraph may be used allocate and connect a bunch of face links.

     A +
       |\
       | \  @C
       |  \
    @B |   + B
       |  /
       | /  @A
       |/
     C +

###

# Auxiliary class used to store extra associated data for use
# in algorithms and stuff.
class BDS.FaceLinkData
    constructor: (faceLink) ->
        @faceLink = faceLink

        ###
        Other data fields may be allocated here externally.
        Some common fields include:
         - triangle, a geometric structure corresponding to the indices.
        ###

class BDS.FaceLink

    constructor: () ->

        @data = new BDS.FaceLinkData(@)

        # Face opposite triangle's 1st index, second, third indices.

        # FaceLinks.
        @a = null
        @b = null
        @c = null

class BDS.FaceLinkGraph

    constructor: (indices) ->
        @_faceLinks = null
        @_build_from_indices(indices)

    # REQURIES indices is a list of indices, where every 3 coorespond to the indices of points in some external array.
    # The input indices are assumed to be well-oriented.
    #
    # ENSURES: Returns an array of FaceLinks in the same order as the inputs.
    #          The face links will be linked when they share common edges containing identical vertices.
    # int[]
    _build_from_indices: (indices) ->

        debugger
        map = new Map()

        @_faceLinks = []

        len = Math.floor(indices.length/3)
        for i in [0...len]
            index = i*3

            a = indices[index]
            b = indices[index + 1]
            c = indices[index + 2]

            # Allocate this face and store it.
            facelink = new BDS.FaceLink()
            @_faceLinks.push(facelink)

            # For all 3 sides, bidirectionally link this to those that have put an edge into the map,
            # else put the reverse edge into the map.
            # Because the indices are assumed to be well oriented, there is no need to create unique keys for both orientations.
            edge_a = @_l2s(b, c)
            edge_b = @_l2s(c, a)
            edge_c = @_l2s(a, b)

            link_a = map.get(edge_a)
            if link_a
                facelink.a = link_a # Link if found.
                map.delete(edge_a)
            else
                edge_a = @_l2s(c, b) # input link otherwise.
                map.set(edge_a, facelink)

            link_b = map.get(edge_b)
            if link_b
                facelink.b = link_b
                map.delete(edge_b)
            else
                edge_b = @_l2s(a, c) #[a, c]
                map.set(edge_b, facelink)

            link_c = map.get(edge_c)
            if link_c
                facelink.c = link_c
                map.delete(edge_c)
            else
                edge_c = @_l2s(b, a)
                map.set(edge_c, facelink)

        return

    _l2s: (i1, i2) ->
        return "" + i1 + "_" + i2

    size: () ->
        return @_faceLinks.length

    # Get the Facelink at the given index.
    get: (index) ->
        return @_faceLinks[index]

    # applies the given function to every 
    # (faceLinkData) -> ()
    
    eval_data: (func) ->
        for faceLink in @_faceLinks
            func(faceLink.data)

        return

    # evaluates the given function for faceLinks and 
    # associated input values.
    # (faceLinkData, input) -> ()
    map_data: (func, inputs) ->
        len = @size()
        for i in [0...len]
            faceLink = @_faceLinks[i]
            input    = inputs[i]
            func(faceLink.data, input)

        return
