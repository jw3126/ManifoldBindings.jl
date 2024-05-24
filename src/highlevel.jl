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

function Base.convert(::Type{CAPI.ManifoldOpType}, s::Symbol)::CAPI.ManifoldOpType
    @argcheck s in (:add, :subtract, :intersect)
    if s === :add
        CAPI.MANIFOLD_ADD
    elseif s === :subtract
        CAPI.MANIFOLD_SUBTRACT
    elseif s === :intersect
        CAPI.MANIFOLD_INTERSECT
    else
        error("Unreachable")
    end
end

function boolean(a::Manifold, b::Manifold, op)::Manifold
    op = convert(CAPI.ManifoldOpType, op)
    @argcheck isalive(a)
    @argcheck isalive(b)
    mem = malloc_for(Manifold)
    Manifold(CAPI.manifold_boolean(mem, a, b, op))
end

function compose(manifolds)::Manifold
    with_manifold_vec(manifolds) do vec
        mem = malloc_for(Manifold)
        Manifold(CAPI.manifold_compose(mem, vec))
    end
end

function unsafe_vector(vec::Ptr{CAPI.ManifoldManifoldVec})::Vector{Manifold}
    # this is unsafe because it takes ownership of the manifolds in the ManifoldManifoldVec
    # So it is easy to create memory corruption.
    # For instance calling this twice on the same ManifoldManifoldVec will lead to double free
    len = CAPI.manifold_manifold_vec_length(vec)
    ret = Vector{Manifold}(undef, len)
    for i in 1:len
        mem = malloc_for(Manifold)
        ptr = CAPI.manifold_manifold_vec_get(mem, vec, i - 1)
        ret[i] = Manifold(ptr)
    end
    return ret
end

function decompose(m::Manifold)::Vector{Manifold}
    @argcheck isalive(m)
    mem = Libc.malloc(CAPI.manifold_manifold_vec_size())
    vec = CAPI.manifold_decompose(mem, m)
    ret = unsafe_vector(vec)
    CAPI.manifold_delete_manifold_vec(vec)
    ret
end

function with_manifold_vec(f, manifolds)
    # we don't want to create a high level wrapper for ManifoldManifoldVec
    # it easily leads to memory bugs
    mem = Libc.malloc(CAPI.manifold_manifold_vec_size())
    vec = CAPI.manifold_manifold_empty_vec(mem)
    try
        for m in manifolds
            @argcheck m isa Manifold
            @argcheck isalive(m)
            CAPI.manifold_manifold_vec_push_back(vec, m)
        end
        return f(vec)
    finally
        CAPI.manifold_delete_manifold_vec(vec)
    end
end

function batch_boolean(manifolds, op)::Manifold
    op = convert(CAPI.ManifoldOpType, op)
    ptr = with_manifold_vec(manifolds) do vec
        mem = malloc_for(Manifold)
        CAPI.manifold_batch_boolean(mem, vec, op)
    end
    Manifold(ptr)
end

function translate(m::Manifold, x::Real, y::Real, z::Real)::Manifold
    @argcheck isalive(m)
    mem = malloc_for(Manifold)
    Manifold(CAPI.manifold_translate(mem, m, x, y, z))
end

function rotate(m::Manifold, x::Real, y::Real, z::Real)::Manifold
    @argcheck isalive(m)
    mem = malloc_for(Manifold)
    Manifold(CAPI.manifold_rotate(mem, m, x, y, z))
end

function scale(m::Manifold, x::Real, y::Real, z::Real)::Manifold
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

struct WarpWrapper{F}
    f::F
end

function (f::WarpWrapper)(x::Cfloat, y::Cfloat, z::Cfloat, _::Ptr{Cvoid})::CAPI.ManifoldVec3
    pt = @SVector [x, y, z]
    f.f(pt)
end

function warp(f, m::Manifold)::Manifold
    cfun = @cfunction($(WarpWrapper(f)), CAPI.ManifoldVec3, (Cfloat, Cfloat, Cfloat, Ptr{Cvoid}))
    mem = malloc_for(Manifold)
    ctx = C_NULL
    ptr = CAPI.manifold_warp(mem, m, cfun, ctx)
    Manifold(ptr)
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
function surface_area_and_volume(m::Manifold)::@NamedTuple{surface_area::Cfloat, volume::Cfloat}
    @argcheck isalive(m)
    (;surface_area, volume) = CAPI.manifold_get_properties(m)
    (;surface_area, volume)
end
function surface_area(m::Manifold)::Cfloat
    surface_area_and_volume(m).surface_area
end

function volume(m::Manifold)::Cfloat
    surface_area_and_volume(m).volume
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
