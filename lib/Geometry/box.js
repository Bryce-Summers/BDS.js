// Generated by CoffeeScript 1.11.1

/*
Box.

Written by Bryce Summers on 1 - 5 - 2017
 */

(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  BDS.Box = (function(superClass) {
    extend(Box, superClass);

    function Box(min, max, _isFilled) {
      this.min = min;
      this.max = max;
      this._isFilled = _isFilled;
      if (!this.min) {
        this.min = new BDS.Point(Number.MAX_VALUE, Number.MAX_VALUE, Number.MAX_VALUE);
      }
      if (!this.max) {
        this.max = new BDS.Point(Number.MIN_VALUE, Number.MIN_VALUE, Number.MIN_VALUE);
      }
      if (!this._isFilled) {
        this._isFilled = true;
      }
    }

    Box.prototype.clone = function() {
      return new BDS.Box(this.min.clone(), this.max.clone());
    };

    Box.prototype.isFilled = function() {
      return this._isFilled;
    };

    Box.prototype.expandByPoint = function(p) {
      this.min = this.min.min(p);
      return this.max = this.max.max(p);
    };

    Box.prototype.union = function(box) {
      var out;
      out = this.clone();
      out.min = this.min.min(box.min);
      out.max = this.max.max(box.max);
      return out;
    };

    Box.prototype.intersect = function(box) {
      var out;
      out = this.clone();
      out.min = this.min.max(box.min);
      out.max = this.max.min(box.max);
      return out;
    };

    Box.prototype.containsPoint = function(pt) {
      return pt.greaterThanOrEqual(this.min) && pt.lessThanOrEqual(this.max);
    };

    Box.prototype.getRandomPointInBox = function() {
      var range, x, y, z;
      range = this.max.sub(this.min);
      x = this.min.x + Math.random() * range.x;
      y = this.min.y + Math.random() * range.y;
      z = this.min.z + Math.random() * range.z;
      return new BDS.Point(x, y, z);
    };

    Box.prototype.area = function() {
      var area, diff;
      diff = this.max.sub(this.min);
      area = Math.abs(diff.x * diff.y);
      if (diff.x < 0 || diff.y < 0) {
        area = -area;
      }
      return area;
    };

    Box.prototype.intersects_box = function(box) {
      var intersection;
      intersection = this.intersect(box);
      return intersection.area() >= 0;
    };

    Box.prototype.toPolyline = function() {
      var p0, p1, p2, p3, points, polyline;
      p0 = this.min.clone();
      p1 = this.min.clone();
      p1.x = this.max.x;
      p2 = this.max.clone();
      p3 = this.min.clone();
      p3.y = this.max.y;
      points = [p0, p1, p2, p3];
      polyline = new BDS.Polyline(true, points, this._isFilled);
      return polyline;
    };


    /*
    Ray Queries
     Here are some top of the brain approaches:
     - Raycast all 6 quad faces.
     - Raycast 12 triangle faces.
     - Since we are axis aligned, we could the ray reletive to center of box space, 
       then prune faces that the ray won't hit. This seems to be the major win for Axis-Alignment.
    
     I looked online and found a better quadrant based approach and modified it to find the exit point for the box as well.
     */

    Box.prototype.rayQueryMin = function(rayQuery) {
      var new_time;
      new_time = this._isect_ray(rayQuery.ray);
      if (0 <= new_time && new_time < rayQuery.min_time) {
        rayQuery.time = new_time;
        rayQuery.min_time = new_time;
        rayQuery.obj = this;
        return true;
      }
      return false;
    };

    Box.prototype.rayQueryAll = function(rayQuery) {
      if (this.rayQueryTimes(rayQuery)) {
        rayQuery.objs.push(this);
        return true;
      }
      return false;
    };

    Box.prototype.rayQueryTime = function(rayQuery) {
      var new_time;
      new_time = this._isect_ray(rayQuery.ray);
      if (0 <= new_time) {
        rayQuery.time = new_time;
        return true;
      }
      return false;
    };

    Box.prototype.rayQueryTimes = function(rayQuery) {
      var enter_time, exit_ray, exit_search, exit_time;
      enter_time = this._isect_ray(rayQuery.ray);
      if (enter_time < 0) {
        return false;
      }
      exit_search = this._exit_ray(rayQuery.ray, enter_time);
      exit_ray = exit_search.ray;
      exit_time = exit_search.origin_time - this._isect_ray(exit_ray);
      rayQuery.times.push(enter_time);
      rayQuery.times.push(exit_time);
      return true;
    };

    Box.prototype._exit_ray = function(ray, enter_time) {
      var direction, max_distance_in_box_lower_bound, new_ray, new_time, origin;
      max_distance_in_box_lower_bound = this._manhattanDiagonal();
      new_time = enter_time + max_distance_in_box_lower_bound;
      origin = ray.getPointAtTime(new_time);
      direction = ray.getDirection().multScalar(-1);
      new_ray = new BDS.Ray(origin, direction);
      return {
        ray: new_ray,
        origin_time: new_time
      };
    };

    Box.prototype._manhattanDiagonal = function() {
      return this.max.x - this.min.x + this.max.y - this.min.y + this.max.z - this.min.z;
    };

    Box.prototype._isect_ray = function(ray) {
      var LEFT, MIDDLE, NUMDIM, RIGHT, candidatePlane, coord, dir, i, inside, j, k, l, m, maxB, maxT, minB, n, origin, quadrant, ref, ref1, ref2, ref3, ref4, results, whichPlane;
      NUMDIM = 3;
      ref = (function() {
        results = [];
        for (var j = 0; 0 <= NUMDIM ? j <= NUMDIM : j >= NUMDIM; 0 <= NUMDIM ? j++ : j--){ results.push(j); }
        return results;
      }).apply(this), RIGHT = ref[0], LEFT = ref[1], MIDDLE = ref[2];
      minB = this.min.toArray();
      maxB = this.max.toArray();
      origin = ray.getPoint().toArray();
      dir = ray.getDirection().toArray();
      inside = true;
      quadrant = [BDS.Box.LEFT, BDS.Box.LEFT, BDS.Box.LEFT];
      i = 0;
      maxT = [0, 0, 0];
      candidatePlane = [0, 0, 0];
      coord = [0, 0, 0];
      for (i = k = 0, ref1 = NUMDIM; k < ref1; i = k += 1) {
        if (origin[i] < minB[i]) {
          quadrant[i] = LEFT;
          candidatePlane[i] = minB[i];
          inside = false;
        } else if (origin[i] > maxB[i]) {
          quadrant[i] = RIGHT;
          candidatePlane[i] = maxB[i];
          inside = false;
        } else {
          quadrant[i] = MIDDLE;
        }
      }
      if (inside) {
        return 0;
      }
      for (i = l = 0, ref2 = NUMDIM; l < ref2; i = l += 1) {
        if (quadrant[i] !== MIDDLE && dir[i] !== 0) {
          maxT[i] = (candidatePlane[i] - origin[i]) / dir[i];
        } else {
          maxT[i] = -1;
        }
      }
      whichPlane = 0;
      for (i = m = 1, ref3 = NUMDIM; m < ref3; i = m += 1) {
        if (maxT[whichPlane] < maxT[i]) {
          whichPlane = i;
        }
      }
      if (maxT[whichPlane] < 0) {
        return -1;
      }
      for (i = n = 0, ref4 = NUMDIM; 0 <= ref4 ? n < ref4 : n > ref4; i = 0 <= ref4 ? ++n : --n) {
        if (whichPlane !== i) {
          coord[i] = origin[i] + maxT[whichPlane] * dir[i];
          if (coord[i] < minB[i] || coord[i] > maxB[i]) {
            return -1;
          }
        } else {
          coord[i] = candidatePlane[i];
        }
      }
      return maxT[whichPlane];
    };

    return Box;

  })(BDS.RayQueryable);

}).call(this);
