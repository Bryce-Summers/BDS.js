###

Intersector

Written by Bryce Summers on 1 - 2 - 2017.

features: Efficient Line Segment Intersection.

###

class BDS.Intersector

    constructor: () ->

    ###
    Calls the Line.intersect method on all intersecting lines.
    Does not treat lines that intersect at common points as intersecting.
    # takes arrays of BDS.Line objects.
    BDS.Line[] -> () [intersection sideeffects]
    ###
    intersectLineSegments: (lines) ->

        # Stores all of the line enter and exit events.
        event_queue = new BDS.Intersector.EventPQ(lines)

        # Stores all of the lines currently spanning the sweep line.
        # We can use a heap for intersection tests across all of the lines and easy deletion of the exiting events.
        # or we can use a Binary search tree where we can furthur bound the possible intersections in a second dimension.
        # I am currently using a simpler heap approach, which is easier to implement.
        # We will assign tuples based on exit locations.
        tupleSet   = new BDS.Intersector.LineTupleSet()

        len = event_queue.size()

        #while(!event_queue.isEmpty())
        # Process every entrance and exit event.
        for i in [0...len] by 1#(int i = 0; i < len; i++)

            event = event_queue.delMin()

            switch (event.type)
            
                when BDS.Intersector.Event.ENTER
                    tuple = event.tuple2
                    tuple.id = i # Set ID.
                    tupleSet.intersect_with_line(tuple.line)
                    tupleSet.addTuple(tuple)
                    continue

                when BDS.Intersector.Event.EXIT
                    tupleSet.removeTuple(event.tuple2)
                    continue

        return

    ###
    Returns true iff there is at least one valid intersection detected in the input set of polylines.
    Does not treat lines that intersect at common points as intersecting.
    
    non_intersection_indices demarcate ranges of indices that should not be intersected against each other.
    Assumes that the indices are in rted order.
    ###
    detect_intersection_line_segments_partitioned: (lines, partition_indices) ->

        # Stores all of the line enter and exit events.
        event_queue = new BDS.Intersector.EventPQ(lines)

        # Stores all of the lines currently spanning the sweep line.
        # We can use a heap for intersection tests across all of the lines and easy deletion of the exiting events.
        # or we can use a Binary search tree where we can furthur bound the possible intersections in a second dimension.
        # I am currently using a simpler heap approach, which is easier to implement.
        # We will assign tuples based on exit locations.
        tupleSet   = new BDS.Intersector.LineTupleSet()

        len = event_queue.size()

        #while(!event_queue.isEmpty())
        # Process every entrance and exit event.
        for i in [0...len] by 1#(int i = 0; i < len; i++)

            event = event_queue.delMin()

            switch (event.type)
            
                when BDS.Intersector.Event.ENTER
                    tuple = event.tuple2

                    # Return true as there is a valid intersection that is detected.
                    if tupleSet.detect_intersection_with_line_partitioned(tuple.line, partition_indices)
                        return true

                    tupleSet.addTuple(tuple)
                    continue

                when BDS.Intersector.Event.EXIT
                    tupleSet.removeTuple(event.tuple2)
                    continue

        return false

    ###
    Slower, but more robust version of intersect.
    Naive N^2 Intersection Algorithm.
    ###
    intersect_brute_force: (lines) ->
        numLines = lines.length

        for a in [0 ...numLines]#(int a = 0; a < numLines; a++)
            for b in [a + 1 ...numLines]#(int b = a + 1; b < numLines; b++)

                lines[a].intersect(lines[b])


###
Event Priority Queue methods.
###
# FIXME: I will probably want to make these guys private classes.
class BDS.Intersector.EventPQ

    constructor: (lines) ->
    
        events = []
        len = lines.length

        for i in [0...len]#(int i = 0; i < len; i++)
        
            line = lines[i]

            #Events.
            enter = new BDS.Intersector.Event()
            exit  = new BDS.Intersector.Event()

            # Points.
            p1 = line.p1;
            p2 = line.p2;

            # Enter at least x coordinate.
            # Exit at greatest x coordinate.
            # We are assuming that there are no vertical lines.
            # Also sort with lower y coordinates entering to higher y coordinates.
            if p1.x < p2.x or (p1.x == p2.x and p1.y < p2.y)

                @_populateEvent(enter, exit, p1, p2, line, i)

            else

                @_populateEvent(enter, exit, p2, p1, line, i)

            events.push(enter)
            events.push(exit)

        @PQ = new BDS.Heap(events, BDS.Intersector.Event_Comparator)

        #cout << "ENTER EVENT Generated : " << enter.x << ", " << enter.y << endl;
        #cout << "EXIT EVENT Generated : "  << exit.x  << ", " << exit.y  << endl;


    # event, event, Point, Point, Line -> void (all BDS)
    _populateEvent: (enter, exit, p1, p2, line, id) ->
    
        enter.type = BDS.Intersector.Event.ENTER
        exit.type  = BDS.Intersector.Event.EXIT

        # Enter events get the entrance location.
        enter.x = p1.x
        enter.y = p1.y

        # Exit events get the exit location.
        exit.x = p2.x
        exit.y = p2.y

        line_tuple = new BDS.Intersector.LineTuple()
        line_tuple.x = p1.x
        line_tuple.y = p1.y
        line_tuple.line = line
        line_tuple.id = id

        line_tuple2 = new BDS.Intersector.LineTuple()
        line_tuple2.x = p2.x
        line_tuple2.y = p2.y
        line_tuple2.line = line
        line_tuple2.id = id

        enter.tuple1 = line_tuple
        enter.tuple2 = line_tuple2
        exit.tuple1  = line_tuple
        exit.tuple2  = line_tuple2
    
    delMin: () ->

        return @PQ.dequeue()

    # () -> bool
    isEmpty: () ->
    
        return @PQ.isEmpty()

    size: () ->

        return @PQ.size()

# Returns true if e1 <= e2 (Occurs before e2)
BDS.Intersector.Event_Comparator = (e1, e2) ->

    # Note: tuples are only used for equality and id's, not for position data.

    # Equal.
    if e1.tuple1 == e2.tuple1 and
       e1.type == e2.type
        return true

    # Equal, but opposite events.
    # Put the enter event first.
    if e1.tuple1 == e2.tuple1
        return e1.type == BDS.Intersector.Event.ENTER

    # Differentiate by x location, then y location.
    return true  if e1.x < e2.x
    return false if e1.x > e2.x
    return true  if e1.y < e2.y
    return false if e1.y > e2.y

    # Events occur at the same location.

    # Exit events before entrance events at identical locations.
    if (e1.type == BDS.Intersector.Event.EXIT) and (e2.type == BDS.Intersector.Event.ENTER)
    
        return true

    if (e1.type == BDS.Intersector.Event.ENTER) && (e2.type == BDS.Intersector.Event.EXIT)

        return false

    # If we have to enter or exit events at the same location, then we differentiate by arbitrary id.
    if (e1.tuple2.id) <= (e2.tuple2.id)

        return true

    return false


# Used to impose an ordering for the tuples in the bst.
# Returns true if e1 <= e2.
BDS.Intersector.LineTuple_Comparator = (e1, e2) ->

    # Equal.
    if (e1 == e2)
        return true

    return true  if (e1.x) < (e2.x)
    return false if (e1.x) > (e2.x)
    
    return true  if (e1.y) < (e2.y)
    return false if (e1.y) > (e2.y)

    # I want to ensure a coorespondence with events in each heap.
    # So I am using these id's to resolve duplicate points.
    return e1.id <= e2.id


###
Line Tuples are stored in a binary search tree to
represent the lines currently crossing the sweep line.
###
class BDS.Intersector.LineTuple

    constructor: () ->

        # Every LineTuple is associated with one line.
        @line = null

        # Used to correctly order the y tuples by y coordinate.
        @x = null
        @y = null

        # Used to resolve ties.
        @id = null


# Represents the set up tuples currently crossing a sweepline. Intersection routines are handled within this class.
class BDS.Intersector.LineTupleSet

    constructor: () ->

        @heap = new BDS.Heap([], BDS.Intersector.LineTuple_Comparator)

    addTuple: (line_tuple) ->

        @heap.add(line_tuple)


    removeTuple: (line_tuple) ->

        tuple = @heap.dequeue()

        if tuple != line_tuple
            err = new Error();
            console.log(err.stack);
            debugger;
            throw new Error("ERROR: line_tuple exit ordering is messed up!")

        return tuple

    # Calls BDS.Line.intersect() on every possible line in this set that could intersect the input_line.
    intersect_with_line: (input_line) ->
        
        len = @heap.size()
        for i in [0...len]
            tuple = @heap.getElem(i)
            line_crossing_sweep = tuple.line
            input_line.intersect(line_crossing_sweep)

    # Returns truee if their is an intersection between two lines from seperate point lists.
    # Partition is done based on pointer equality for the point's lists.
    detect_intersection_with_line_partitioned: (input_line) ->

        len = @heap.size()
        for i in [0...len]
            tuple = @heap.getElem(i)
            line_crossing_sweep = tuple.line
            
            # Same Partition, ignore this pair.
            if line_crossing_sweep.points == input_line.points
                continue

            # Return detected intersections from lines in seperate partitions.
            if input_line.detect_intersection(line_crossing_sweep)
                return true

        return false

    detect_intersection_with_line: (input_line) ->

        len = @heap.size()
        for i in [0...len]
            tuple = @heap.getElem(i)
            line_crossing_sweep = tuple.line

            if input_line.detect_intersection(line_crossing_sweep)
                return true

        return false

# These objects represent events along the sweep line.
class BDS.Intersector.Event

    @ENTER = 0
    @EXIT  = 1

    constructor: () ->
    
        @tuple1 = null
        @tuple2 = null

        @type = null

        @x = null
        @y = null