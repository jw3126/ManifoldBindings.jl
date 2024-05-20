import ManifoldBindings as MB
using Test
using StaticArrays

@testset "empty" begin
    m = MB.Manifold_empty()
    @test MB.num_tri(m) == 0
    @test MB.num_vert(m) == 0
    @test MB.is_empty(m)
end

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

    b = MB.bounding_box(m)
    @test MB.box_min(b) == @SVector[-1.0, -1.0, -1.0]
    @test MB.box_max(b) == @SVector[1.0, 1.0, 1.0]
    @test MB.genus(m) == 0
    @test MB.is_empty(m) === false

    m2 = MB.translate(m, 1,2,3)
    @test MB.collect_vertices(m2) == map(x -> x .+ @SVector[1,2,3], MB.collect_vertices(m))

    m3 = MB.scale(m, 1,2,3)
    @test MB.collect_vertices(m3) == map(x -> x .* @SVector[1,2,3], MB.collect_vertices(m))
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

@testset "cube" begin
    center=true
    m = MB.Manifold_cube(1,2,3, center)
    @test MB.num_tri(m) == 12
    @test MB.num_vert(m) == 8
    @test MB.collect_vertices(m) == [
     @SVector[-0.5 , -1.0 , -1.5 ],
     @SVector[-0.5 , -1.0 , 1.5  ],
     @SVector[-0.5 , 1.0  , -1.5 ],
     @SVector[-0.5 , 1.0  , 1.5  ],
     @SVector[0.5  , -1.0 , -1.5 ],
     @SVector[0.5  , -1.0 , 1.5  ],
     @SVector[0.5  , 1.0  , -1.5 ],
     @SVector[0.5  , 1.0  , 1.5  ],
    ]
    @test MB.volume(m) ≈ 1*2*3
    @test MB.surface_area(m) ≈ 2*(1*2 + 2*3 + 1*3)
    @test length(MB.collect_vertices(m)) == 8
    @test length(MB.collect_triangles(m)) == 12
    @test MB.collect_triangles(m) == [
     @SVector[0x00000002, 0x00000001, 0x00000005],
     @SVector[0x00000003, 0x00000005, 0x00000001],
     @SVector[0x00000002, 0x00000004, 0x00000001],
     @SVector[0x00000004, 0x00000002, 0x00000006],
     @SVector[0x00000004, 0x00000003, 0x00000001],
     @SVector[0x00000004, 0x00000008, 0x00000003],
     @SVector[0x00000006, 0x00000005, 0x00000007],
     @SVector[0x00000006, 0x00000002, 0x00000005],
     @SVector[0x00000007, 0x00000005, 0x00000003],
     @SVector[0x00000008, 0x00000007, 0x00000003],
     @SVector[0x00000008, 0x00000004, 0x00000006],
     @SVector[0x00000008, 0x00000006, 0x00000007],
    ]
end

@testset "sphere" begin
    m = MB.Manifold_sphere(1.0, 10)
    faces = MB.collect_triangles(m)
    verts = MB.collect_vertices(m)
end


@testset "booleans" begin
    m = MB.Manifold_tetrahedron()
    res = MB.difference(m, m)
    @test MB.num_tri(res) == 0
    @test MB.num_vert(res) == 0

    res = MB.boolean(m, m, :subtract)
    @test MB.num_tri(res) == 0
    @test MB.num_vert(res) == 0

    res = MB.intersection(m, m)
    @test MB.num_tri(res) == MB.num_tri(m)
    @test MB.num_vert(res) == MB.num_vert(m)

    res = MB.boolean(m, m, :intersect)
    @test MB.num_tri(res) == MB.num_tri(m)
    @test MB.num_vert(res) == MB.num_vert(m)

    res = MB.union(m, m)
    @test MB.num_tri(res) == MB.num_tri(m)
    @test MB.num_vert(res) == MB.num_vert(m)

    res = MB.batch_boolean([m,m,m], :add)
    @test MB.num_tri(res) == MB.num_tri(m)
    @test MB.num_vert(res) == MB.num_vert(m)

    res = MB.boolean(m, m, :add)
    @test MB.num_tri(res) == MB.num_tri(m)
    @test MB.num_vert(res) == MB.num_vert(m)

end

@testset "error" begin
    vertices = [
        @SVector[1,2,3],
        @SVector[2,2,3],
        @SVector[3,2,3],
       ]
    faces = [
        (1,2,3),
            ]
    mgl = MB.MeshGL(vertices, faces)
    @test_throws MB.ManifoldException MB.Manifold(mgl)
end
