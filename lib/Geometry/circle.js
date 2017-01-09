// Generated by CoffeeScript 1.11.1

/*

Circle Class
Written by Bryce Summers on 1 - 6 - 2017.
 */

(function() {
  BDS.Circle = (function() {
    function Circle(_center, _radius, filled) {
      this._center = _center;
      this._radius = _radius;
      this.filled = filled;
      if (this.filled === void 0) {
        this.filled = false;
      }

      /*
      @_boundingbox, stored the bounding box.
       */
    }

    Circle.prototype.isFilled = function() {
      return this.filled;
    };

    Circle.prototype.setPosition = function(x, y) {
      this._center.x = x;
      return this._center.y = y;
    };

    Circle.prototype.getPosition = function() {
      return this._center.clone();
    };

    Circle.prototype.getRadius = function() {
      return this._radius;
    };

    Circle.prototype.minnimum_time_of_intersection_with_ray = function(ray) {
      var det, det_sqr, l, loc, o, o_sub_c, o_sub_c_sqr, time1, time2;
      o = ray.getPoint();
      l = ray.getDirection();
      o_sub_c = o.sub(this._center);
      o_sub_c_sqr = o_sub_c.dot(o_sub_c);
      if (this.filled && Math.sqrt(o_sub_c_sqr) < this._radius) {
        return 0;
      }
      loc = o_sub_c.dot(l);
      det_sqr = loc * loc - o_sub_c_sqr + this._radius * this._radius;
      if (det_sqr < 0) {
        return null;
      }
      det = Math.sqrt(det_sqr);
      time1 = -loc + det;
      time2 = -loc - det;
      if (time2 > 0) {
        return time2;
      }
      if (time1 > 0) {
        return time1;
      }
      return null;
    };

    Circle.prototype.detect_intersection_with_line = function(line) {
      var in1, in2;
      in1 = this.containsPoint(line.p1);
      in2 = this.containsPoint(line.p1);
      if (this.filled && (in1 || in2)) {
        return true;
      }
      return (in1 && !in2) || (!in1 && in2);
    };

    Circle.prototype.containsPoint = function(pt) {
      var diff, dist;
      diff = pt.sub(this._center);
      dist = diff.norm();
      return dist < this._radius;
    };

    Circle.prototype.generateBoundingBox = function() {
      var max, min;
      this._boundingbox = new BDS.Box();
      min = this._center.clone();
      min.x -= this._radius;
      min.y -= this._radius;
      max = this._center.clone();
      max.x += this._radius;
      max.y += this._radius;
      this._boundingbox.expandByPoint(min);
      this._boundingbox.expandByPoint(max);
      return this._boundingbox;
    };

    Circle.prototype.getBoundingBox = function() {
      return this._boundingbox;
    };

    return Circle;

  })();

}).call(this);