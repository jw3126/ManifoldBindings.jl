# [ManifoldBindings.jl](https://github.com/jw3126/ManifoldBindings.jl)

[![Build Status](https://github.com/jw3126/ManifoldBindings.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/jw3126/ManifoldBindings.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/jw3126/ManifoldBindings.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/jw3126/ManifoldBindings.jl)

This package provides inofficial julia bindings for [manifold](https://github.com/elalish/manifold) a fast and robust mesh library.
It provides low level 1:1 bindings around the official C-API in `JuliaBindings.CAPI` and
also a memory safe high level api. The high level API is not yet fully implemented 
and might change in future.

# Usage
```julia
using StaticArrays
import ManifoldBindings as MB

# use a predefined mesh
radius = 1.1
nseg = 10
sphere = MB.Manifold_sphere(radius, nseg)

# create a custom mesh
vertices = [
    @SVector[-1.0, -1.0, 1.0],
    @SVector[-1.0, 1.0, -1.0],
    @SVector[1.0, -1.0, -1.0],
    @SVector[1.0, 1.0, 1.0],
]
triangles = [
    @SVector[0x00000003, 0x00000001, 0x00000002], 
    @SVector[0x00000001, 0x00000004, 0x00000002], 
    @SVector[0x00000003, 0x00000004, 0x00000001], 
    @SVector[0x00000004, 0x00000003, 0x00000002]
   ]
tetrahedron = MB.Manifold(vertices, triangles) # a custom tetrahedron

# get information out of a manifold
@assert MB.collect_vertices(tetrahedron)  == vertices
@assert MB.collect_triangles(tetrahedron) == triangles

# use a mesh boolean
m = MB.difference(tetrahedron, sphere)

# plotting support
using GLMakie
plot(m)
```
![difference.png](resources/difference.png)
