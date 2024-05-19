module CAPI

const libmanifoldc = "libmanifoldc"
using CEnum

mutable struct ManifoldManifold end

mutable struct ManifoldManifoldVec end

mutable struct ManifoldCrossSection end

mutable struct ManifoldCrossSectionVec end

mutable struct ManifoldSimplePolygon end

mutable struct ManifoldPolygons end

mutable struct ManifoldMesh end

mutable struct ManifoldMeshGL end

mutable struct ManifoldBox end

mutable struct ManifoldRect end

struct ManifoldManifoldPair
    first::Ptr{ManifoldManifold}
    second::Ptr{ManifoldManifold}
end

struct ManifoldVec2
    x::Cfloat
    y::Cfloat
end

struct ManifoldVec3
    x::Cfloat
    y::Cfloat
    z::Cfloat
end

struct ManifoldIVec3
    x::Cint
    y::Cint
    z::Cint
end

struct ManifoldVec4
    x::Cfloat
    y::Cfloat
    z::Cfloat
    w::Cfloat
end

struct ManifoldProperties
    surface_area::Cfloat
    volume::Cfloat
end

@cenum ManifoldOpType::UInt32 begin
    MANIFOLD_ADD = 0
    MANIFOLD_SUBTRACT = 1
    MANIFOLD_INTERSECT = 2
end

@cenum ManifoldError::UInt32 begin
    MANIFOLD_NO_ERROR = 0
    MANIFOLD_NON_FINITE_VERTEX = 1
    MANIFOLD_NOT_MANIFOLD = 2
    MANIFOLD_VERTEX_INDEX_OUT_OF_BOUNDS = 3
    MANIFOLD_PROPERTIES_WRONG_LENGTH = 4
    MANIFOLD_MISSING_POSITION_PROPERTIES = 5
    MANIFOLD_MERGE_VECTORS_DIFFERENT_LENGTHS = 6
    MANIFOLD_MERGE_INDEX_OUT_OF_BOUNDS = 7
    MANIFOLD_TRANSFORM_WRONG_LENGTH = 8
    MANIFOLD_RUN_INDEX_WRONG_LENGTH = 9
    MANIFOLD_FACE_ID_WRONG_LENGTH = 10
    MANIFOLD_INVALID_CONSTRUCTION = 11
end

@cenum ManifoldFillRule::UInt32 begin
    MANIFOLD_FILL_RULE_EVEN_ODD = 0
    MANIFOLD_FILL_RULE_NON_ZERO = 1
    MANIFOLD_FILL_RULE_POSITIVE = 2
    MANIFOLD_FILL_RULE_NEGATIVE = 3
end

@cenum ManifoldJoinType::UInt32 begin
    MANIFOLD_JOIN_TYPE_SQUARE = 0
    MANIFOLD_JOIN_TYPE_ROUND = 1
    MANIFOLD_JOIN_TYPE_MITER = 2
end

function manifold_simple_polygon(mem, ps, length)
    ccall((:manifold_simple_polygon, libmanifoldc), Ptr{ManifoldSimplePolygon}, (Ptr{Cvoid}, Ptr{ManifoldVec2}, Csize_t), mem, ps, length)
end

function manifold_polygons(mem, ps, length)
    ccall((:manifold_polygons, libmanifoldc), Ptr{ManifoldPolygons}, (Ptr{Cvoid}, Ptr{Ptr{ManifoldSimplePolygon}}, Csize_t), mem, ps, length)
end

function manifold_simple_polygon_length(p)
    ccall((:manifold_simple_polygon_length, libmanifoldc), Csize_t, (Ptr{ManifoldSimplePolygon},), p)
end

function manifold_polygons_length(ps)
    ccall((:manifold_polygons_length, libmanifoldc), Csize_t, (Ptr{ManifoldPolygons},), ps)
end

function manifold_polygons_simple_length(ps, idx)
    ccall((:manifold_polygons_simple_length, libmanifoldc), Csize_t, (Ptr{ManifoldPolygons}, Cint), ps, idx)
end

function manifold_simple_polygon_get_point(p, idx)
    ccall((:manifold_simple_polygon_get_point, libmanifoldc), ManifoldVec2, (Ptr{ManifoldSimplePolygon}, Cint), p, idx)
end

function manifold_polygons_get_simple(mem, ps, idx)
    ccall((:manifold_polygons_get_simple, libmanifoldc), Ptr{ManifoldSimplePolygon}, (Ptr{Cvoid}, Ptr{ManifoldPolygons}, Cint), mem, ps, idx)
end

function manifold_polygons_get_point(ps, simple_idx, pt_idx)
    ccall((:manifold_polygons_get_point, libmanifoldc), ManifoldVec2, (Ptr{ManifoldPolygons}, Cint, Cint), ps, simple_idx, pt_idx)
end

function manifold_meshgl(mem, vert_props, n_verts, n_props, tri_verts, n_tris)
    ccall((:manifold_meshgl, libmanifoldc), Ptr{ManifoldMeshGL}, (Ptr{Cvoid}, Ptr{Cfloat}, Csize_t, Csize_t, Ptr{UInt32}, Csize_t), mem, vert_props, n_verts, n_props, tri_verts, n_tris)
end

function manifold_meshgl_w_tangents(mem, vert_props, n_verts, n_props, tri_verts, n_tris, halfedge_tangent)
    ccall((:manifold_meshgl_w_tangents, libmanifoldc), Ptr{ManifoldMeshGL}, (Ptr{Cvoid}, Ptr{Cfloat}, Csize_t, Csize_t, Ptr{UInt32}, Csize_t, Ptr{Cfloat}), mem, vert_props, n_verts, n_props, tri_verts, n_tris, halfedge_tangent)
end

function manifold_get_meshgl(mem, m)
    ccall((:manifold_get_meshgl, libmanifoldc), Ptr{ManifoldMeshGL}, (Ptr{Cvoid}, Ptr{ManifoldManifold}), mem, m)
end

function manifold_meshgl_copy(mem, m)
    ccall((:manifold_meshgl_copy, libmanifoldc), Ptr{ManifoldMeshGL}, (Ptr{Cvoid}, Ptr{ManifoldMeshGL}), mem, m)
end

function manifold_level_set(mem, sdf, bounds, edge_length, level, ctx)
    ccall((:manifold_level_set, libmanifoldc), Ptr{ManifoldMeshGL}, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{ManifoldBox}, Cfloat, Cfloat, Ptr{Cvoid}), mem, sdf, bounds, edge_length, level, ctx)
end

function manifold_level_set_seq(mem, sdf, bounds, edge_length, level, ctx)
    ccall((:manifold_level_set_seq, libmanifoldc), Ptr{ManifoldMeshGL}, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{ManifoldBox}, Cfloat, Cfloat, Ptr{Cvoid}), mem, sdf, bounds, edge_length, level, ctx)
end

function manifold_manifold_empty_vec(mem)
    ccall((:manifold_manifold_empty_vec, libmanifoldc), Ptr{ManifoldManifoldVec}, (Ptr{Cvoid},), mem)
end

function manifold_manifold_vec(mem, sz)
    ccall((:manifold_manifold_vec, libmanifoldc), Ptr{ManifoldManifoldVec}, (Ptr{Cvoid}, Csize_t), mem, sz)
end

function manifold_manifold_vec_reserve(ms, sz)
    ccall((:manifold_manifold_vec_reserve, libmanifoldc), Cvoid, (Ptr{ManifoldManifoldVec}, Csize_t), ms, sz)
end

function manifold_manifold_vec_length(ms)
    ccall((:manifold_manifold_vec_length, libmanifoldc), Csize_t, (Ptr{ManifoldManifoldVec},), ms)
end

function manifold_manifold_vec_get(mem, ms, idx)
    ccall((:manifold_manifold_vec_get, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldManifoldVec}, Cint), mem, ms, idx)
end

function manifold_manifold_vec_set(ms, idx, m)
    ccall((:manifold_manifold_vec_set, libmanifoldc), Cvoid, (Ptr{ManifoldManifoldVec}, Cint, Ptr{ManifoldManifold}), ms, idx, m)
end

function manifold_manifold_vec_push_back(ms, m)
    ccall((:manifold_manifold_vec_push_back, libmanifoldc), Cvoid, (Ptr{ManifoldManifoldVec}, Ptr{ManifoldManifold}), ms, m)
end

function manifold_boolean(mem, a, b, op)
    ccall((:manifold_boolean, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldManifold}, Ptr{ManifoldManifold}, ManifoldOpType), mem, a, b, op)
end

function manifold_batch_boolean(mem, ms, op)
    ccall((:manifold_batch_boolean, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldManifoldVec}, ManifoldOpType), mem, ms, op)
end

function manifold_union(mem, a, b)
    ccall((:manifold_union, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldManifold}, Ptr{ManifoldManifold}), mem, a, b)
end

function manifold_difference(mem, a, b)
    ccall((:manifold_difference, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldManifold}, Ptr{ManifoldManifold}), mem, a, b)
end

function manifold_intersection(mem, a, b)
    ccall((:manifold_intersection, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldManifold}, Ptr{ManifoldManifold}), mem, a, b)
end

function manifold_split(mem_first, mem_second, a, b)
    ccall((:manifold_split, libmanifoldc), ManifoldManifoldPair, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{ManifoldManifold}, Ptr{ManifoldManifold}), mem_first, mem_second, a, b)
end

function manifold_split_by_plane(mem_first, mem_second, m, normal_x, normal_y, normal_z, offset)
    ccall((:manifold_split_by_plane, libmanifoldc), ManifoldManifoldPair, (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{ManifoldManifold}, Cfloat, Cfloat, Cfloat, Cfloat), mem_first, mem_second, m, normal_x, normal_y, normal_z, offset)
end

function manifold_trim_by_plane(mem, m, normal_x, normal_y, normal_z, offset)
    ccall((:manifold_trim_by_plane, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldManifold}, Cfloat, Cfloat, Cfloat, Cfloat), mem, m, normal_x, normal_y, normal_z, offset)
end

function manifold_slice(mem, m, height)
    ccall((:manifold_slice, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Ptr{ManifoldManifold}, Cfloat), mem, m, height)
end

function manifold_project(mem, m)
    ccall((:manifold_project, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Ptr{ManifoldManifold}), mem, m)
end

function manifold_hull(mem, m)
    ccall((:manifold_hull, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldManifold}), mem, m)
end

function manifold_batch_hull(mem, ms)
    ccall((:manifold_batch_hull, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldManifoldVec}), mem, ms)
end

function manifold_hull_pts(mem, ps, length)
    ccall((:manifold_hull_pts, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldVec3}, Csize_t), mem, ps, length)
end

function manifold_translate(mem, m, x, y, z)
    ccall((:manifold_translate, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldManifold}, Cfloat, Cfloat, Cfloat), mem, m, x, y, z)
end

function manifold_rotate(mem, m, x, y, z)
    ccall((:manifold_rotate, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldManifold}, Cfloat, Cfloat, Cfloat), mem, m, x, y, z)
end

function manifold_scale(mem, m, x, y, z)
    ccall((:manifold_scale, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldManifold}, Cfloat, Cfloat, Cfloat), mem, m, x, y, z)
end

function manifold_transform(mem, m, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)
    ccall((:manifold_transform, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldManifold}, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat), mem, m, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)
end

function manifold_mirror(mem, m, nx, ny, nz)
    ccall((:manifold_mirror, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldManifold}, Cfloat, Cfloat, Cfloat), mem, m, nx, ny, nz)
end

function manifold_warp(mem, m, fun, ctx)
    ccall((:manifold_warp, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldManifold}, Ptr{Cvoid}, Ptr{Cvoid}), mem, m, fun, ctx)
end

function manifold_smooth_by_normals(mem, m, normalIdx)
    ccall((:manifold_smooth_by_normals, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldManifold}, Cint), mem, m, normalIdx)
end

function manifold_smooth_out(mem, m, minSharpAngle, minSmoothness)
    ccall((:manifold_smooth_out, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldManifold}, Cfloat, Cfloat), mem, m, minSharpAngle, minSmoothness)
end

function manifold_refine(mem, m, refine)
    ccall((:manifold_refine, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldManifold}, Cint), mem, m, refine)
end

function manifold_refine_to_length(mem, m, length)
    ccall((:manifold_refine_to_length, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldManifold}, Cfloat), mem, m, length)
end

function manifold_empty(mem)
    ccall((:manifold_empty, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid},), mem)
end

function manifold_copy(mem, m)
    ccall((:manifold_copy, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldManifold}), mem, m)
end

function manifold_tetrahedron(mem)
    ccall((:manifold_tetrahedron, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid},), mem)
end

function manifold_cube(mem, x, y, z, center)
    ccall((:manifold_cube, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Cfloat, Cfloat, Cfloat, Cint), mem, x, y, z, center)
end

function manifold_cylinder(mem, height, radius_low, radius_high, circular_segments, center)
    ccall((:manifold_cylinder, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Cfloat, Cfloat, Cfloat, Cint, Cint), mem, height, radius_low, radius_high, circular_segments, center)
end

function manifold_sphere(mem, radius, circular_segments)
    ccall((:manifold_sphere, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Cfloat, Cint), mem, radius, circular_segments)
end

function manifold_of_meshgl(mem, mesh)
    ccall((:manifold_of_meshgl, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldMeshGL}), mem, mesh)
end

function manifold_smooth(mem, mesh, half_edges, smoothness, n_idxs)
    ccall((:manifold_smooth, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldMeshGL}, Ptr{Cint}, Ptr{Cfloat}, Cint), mem, mesh, half_edges, smoothness, n_idxs)
end

function manifold_extrude(mem, cs, height, slices, twist_degrees, scale_x, scale_y)
    ccall((:manifold_extrude, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldCrossSection}, Cfloat, Cint, Cfloat, Cfloat, Cfloat), mem, cs, height, slices, twist_degrees, scale_x, scale_y)
end

function manifold_revolve(mem, cs, circular_segments)
    ccall((:manifold_revolve, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldCrossSection}, Cint), mem, cs, circular_segments)
end

function manifold_compose(mem, ms)
    ccall((:manifold_compose, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldManifoldVec}), mem, ms)
end

function manifold_decompose(mem, m)
    ccall((:manifold_decompose, libmanifoldc), Ptr{ManifoldManifoldVec}, (Ptr{Cvoid}, Ptr{ManifoldManifold}), mem, m)
end

function manifold_as_original(mem, m)
    ccall((:manifold_as_original, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldManifold}), mem, m)
end

function manifold_is_empty(m)
    ccall((:manifold_is_empty, libmanifoldc), Cint, (Ptr{ManifoldManifold},), m)
end

function manifold_status(m)
    ccall((:manifold_status, libmanifoldc), ManifoldError, (Ptr{ManifoldManifold},), m)
end

function manifold_num_vert(m)
    ccall((:manifold_num_vert, libmanifoldc), Cint, (Ptr{ManifoldManifold},), m)
end

function manifold_num_edge(m)
    ccall((:manifold_num_edge, libmanifoldc), Cint, (Ptr{ManifoldManifold},), m)
end

function manifold_num_tri(m)
    ccall((:manifold_num_tri, libmanifoldc), Cint, (Ptr{ManifoldManifold},), m)
end

function manifold_bounding_box(mem, m)
    ccall((:manifold_bounding_box, libmanifoldc), Ptr{ManifoldBox}, (Ptr{Cvoid}, Ptr{ManifoldManifold}), mem, m)
end

function manifold_precision(m)
    ccall((:manifold_precision, libmanifoldc), Cfloat, (Ptr{ManifoldManifold},), m)
end

function manifold_genus(m)
    ccall((:manifold_genus, libmanifoldc), Cint, (Ptr{ManifoldManifold},), m)
end

function manifold_get_properties(m)
    ccall((:manifold_get_properties, libmanifoldc), ManifoldProperties, (Ptr{ManifoldManifold},), m)
end

function manifold_get_circular_segments(radius)
    ccall((:manifold_get_circular_segments, libmanifoldc), Cint, (Cfloat,), radius)
end

function manifold_original_id(m)
    ccall((:manifold_original_id, libmanifoldc), Cint, (Ptr{ManifoldManifold},), m)
end

function manifold_reserve_ids(n)
    ccall((:manifold_reserve_ids, libmanifoldc), UInt32, (UInt32,), n)
end

function manifold_set_properties(mem, m, num_prop, fun, ctx)
    ccall((:manifold_set_properties, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldManifold}, Cint, Ptr{Cvoid}, Ptr{Cvoid}), mem, m, num_prop, fun, ctx)
end

function manifold_calculate_curvature(mem, m, gaussian_idx, mean_idx)
    ccall((:manifold_calculate_curvature, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldManifold}, Cint, Cint), mem, m, gaussian_idx, mean_idx)
end

function manifold_min_gap(m, other, searchLength)
    ccall((:manifold_min_gap, libmanifoldc), Cfloat, (Ptr{ManifoldManifold}, Ptr{ManifoldManifold}, Cfloat), m, other, searchLength)
end

function manifold_calculate_normals(mem, m, normal_idx, min_sharp_angle)
    ccall((:manifold_calculate_normals, libmanifoldc), Ptr{ManifoldManifold}, (Ptr{Cvoid}, Ptr{ManifoldManifold}, Cint, Cint), mem, m, normal_idx, min_sharp_angle)
end

function manifold_cross_section_empty(mem)
    ccall((:manifold_cross_section_empty, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid},), mem)
end

function manifold_cross_section_copy(mem, cs)
    ccall((:manifold_cross_section_copy, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Ptr{ManifoldCrossSection}), mem, cs)
end

function manifold_cross_section_of_simple_polygon(mem, p, fr)
    ccall((:manifold_cross_section_of_simple_polygon, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Ptr{ManifoldSimplePolygon}, ManifoldFillRule), mem, p, fr)
end

function manifold_cross_section_of_polygons(mem, p, fr)
    ccall((:manifold_cross_section_of_polygons, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Ptr{ManifoldPolygons}, ManifoldFillRule), mem, p, fr)
end

function manifold_cross_section_square(mem, x, y, center)
    ccall((:manifold_cross_section_square, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Cfloat, Cfloat, Cint), mem, x, y, center)
end

function manifold_cross_section_circle(mem, radius, circular_segments)
    ccall((:manifold_cross_section_circle, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Cfloat, Cint), mem, radius, circular_segments)
end

function manifold_cross_section_compose(mem, csv)
    ccall((:manifold_cross_section_compose, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Ptr{ManifoldCrossSectionVec}), mem, csv)
end

function manifold_cross_section_decompose(mem, cs)
    ccall((:manifold_cross_section_decompose, libmanifoldc), Ptr{ManifoldCrossSectionVec}, (Ptr{Cvoid}, Ptr{ManifoldCrossSection}), mem, cs)
end

function manifold_cross_section_empty_vec(mem)
    ccall((:manifold_cross_section_empty_vec, libmanifoldc), Ptr{ManifoldCrossSectionVec}, (Ptr{Cvoid},), mem)
end

function manifold_cross_section_vec(mem, sz)
    ccall((:manifold_cross_section_vec, libmanifoldc), Ptr{ManifoldCrossSectionVec}, (Ptr{Cvoid}, Csize_t), mem, sz)
end

function manifold_cross_section_vec_reserve(csv, sz)
    ccall((:manifold_cross_section_vec_reserve, libmanifoldc), Cvoid, (Ptr{ManifoldCrossSectionVec}, Csize_t), csv, sz)
end

function manifold_cross_section_vec_length(csv)
    ccall((:manifold_cross_section_vec_length, libmanifoldc), Csize_t, (Ptr{ManifoldCrossSectionVec},), csv)
end

function manifold_cross_section_vec_get(mem, csv, idx)
    ccall((:manifold_cross_section_vec_get, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Ptr{ManifoldCrossSectionVec}, Cint), mem, csv, idx)
end

function manifold_cross_section_vec_set(csv, idx, cs)
    ccall((:manifold_cross_section_vec_set, libmanifoldc), Cvoid, (Ptr{ManifoldCrossSectionVec}, Cint, Ptr{ManifoldCrossSection}), csv, idx, cs)
end

function manifold_cross_section_vec_push_back(csv, cs)
    ccall((:manifold_cross_section_vec_push_back, libmanifoldc), Cvoid, (Ptr{ManifoldCrossSectionVec}, Ptr{ManifoldCrossSection}), csv, cs)
end

function manifold_cross_section_boolean(mem, a, b, op)
    ccall((:manifold_cross_section_boolean, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Ptr{ManifoldCrossSection}, Ptr{ManifoldCrossSection}, ManifoldOpType), mem, a, b, op)
end

function manifold_cross_section_batch_boolean(mem, csv, op)
    ccall((:manifold_cross_section_batch_boolean, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Ptr{ManifoldCrossSectionVec}, ManifoldOpType), mem, csv, op)
end

function manifold_cross_section_union(mem, a, b)
    ccall((:manifold_cross_section_union, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Ptr{ManifoldCrossSection}, Ptr{ManifoldCrossSection}), mem, a, b)
end

function manifold_cross_section_difference(mem, a, b)
    ccall((:manifold_cross_section_difference, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Ptr{ManifoldCrossSection}, Ptr{ManifoldCrossSection}), mem, a, b)
end

function manifold_cross_section_intersection(mem, a, b)
    ccall((:manifold_cross_section_intersection, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Ptr{ManifoldCrossSection}, Ptr{ManifoldCrossSection}), mem, a, b)
end

function manifold_cross_section_hull(mem, cs)
    ccall((:manifold_cross_section_hull, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Ptr{ManifoldCrossSection}), mem, cs)
end

function manifold_cross_section_batch_hull(mem, css)
    ccall((:manifold_cross_section_batch_hull, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Ptr{ManifoldCrossSectionVec}), mem, css)
end

function manifold_cross_section_hull_simple_polygon(mem, ps)
    ccall((:manifold_cross_section_hull_simple_polygon, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Ptr{ManifoldSimplePolygon}), mem, ps)
end

function manifold_cross_section_hull_polygons(mem, ps)
    ccall((:manifold_cross_section_hull_polygons, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Ptr{ManifoldPolygons}), mem, ps)
end

function manifold_cross_section_translate(mem, cs, x, y)
    ccall((:manifold_cross_section_translate, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Ptr{ManifoldCrossSection}, Cfloat, Cfloat), mem, cs, x, y)
end

function manifold_cross_section_rotate(mem, cs, deg)
    ccall((:manifold_cross_section_rotate, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Ptr{ManifoldCrossSection}, Cfloat), mem, cs, deg)
end

function manifold_cross_section_scale(mem, cs, x, y)
    ccall((:manifold_cross_section_scale, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Ptr{ManifoldCrossSection}, Cfloat, Cfloat), mem, cs, x, y)
end

function manifold_cross_section_mirror(mem, cs, ax_x, ax_y)
    ccall((:manifold_cross_section_mirror, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Ptr{ManifoldCrossSection}, Cfloat, Cfloat), mem, cs, ax_x, ax_y)
end

function manifold_cross_section_transform(mem, cs, x1, y1, x2, y2, x3, y3)
    ccall((:manifold_cross_section_transform, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Ptr{ManifoldCrossSection}, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat), mem, cs, x1, y1, x2, y2, x3, y3)
end

function manifold_cross_section_warp(mem, cs, fun)
    ccall((:manifold_cross_section_warp, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Ptr{ManifoldCrossSection}, Ptr{Cvoid}), mem, cs, fun)
end

function manifold_cross_section_warp_context(mem, cs, fun, ctx)
    ccall((:manifold_cross_section_warp_context, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Ptr{ManifoldCrossSection}, Ptr{Cvoid}, Ptr{Cvoid}), mem, cs, fun, ctx)
end

function manifold_cross_section_simplify(mem, cs, epsilon)
    ccall((:manifold_cross_section_simplify, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Ptr{ManifoldCrossSection}, Cdouble), mem, cs, epsilon)
end

function manifold_cross_section_offset(mem, cs, delta, jt, miter_limit, circular_segments)
    ccall((:manifold_cross_section_offset, libmanifoldc), Ptr{ManifoldCrossSection}, (Ptr{Cvoid}, Ptr{ManifoldCrossSection}, Cdouble, ManifoldJoinType, Cdouble, Cint), mem, cs, delta, jt, miter_limit, circular_segments)
end

function manifold_cross_section_area(cs)
    ccall((:manifold_cross_section_area, libmanifoldc), Cdouble, (Ptr{ManifoldCrossSection},), cs)
end

function manifold_cross_section_num_vert(cs)
    ccall((:manifold_cross_section_num_vert, libmanifoldc), Cint, (Ptr{ManifoldCrossSection},), cs)
end

function manifold_cross_section_num_contour(cs)
    ccall((:manifold_cross_section_num_contour, libmanifoldc), Cint, (Ptr{ManifoldCrossSection},), cs)
end

function manifold_cross_section_is_empty(cs)
    ccall((:manifold_cross_section_is_empty, libmanifoldc), Cint, (Ptr{ManifoldCrossSection},), cs)
end

function manifold_cross_section_bounds(mem, cs)
    ccall((:manifold_cross_section_bounds, libmanifoldc), Ptr{ManifoldRect}, (Ptr{Cvoid}, Ptr{ManifoldCrossSection}), mem, cs)
end

function manifold_cross_section_to_polygons(mem, cs)
    ccall((:manifold_cross_section_to_polygons, libmanifoldc), Ptr{ManifoldPolygons}, (Ptr{Cvoid}, Ptr{ManifoldCrossSection}), mem, cs)
end

function manifold_rect(mem, x1, y1, x2, y2)
    ccall((:manifold_rect, libmanifoldc), Ptr{ManifoldRect}, (Ptr{Cvoid}, Cfloat, Cfloat, Cfloat, Cfloat), mem, x1, y1, x2, y2)
end

function manifold_rect_min(r)
    ccall((:manifold_rect_min, libmanifoldc), ManifoldVec2, (Ptr{ManifoldRect},), r)
end

function manifold_rect_max(r)
    ccall((:manifold_rect_max, libmanifoldc), ManifoldVec2, (Ptr{ManifoldRect},), r)
end

function manifold_rect_dimensions(r)
    ccall((:manifold_rect_dimensions, libmanifoldc), ManifoldVec2, (Ptr{ManifoldRect},), r)
end

function manifold_rect_center(r)
    ccall((:manifold_rect_center, libmanifoldc), ManifoldVec2, (Ptr{ManifoldRect},), r)
end

function manifold_rect_scale(r)
    ccall((:manifold_rect_scale, libmanifoldc), Cfloat, (Ptr{ManifoldRect},), r)
end

function manifold_rect_contains_pt(r, x, y)
    ccall((:manifold_rect_contains_pt, libmanifoldc), Cint, (Ptr{ManifoldRect}, Cfloat, Cfloat), r, x, y)
end

function manifold_rect_contains_rect(a, b)
    ccall((:manifold_rect_contains_rect, libmanifoldc), Cint, (Ptr{ManifoldRect}, Ptr{ManifoldRect}), a, b)
end

function manifold_rect_include_pt(r, x, y)
    ccall((:manifold_rect_include_pt, libmanifoldc), Cvoid, (Ptr{ManifoldRect}, Cfloat, Cfloat), r, x, y)
end

function manifold_rect_union(mem, a, b)
    ccall((:manifold_rect_union, libmanifoldc), Ptr{ManifoldRect}, (Ptr{Cvoid}, Ptr{ManifoldRect}, Ptr{ManifoldRect}), mem, a, b)
end

function manifold_rect_transform(mem, r, x1, y1, x2, y2, x3, y3)
    ccall((:manifold_rect_transform, libmanifoldc), Ptr{ManifoldRect}, (Ptr{Cvoid}, Ptr{ManifoldRect}, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat), mem, r, x1, y1, x2, y2, x3, y3)
end

function manifold_rect_translate(mem, r, x, y)
    ccall((:manifold_rect_translate, libmanifoldc), Ptr{ManifoldRect}, (Ptr{Cvoid}, Ptr{ManifoldRect}, Cfloat, Cfloat), mem, r, x, y)
end

function manifold_rect_mul(mem, r, x, y)
    ccall((:manifold_rect_mul, libmanifoldc), Ptr{ManifoldRect}, (Ptr{Cvoid}, Ptr{ManifoldRect}, Cfloat, Cfloat), mem, r, x, y)
end

function manifold_rect_does_overlap_rect(a, r)
    ccall((:manifold_rect_does_overlap_rect, libmanifoldc), Cint, (Ptr{ManifoldRect}, Ptr{ManifoldRect}), a, r)
end

function manifold_rect_is_empty(r)
    ccall((:manifold_rect_is_empty, libmanifoldc), Cint, (Ptr{ManifoldRect},), r)
end

function manifold_rect_is_finite(r)
    ccall((:manifold_rect_is_finite, libmanifoldc), Cint, (Ptr{ManifoldRect},), r)
end

function manifold_box(mem, x1, y1, z1, x2, y2, z2)
    ccall((:manifold_box, libmanifoldc), Ptr{ManifoldBox}, (Ptr{Cvoid}, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat), mem, x1, y1, z1, x2, y2, z2)
end

function manifold_box_min(b)
    ccall((:manifold_box_min, libmanifoldc), ManifoldVec3, (Ptr{ManifoldBox},), b)
end

function manifold_box_max(b)
    ccall((:manifold_box_max, libmanifoldc), ManifoldVec3, (Ptr{ManifoldBox},), b)
end

function manifold_box_dimensions(b)
    ccall((:manifold_box_dimensions, libmanifoldc), ManifoldVec3, (Ptr{ManifoldBox},), b)
end

function manifold_box_center(b)
    ccall((:manifold_box_center, libmanifoldc), ManifoldVec3, (Ptr{ManifoldBox},), b)
end

function manifold_box_scale(b)
    ccall((:manifold_box_scale, libmanifoldc), Cfloat, (Ptr{ManifoldBox},), b)
end

function manifold_box_contains_pt(b, x, y, z)
    ccall((:manifold_box_contains_pt, libmanifoldc), Cint, (Ptr{ManifoldBox}, Cfloat, Cfloat, Cfloat), b, x, y, z)
end

function manifold_box_contains_box(a, b)
    ccall((:manifold_box_contains_box, libmanifoldc), Cint, (Ptr{ManifoldBox}, Ptr{ManifoldBox}), a, b)
end

function manifold_box_include_pt(b, x, y, z)
    ccall((:manifold_box_include_pt, libmanifoldc), Cvoid, (Ptr{ManifoldBox}, Cfloat, Cfloat, Cfloat), b, x, y, z)
end

function manifold_box_union(mem, a, b)
    ccall((:manifold_box_union, libmanifoldc), Ptr{ManifoldBox}, (Ptr{Cvoid}, Ptr{ManifoldBox}, Ptr{ManifoldBox}), mem, a, b)
end

function manifold_box_transform(mem, b, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)
    ccall((:manifold_box_transform, libmanifoldc), Ptr{ManifoldBox}, (Ptr{Cvoid}, Ptr{ManifoldBox}, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat), mem, b, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)
end

function manifold_box_translate(mem, b, x, y, z)
    ccall((:manifold_box_translate, libmanifoldc), Ptr{ManifoldBox}, (Ptr{Cvoid}, Ptr{ManifoldBox}, Cfloat, Cfloat, Cfloat), mem, b, x, y, z)
end

function manifold_box_mul(mem, b, x, y, z)
    ccall((:manifold_box_mul, libmanifoldc), Ptr{ManifoldBox}, (Ptr{Cvoid}, Ptr{ManifoldBox}, Cfloat, Cfloat, Cfloat), mem, b, x, y, z)
end

function manifold_box_does_overlap_pt(b, x, y, z)
    ccall((:manifold_box_does_overlap_pt, libmanifoldc), Cint, (Ptr{ManifoldBox}, Cfloat, Cfloat, Cfloat), b, x, y, z)
end

function manifold_box_does_overlap_box(a, b)
    ccall((:manifold_box_does_overlap_box, libmanifoldc), Cint, (Ptr{ManifoldBox}, Ptr{ManifoldBox}), a, b)
end

function manifold_box_is_finite(b)
    ccall((:manifold_box_is_finite, libmanifoldc), Cint, (Ptr{ManifoldBox},), b)
end

function manifold_set_min_circular_angle(degrees)
    ccall((:manifold_set_min_circular_angle, libmanifoldc), Cvoid, (Cfloat,), degrees)
end

function manifold_set_min_circular_edge_length(length)
    ccall((:manifold_set_min_circular_edge_length, libmanifoldc), Cvoid, (Cfloat,), length)
end

function manifold_set_circular_segments(number)
    ccall((:manifold_set_circular_segments, libmanifoldc), Cvoid, (Cint,), number)
end

function manifold_meshgl_num_prop(m)
    ccall((:manifold_meshgl_num_prop, libmanifoldc), Cint, (Ptr{ManifoldMeshGL},), m)
end

function manifold_meshgl_num_vert(m)
    ccall((:manifold_meshgl_num_vert, libmanifoldc), Cint, (Ptr{ManifoldMeshGL},), m)
end

function manifold_meshgl_num_tri(m)
    ccall((:manifold_meshgl_num_tri, libmanifoldc), Cint, (Ptr{ManifoldMeshGL},), m)
end

function manifold_meshgl_vert_properties_length(m)
    ccall((:manifold_meshgl_vert_properties_length, libmanifoldc), Csize_t, (Ptr{ManifoldMeshGL},), m)
end

function manifold_meshgl_tri_length(m)
    ccall((:manifold_meshgl_tri_length, libmanifoldc), Csize_t, (Ptr{ManifoldMeshGL},), m)
end

function manifold_meshgl_merge_length(m)
    ccall((:manifold_meshgl_merge_length, libmanifoldc), Csize_t, (Ptr{ManifoldMeshGL},), m)
end

function manifold_meshgl_run_index_length(m)
    ccall((:manifold_meshgl_run_index_length, libmanifoldc), Csize_t, (Ptr{ManifoldMeshGL},), m)
end

function manifold_meshgl_run_original_id_length(m)
    ccall((:manifold_meshgl_run_original_id_length, libmanifoldc), Csize_t, (Ptr{ManifoldMeshGL},), m)
end

function manifold_meshgl_run_transform_length(m)
    ccall((:manifold_meshgl_run_transform_length, libmanifoldc), Csize_t, (Ptr{ManifoldMeshGL},), m)
end

function manifold_meshgl_face_id_length(m)
    ccall((:manifold_meshgl_face_id_length, libmanifoldc), Csize_t, (Ptr{ManifoldMeshGL},), m)
end

function manifold_meshgl_tangent_length(m)
    ccall((:manifold_meshgl_tangent_length, libmanifoldc), Csize_t, (Ptr{ManifoldMeshGL},), m)
end

function manifold_meshgl_vert_properties(mem, m)
    ccall((:manifold_meshgl_vert_properties, libmanifoldc), Ptr{Cfloat}, (Ptr{Cvoid}, Ptr{ManifoldMeshGL}), mem, m)
end

function manifold_meshgl_tri_verts(mem, m)
    ccall((:manifold_meshgl_tri_verts, libmanifoldc), Ptr{UInt32}, (Ptr{Cvoid}, Ptr{ManifoldMeshGL}), mem, m)
end

function manifold_meshgl_merge_from_vert(mem, m)
    ccall((:manifold_meshgl_merge_from_vert, libmanifoldc), Ptr{UInt32}, (Ptr{Cvoid}, Ptr{ManifoldMeshGL}), mem, m)
end

function manifold_meshgl_merge_to_vert(mem, m)
    ccall((:manifold_meshgl_merge_to_vert, libmanifoldc), Ptr{UInt32}, (Ptr{Cvoid}, Ptr{ManifoldMeshGL}), mem, m)
end

function manifold_meshgl_run_index(mem, m)
    ccall((:manifold_meshgl_run_index, libmanifoldc), Ptr{UInt32}, (Ptr{Cvoid}, Ptr{ManifoldMeshGL}), mem, m)
end

function manifold_meshgl_run_original_id(mem, m)
    ccall((:manifold_meshgl_run_original_id, libmanifoldc), Ptr{UInt32}, (Ptr{Cvoid}, Ptr{ManifoldMeshGL}), mem, m)
end

function manifold_meshgl_run_transform(mem, m)
    ccall((:manifold_meshgl_run_transform, libmanifoldc), Ptr{Cfloat}, (Ptr{Cvoid}, Ptr{ManifoldMeshGL}), mem, m)
end

function manifold_meshgl_face_id(mem, m)
    ccall((:manifold_meshgl_face_id, libmanifoldc), Ptr{UInt32}, (Ptr{Cvoid}, Ptr{ManifoldMeshGL}), mem, m)
end

function manifold_meshgl_halfedge_tangent(mem, m)
    ccall((:manifold_meshgl_halfedge_tangent, libmanifoldc), Ptr{Cfloat}, (Ptr{Cvoid}, Ptr{ManifoldMeshGL}), mem, m)
end

# no prototype is found for this function at manifoldc.h:376:8, please use with caution
function manifold_manifold_size()
    ccall((:manifold_manifold_size, libmanifoldc), Csize_t, ())
end

# no prototype is found for this function at manifoldc.h:377:8, please use with caution
function manifold_manifold_vec_size()
    ccall((:manifold_manifold_vec_size, libmanifoldc), Csize_t, ())
end

# no prototype is found for this function at manifoldc.h:378:8, please use with caution
function manifold_cross_section_size()
    ccall((:manifold_cross_section_size, libmanifoldc), Csize_t, ())
end

# no prototype is found for this function at manifoldc.h:379:8, please use with caution
function manifold_cross_section_vec_size()
    ccall((:manifold_cross_section_vec_size, libmanifoldc), Csize_t, ())
end

# no prototype is found for this function at manifoldc.h:380:8, please use with caution
function manifold_simple_polygon_size()
    ccall((:manifold_simple_polygon_size, libmanifoldc), Csize_t, ())
end

# no prototype is found for this function at manifoldc.h:381:8, please use with caution
function manifold_polygons_size()
    ccall((:manifold_polygons_size, libmanifoldc), Csize_t, ())
end

# no prototype is found for this function at manifoldc.h:382:8, please use with caution
function manifold_manifold_pair_size()
    ccall((:manifold_manifold_pair_size, libmanifoldc), Csize_t, ())
end

# no prototype is found for this function at manifoldc.h:383:8, please use with caution
function manifold_meshgl_size()
    ccall((:manifold_meshgl_size, libmanifoldc), Csize_t, ())
end

# no prototype is found for this function at manifoldc.h:384:8, please use with caution
function manifold_box_size()
    ccall((:manifold_box_size, libmanifoldc), Csize_t, ())
end

# no prototype is found for this function at manifoldc.h:385:8, please use with caution
function manifold_rect_size()
    ccall((:manifold_rect_size, libmanifoldc), Csize_t, ())
end

# no prototype is found for this function at manifoldc.h:386:8, please use with caution
function manifold_curvature_size()
    ccall((:manifold_curvature_size, libmanifoldc), Csize_t, ())
end

function manifold_destruct_manifold(m)
    ccall((:manifold_destruct_manifold, libmanifoldc), Cvoid, (Ptr{ManifoldManifold},), m)
end

function manifold_destruct_manifold_vec(ms)
    ccall((:manifold_destruct_manifold_vec, libmanifoldc), Cvoid, (Ptr{ManifoldManifoldVec},), ms)
end

function manifold_destruct_cross_section(m)
    ccall((:manifold_destruct_cross_section, libmanifoldc), Cvoid, (Ptr{ManifoldCrossSection},), m)
end

function manifold_destruct_cross_section_vec(csv)
    ccall((:manifold_destruct_cross_section_vec, libmanifoldc), Cvoid, (Ptr{ManifoldCrossSectionVec},), csv)
end

function manifold_destruct_simple_polygon(p)
    ccall((:manifold_destruct_simple_polygon, libmanifoldc), Cvoid, (Ptr{ManifoldSimplePolygon},), p)
end

function manifold_destruct_polygons(p)
    ccall((:manifold_destruct_polygons, libmanifoldc), Cvoid, (Ptr{ManifoldPolygons},), p)
end

function manifold_destruct_meshgl(m)
    ccall((:manifold_destruct_meshgl, libmanifoldc), Cvoid, (Ptr{ManifoldMeshGL},), m)
end

function manifold_destruct_box(b)
    ccall((:manifold_destruct_box, libmanifoldc), Cvoid, (Ptr{ManifoldBox},), b)
end

function manifold_destruct_rect(b)
    ccall((:manifold_destruct_rect, libmanifoldc), Cvoid, (Ptr{ManifoldRect},), b)
end

function manifold_delete_manifold(m)
    ccall((:manifold_delete_manifold, libmanifoldc), Cvoid, (Ptr{ManifoldManifold},), m)
end

function manifold_delete_manifold_vec(ms)
    ccall((:manifold_delete_manifold_vec, libmanifoldc), Cvoid, (Ptr{ManifoldManifoldVec},), ms)
end

function manifold_delete_cross_section(cs)
    ccall((:manifold_delete_cross_section, libmanifoldc), Cvoid, (Ptr{ManifoldCrossSection},), cs)
end

function manifold_delete_cross_section_vec(csv)
    ccall((:manifold_delete_cross_section_vec, libmanifoldc), Cvoid, (Ptr{ManifoldCrossSectionVec},), csv)
end

function manifold_delete_simple_polygon(p)
    ccall((:manifold_delete_simple_polygon, libmanifoldc), Cvoid, (Ptr{ManifoldSimplePolygon},), p)
end

function manifold_delete_polygons(p)
    ccall((:manifold_delete_polygons, libmanifoldc), Cvoid, (Ptr{ManifoldPolygons},), p)
end

function manifold_delete_meshgl(m)
    ccall((:manifold_delete_meshgl, libmanifoldc), Cvoid, (Ptr{ManifoldMeshGL},), m)
end

function manifold_delete_box(b)
    ccall((:manifold_delete_box, libmanifoldc), Cvoid, (Ptr{ManifoldBox},), b)
end

function manifold_delete_rect(b)
    ccall((:manifold_delete_rect, libmanifoldc), Cvoid, (Ptr{ManifoldRect},), b)
end

end # module
