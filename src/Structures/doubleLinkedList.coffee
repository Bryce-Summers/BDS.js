###
 * Double Linked List Class
 * Written as part of the Bryce Summers Javascript Data Structures Libary.
 * Written by Bryce Summers on 1/3/2017.
###
 
class BDS.DoubleLinkedList

    constructor: () ->
        @clear()

    clear: () ->
    
        @_size = 0

        # The head and tail will always point to list nodes with null data,
        # because this keeps things simple.
        @_head = new BDS.DoubleListNode(null, null, null)
        @_tail = new BDS.DoubleListNode(null, null, null)

        # Link these two nodes.
        @_head.next = @_tail
        @_tail.prev = @_head

    isEmpty: () -> @_size == 0
    size: () -> return @_size
     
    # Double Ended Queue functions.
    
    push_back: (elem) ->

        @_tail.data = elem
        @_tail.next = new BDS.DoubleListNode(null, @_tail, null)
        @_tail = @_tail.next
        @_size++

        return

    pop_back: () ->
        @_tail = @_tail.prev
        @_tail.next.prev = null # Erase the reference from the dummy node to the list in case someone still has this iterator.
        @_tail.next = null # Erase the reference to the dummy node.
        output = @_tail.data
        @_tail.data = null # erase the back data.
        @_size--

        return output

    push_front: (elem) ->

        @_head.data = elem
        @_head.prev = new BDS.DoubleListNode(null, null, @_head)
        @_head = @_head.next
        @_size++

        return


    pop_front: (elem) ->

        @_head = @_head.next
        @_head.prev.next = null # Erase the reference from the dummy node to the list in case someone still has this iterator.
        @_head.prev = null # Erase the reference to the dummy node.
        output = @_head.data
        @_head.data = null # erase the front data.
        @_size--

        return output

    add: (elem) ->
        @push_back(elem)
        return

    push: (elem) ->
        @push_back(elem)
        return

    pop: (elem) -> return @pop_back()



    # Removes the given list node from the list.
    # Assumes the given node is not the head or tail node.
    # Does not clear the node, because it will be in an iterator that the user may wish to move forwards of backwards.
    _remove: (node) ->

        if node == @_head or node == @_tail
            throw new Error("Error: Do not attempt to remove the ending iterators, only use them to stop iteration.")

        # Create the skip links.
        node.next.prev = node.prev
        node.prev.next = node.next

        return
    
    # Pushes all of the input element onto the list in the back.
    append: (array) ->
        for e in array
            @push_back(e)
        return
    
    # Iterators.
    # Returns a DoubleListIterator pointing to the head node of this list.
    begin: () -> new BDS.DoubleListIterator(@_head, @)

    # Returns a DoubleListIterator pointing to the tail of this list.
    end: () -> new BDS.DoubleListIterator(@_tail, @)

    toString: () ->

        output = ""
        
        iter = @iterator()
        
        # toString and iterate on each next call.
        while(iter.hasNext())
            output += iter.next()

# Stores data, forward, and backward links.
class BDS.DoubleListNode

    # The Data that this node stores.
    # A link to the next node in the list.
    constructor: (@data, @prev, @next) ->

class BDS.DoubleListIterator

    # Input: BDS.ListNode node.
    constructor: (@_node, @_list) ->

    # Boolean : return true if there is another element that we have not iterated to yet.
    hasNext: () -> @_node.next.data != null
    hasPrev: () -> @_node.prev.data != null

    # Returns the next element in the linked list.
    # () -> E genaric type data
    next: () ->

        @_node = @_node.next
        return @_node.data

    prev: () ->
        @_node = @_node.prev
        return @_node.data

    current: () ->
        return @_node.data

    # Removes the last returned element from the list.
    # returns the data from the removed node.
    # The iterator may still be moved forwards or backwards immediatly following this operation.
    remove: () ->
        return @_list._remove(@_node)
