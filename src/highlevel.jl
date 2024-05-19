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

function delete(m::Manifold)
    CAPI.manifold_delete_manifold(m)
    m.ptr = C_NULL
end

function Manifold_tetrahedron()::Manifold
    mem = malloc_for(Manifold)
    Manifold(CAPI.manifold_tetrahedron(mem))
end

function union(a::Manifold, b::Manifold)::Manifold
    mem = malloc_for(Manifold)
    GC.@preserve a b begin
        CAPI.manifold_union(mem, a, b)
    end
end

function difference(a::Manifold, b::Manifold)::Manifold
    mem = malloc_for(Manifold)
    GC.@preserve a b begin
        CAPI.manifold_difference(mem, a, b)
    end
end

function intersection(a::Manifold, b::Manifold)::Manifold
    mem = malloc_for(Manifold)
    GC.@preserve a b begin
        CAPI.manifold_intersection(mem, a, b)
    end
end


#################################################################################
#### ManifoldMeshGL
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
    # TODO does this require m to be alive?
    # do we need to add GC handles?
    mem = malloc_for(MeshGL)
    MeshGL(CAPI.manifold_get_meshgl(mem, m); gchandles = [m])
end

function Base.copy(m::MeshGL)::MeshGL
    # TODO is this really a deepcopy?
    # should we overload deepcopy_internal instead?
    #
    mem = malloc_for(m)
    MeshGL(CAPI.manifold_meshgl_copy(mem, m))
end

function ManifoldMeshGL_create(vert_props::AbstractVector{Float32}, tri_verts::AbstractVector{UInt32}, n_verts)::MeshGL
    @argcheck n_verts*3 <= length(vert_props)
    mem = malloc_for(MeshGL)
    n_props = length(vert_props)
    n_tris = length(tri_verts)
    MeshGL(CAPI.manifold_meshgl(mem, vert_props, n_verts, n_props, tri_verts, n_tris))
end

function num_vert(m::MeshGL)::Cint
    CAPI.manifold_meshgl_num_vert(m)
end

function num_tri(m::MeshGL)::Cint
    CAPI.manifold_meshgl_num_tri(m)
end

function num_prop(m::MeshGL)::Cint
    CAPI.manifold_meshgl_num_prop(m)
end

function vert_properties_length(m::MeshGL)::Cint
    CAPI.manifold_meshgl_vert_properties_length(m)
end

function tri_length(m::MeshGL)::Cint
    CAPI.manifold_meshgl_tri_length(m)
end

function tri_verts!(out::Vector{UInt32}, m::MeshGL)::typeof(out)
    resize!(out, num_vert(m)*3)
    CAPI.manifold_meshgl_tri_verts(out, m)
    out
end

function tri_verts(m::MeshGL)::Vector{UInt32}
    tri_verts!(UInt32[], m)
end

function vert_properties!(out::Vector{Float32}, m::MeshGL)::typeof(out)
    resize!(out, vert_properties_length(m))
    CAPI.manifold_meshgl_vert_properties(out, m)
    out
end

function vert_properties(m::MeshGL)::Vector{Float32}
    vert_properties!(Float32[], m)
end

function collect_vertices(m::MeshGL)::Vector{SVector{3,Float32}}
    @argcheck num_prop(m) == 3 # TODO
    reinterpret(SVector{3,Float32}, vert_properties(m))
end

function collect_vertices(m::Manifold)::Vector{SVector{3,Float32}}
    collect_vertices(get_meshgl(m))
end

function collect_triangles(m::MeshGL)::Vector{SVector{3,UInt32}}
    reinterpret(SVector{3,UInt32}, tri_verts(m))
end

function collect_triangles(m::Manifold)::Vector{SVector{3,UInt32}}
    collect_triangles(get_meshgl(m))
end
