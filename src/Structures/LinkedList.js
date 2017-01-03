/*
 * Java Script Linked List Class.
 *
 * Written by Bryce Summers on 6/12/2015.
 */
 
 
 function List()
 {
	this.make_empty();
 }
 
List.prototype =
{
	// Stack Functions.
	
	// Adds an element to the beginning of the list.
	push(elem)
	{
		var new_head = new ListNode(elem, this.head);
		this.head = new_head;
		this.size++;
	},
	
	// Removes an element from the beginning of the list.
	// Returns the element.
	pop()
	{
		var output = this.head.data;
		this.head = this.head.next;
		this.size--;
		return output;
	},
	
	add(elem)
	{
		push(elem);
	},
	
	remove(elem)
	{
		return pop();
	},
	
	// -- Queue Operations.
	
	// Adds an element to the end of the list.
	enq(elem)
	{
		this.tail.data = elem;
		this.tail.next = new ListNode(null, null);
		this.tail = this.tail.next;
		this.size++;
	},
	
	// Removes an element from the beginning of the list.
	deq()
	{
		return this.pop();
	},
	
	iterator()
	{
		return new ListIterator(this.head, this);
	},
	
	isEmpty()
	{
		return this.size == 0;
	},
	
	make_empty()
	{
		this.size = 0;
		this.head = new ListNode(null);
	
		// tail will always point to a null node at the end, this keeps things simple.
		this.tail = this.head;	
	},
	
	print()
	{
		var iter = this.iterator();
		
		while(iter.hasNext())
		{
			console.log(iter.next());
		}
	}
}

function ListNode(data, next)
{
	// The Data that this node stores.
	this.data = data;
	
	// A link to the next node in the list.
	this.next = next;
}

ListNode.prototype =
{
	
}

// Input: ListNode node.
function ListIterator(node, list)
{
	this.node = node;
	this.last = node;
	
	this.list = list;
}

ListIterator.prototype =
{
	// Boolean : return true if their is another element that we have not iterated to yet.
	hasNext()
	{
		return this.node.next != null;
	},

	// Returns the next element in the linked list.
	// ListNode return value.
	next()
	{
		var output = this.node.data;
		this.last = this.node;
		this.node = this.node.next;
		return output;
	},
	
	// Removes the last returned element from the list.
	// void.
	remove()
	{
		// Copy all of the next node's information over to the node that was just returned.
		// thereby erasing and possibly releasing the memory.
		this.last.data = this.node.data;
		this.last.next = this.node.next;
		
		if(this.node.next === null)
		{
			this.list.tail = this.last;
		}
		
		this.node = this.last;
		
		this.list.size--;
		

		
	}
}