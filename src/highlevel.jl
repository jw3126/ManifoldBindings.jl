using StaticArrays

################################################################################
#### Manifold
################################################################################

mutable struct Manifold
    ptr::Ptr{CAPI.ManifoldManifold}
    function Manifold(ptr::Ptr{CAPI.ManifoldManifold})
        m = new(ptr)
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

function delete(m::Manifold)
    CAPI.manifold_delete_manifold(m)
    m.ptr = C_NULL
end

function Manifold_tetrahedron()::Manifold
    mem = malloc_for(Manifold)
    Manifold(CAPI.manifold_tetrahedron(mem))
end

function union(a::Manifold, b::Manifold)::Manifold
    @argcheck isalive(a)
    @argcheck isalive(b)
    mem = malloc_for(Manifold)
    CAPI.manifold_union(mem, a, b)
end

function difference(a::Manifold, b::Manifold)::Manifold
    @argcheck isalive(a)
    @argcheck isalive(b)
    mem = malloc_for(Manifold)
    CAPI.manifold_difference(mem, a, b)
end

function intersection(a::Manifold, b::Manifold)::Manifold
    @argcheck isalive(a)
    @argcheck isalive(b)
    mem = malloc_for(Manifold)
    CAPI.manifold_intersection(mem, a, b)
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
    # TODO confirm that gchandles are necessary
    mem = malloc_for(MeshGL)
    MeshGL(CAPI.manifold_get_meshgl(mem, m); gchandles = [m])
end

function Base.copy(m::MeshGL)::MeshGL
    @argcheck isalive(m)
    mem = malloc_for(m)
    MeshGL(CAPI.manifold_meshgl_copy(mem, m))
end

function MeshGL_create(vert_props::AbstractVector{Float32}, tri_verts::AbstractVector{UInt32}, n_verts)::MeshGL
    @argcheck n_verts*3 <= length(vert_props)
    mem = malloc_for(MeshGL)
    n_props = length(vert_props)
    n_tris = length(tri_verts)
    MeshGL(CAPI.manifold_meshgl(mem, vert_props, n_verts, n_props, tri_verts, n_tris))
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
    resize!(out, num_vert(m)*3)
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
