/*
Standard Array methods.
*/

Array.prototype.swap = function (i1,i2) {
  var temp = this[i1];
  this[i1] = this[i2];
  this[i2] = temp;
  return this;
}