// Generated by CoffeeScript 1.11.1

/*
Line with associated intersection data.
Written by Bryce Summers on 1 - 2 - 2017.

This class is designed for intersection techniques and line segment splitting,
rather than for simply representing a line segment.
Please use Polylines for the geometric representation and drawing of lines.
 */

(function() {
  BDS.Line = (function() {
    function Line(start_point_index, end_point_index, point_array) {
      this.p1_index = start_point_index;
      this.p2_index = end_point_index;
      this.points = point_array;
      this.p1 = this.points[this.p1_index];
      this.p2 = this.points[this.p2_index];
      this.offset = this.p2.sub(this.p1);
      this.split_points_per = [];
      this.split_points_indices = [];
    }


    /*
    intersects the given other_line with this line.
    Adds a split point if they do intersect.
    Any created split points are added to the referenced global collection of points.
     * Line -> bool
     */

    Line.prototype.intersect = function(other) {
      if (this.p1_index === other.p1_index || this.p1_index === other.p2_index || this.p2_index === other.p1_index || this.p2_index === other.p2_index) {
        return false;
      }
      if (!this.detect_intersection(other)) {
        return false;
      }
      this._report_intersection(other);
      return true;
    };


    /*
    Returns a signed floating point number indicating which direction the given point is relative to this line.
     * Point -> float.
     */

    Line.prototype.line_side_test = function(c) {
      return (this.p2.x - this.p1.x) * (c.y - this.p1.y) - (this.p2.y - this.p1.y) * (c.x - this.p1.x);
    };


    /*
    Appends all of the split set of lines in order to the output vector.
    Adds itself if it does not contain any split lines.
    Line pts are oriented along the polyline, such that p1 comes before p2 in the polyline + intersection point ordering.
    Line[] -> void
     */

    Line.prototype.getSplitLines = function(lines_out) {
      var i, j, last_indice, len, next_indice, ref;
      len = this.split_points_per.length;
      if (len === 0) {
        lines_out.push(this);
        return;
      }
      this._sort_split_points();
      this.split_points_indices.push(this.p2_index);
      last_indice = this.split_points_indices[0];
      lines_out.push(new BDS.Line(this.p1_index, last_indice, this.points));
      for (i = j = 1, ref = len; 1 <= ref ? j < ref : j > ref; i = 1 <= ref ? ++j : --j) {
        next_indice = this.split_points_indices[i];
        lines_out.push(new BDS.Line(last_indice, next_indice, this.points));
        last_indice = next_indice;
      }
      lines_out.push(new BDS.Line(last_indice, this.p2_index, this.points));
    };


    /*
    This function should only be called after a call to intersect has returned true.
    Returns the last intersection point.
    this is only guranteed to be valid immediatly after the true return from the intersect function.
    void -> Point.
     */

    Line.prototype.getLatestIntersectionPoint = function() {
      return this.points[this.points.length - 1];
    };


    /*
    Internally sorts the split points from the start to the end of this line.
     */

    Line.prototype._sort_split_points = function() {
      var i, i1, i2, j, k, len, ref, ref1, temp_f, temp_i;
      len = this.split_points_per.length;
      for (i = j = 1, ref = len; 1 <= ref ? j < ref : j > ref; i = 1 <= ref ? ++j : --j) {
        for (i2 = k = ref1 = i - 1; ref1 <= 0 ? k <= 0 : k >= 0; i2 = ref1 <= 0 ? ++k : --k) {
          i1 = i2 + 1;
          if (this.split_points_per[i2] <= this.split_points_per[i1]) {
            break;
          }
          temp_f = this.split_points_per[i2];
          this.split_points_per[i2] = this.split_points_per[i1];
          this.split_points_per[i1] = temp_f;
          temp_i = this.split_points_indices[i2];
          this.split_points_indices[i2] = this.split_points_indices[i1];
          this.split_points_indices[i1] = temp_i;
        }
      }
    };


    /*
    Returns true iff this line segment intersects with the other line segment.
    Doesn't do any degeneracy checking.
    Line -> bool.
     */

    Line.prototype.detect_intersection = function(other) {
      var a1, a2, a_opposites, b1, b2, b_opposites;
      a1 = this.line_side_test(other.p1);
      a2 = this.line_side_test(other.p2);
      b1 = other.line_side_test(this.p1);
      b2 = other.line_side_test(this.p2);

      /*
      The product of two point based line side tests will be negative iff
      the points are not on strictly opposite sides of the line.
      If the product is 0, then at least one of the points is on the line not containing the points.
       */

      /*
      epsilon = .001
      a_on = (Math.abs(a1) < epsilon or Math.abs(a2) < epsilon)
      b_on = (Math.abs(b1) < epsilon or Math.abs(b2) < epsilon)
       */
      a_opposites = a1 * a2 <= 0;
      b_opposites = b1 * b2 <= 0;
      if (a_opposites && b_opposites) {
        return true;
      }

      /*
                     (a_opposites and b_on) or
                     (a_on and b_opposites)
       */
    };


    /*
    Line -> void.
     */

    Line.prototype._report_intersection = function(other) {

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
      var ad, as, bd, bs, det, dx, dy, index, intersection_point, u, v;
      as = this.p1;
      bs = other.p1;
      ad = this.offset;
      bd = other.offset;
      dx = bs.x - as.x;
      dy = bs.y - as.y;
      det = bd.x * ad.y - bd.y * ad.x;
      u = (dy * bd.x - dx * bd.y) / det;
      v = (dy * ad.x - dx * ad.y) / det;
      this.split_points_per.push(u);
      other.split_points_per.push(v);
      intersection_point = as.add(ad.multScalar(u));
      index = this.points.length;
      this.points.push(intersection_point);
      this.split_points_indices.push(index);
      return other.split_points_indices.push(index);
    };

    Line.prototype.clearIntersections = function() {
      this.split_points_per = [];
      return this.split_points_indices = [];
    };

    Line.prototype.getNormal = function(pt) {
      var dir, normal, temp;
      normal = this.offset.normalize();
      temp = normal.x;
      normal.x = -normal.y;
      normal.y = temp;
      dir = pt.sub(this.p1);
      if (normal.dot(dir) < 0) {
        return normal.multScalar(-1);
      }
      return normal;
    };

    return Line;

  })();

}).call(this);