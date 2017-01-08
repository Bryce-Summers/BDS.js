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

    # inclusive.
    min = 0

    # exclusive.
    max = array.length

    mid = max/2

    while min < max

        elem_current = array[mid]

        #if 