# Programming Guide

We will have a javascript injected index.html file for the current build.

We will then concatenate standalone builds for each experiment once we are done.

My goal is that whenever I want to go test out programming something, I can jsut come to this repository and hit the ground running writing logic,
rather then worrying about setting up a repository.

# GIT
To checkout a remote branch use:
git fetch
git checkout i[x]

# Grunt

run 'grunt' to include all of the files.
run 'grunt concat' to build a single file.



TSAG
element.bvh  // BDS.BVH2D
element.view // THREE.Object3D
element.topology // SCRIB.HalfedgeGraph element.

THREE
Object3D.element      // TSAG.Element

[SCRIB.HalfedgeGraph element].data.element // TSAG.Element


Sub structures update macro structures with addition and subtraction calls.
For instance, a road element will need to add its collision geometry to the e_network.