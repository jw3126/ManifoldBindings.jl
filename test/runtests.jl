import ManifoldBindings as MB
using Test
using StaticArrays


@testset "tetrahedron" begin
    m = MB.Manifold_tetrahedron()
    mgl = MB.get_meshgl(m)
    @test MB.num_tri(mgl) == 4
    @test MB.num_vert(mgl) == 4
    @test MB.num_prop(mgl) == 3
    verts = MB.collect_vertices(mgl)
    @test verts == [
        @SVector[-1.0, -1.0, 1.0],
        @SVector[-1.0, 1.0, -1.0],
        @SVector[1.0, -1.0, -1.0],
        @SVector[1.0, 1.0, 1.0],
    ]
    @test MB.collect_vertices(mgl) == MB.collect_vertices(m)

    @test MB.collect_triangles(m) == MB.collect_triangles(mgl)
    tris = MB.collect_triangles(mgl)
    @test tris == [
        @SVector[0x00000003, 0x00000001, 0x00000002], 
        @SVector[0x00000001, 0x00000004, 0x00000002], 
        @SVector[0x00000003, 0x00000004, 0x00000001], 
        @SVector[0x00000004, 0x00000003, 0x00000002]
       ]
end

@testset "custom tetrahedron" begin
    vertices = [
        @SVector[-1.0, -1.0, 1.0],
        @SVector[-1.0, 1.0, -1.0],
        @SVector[1.0, -1.0, -1.0],
        @SVector[1.0, 1.0, 1.0],
    ]
    faces = [
        @SVector[0x00000003, 0x00000001, 0x00000002], 
        @SVector[0x00000001, 0x00000004, 0x00000002], 
        @SVector[0x00000003, 0x00000004, 0x00000001], 
        @SVector[0x00000004, 0x00000003, 0x00000002]
       ]

    mgl = MB.MeshGL(vertices, faces)
    sprint(show, mgl)
    @test MB.num_tri(mgl) == 4
    @test MB.num_vert(mgl) == 4
    @test MB.num_prop(mgl) == 3
    @test MB.collect_triangles(mgl) == faces
    @test MB.collect_vertices(mgl) == vertices

    m = MB.Manifold(vertices, faces)
    sprint(show, m)
    @test MB.num_tri(m) == 4
    @test MB.num_vert(m) == 4
    @test MB.num_edge(m) == 6
    @test MB.collect_triangles(m) == faces
    @test MB.collect_vertices(m) == vertices

    @test MB.isalive(m)
    MB.delete(m)
    @test !MB.isalive(m)
    sprint(show, m)
    @test_throws ArgumentError MB.num_vert(m)
    MB.delete(m) # multi delete is fine
    @test !MB.isalive(m)
end

@testset "booleans" begin
    m = MB.Manifold_tetrahedron()
    res = MB.difference(m, m)
    @test MB.num_tri(res) == 0
    @test MB.num_vert(res) == 0

    res = MB.intersection(m, m)
    @test MB.num_tri(res) == MB.num_tri(m)
    @test MB.num_vert(res) == MB.num_vert(m)

    res = MB.union(m, m)
    @test MB.num_tri(res) == MB.num_tri(m)
    @test MB.num_vert(res) == MB.num_vert(m)
end
