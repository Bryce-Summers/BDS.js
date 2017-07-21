// Generated by CoffeeScript 1.11.1

/*

FaceLink Data Structure.
Written by Bryce Summers on July.10.2017

Purpose: Low memory data structure for storing the linkages between the triangles in a manifold mesh.
         BDS.FaceLinkGraph may be used allocate and connect a bunch of face links.

     A +
       |\
       | \  @C
       |  \
    @B |   + B
       |  /
       | /  @A
       |/
     C +
 */

(function() {
  BDS.FaceLinkData = (function() {
    function FaceLinkData(faceLink) {
      this.faceLink = faceLink;

      /*
      Other data fields may be allocated here externally.
      Some common fields include:
       - triangle, a geometric structure corresponding to the indices.
       */
    }

    return FaceLinkData;

  })();

  BDS.FaceLink = (function() {
    function FaceLink() {
      this.data = new BDS.FaceLinkData(this);
      this.a = null;
      this.b = null;
      this.c = null;
    }

    return FaceLink;

  })();

  BDS.FaceLinkGraph = (function() {
    function FaceLinkGraph(indices) {
      this._faceLinks = null;
      this._build_from_indices(indices);
    }

    FaceLinkGraph.prototype._build_from_indices = function(indices) {
      var a, b, c, edgeLink_a, edgeLink_b, edgeLink_c, edge_a, edge_b, edge_c, faceLink, i, index, j, len, map, ref;
      map = new Map();
      this._faceLinks = [];
      len = Math.floor(indices.length / 3);
      for (i = j = 0, ref = len; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
        index = i * 3;
        a = indices[index];
        b = indices[index + 1];
        c = indices[index + 2];
        faceLink = new BDS.FaceLink();
        this._faceLinks.push(faceLink);
        edge_a = this._l2s(b, c);
        edge_b = this._l2s(c, a);
        edge_c = this._l2s(a, b);
        edgeLink_a = map.get(edge_a);
        if (edgeLink_a) {
          faceLink.a = edgeLink_a.faceLink;
          this._link(edgeLink_a, faceLink);
          map["delete"](edge_a);
        } else {
          edge_a = this._l2s(c, b);
          map.set(edge_a, {
            faceLink: faceLink,
            type: 'a'
          });
        }
        edgeLink_b = map.get(edge_b);
        if (edgeLink_b) {
          faceLink.b = edgeLink_b.faceLink;
          this._link(edgeLink_b, faceLink);
          map["delete"](edge_b);
        } else {
          edge_b = this._l2s(a, c);
          map.set(edge_b, {
            faceLink: faceLink,
            type: 'b'
          });
        }
        edgeLink_c = map.get(edge_c);
        if (edgeLink_c) {
          faceLink.c = edgeLink_c.faceLink;
          this._link(edgeLink_c, faceLink);
          map["delete"](edge_c);
        } else {
          edge_c = this._l2s(b, a);
          map.set(edge_c, {
            faceLink: faceLink,
            type: 'c'
          });
        }
      }
    };

    FaceLinkGraph.prototype._l2s = function(i1, i2) {
      return "" + i1 + "_" + i2;
    };

    FaceLinkGraph.prototype._link = function(edgeLink, target) {
      var src, type;
      src = edgeLink.faceLink;
      type = edgeLink.type;
      if (type === 'a') {
        src.a = target;
      }
      if (type === 'b') {
        src.b = target;
      }
      if (type === 'c') {
        src.c = target;
      }
    };

    FaceLinkGraph.prototype.size = function() {
      return this._faceLinks.length;
    };

    FaceLinkGraph.prototype.get = function(index) {
      return this._faceLinks[index];
    };

    FaceLinkGraph.prototype.eval_data = function(func) {
      var faceLink, j, len1, ref;
      ref = this._faceLinks;
      for (j = 0, len1 = ref.length; j < len1; j++) {
        faceLink = ref[j];
        func(faceLink.data);
      }
    };

    FaceLinkGraph.prototype.map_data = function(func, inputs) {
      var faceLink, i, input, j, len, ref;
      len = this.size();
      for (i = j = 0, ref = len; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
        faceLink = this._faceLinks[i];
        input = inputs[i];
        func(faceLink.data, input);
      }
    };

    return FaceLinkGraph;

  })();

}).call(this);