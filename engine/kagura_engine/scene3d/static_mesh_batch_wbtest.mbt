///|
test "static batches relocate indices and coalesce only adjacent visible chunks" {
  let triangle = @mesh3d.Mesh3D::new(
    [
      0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 0.0,
    ],
    [0, 1, 2],
  )
  let empty = @mesh3d.Mesh3D::new([], [])
  let batch = StaticMeshBatch::new([triangle, empty, triangle, triangle]).unwrap()
  assert_eq(batch.mesh.indices, [0, 1, 2, 3, 4, 5, 6, 7, 8])
  let all = batch.select(_ => true)
  assert_eq(all, [{ first_index: 0, index_count: 9, }])
  assert_eq(batch.select(i => i != 2), [
    { first_index: 0, index_count: 3, },
    { first_index: 6, index_count: 3, },
  ])
  assert_eq(batch.select(i => i != 1), all) // empty hidden chunks don't split runs
  assert_eq(batch.select(_ => false).length(), 0)
  assert_eq(batch.mesh.vertex_count(), 9)
  assert_eq(triangle.indices, [0, 1, 2])
  assert_eq(StaticMeshBatch::new([]).unwrap().select(_ => true).length(), 0)
}

///|
test "static batches reject mixed layouts and invalid geometry before uploading" {
  let rigid = @mesh3d.Mesh3D::new([], [])
  let skinned = @mesh3d.Mesh3D::new_with_format(
    [],
    [],
    @mesh3d.VertexFormat::skinned_3d(),
  )
  assert_true(StaticMeshBatch::new([rigid, skinned]) is None)
  assert_true(
    StaticMeshBatch::new([@mesh3d.Mesh3D::new([1.0], [0, 0, 0])]) is None,
  )
  assert_true(
    StaticMeshBatch::new([@mesh3d.Mesh3D::new([], [0, 0, 0])]) is None,
  )
}
