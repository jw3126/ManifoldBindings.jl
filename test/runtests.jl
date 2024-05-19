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
    @test tris == 
    [
     @SVector[0x00000002, 0x00000000, 0x00000001],
     @SVector[0x00000000, 0x00000003, 0x00000001],
     @SVector[0x00000002, 0x00000003, 0x00000000],
     @SVector[0x00000003, 0x00000002, 0x00000001],
    ]
end
