// Generated by CoffeeScript 1.11.1

/*
Geometry Super Class
Written by Bryce Summers on 1 - 9 - 2017.

This class abstract away many common procedures and specifies a common interface for algorithms on geometries.
 */

(function() {
  BDS.Geometry = (function() {
    function Geometry(closed, filled) {
      this.closed = closed;
      this.filled = filled;
    }

    Geometry.prototype.generateBoundingBox = function() {};

    Geometry.prototype.containsPoint = function(pt) {};

    Geometry.prototype.detect_intersection_with_polyline = function(polyline) {
      throw new Error("Please Override Me!");
    };

    return Geometry;

  })();

}).call(this);