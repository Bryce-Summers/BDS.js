// Generated by CoffeeScript 1.11.1

/*
Ray Class.

Written by Bryce Summers on 1 - 6 - 2017.

Purpose:
 */

(function() {
  BDS.Ray = (function() {
    function Ray(point, dir, _time_scale) {
      this.dir = dir;
      this._time_scale = _time_scale;
      if (this._time_scale === void 0) {
        this._time_scale = this.dir.norm();
        this.dir = this.dir.divScalar(this._time_scale);
      } else {
        this.dir = this.dir.normalize();
      }
      this.p1 = point;
      this.p2 = this.p1.add(this.dir);
    }

    Ray.prototype.getPoint = function() {
      return this.p1.clone();
    };

    Ray.prototype.getDirection = function() {
      return this.dir.clone();
    };

    Ray.prototype.getRightPerpendicularDirection = function() {
      return new BDS.Point(-this.dir.y, this.dir.x);
    };

    Ray.prototype.getLeftPerpendicularDirection = function() {
      return new BDS.Point(this.dir.y, -this.dir.x);
    };

    Ray.prototype.getTimeScale = function() {
      return this._time_scale;
    };

    Ray.prototype.getPointAtTime = function(t) {
      return this.p1.add(this.dir.multScalar(t * this._time_scale));
    };

    Ray.prototype.detect_intersection_with_line = function(line) {
      var correct_direction, normal, side1, side2;
      side1 = this.line_side_test(line.p1);
      side2 = this.line_side_test(line.p2);
      normal = line.getNormal(this.p1);
      correct_direction = normal.dot(this.dir) < 0;
      return side1 * side2 <= 0 && correct_direction;
    };

    Ray.prototype.line_side_test = function(c) {
      return (this.p2.x - this.p1.x) * (c.y - this.p1.y) - (this.p2.y - this.p1.y) * (c.x - this.p1.x);
    };

    Ray.prototype.getAngle = function() {
      return Math.atan2(this.p2.y - this.p1.y, this.p2.x - this.p1.x);
    };

    Ray.prototype.intersect_ray = function(other) {

      /*
      u = ((bs.y - as.y) * bd.x - (bs.x - as.x) * bd.y) / (bd.x * ad.y - bd.y * ad.x)
      v = ((bs.y - as.y) * ad.x - (bs.x - as.x) * ad.y) / (bd.x * ad.y - bd.y * ad.x)
      Factoring out the common terms, this comes to:
      
      dx = bs.x - as.x
      dy = bs.y - as.y
      det = bd.x * ad.y - bd.y * ad.x
      u = (dy * bd.x - dx * bd.y) / det
      v = (dy * ad.x - dx * ad.y) / det
       */
      var ad, as, bd, bs, det, dx, dy, intersection_point, u, v;
      as = this.p1;
      bs = other.p1;
      ad = this.dir;
      bd = other.dir;
      dx = bs.x - as.x;
      dy = bs.y - as.y;
      det = bd.x * ad.y - bd.y * ad.x;
      u = (dy * bd.x - dx * bd.y) / det;
      v = (dy * ad.x - dx * ad.y) / det;

      /*
      if u < 0 or v < 0
          return null
       */
      if (det === 0) {
        return null;
      }
      intersection_point = as.add(ad.multScalar(u));
      if (isNaN(intersection_point.x)) {
        debugger;
        return null;
      }
      return intersection_point;
    };

    Ray.prototype.getPerpAndParLengths = function(pt) {
      var displacement, parrallel_component, perp_component;
      displacement = pt.sub(this.p1);
      parrallel_component = displacement.dot(this.dir);
      perp_component = displacement.dot(this.getRightPerpendicularDirection());
      return [Math.abs(perp_component), parrallel_component / this._time_scale];
    };

    Ray.prototype.projectPoint = function(pt) {
      var displacement, parrallel_component;
      displacement = pt.sub(this.p1);
      parrallel_component = displacement.dot(this.dir);
      return this.p1.add(this.dir.multScalar(parrallel_component));
    };

    return Ray;

  })();

}).call(this);
