###

HalfedgeMesh Data Structure.

Written by Bryce Summers on _____

Purpose: An elegant connectivity data structure for polygonal meshes,
         which are b-reps of manifolds and manifolds with boundaries.


Note: This is a 3D halfedge class, not to be confused with the 2D halfedgegraph class
      found in Scribble.js, which is specially made for doing planar geometry.

###

class BDS.HalfedgeMesh
    constructor: (triangles) -> # Could be quads as well...
