###
Standard Array methods.
###
BDS.Arrays = {}
BDS.Arrays.swap = (array, i1,i2) ->
  temp = array[i1]
  array[i1] = array[i2]
  array[i2] = temp
  return

# Returns the index of the highest element in the array that is
# less than or equal to the target element.
# NOTEs on comparators:
# Used to impose an orderings,
# comparator = (e1, e2) -> Returns true if e1 <= e2.
BDS.Arrays.binarySearch = (array, elem_target, comparator) ->

    if comparator == undefined
        comparator = (a, b) -> a <= b

    min = 0 # The minnimum element that is guranteed to be <= than the target.

    max = array.length - 1 # the maximum element that could be <= the target.

    mid = Math.floor(max/2)

    while min <= max

        elem_current = array[mid]

        # If current <= target, then we have a non strict lower bound.
        if comparator(elem_current, elem_target)
            min = mid + 1 # Force the min up.
        # Otherwise we have a strict upper bound.
        else      
            max = mid - 1# Force the max down.

        mid = Math.floor((min + max)/2)

    return min - 1

# Sorts an array of number, data associated pairs by their number.
# {key: data, value: data_value}
BDS.Arrays.sortByValue = (array) ->

    compare_func = (a, b) -> return a.value - b.value

    array.sort(compare_func)