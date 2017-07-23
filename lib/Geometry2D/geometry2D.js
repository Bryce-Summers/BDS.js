// Generated by CoffeeScript 1.11.1

/*
Geometry2D Super Class
Written by Bryce Summers on 1 - 9 - 2017.

This class abstract away many common procedures and specifies a common interface for algorithms on geometries.
 */

(function() {
  BDS.Geometry2D = (function() {
    function Geometry2D(closed, filled) {
      this.closed = closed;
      this.filled = filled;
    }

    Geometry2D.prototype.generateBoundingBox = function() {};

    Geometry2D.prototype.containsPoint = function(pt) {};

    Geometry2D.prototype.detect_intersection_with_polyline = function(polyline) {
      throw new Error("Please Override Me!");
    };

    return Geometry2D;

  })();

}).call(this);