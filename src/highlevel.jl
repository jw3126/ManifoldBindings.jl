using StaticArrays
using ArgCheck

################################################################################
#### Manifold
################################################################################

mutable struct Manifold
    ptr::Ptr{CAPI.ManifoldManifold}
    gchandles::Vector{Any}
    function Manifold(ptr::Ptr{CAPI.ManifoldManifold}; gchandles = Any[])
        m = new(ptr, gchandles)
        finalizer(delete, m)
        m
    end
end

function Base.unsafe_convert(::Type{Ptr{CAPI.ManifoldManifold}}, m::Manifold)
    m.ptr
end

function malloc_for(::Type{Manifold})
    Base.Libc.malloc(CAPI.manifold_manifold_size())
end

function isalive(obj)::Bool
    obj.ptr != C_NULL
end

function num_tri(m::Manifold)::Cint
    @argcheck isalive(m)
    CAPI.manifold_num_tri(m)
end

function num_edge(m::Manifold)::Cint
    @argcheck isalive(m)
    CAPI.manifold_num_edge(m)
end

function num_vert(m::Manifold)::Cint
    @argcheck isalive(m)
    CAPI.manifold_num_vert(m)
end

function delete(m::Manifold)
    CAPI.manifold_delete_manifold(m)
    empty!(m.gchandles)
    m.ptr = C_NULL
end

function Manifold_tetrahedron()::Manifold
    mem = malloc_for(Manifold)
    Manifold(CAPI.manifold_tetrahedron(mem))
end

function Manifold_empty()::Manifold
    mem = malloc_for(Manifold)
    Manifold(CAPI.manifold_empty(mem))
end

function Manifold_cube(x, y, z, center::Bool)::Manifold
    mem = malloc_for(Manifold)
    Manifold(CAPI.manifold_cube(mem, x, y, z, center))
end

function Manifold_cylinder(height, radius_low, radius_high, circular_segments, center)::Manifold
    mem = malloc_for(Manifold)
    Manifold(CAPI.manifold_cylinder(mem, height, radius_low, radius_high, circular_segments, center))
end

function Manifold_sphere(radius, circular_segments)::Manifold
    mem = malloc_for(Manifold)
    Manifold(CAPI.manifold_sphere(mem, radius, circular_segments))
end

function union(a::Manifold, b::Manifold)::Manifold
    @argcheck isalive(a)
    @argcheck isalive(b)
    mem = malloc_for(Manifold)
    Manifold(CAPI.manifold_union(mem, a, b))
end

function difference(a::Manifold, b::Manifold)::Manifold
    @argcheck isalive(a)
    @argcheck isalive(b)
    mem = malloc_for(Manifold)
    Manifold(CAPI.manifold_difference(mem, a, b))
end

function intersection(a::Manifold, b::Manifold)::Manifold
    @argcheck isalive(a)
    @argcheck isalive(b)
    mem = malloc_for(Manifold)
    Manifold(CAPI.manifold_intersection(mem, a, b))
end

function translate(m::Manifold, x::Cfloat, y::Cfloat, z::Cfloat)::Manifold
    @argcheck isalive(m)
    mem = malloc_for(Manifold)
    Manifold(CAPI.manifold_translate(mem, m, x, y, z))
end

function rotate(m::Manifold, x::Cfloat, y::Cfloat, z::Cfloat)::Manifold
    @argcheck isalive(m)
    mem = malloc_for(Manifold)
    Manifold(CAPI.manifold_rotate(mem, m, x, y, z))
end

function scale(m::Manifold, x::Cfloat, y::Cfloat, z::Cfloat)::Manifold
    @argcheck isalive(m)
    mem = malloc_for(Manifold)
    Manifold(CAPI.manifold_scale(mem, m, x, y, z))
end

function transform(m::Manifold, x1::Cfloat, y1::Cfloat, z1::Cfloat, x2::Cfloat, y2::Cfloat, z2::Cfloat, x3::Cfloat, y3::Cfloat, z3::Cfloat, x4::Cfloat, y4::Cfloat, z4::Cfloat)::Manifold
    @argcheck isalive(m)
    mem = malloc_for(Manifold)
    Manifold(CAPI.manifold_transform(mem, m, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4))
end

function mirror(m::Manifold, nx::Cfloat, ny::Cfloat, nz::Cfloat)::Manifold
    @argcheck isalive(m)
    mem = malloc_for(Manifold)
    Manifold(CAPI.manifold_mirror(mem, m, nx, ny, nz))
end


function refine(m::Manifold, level::Cint)::Manifold
    @argcheck isalive(m)
    mem = malloc_for(Manifold)
    Manifold(CAPI.manifold_refine(mem, m, level))
end

function refine_to_length(m::Manifold, length::Cfloat)::Manifold
    @argcheck isalive(m)
    mem = malloc_for(Manifold)
    Manifold(CAPI.manifold_refine_to_length(mem, m, length))
end

function is_empty(m::Manifold)::Bool
    @argcheck isalive(m)
    CAPI.manifold_is_empty(m) == 1
end

function status(m::Manifold)::CAPI.ManifoldError
    @argcheck isalive(m)
    CAPI.manifold_status(m)
end

function bounding_box(m::Manifold)::Box
    @argcheck isalive(m)
    mem = malloc_for(Box)
    Box(CAPI.manifold_bounding_box(mem, m))
end

function precision(m::Manifold)::Cfloat
    @argcheck isalive(m)
    CAPI.manifold_precision(m)
end

function genus(m::Manifold)::Cint
    @argcheck isalive(m)
    CAPI.manifold_genus(m)
end

function properties(m::Manifold)::CAPI.ManifoldProperties
    @argcheck isalive(m)
    CAPI.manifold_get_properties(m)
end

function original_id(m::Manifold)::Cint
    @argcheck isalive(m)
    CAPI.manifold_original_id(m)
end

#################################################################################
#### MeshGL
################################################################################

mutable struct MeshGL
    ptr::Ptr{CAPI.ManifoldMeshGL}
    gchandles::Vector{Any}
    function MeshGL(ptr::Ptr{CAPI.ManifoldMeshGL}; gchandles = Any[])
        m = new(ptr, gchandles)
        finalizer(delete, m)
        m
    end
end

function Base.unsafe_convert(::Type{Ptr{CAPI.ManifoldMeshGL}}, m::MeshGL)
    m.ptr
end

function malloc_for(::Type{MeshGL})
    malloc(CAPI.manifold_meshgl_size())
end

function delete(m::MeshGL)
    CAPI.manifold_delete_meshgl(m)
    empty!(m.gchandles)
    m.ptr = C_NULL
end

function get_meshgl(m::Manifold)::MeshGL
    @argcheck isalive(m)
    mem = malloc_for(MeshGL)
    MeshGL(CAPI.manifold_get_meshgl(mem, m); gchandles = [m])
end

function Base.copy(m::MeshGL)::MeshGL
    @argcheck isalive(m)
    mem = malloc_for(m)
    MeshGL(CAPI.manifold_meshgl_copy(mem, m))
end

function MeshGL_create(vert_props::Vector{Float32}, tri_verts::Vector{UInt32}, n_verts)::MeshGL
    @argcheck n_verts*3 <= length(vert_props)
    mem = malloc_for(MeshGL)
    n_props = Int(length(vert_props) / n_verts)
    n_tris = Int(length(tri_verts) / 3)
    ptr = CAPI.manifold_meshgl(mem, vert_props, n_verts, n_props, tri_verts, n_tris)
    MeshGL(ptr; gchandles = [vert_props, tri_verts])
end

function MeshGL(vertices::AbstractVector, triangles::AbstractVector)::MeshGL
    vert_props = Float32[]
    tri_verts = UInt32[]
    for v in vertices
        @check length(v) == 3
        x,y,z = v
        push!(vert_props, x, y, z)
    end
    i0 = firstindex(vertices)
    for t in triangles
        @check length(t) == 3
        i1,i2,i3 = t
        @check i1 in eachindex(vertices) 
        @check i2 in eachindex(vertices) 
        @check i3 in eachindex(vertices)
        push!(tri_verts, i1-i0,i2-i0,i3-i0) # convert to zero based indexing
    end
    MeshGL_create(vert_props, tri_verts, length(vertices))
end

struct ManifoldException <: Exception
    error::CAPI.ManifoldError
end

function Manifold(mgl::MeshGL)::Manifold
    @argcheck isalive(mgl)
    mem = malloc_for(Manifold)
    m = Manifold(CAPI.manifold_of_meshgl(mem, mgl); gchandles = [mgl])
    s = status(m)
    if s == CAPI.MANIFOLD_NO_ERROR
        return m
    else
        throw(ManifoldException(s))
        delete(m)
    end
end

function Manifold(verts::AbstractVector, tris::AbstractVector)::Manifold
    Manifold(MeshGL(verts, tris))
end

function num_vert(m::MeshGL)::Cint
    @argcheck isalive(m)
    CAPI.manifold_meshgl_num_vert(m)
end

function num_tri(m::MeshGL)::Cint
    @argcheck isalive(m)
    CAPI.manifold_meshgl_num_tri(m)
end

function num_prop(m::MeshGL)::Cint
    @argcheck isalive(m)
    CAPI.manifold_meshgl_num_prop(m)
end

function vert_properties_length(m::MeshGL)::Cint
    @argcheck isalive(m)
    CAPI.manifold_meshgl_vert_properties_length(m)
end

function tri_length(m::MeshGL)::Cint
    @argcheck isalive(m)
    CAPI.manifold_meshgl_tri_length(m)
end

function tri_verts!(out::Vector{UInt32}, m::MeshGL)::typeof(out)
    @argcheck isalive(m)
    resize!(out, tri_length(m))
    CAPI.manifold_meshgl_tri_verts(out, m)
    # convert to 1 based indexing
    out .+= one(UInt32)
    out
end

function tri_verts(m::MeshGL)::Vector{UInt32}
    @argcheck isalive(m)
    tri_verts!(UInt32[], m)
end

function vert_properties!(out::Vector{Float32}, m::MeshGL)::typeof(out)
    @argcheck isalive(m)
    resize!(out, vert_properties_length(m))
    CAPI.manifold_meshgl_vert_properties(out, m)
    out
end

function vert_properties(m::MeshGL)::Vector{Float32}
    @argcheck isalive(m)
    vert_properties!(Float32[], m)
end

function collect_vertices(m::MeshGL)::Vector{SVector{3,Float32}}
    @argcheck isalive(m)
    @argcheck num_prop(m) == 3 # TODO
    reinterpret(SVector{3,Float32}, vert_properties(m))
end

function collect_vertices(m::Manifold)::Vector{SVector{3,Float32}}
    @argcheck isalive(m)
    collect_vertices(get_meshgl(m))
end

function collect_triangles(m::MeshGL)::Vector{SVector{3,UInt32}}
    @argcheck isalive(m)
    reinterpret(SVector{3,UInt32}, tri_verts(m))
end

function collect_triangles(m::Manifold)::Vector{SVector{3,UInt32}}
    @argcheck isalive(m)
    collect_triangles(get_meshgl(m))
end

################################################################################
#### ManifoldVec
################################################################################
function Base.convert(::Type{CAPI.ManifoldVec2}, v::AbstractVector)::CAPI.ManifoldVec2
    @argcheck length(v) == 2
    x,y = v
    CAPI.ManifoldVec2(x, y)
end

function Base.convert(::Type{CAPI.ManifoldVec3}, v::AbstractVector)::CAPI.ManifoldVec3
    @argcheck length(v) == 3
    x,y,z = v
    CAPI.ManifoldVec3(x, y, z)
end

function Base.convert(::Type{CAPI.ManifoldVec4}, v::AbstractVector)::CAPI.ManifoldVec4
    @argcheck length(v) == 4
    x1,x2,x3,x4 = v
    CAPI.ManifoldVec4(x1, x2, x3, x4)
end

function Base.show(io::IO, obj::Union{Manifold, MeshGL})
    print(io, nameof(typeof(obj)))
    if !isalive(obj)
        print(io, "(deleted)")
    else
        print(io, (;num_vert=num_vert(obj), num_tri=num_tri(obj)))
    end
end

function Base.convert(::Type{SVector{2,Cfloat}}, v::CAPI.ManifoldVec2)::SVector{2,Cfloat}
    SVector{2,Cfloat}(v.x, v.y)
end

function Base.convert(::Type{SVector{3,Cfloat}}, v::CAPI.ManifoldVec3)::SVector{3,Cfloat}
    SVector{3,Cfloat}(v.x, v.y, v.z)
end

function Base.convert(::Type{SVector{4,Cfloat}}, v::CAPI.ManifoldVec4)::SVector{4,Cfloat}
    SVector{4,Cfloat}(v.x, v.y, v.z, v.w)
end

################################################################################
#### Manifold Properties
################################################################################
function surface_area(m::Manifold)::Cfloat
    @argcheck isalive(m)
    CAPI.manifold_get_properties(m).surface_area
end

function volume(m::Manifold)::Cfloat
    @argcheck isalive(m)
    CAPI.manifold_get_properties(m).volume
end

################################################################################
#### CrossSection
################################################################################
mutable struct CrossSection
    ptr::Ptr{CAPI.ManifoldCrossSection}
    gchandles::Vector{Any}
    function CrossSection(ptr::Ptr{CAPI.ManifoldCrossSection}; gchandles = Any[])
        cs = new(ptr, gchandles)
        finalizer(delete, cs)
        cs
    end
end

function Base.unsafe_convert(::Type{Ptr{CAPI.ManifoldCrossSection}}, cs::CrossSection)
    cs.ptr
end

function malloc_for(::Type{CrossSection})
    Base.Libc.malloc(CAPI.manifold_cross_section_size())
end

function delete(cs::CrossSection)
    CAPI.manifold_delete_cross_section(cs)
    empty!(cs.gchandles)
    cs.ptr = C_NULL
end

function CrossSection_empty()::CrossSection
    mem = malloc_for(CrossSection)
    CrossSection(CAPI.manifold_cross_section_empty(mem))
end

function CrossSection_square(x::Cfloat, y::Cfloat, center::Cint)::CrossSection
    mem = malloc_for(CrossSection)
    CrossSection(CAPI.manifold_cross_section_square(mem, x, y, center))
end

function CrossSection_circle(radius::Cfloat, circular_segments::Cint)::CrossSection
    mem = malloc_for(CrossSection)
    CrossSection(CAPI.manifold_cross_section_circle(mem, radius, circular_segments))
end

function is_empty(cs::CrossSection)::Bool
    @argcheck isalive(cs)
    CAPI.manifold_cross_section_is_empty(cs) == 1
end

function area(cs::CrossSection)::Cdouble
    @argcheck isalive(cs)
    CAPI.manifold_cross_section_area(cs)
end

function num_vert(cs::CrossSection)::Cint
    @argcheck isalive(cs)
    CAPI.manifold_cross_section_num_vert(cs)
end

function num_contour(cs::CrossSection)::Cint
    @argcheck isalive(cs)
    CAPI.manifold_cross_section_num_contour(cs)
end

function bounds(cs::CrossSection)::ManifoldRect
    @argcheck isalive(cs)
    mem = malloc_for(ManifoldRect)
    CAPI.manifold_cross_section_bounds(mem, cs)
end

function translate(cs::CrossSection, x::Cfloat, y::Cfloat)::CrossSection
    @argcheck isalive(cs)
    mem = malloc_for(CrossSection)
    CrossSection(CAPI.manifold_cross_section_translate(mem, cs, x, y))
end

function rotate(cs::CrossSection, deg::Cfloat)::CrossSection
    @argcheck isalive(cs)
    mem = malloc_for(CrossSection)
    CrossSection(CAPI.manifold_cross_section_rotate(mem, cs, deg))
end

function scale(cs::CrossSection, x::Cfloat, y::Cfloat)::CrossSection
    @argcheck isalive(cs)
    mem = malloc_for(CrossSection)
    CrossSection(CAPI.manifold_cross_section_scale(mem, cs, x, y))
end

function mirror(cs::CrossSection, ax_x::Cfloat, ax_y::Cfloat)::CrossSection
    @argcheck isalive(cs)
    mem = malloc_for(CrossSection)
    CrossSection(CAPI.manifold_cross_section_mirror(mem, cs, ax_x, ax_y))
end

function transform(cs::CrossSection, x1::Cfloat, y1::Cfloat, x2::Cfloat, y2::Cfloat, x3::Cfloat, y3::Cfloat)::CrossSection
    @argcheck isalive(cs)
    mem = malloc_for(CrossSection)
    CrossSection(CAPI.manifold_cross_section_transform(mem, cs, x1, y1, x2, y2, x3, y3))
end

function simplify(cs::CrossSection, epsilon::Cdouble)::CrossSection
    @argcheck isalive(cs)
    mem = malloc_for(CrossSection)
    CrossSection(CAPI.manifold_cross_section_simplify(mem, cs, epsilon))
end

function offset(cs::CrossSection, delta::Cdouble, jt::CAPI.ManifoldJoinType, miter_limit::Cdouble, circular_segments::Cint)::CrossSection
    @argcheck isalive(cs)
    mem = malloc_for(CrossSection)
    CrossSection(CAPI.manifold_cross_section_offset(mem, cs, delta, jt, miter_limit, circular_segments))
end

################################################################################
#### Box
################################################################################
mutable struct Box
    ptr::Ptr{CAPI.ManifoldBox}
    gchandles::Vector{Any}
    function Box(ptr::Ptr{CAPI.ManifoldBox}; gchandles = Any[])
        mb = new(ptr, gchandles)
        finalizer(delete, mb)
        mb
    end
end

function Base.unsafe_convert(::Type{Ptr{CAPI.ManifoldBox}}, mb::Box)
    mb.ptr
end

function malloc_for(::Type{Box})
    Base.Libc.malloc(CAPI.manifold_box_size())
end

function delete(mb::Box)
    CAPI.manifold_delete_box(mb)
    empty!(mb.gchandles)
    mb.ptr = C_NULL
end

function Box(x1::Cfloat, y1::Cfloat, z1::Cfloat, x2::Cfloat, y2::Cfloat, z2::Cfloat)::Box
    mem = malloc_for(Box)
    Box(CAPI.manifold_box(mem, x1, y1, z1, x2, y2, z2))
end

function Base.show(io::IO, obj::Box)
    print(io, "Box(min=", box_min(obj), ", max=", box_max(obj), ")")
end

function box_min(b::Box)::SVector{3, Cfloat}
    @argcheck isalive(b)
    CAPI.manifold_box_min(b)
end

function box_max(b::Box)::SVector{3, Cfloat}
    @argcheck isalive(b)
    CAPI.manifold_box_max(b)
end

function box_dimensions(b::Box)::SVector{3, Cfloat}
    @argcheck isalive(b)
    CAPI.manifold_box_dimensions(b)
end

function box_center(b::Box)::SVector{3, Cfloat}
    @argcheck isalive(b)
    CAPI.manifold_box_center(b)
end

function box_scale(b::Box)::Cfloat
    @argcheck isalive(b)
    CAPI.manifold_box_scale(b)
end

function box_contains_pt(b::Box, x::Cfloat, y::Cfloat, z::Cfloat)::Bool
    @argcheck isalive(b)
    CAPI.manifold_box_contains_pt(b, x, y, z) == 1
end

function box_contains_box(a::Box, b::Box)::Bool
    @argcheck isalive(a)
    @argcheck isalive(b)
    CAPI.manifold_box_contains_box(a, b) == 1
end

function box_union(a::Box, b::Box)::Box
    @argcheck isalive(a)
    @argcheck isalive(b)
    mem = malloc_for(Box)
    Box(CAPI.manifold_box_union(mem, a, b))
end

function box_transform(b::Box, x1::Cfloat, y1::Cfloat, z1::Cfloat, x2::Cfloat, y2::Cfloat, z2::Cfloat, x3::Cfloat, y3::Cfloat, z3::Cfloat, x4::Cfloat, y4::Cfloat, z4::Cfloat)::Box
    @argcheck isalive(b)
    mem = malloc_for(Box)
    Box(CAPI.manifold_box_transform(mem, b, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4))
end

function box_translate(b::Box, x::Cfloat, y::Cfloat, z::Cfloat)::Box
    @argcheck isalive(b)
    mem = malloc_for(Box)
    Box(CAPI.manifold_box_translate(mem, b, x, y, z))
end

function box_mul(b::Box, x::Cfloat, y::Cfloat, z::Cfloat)::Box
    @argcheck isalive(b)
    mem = malloc_for(Box)
    Box(CAPI.manifold_box_mul(mem, b, x, y, z))
end

function box_does_overlap_pt(b::Box, x::Cfloat, y::Cfloat, z::Cfloat)::Bool
    @argcheck isalive(b)
    CAPI.manifold_box_does_overlap_pt(b, x, y, z) == 1
end

function box_does_overlap_box(a::Box, b::Box)::Bool
    @argcheck isalive(a)
    @argcheck isalive(b)
    CAPI.manifold_box_does_overlap_box(a, b) == 1
end

function box_is_finite(b::Box)::Bool
    @argcheck isalive(b)
    CAPI.manifold_box_is_finite(b) == 1
end

################################################################################
#### ManifoldRect
################################################################################
mutable struct ManifoldRect
    ptr::Ptr{CAPI.ManifoldRect}
    gchandles::Vector{Any}
    function ManifoldRect(ptr::Ptr{CAPI.ManifoldRect}; gchandles = Any[])
        mr = new(ptr, gchandles)
        finalizer(delete, mr)
        mr
    end
end

function Base.unsafe_convert(::Type{Ptr{CAPI.ManifoldRect}}, mr::ManifoldRect)
    mr.ptr
end

function malloc_for(::Type{ManifoldRect})
    Base.Libc.malloc(CAPI.manifold_rect_size())
end

function delete(mr::ManifoldRect)
    CAPI.manifold_delete_rect(mr)
    empty!(mr.gchandles)
    mr.ptr = C_NULL
end

function ManifoldRect(x1::Cfloat, y1::Cfloat, x2::Cfloat, y2::Cfloat)::ManifoldRect
    mem = malloc_for(ManifoldRect)
    ManifoldRect(CAPI.manifold_rect(mem, x1, y1, x2, y2))
end

function rect_min(r::ManifoldRect)::SVector{2, Cfloat}
    @argcheck isalive(r)
    CAPI.manifold_rect_min(r)
end

function rect_max(r::ManifoldRect)::SVector{2, Cfloat}
    @argcheck isalive(r)
    CAPI.manifold_rect_max(r)
end

function rect_dimensions(r::ManifoldRect)::SVector{2, Cfloat}
    @argcheck isalive(r)
    CAPI.manifold_rect_dimensions(r)
end

function rect_center(r::ManifoldRect)::SVector{2, Cfloat}
    @argcheck isalive(r)
    CAPI.manifold_rect_center(r)
end

function rect_scale(r::ManifoldRect)::Cfloat
    @argcheck isalive(r)
    CAPI.manifold_rect_scale(r)
end

function rect_contains_pt(r::ManifoldRect, x::Cfloat, y::Cfloat)::Bool
    @argcheck isalive(r)
    CAPI.manifold_rect_contains_pt(r, x, y) == 1
end

function rect_contains_rect(a::ManifoldRect, b::ManifoldRect)::Bool
    @argcheck isalive(a)
    @argcheck isalive(b)
    CAPI.manifold_rect_contains_rect(a, b) == 1
end

function rect_include_pt(r::ManifoldRect, x::Cfloat, y::Cfloat)
    @argcheck isalive(r)
    CAPI.manifold_rect_include_pt(r, x, y)
end

function rect_union(a::ManifoldRect, b::ManifoldRect)::ManifoldRect
    @argcheck isalive(a)
    @argcheck isalive(b)
    mem = malloc_for(ManifoldRect)
    ManifoldRect(CAPI.manifold_rect_union(mem, a, b))
end

function rect_transform(r::ManifoldRect, x1::Cfloat, y1::Cfloat, x2::Cfloat, y2::Cfloat, x3::Cfloat, y3::Cfloat)::ManifoldRect
    @argcheck isalive(r)
    mem = malloc_for(ManifoldRect)
    ManifoldRect(CAPI.manifold_rect_transform(mem, r, x1, y1, x2, y2, x3, y3))
end

function rect_translate(r::ManifoldRect, x::Cfloat, y::Cfloat)::ManifoldRect
    @argcheck isalive(r)
    mem = malloc_for(ManifoldRect)
    ManifoldRect(CAPI.manifold_rect_translate(mem, r, x, y))
end

function rect_mul(r::ManifoldRect, x::Cfloat, y::Cfloat)::ManifoldRect
    @argcheck isalive(r)
    mem = malloc_for(ManifoldRect)
    ManifoldRect(CAPI.manifold_rect_mul(mem, r, x, y))
end

function rect_does_overlap_rect(a::ManifoldRect, r::ManifoldRect)::Bool
    @argcheck isalive(a)
    @argcheck isalive(r)
    CAPI.manifold_rect_does_overlap_rect(a, r) == 1
end

function is_empty(r::ManifoldRect)::Bool
    @argcheck isalive(r)
    CAPI.manifold_rect_is_empty(r) == 1
end

function rect_is_finite(r::ManifoldRect)::Bool
    @argcheck isalive(r)
    CAPI.manifold_rect_is_finite(r) == 1
end

################################################################################
#### Utilities
################################################################################
function set_min_circular_angle(degrees::Cfloat)
    CAPI.manifold_set_min_circular_angle(degrees)
end

function set_min_circular_edge_length(length::Cfloat)
    CAPI.manifold_set_min_circular_edge_length(length)
end

function set_circular_segments(number::Cint)
    CAPI.manifold_set_circular_segments(number)
end

function get_circular_segments(radius::Cfloat)::Cint
    CAPI.manifold_get_circular_segments(radius)
end
