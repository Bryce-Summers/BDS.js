class BDS.Testing

    constructor: () ->
        @test_heaps()
        @test_DoubleLinkedList()

        # Geometry Tests.
        @test_points()
        @test_lines()
        @test_intersector()

        @test_arrays()

        # FIXME: Test the rest!
        #@test_polyline()

        console.log("All tests have passed!")
        document.getElementById("text").innerHTML = "All Tests Have Passed!";
        

    ASSERT: (b) ->
        if !b
            err = new Error()
            console.log(err.stack)
            debugger
            throw new Error("Assertion Failed!")

    test_heaps: () ->

        #comparison furnction
        LE = (a, b) -> (a <= b)
        

        h1 = new BDS.Heap([], LE)
        
        @ASSERT(h1.isEmpty())
        @ASSERT(h1.size() == 0)

        h1.append([1, 3, 5, 7, 9, 0, 8, 4, 6, 2])

        # Test Ordering and sorted array output.
        sorted = h1.toSortedArray()
        for i in [0...10] by 1
            @ASSERT(sorted[i] == i)
        
        @ASSERT(!h1.isEmpty())
        @ASSERT(h1.size() == 10)
        
        for i in [0...10] by 1
        
            @ASSERT(h1.size() == 10 - i)
            @ASSERT(h1.peek() == i)
            @ASSERT(h1.dequeue() == i)
        
        @ASSERT(h1.isEmpty())

        # Test out a random array.
        random_array = []
        len = 10000
        for i in [0 ... len] by 1
            random_array.push(Math.random())

        # Test out clear and append.
        h1.clear()
        h1.append(random_array)
        sorted = h1.toSortedArray()

        for i in [0...len - 1] by 1
            @ASSERT(sorted[i] < sorted[i + 1])

        # Test out heapify with a large array.
        h1 = new BDS.Heap(random_array, LE)
        sorted = h1.toSortedArray()

        for i in [0...len - 1] by 1
            @ASSERT(sorted[i] < sorted[i + 1])

        return

    test_DoubleLinkedList: () ->

        list = new BDS.DoubleLinkedList()
        @ASSERT(list.size() == 0)
        @ASSERT(list.isEmpty())

        list.add(5)
        @ASSERT(list.size() == 1)
        @ASSERT(!list.isEmpty())

        list.append([0, 1, 2, 3, 4, 5, 6])
        @ASSERT(list.size() == 8)
        @ASSERT(list.pop_front() == 5)

        for i in [0...7]
            @ASSERT(list.size() == 7 - i)
            @ASSERT(list.pop_front() == i)

        list.append([7, 6, 5, 4, 3, 2, 1, 0])
        
        # Idiosyncratic pushes and pops.
        list.push(5)
        @ASSERT(list.pop() == 5)
        list.push(7)
        @ASSERT(list.pop() == 7)

        for i in [0...8]
            @ASSERT(list.size() == 8 - i)
            @ASSERT(list.pop() == i)

        @ASSERT(list.isEmpty())

        # Test clear.
        list.append([7, 6, 5, 4, 3, 2, 1, 0])
        @ASSERT(list.size() == 8)
        list.clear()
        @ASSERT(list.isEmpty())

        for i in [0...1000]
            list.add(i)

        # Test forwards iteration.
        iter = list.begin()
        i = 0
        while(iter.hasNext())
            @ASSERT(iter.next() == i)
            i++

        # Test backwards iteration.
        iter = list.end()
        while(iter.hasPrev())
            i--
            @ASSERT(iter.prev() == i)

        iter = list.begin()
        i = 0
        while(iter.hasNext())
            # Remove odd numbers
            if iter.next() % 2 == 1
                iter.remove()
            i++

        iter = list.begin()
        i = 0
        while(iter.hasNext())
           @ASSERT(iter.next() == i)
           i += 2

    test_points: () ->

        p0 = new BDS.Point(1, 1, 1)
        p1 = new BDS.Point(2, 3, 4)

        # Addition.
        p2 = p0.add(p1)
        @ASSERT(p2.x == 3)
        @ASSERT(p2.y == 4)
        @ASSERT(p2.z == 5)

        # Subtraction.
        p2 = p0.sub(p1)
        @ASSERT(p2.x == -1)
        @ASSERT(p2.y == -2)
        @ASSERT(p2.z == -3)

        p2 = p1.sub(p0)
        @ASSERT(p2.x == 1)
        @ASSERT(p2.y == 2)
        @ASSERT(p2.z == 3)        

        # Multiplication
        p2 = p0.multScalar(5)
        @ASSERT(p2.x == 5)
        @ASSERT(p2.y == 5)
        @ASSERT(p2.z == 5)

        p2 = new BDS.Point(5, 0)

        mag = p2.norm2()
        @ASSERT(24.99 < mag and mag < 25.01)
        mag = p2.norm()
        @ASSERT(4.99 < mag and mag < 5.01)


    test_lines: () ->

        points = [new BDS.Point(0, 0), new BDS.Point(2, 0), new BDS.Point(1, 1), new BDS.Point(1, -1)]

        l0 = new BDS.Line(0, 1, points)
        l1 = new BDS.Line(2, 3, points)

        @ASSERT(points[0] == l0.p1)
        @ASSERT(points[1] == l0.p2)

        @ASSERT(points[2] == l1.p1)
        @ASSERT(points[3] == l1.p2)

        @ASSERT(l0.line_side_test(points[2]) * l0.line_side_test(points[3]) < 0)

        @ASSERT(l0.detect_intersection(l1))
        @ASSERT(l1.detect_intersection(l0))

        @ASSERT(points.length == 4)
        @ASSERT(l0.intersect(l1))

        pt = l0.getLatestIntersectionPoint()
        @ASSERT(pt.y < .0001 and pt.y > -.0001)

        @ASSERT(points.length == 5)

        return

    test_intersector: () ->

        len = 100

        points = [new BDS.Point(0, 0),
                  new BDS.Point(100, 0)]

        for i in [0...len] by 1
            points.push(new BDS.Point(i + .1, -1))
            points.push(new BDS.Point(i + .1, 1))

        lines = []
        lines.push(new BDS.Line(0, 1, points))
        for i in [0...len] by 1
            i1 = 2 + i*2
            i2 = 2 + i*2 + 1
            lines.push(new BDS.Line(i1, i2, points))


        intersector = new BDS.Intersector()


        ###
        Test Brute Force intersection.
        ###

        intersector.intersect_brute_force(lines)

        split_lines = []
        len = lines.length
        for i in [0...len] by 1
            lines[i].getSplitLines(split_lines)

        # middle lines, up lines, and down lines.
        @ASSERT(split_lines.length == 101 + 100 + 100)

        for i in [1...len] by 1
            @ASSERT(Math.floor(split_lines[i].p1.x) == i - 1)
            @ASSERT(Math.floor(split_lines[i].p2.x) == i)

        # Clear the previous results.
        for i in [0...len]
            lines[i].clearIntersections()

        ###
        Test Optimized Intersection.
        ###

        len = 100

        points = [new BDS.Point(0, 0),
                  new BDS.Point(100, 0)]

        for i in [0...len] by 1
            points.push(new BDS.Point(i + .1, -1))
            points.push(new BDS.Point(i + .1, 1))

        lines = []
        lines.push(new BDS.Line(0, 1, points))
        for i in [0...len] by 1
            i1 = 2 + i*2
            i2 = 2 + i*2 + 1
            lines.push(new BDS.Line(i1, i2, points))

        intersector.intersectLineSegments(lines)

        split_lines = []
        len = lines.length
        for i in [0...len] by 1
            lines[i].getSplitLines(split_lines)

        # middle lines, up lines, and down lines.
        @ASSERT(split_lines.length == 101 + 100 + 100)

        for i in [1...len] by 1
            @ASSERT(Math.floor(split_lines[i].p1.x) == i - 1)
            @ASSERT(Math.floor(split_lines[i].p2.x) == i)


        return

    test_halfedge: () ->


    test_arrays: () ->
        array = [0, 1, 2, 3, 4, 4, 4, 5]

        comparator = (a, b) -> a <= b

        # finding 0, 1, 2, and 3.
        for i in [0..3]
            @ASSERT(BDS.Arrays.binarySearch(array, i, comparator) == i)

        @ASSERT(BDS.Arrays.binarySearch(array, 4, comparator) == 6)
    
        # Larger than array should return the last array element.
        @ASSERT(BDS.Arrays.binarySearch(array, 89, comparator) == 7)

        # Check lower than array should return -1
        @ASSERT(BDS.Arrays.binarySearch(array, -89, comparator) == -1)

new BDS.Testing()

###
# Tests for sorting algorithms.

function is_sorted(array)
{
    var len = array.length;
    
    var val = array[0];
    
    for(var i = 1; i < len; i++)
    {
        var next_val = array[i];
    
        if(next_val < val)
        {
            return false;
        }
        
        val = next_val;
    }
    
    return true;
}

function test_array()
{
    return [1,3,2,5,4,7,7,9,13,0,2,1];
}

function test_sort(func, name)
{
    var test = test_array();
    func(test);
    console.log(name + " " + is_sorted(test));
}

function test_sorting()
{

    // -- Testing Code.
    var sort = new Sort();
    var test;

    test = test_array();
    console.log("UnSorted Array : " + test);
    console.log("isSorted = " + is_sorted(test));
    console.log("Insertion Sort.");
    sort.insertion_sort(test);
    console.log("Sorted Array : " + test);
    console.log("isSorted = " + is_sorted(test));
    console.log("");

    test = test_array();
    sort.quick_sort(test);
    console.log("Selection Sort = " + is_sorted(test));

    test = test_array();
    sort.insertion_sort(test);
    console.log("Insertion Sort = " + is_sorted(test));

    test = test_array();
    sort.quick_sort(test);
    console.log("Quick Sort = " + is_sorted(test));

    test = test_array();
    sort.merge_sort(test);
    console.log("Merge Sort = " + is_sorted(test));

    console.log(test);
}

function test_List()
{
    var list = new List();
    
    for(i = 0; i < 10; i++)
    {   
        list.push(i);
    }

    console.log("Size = " + list.size);
    
    list.print();
    
    var iter = list.iterator();
    
    // Remove all even numbers.
    while(iter.hasNext())
    {       
        var elem = iter.next();
        if(elem % 2 == 0)
        {
            iter.remove();
        }
    
    }
    
    list.print();
    
    list.make_empty();
    for(i = 0; i < 10; i++)
    {   
        list.enq(i);
    }
    
    for(i = 0; i < 10; i++)
    {
        console.log(list.deq(i));
    }
    
    
}

//test_sorting();
test_List();
###