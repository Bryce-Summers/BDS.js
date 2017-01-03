/*! Bryce Data Structures, a project by Bryce Summers.
 *  Single File concatenated by Grunt Concatenate on 03-01-2017
 */
/*
 * Defines namespaces.
 * Adapted by Bryce Summers on 1 - 2 - 2017.
 */

// Bryce Data Structures.
BDS = {};
// Generated by CoffeeScript 1.11.1

/*
Standard Array methods.
 */

(function() {
  BDS.Arrays = {};

  BDS.Arrays.swap = function(array, i1, i2) {
    var temp;
    temp = array[i1];
    array[i1] = array[i2];
    array[i2] = temp;
  };

}).call(this);

// Generated by CoffeeScript 1.11.1
(function() {
  BDS.S_Curve = (function() {
    function S_Curve() {
      this._spline = new THREE.CatmullRomCurve3();
      this._point_discretization = [];
    }

    S_Curve.prototype.addPoint = function(p) {
      return this._spline.points.push(p);
    };

    S_Curve.prototype.numPoints = function(p) {
      return this._spline.points.length;
    };

    S_Curve.prototype.getPointAtIndex = function(i) {
      return this._spline.points[i];
    };

    S_Curve.prototype.getLastPoint = function() {
      return this.getPointAtIndex(this.numPoints() - 1);
    };

    S_Curve.prototype.removeLastPoint = function() {
      return this._spline.points.pop();
    };

    S_Curve.prototype.position = function(t) {
      return this._spline.getPoint(t);
    };

    S_Curve.prototype.tangent = function(t) {
      return this._spline.getTangent(t);
    };

    S_Curve.prototype.offset = function(t, amount) {
      var tan, x, y;
      tan = this.tangent(t);
      tan.setLength(amount);
      x = tan.x;
      y = tan.y;
      tan.x = y;
      tan.y = -x;
      return this.position(t).add(tan);
    };

    S_Curve.prototype.getDiscretization = function(max_length) {
      return this._discretization;
    };

    S_Curve.prototype.updateDiscretization = function(max_length) {
      var S, high, low, output, p0, p_high, p_low;
      output = [];
      p0 = this._spline.getPoint(0);
      output.push(p0);
      S = [];
      S.push(1.0);
      low = 0;
      p_low = this._spline.getPoint(low);
      while (S.length !== 0) {
        high = S.pop();
        p_high = this._spline.getPoint(high);
        while (p_low.distanceTo(p_high) > max_length) {
          S.push(high);
          high = (low + high) / 2.0;
          p_high = this._spline.getPoint(high);
        }
        output.push(p_high);
        low = high;
        p_low = p_high;
        continue;
      }
      return this._discretization = output;
    };

    S_Curve.prototype.getOffsets = function(max_length, amount, times_output) {
      var S, high, low, o0, output, p_high, p_low;
      o0 = this.offset(0, amount);
      output = [];
      output.push(o0);
      if (times_output) {
        times_output.push(0);
      }
      S = [];
      S.push(1.0);
      low = 0;
      p_low = this.offset(low, amount);
      while (S.length !== 0) {
        high = S.pop();
        p_high = this.offset(high, amount);
        while (p_low.distanceTo(p_high) > max_length) {
          S.push(high);
          high = (low + high) / 2.0;
          p_high = this.offset(high, amount);
        }
        output.push(p_high);
        if (times_output) {
          times_output.push(high);
        }
        low = high;
        p_low = p_high;
        continue;
      }
      return output;
    };

    return S_Curve;

  })();

}).call(this);

// Generated by CoffeeScript 1.11.1
(function() {
  BDS.S_AABVH = (function() {
    function S_AABVH(obj, xyz) {
      var i, j, left_partition, ref, ref1, right_partition, triangle_list;
      this._leafs = [];
      this._leaf_node = false;
      if (obj instanceof THREE.Object3D) {
        triangle_list = this._extract_triangle_list(obj);
      } else {
        triangle_list = obj;
      }
      this._ensure_bounding_boxes(triangle_list);
      this._AABB = this._compute_AABB(triangle_list);
      if (triangle_list.length < 100) {
        this._leaf_node = true;
        for (i = j = 0, ref = triangle_list.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
          this._leafs.push(triangle_list[i]);
        }
        return;
      }
      if (xyz.dim === 2) {
        this._AABB.min.z = -1;
        this._AABB.max.z = +1;
      }
      triangle_list = this._sort_triangle_list(triangle_list, xyz);
      ref1 = this._partition_by_SA(triangle_list), left_partition = ref1[0], right_partition = ref1[1];
      xyz.val = this._nextXYZ(xyz);
      this._left = new TSAG.S_AABVH(left_partition, xyz);
      this._right = new TSAG.S_AABVH(right_partition, xyz);
    }

    S_AABVH.prototype.query_point = function(x, y) {
      var ray;
      ray = new THREE.Ray(new THREE.Vector3(x, y, 10), new THREE.Vector3(0, 0, 1));
      return this.query_ray(ray);
    };

    S_AABVH.prototype.query_ray = function(ray) {
      var a, b, c, i, intersection, j, output, ref, triangle;
      if (ray.intersectsBox(this._AABB) === null) {
        return null;
      }
      if (this._leaf_node) {
        for (i = j = 0, ref = this._leafs.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
          triangle = this._leafs[i];
          a = triangle.a;
          b = triangle.b;
          c = triangle.c;
          intersection = ray.intersectTriangle(a, b, c, false);
          if (intersection !== null) {
            return triangle;
          }
        }
      } else {
        output = this._left.query_ray(ray);
        if (output !== null) {
          return output;
        }
        output = this._right.query_ray(ray);
        if (output !== null) {
          return output;
        }
      }
      return null;
    };

    S_AABVH.prototype.toVisual = function(material) {
      var geom, geometries, j, len1, line, output;
      geometries = [];
      this.get_AABB_geometries(geometries);
      output = new THREE.Object3D();
      for (j = 0, len1 = geometries.length; j < len1; j++) {
        geom = geometries[j];
        line = new THREE.Line(geom, material);
        output.add(line);
      }
      return output;
    };

    S_AABVH.prototype.get_AABB_geometries = function(output) {
      var geometry, max, max_x, max_y, min, min_x, min_y;
      min = this._AABB.min;
      max = this._AABB.max;
      min_x = min.x;
      min_y = min.y;
      max_x = max.x;
      max_y = max.y;
      geometry = new THREE.Geometry();
      geometry.vertices.push(new THREE.Vector3(min_x, min_y, 0), new THREE.Vector3(max_x, min_y, 0), new THREE.Vector3(max_x, max_y, 0), new THREE.Vector3(min_x, max_y, 0), new THREE.Vector3(min_x, min_y, 0));
      output.push(geometry);
      if (!this._leaf_node) {
        this._left.get_AABB_geometries(output);
        this._right.get_AABB_geometries(output);
      }
    };


    /*
     - Private Construction Methods. -----------------------
     */

    S_AABVH.prototype._extract_triangle_list = function(obj) {
      var a, b, c, face, faces, geometry, j, k, len1, len2, localToWorld, mesh, mesh_list, triangle, triangle_list, vertices;
      mesh_list = this._extract_mesh_list(obj);
      triangle_list = [];
      for (j = 0, len1 = mesh_list.length; j < len1; j++) {
        mesh = mesh_list[j];
        geometry = mesh.geometry;
        vertices = geometry.vertices;
        faces = geometry.faces;
        localToWorld = mesh.matrixWorld;
        for (k = 0, len2 = faces.length; k < len2; k++) {
          face = faces[k];
          a = vertices[face.a].clone();
          b = vertices[face.b].clone();
          c = vertices[face.c].clone();
          a.applyMatrix4(localToWorld);
          b.applyMatrix4(localToWorld);
          c.applyMatrix4(localToWorld);
          triangle = new THREE.Triangle(a, b, c);
          triangle.mesh = mesh;
          triangle_list.push(triangle);
        }
      }
      return triangle_list;
    };

    S_AABVH.prototype._extract_mesh_list = function(obj) {
      var add_output, output;
      output = [];
      add_output = function(o) {
        if (o.geometry) {
          return output.push(o);
        }
      };
      obj.traverse(add_output);
      return output;
    };

    S_AABVH.prototype._sort_triangle_list = function(triangle_list, xyz) {
      var centroid_index_list, i, j, len, output, ref, sort_function, triangle_index;
      centroid_index_list = this._centroid_index_list(triangle_list);
      sort_function = function(a, b) {
        switch (xyz.val) {
          case 'x':
            return a.centroid.x - b.centroid.x;
          case 'y':
            return a.centroid.y - b.centroid.y;
          case 'z':
            return a.centroid.z - b.centroid.z;
        }
        debugger;
        return console.log("xyz is malformed.");
      };
      centroid_index_list.sort(sort_function);
      output = [];
      len = triangle_list.length;
      for (i = j = 0, ref = len; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
        triangle_index = centroid_index_list[i].index;
        output.push(triangle_list[triangle_index]);
      }
      return output;
    };

    S_AABVH.prototype._nextXYZ = function(xyz) {
      if (xyz.dim === 2) {
        switch (xyz.val) {
          case 'x':
            return 'y';
          case 'y':
            return 'x';
          case 'z':
            console.log("xyz is malformed.");
        }
        debugger;
        console.log("xyz is malformed.");
      } else if (xyz.dim === 3) {
        switch (xyz) {
          case 'x':
            return 'y';
          case 'y':
            return 'z';
          case 'z':
            return 'x';
        }
      }
      debugger;
      return console.log("Case not handled.");
    };

    S_AABVH.prototype._centroid_index_list = function(triangle_list) {
      var centroid_index_node, i, j, len, output, ref;
      output = [];
      len = triangle_list.length;
      for (i = j = 0, ref = len; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
        centroid_index_node = {};
        centroid_index_node.index = i;
        centroid_index_node.centroid = this._computeCentroid(triangle_list[i]);
        output.push(centroid_index_node);
      }
      return output;
    };

    S_AABVH.prototype._computeCentroid = function(triangle) {
      var centroid;
      centroid = new THREE.Vector3(0, 0, 0);
      centroid.add(triangle.a);
      centroid.add(triangle.b);
      centroid.add(triangle.c);
      centroid.divideScalar(3);
      return centroid;
    };

    S_AABVH.prototype._partition_by_SA = function(triangle_list) {
      var i, i0, j, k, l, left, left_AABB, m, min_index, min_sah, ref, ref1, ref2, ref3, ref4, right, right_AABB, sah, sah_left, sah_right;
      min_sah = Number.MAX_VALUE;
      min_index = -1;
      left = [triangle_list[0]];
      right = [];
      i0 = triangle_list.length - 1;
      for (i = j = ref = i0; ref <= 1 ? j <= 1 : j >= 1; i = ref <= 1 ? ++j : --j) {
        right.push(triangle_list[i]);
      }
      for (i = k = 1, ref1 = i0; 1 <= ref1 ? k <= ref1 : k >= ref1; i = 1 <= ref1 ? ++k : --k) {
        left_AABB = this._compute_AABB(left);
        sah_left = this._compute_SA(left_AABB);
        right_AABB = this._compute_AABB(right);
        sah_right = this._compute_SA(right_AABB);
        sah = Math.max(sah_left, sah_right);
        if (sah < min_sah) {
          min_sah = sah;
          min_index = i;
        }
        left.push(right.pop());
      }
      left = [];
      right = [];
      for (i = l = 0, ref2 = min_index; 0 <= ref2 ? l < ref2 : l > ref2; i = 0 <= ref2 ? ++l : --l) {
        left.push(triangle_list[i]);
      }
      for (i = m = ref3 = min_index, ref4 = i0; ref3 <= ref4 ? m <= ref4 : m >= ref4; i = ref3 <= ref4 ? ++m : --m) {
        right.push(triangle_list[i]);
      }
      return [left, right];
    };

    S_AABVH.prototype._ensure_bounding_boxes = function(triangle_list) {
      var i, j, len, ref, results, triangle;
      len = triangle_list.length;
      results = [];
      for (i = j = 0, ref = len; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
        triangle = triangle_list[i];
        if (!triangle) {
          debugger;
        }
        if (!triangle.boundingBox) {
          results.push(this._computeBoundingBox(triangle));
        } else {
          results.push(void 0);
        }
      }
      return results;
    };

    S_AABVH.prototype._computeBoundingBox = function(triangle) {
      var AABB;
      AABB = new THREE.Box3();
      AABB.expandByPoint(triangle.a);
      AABB.expandByPoint(triangle.b);
      AABB.expandByPoint(triangle.c);
      return triangle.boundingBox = AABB;
    };

    S_AABVH.prototype._compute_AABB = function(triangle_list) {
      var AABB, i, j, output, ref, triangle;
      output = new THREE.Box3();
      for (i = j = 0, ref = triangle_list.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
        triangle = triangle_list[i];
        AABB = triangle.boundingBox;
        output.union(AABB);
      }
      return output;
    };

    S_AABVH.prototype._compute_SA = function(AABB) {
      var dx, dy, dz, max, min, sxy, sxz, syz;
      min = AABB.min;
      max = AABB.max;
      dx = max.x - min.x;
      dy = max.y - min.y;
      dz = max.z - min.z;
      sxy = dx * dy;
      sxz = dx * dz;
      syz = dy * dz;
      return sxy + sxz + syz;
    };

    return S_AABVH;

  })();

}).call(this);

// Generated by CoffeeScript 1.11.1

/*
Heap
Implements a priority Queue using an Array Heap.
Written by Bryce Summers on 11 - 2 - 2017.

 * 
 * Note : This is a MIN heap.
 * 
 * Heap property :  For every element in the tree,
 *                  it is less than or equal to its left and right children in the tree as defined by the elements at the indexes associated by
 *                  the relationships index_left(index) and index_right(index).
 *  
 * Root node is always at index 0.
 * 
 * Left biased, when equal keys are present, the one on the left will be chosen.
 * 
 * Allows for duplicate keys.
 * 
 * Binary tree invariants :
 * The heap is represented by a binary tree that is encoded by index relationships within an unbounded array.
 * We maintain the UBA with a minimality of nodes, so the UBA will only contain N elements, when size = n.
 * 
 * The heap is as balanced as possible. This causes their to be a preference for left children over right children.
 * 
 * FIXME : I will need to work to preserve key stability, so that all keys will eventually be deleted, even if all keys entered are equal.
 */

(function() {
  BDS.Heap = (function() {
    Heap._D = 3;

    function Heap(data_in, comparator) {
      this._LE = comparator;
      if (!data_in) {
        this._data = [];
      } else {
        this._data = data_in.slice(0);
        this._heapify();
      }
    }

    Heap.prototype.size = function() {
      return this._data.length;
    };

    Heap.prototype.isEmpty = function() {
      return this._data.length === 0;
    };

    Heap.prototype.add = function(elem) {
      var len;
      len = this._data.length;
      this._data.push(elem);
      return this._sift_up(len);
    };

    Heap.prototype.append = function(elems) {
      var e, j, len1, results;
      results = [];
      for (j = 0, len1 = elems.length; j < len1; j++) {
        e = elems[j];
        results.push(this.add(e));
      }
      return results;
    };

    Heap.prototype.peek = function() {
      return this._data[0];
    };

    Heap.prototype.dequeue = function() {
      var last, output;
      if (this._data.length === 1) {
        return this._data.pop();
      }
      output = this._data[0];
      last = this._data.pop();
      this._data[0] = last;
      this.sift_down(0);
      return output;
    };

    Heap.prototype.toArray = function() {
      return this._data.slice(0);
    };

    Heap.prototype.getElem = function(index) {
      return this._data[index];
    };


    /*
    // Heapifies all of the nodes of the Tree with a root at the given index.
    // Builds the heap invariant downwards to all sub trees.
    // O(n), checks each node in the tree once.
    // Transforms a random array into an array that meets the heap invariants.
     */

    Heap.prototype._heapify = function() {
      var i, j, ref;
      for (i = j = ref = this._data.length - 1; ref <= 0 ? j <= 0 : j >= 0; i = ref <= 0 ? ++j : --j) {
        this.sift_down(i);
      }
    };


    /*
    // Given an index, swaps the node down the tree while maintaining the min
    // heap invariant until the node is in an invariant correct place.
    // O(log(n)). Non recursive, so has O(1) function calls.
    // SIFT down.
     */

    Heap.prototype.sift_down = function(index) {
      var child, child_index, elem, i, min_elem, min_elem_index, size;
      size = this._data.length;
      child_index = this._index_child(index, 1);
      elem = this._data[index];
      while (child_index < size) {
        min_elem_index = -1;
        min_elem = elem;
        i = child_index;
        while (i < child_index + BDS.Heap._D && i < size) {
          child = this._data[i];
          if (this._LE(child, min_elem)) {
            min_elem = child;
            min_elem_index = i;
          }
          i++;
        }
        if (min_elem === elem) {
          return;
        }
        this._min_first(index, min_elem_index);
        index = min_elem_index;
        child_index = this._index_child(index, 1);
      }
    };

    Heap.prototype._sift_up = function(index) {
      var parent_index, results;
      parent_index = this._index_parent(index);
      results = [];
      while (index > 0 && this._min_first(parent_index, index)) {
        index = parent_index;
        results.push(parent_index = this._index_parent(index));
      }
      return results;
    };

    Heap.prototype._index_parent = function(index) {
      return Math.floor((index - 1) / BDS.Heap._D);
    };

    Heap.prototype._index_child = function(index, child_index) {
      return BDS.Heap._D * index + child_index;
    };

    Heap.prototype._min_first = function(index1, index2) {
      var elem1, elem2;
      elem1 = this._data[index1];
      elem2 = this._data[index2];
      if (!this._LE(elem1, elem2)) {
        BDS.Arrays.swap(this._data, index1, index2);
        return true;
      }
      return false;
    };

    Heap.prototype.toString = function() {
      var elem, j, len1, output, ref;
      output = "";
      output += "\nMinHeap[";
      ref = this._data;
      for (j = 0, len1 = ref.length; j < len1; j++) {
        elem = ref[j];
        output += elem;
        output += ",\n";
      }
      output += "]";
      return output;
    };

    Heap.prototype.clone = function() {
      return new BDS.Heap(this._data, this._LE);
    };

    Heap.prototype.toSortedArray = function() {
      var heap, i, j, len, output, ref;
      len = this._data.length;
      output = [];
      heap = this.clone();
      for (i = j = 0, ref = len; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
        output.push(heap.dequeue());
      }
      return output;
    };

    Heap.prototype.clear = function() {
      return this._data = [];
    };

    return Heap;

  })();

}).call(this);
