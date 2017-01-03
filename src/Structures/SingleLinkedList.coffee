###
 * Single Linked List Class
 * Written as part of the Bryce Summers Javascript Data Structures Libary.
 * Written by Bryce Summers on 6/12/2015.
 * Adapted by Bryce on 1 - 3 - 2017.

This should be used for more space efficient queues, stacks, or just iteration lists that support removal during iteration, such as in a game loop.

###
 
class BDS.SingleLinkedList

    constructor: () ->
        @clear()

    clear: () ->
    
        @_size = 0;
        @_head = new BDS.ListNode(null);
    
        # tail will always point to a null node at the end, this keeps things simple.
        @_tail = @_head;
     
	# Stack Functions.
	
	# Adds an element to the beginning of the list.
	push: (elem) ->

		new_head = new BDS.ListNode(elem, @_head)
		@_head = new_head
		@size++
	
	# Removes an element from the beginning of the list.
	# Returns the element.
	pop: () ->
	
		output = @_head.data
		@_head = @_head.next
		@_size--
		return output
	
	add: (elem) ->
	   @push(elem)
	
    # Pushesall elemnts from an array in order.
    append: (array) ->
        for e in array
            @push(e)

    remove_beginning: () ->
        return @pop()
	
	# -- Queue Operations.
	
	# Adds an element to the end of the list.
	enqueue: (elem) ->
	
		@_tail.data = elem
		@_tail.next = new BDS.ListNode(null, null)
		@_tail = @_tail.next
		@_size++
	
	
	# Removes an element from the beginning of the list.
	dequeue: () -> @pop()
	iterator: () -> new ListIterator(@_head, @);
	isEmpty: () -> this.size == 0
    size: () -> return @_size
	
	toString: () ->

        output = ""
		
        iter = @iterator()
		
        # toString and iterate on each next call.
        while(iter.hasNext())
			output += iter.next()

class BDS.ListNode

    # The Data that this node stores.
    # A link to the next node in the list.
    constructor: (@data, @next) ->

class BDS.ListIterator

    # Input: BDS.ListNode node.
    constructor: (@_node, @_list) ->
        this.last = @_node

	# Boolean : return true if their is another element that we have not iterated to yet.
	hasNext: () -> @_node.next != null

	# Returns the next element in the linked list.
	# ListNode return value.
	next: () ->

		output = @_node.data
		@_last = @_node
		@_node = @_node.next
		return output

	
    # FIXME: call a remove list node function from the list.
	# Removes the last returned element from the list.
	# void.
	remove: () ->

		###
        Copy all of the next node's information over to the node that was just returned.
		thereby erasing and possibly releasing the memory.
        ###
		@_last.data = @_node.data
		@_last.next = @_node.next
		
		if @_node.next == null
		
			@_list.tail = @_last
		
		@_node = @_last
		@_list._size--