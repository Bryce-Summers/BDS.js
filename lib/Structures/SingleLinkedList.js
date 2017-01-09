// Generated by CoffeeScript 1.11.1

/*
 * Single Linked List Class
 * Written as part of the Bryce Summers Javascript Data Structures Libary.
 * Written by Bryce Summers on 6/12/2015.
 * Adapted by Bryce on 1 - 3 - 2017.

This should be used for more space efficient queues, stacks, or just iteration lists that support removal during iteration, such as in a game loop.
 */

(function() {
  BDS.SingleLinkedList = (function() {
    function SingleLinkedList() {
      this.clear();
    }

    SingleLinkedList.prototype.clear = function() {
      this._size = 0;
      this._head = new BDS.ListNode(null);
      return this._tail = this._head;
    };

    SingleLinkedList.prototype.push = function(elem) {
      var new_head;
      new_head = new BDS.ListNode(elem, this._head);
      this._head = new_head;
      return this.size++;
    };

    SingleLinkedList.prototype.pop = function() {
      var output;
      output = this._head.data;
      this._head = this._head.next;
      this._size--;
      return output;
    };

    SingleLinkedList.prototype.add = function(elem) {
      return this.push(elem);
    };

    SingleLinkedList.prototype.append = function(array) {
      var e, i, len, results;
      results = [];
      for (i = 0, len = array.length; i < len; i++) {
        e = array[i];
        results.push(this.push(e));
      }
      return results;
    };

    SingleLinkedList.prototype.remove_beginning = function() {
      return this.pop();
    };

    SingleLinkedList.prototype.enqueue = function(elem) {
      this._tail.data = elem;
      this._tail.next = new BDS.ListNode(null, null);
      this._tail = this._tail.next;
      return this._size++;
    };

    SingleLinkedList.prototype.dequeue = function() {
      return this.pop();
    };

    SingleLinkedList.prototype.iterator = function() {
      return new ListIterator(this._head, this);
    };

    SingleLinkedList.prototype.isEmpty = function() {
      return this.size === 0;
    };

    SingleLinkedList.prototype.size = function() {
      return this._size;
    };

    SingleLinkedList.prototype.toString = function() {
      var iter, output, results;
      output = "";
      iter = this.iterator();
      results = [];
      while (iter.hasNext()) {
        results.push(output += iter.next());
      }
      return results;
    };

    return SingleLinkedList;

  })();

  BDS.ListNode = (function() {
    function ListNode(data, next) {
      this.data = data;
      this.next = next;
    }

    return ListNode;

  })();

  BDS.ListIterator = (function() {
    function ListIterator(_node, _list) {
      this._node = _node;
      this._list = _list;
      this.last = this._node;
    }

    ListIterator.prototype.hasNext = function() {
      return this._node.next !== null;
    };

    ListIterator.prototype.next = function() {
      var output;
      output = this._node.data;
      this._last = this._node;
      this._node = this._node.next;
      return output;
    };

    ListIterator.prototype.remove = function() {

      /*
      Copy all of the next node's information over to the node that was just returned.
      thereby erasing and possibly releasing the memory.
       */
      this._last.data = this._node.data;
      this._last.next = this._node.next;
      if (this._node.next === null) {
        this._list.tail = this._last;
      }
      this._node = this._last;
      return this._list._size--;
    };

    return ListIterator;

  })();

}).call(this);