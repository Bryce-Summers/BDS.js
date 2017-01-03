###
Heap
Implements a priority Queue using an Array Heap.
Written by Bryce Summers on 11 - 2 - 2017.

 * 
 * Note : This is a MIN heap.
 * 
 * Heap property :  For every element in the tree,
 *                  it is less than or equal to its left and right children in the tree as defined by the elements at the indexes associated by
 *                  the relationships index_left(index) and index_right(index).
 *  
 * Root node is always at index 0.
 * 
 * Left biased, when equal keys are present, the one on the left will be chosen.
 * 
 * Allows for duplicate keys.
 * 
 * Binary tree invariants :
 * The heap is represented by a binary tree that is encoded by index relationships within an unbounded array.
 * We maintain the UBA with a minimality of nodes, so the UBA will only contain N elements, when size = n.
 * 
 * The heap is as balanced as possible. This causes their to be a preference for left children over right children.
 * 
 * FIXME : I will need to work to preserve key stability, so that all keys will eventually be deleted, even if all keys entered are equal.
 ###

class BDS.Heap

    # Controls the branching factor.
    @_D: 3

    # Comparator is a function (elem1, elem2) -> bool, which returns true if elem1 <= elem2
    constructor: (data_in, comparator) ->

        @_LE = comparator

        if !data_in
            @_data = []
        else
            # Clone input array.
            @_data = data_in.slice(0)
            @_heapify()

    # -- Public interface functions.
    size: () ->
        return @_data.length
    
    isEmpty: () ->
        return @_data.length == 0
    
    
    add: (elem) ->

        len = @_data.length
        @_data.push(elem)

        @_sift_up(len)

    # Append an array of elements to the array.
    append: (elems) ->
        for e in elems
            @add(e)
    
    peek: () ->

        return @_data[0]

    # O(log(n)) deletes and returns the minimum element.
    dequeue: () ->

        # Trivial 1 element heap.
        if@_data.length == 1
            return @_data.pop()
        
        
        # Extract the minimum element.
        output = @_data[0]

        # Maintain the minimum heap invariants.
        last = @_data.pop()
        @_data[0] = last
        @sift_down(0)
        
        return output
    
    # -- Data_structure interface functions.
    toArray: () ->
        # Clone data array.
        return @_data.slice(0)

    # Takes an index in [0, size) and returns that element.
    # Mainly useful for iteration.
    getElem: (index) ->
        return @_data[index]
    
    # -- Private functions.
    
    ###
    // Heapifies all of the nodes of the Tree with a root at the given index.
    // Builds the heap invariant downwards to all sub trees.
    // O(n), checks each node in the tree once.
    // Transforms a random array into an array that meets the heap invariants.
    ###
    _heapify: () ->

        for i in [@_data.length - 1 .. 0] #(int i = data.size() - 1; i >= 0; i--)
            @sift_down(i)

        return
        

    ###
    // Given an index, swaps the node down the tree while maintaining the min
    // heap invariant until the node is in an invariant correct place.
    // O(log(n)). Non recursive, so has O(1) function calls.
    // SIFT down.
    ###
    sift_down: (index) ->

        size   = @_data.length

        child_index = @_index_child(index, 1)
                
        elem = @_data[index]
        
        # While the node has at least 1 child.
        while child_index < size
                                
            min_elem_index = -1
            min_elem = elem
            
            # ASSUMES that Children are contiguous in memory.
            # try to sift the elemnt down to the least child.
            # int i = child_index; i < child_index + D && i < size; i++
            i = child_index
            while i < child_index + BDS.Heap._D and i < size

                child = @_data[i]
                
                # If child is lesser, keep going.
                if @_LE(child, min_elem)

                    min_elem = child
                    min_elem_index = i

                i++
            
            # The heap invariants are held and no further swaps need to be made.
            # Reference comparison.
            if min_elem == elem
                return
                        
            @_min_first(index, min_elem_index)
            index = min_elem_index
            child_index = @_index_child(index, 1)
                        
        #// End of while loop.     
    
    # Builds the heap invariant going up the tree from a given child node.
    _sift_up: (index) ->
    
        parent_index = @_index_parent(index)
        
        # Root node is always at index 0.
        while index > 0 and @_min_first(parent_index, index)
        
            index = parent_index
            parent_index = @_index_parent(index)        
    
    
    # -- Array tree transversing functions.
    
    _index_parent: (index) ->
    
        return Math.floor((index - 1)/BDS.Heap._D)
    

    # REQUIRES: The index of a given node, which child is desired. Child in [1, D]
    # ENSURES: Returns the child_index'th child of the node at the given index in the array.
    _index_child: (index, child_index) ->

        return BDS.Heap._D*index + child_index

    # REQUIRES : index1 < index2.
    # Performs a swap to fix heap invariant errors for the elements at the given indices.
    # Returns true iff the swap was performed.
    #(int, int) -> bool
    _min_first: (index1, index2) ->

        elem1 = @_data[index1]
        elem2 = @_data[index2]
        
        # Elem1 is greater than elem2.
        if !@_LE(elem1, elem2)
        
            BDS.Arrays.swap(@_data, index1, index2)

            return true
        
        
        return false

    toString: () ->
    
        output = ""
        output += "\nMinHeap["
        
        for elem in @_data
        
            output += elem
            output += ",\n"
        
        
        output += "]"
        
        return output
    

    
    clone: () ->
    
        return new BDS.Heap(@_data, @_LE)
    
    
    # Returns a UBA that is sorted from least to greatest.
    toSortedArray: () ->

        len = @_data.length
        output = []
        
        heap = @clone();
        
        for i in [0...len]

            output.push(heap.dequeue())

        return output

    clear: () ->
        @_data = []