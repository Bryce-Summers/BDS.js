###
Standard Array methods.
###
BDS.Arrays = {}
BDS.Arrays.swap = (array, i1,i2) ->
  temp = array[i1]
  array[i1] = array[i2]
  array[i2] = temp
  return
