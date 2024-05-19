# TODO make this a package extension?
import MakieCore as MC

function MC.plottype(::Union{MeshGL, Manifold})
    MC.Mesh
end

function MC.convert_arguments(::Type{MC.Mesh}, m::Union{MeshGL, Manifold})
    tris = collect_triangles(m)
    verts = collect_vertices(m)

    xyz = Matrix{Float32}(undef, length(verts), 3)
    for (i,v) in pairs(verts)
        xyz[i,1] = v[1]
        xyz[i,2] = v[2]
        xyz[i,3] = v[3]
    end
    faces = Matrix{Int32}(undef, length(tris), 3)
    for (i,t) in pairs(tris)
        faces[i,1] = t[1]
        faces[i,2] = t[2]
        faces[i,3] = t[3]
    end
    MC.convert_arguments(MC.Mesh, xyz, faces)
end
