///|
test "skinned asset keeps GPU geometry immutable and deforms CPU mesh on demand" {
  let mesh = @mesh3d.Mesh3D::cube(1.0)
  let skin : @skeleton3d.SkinData = {
    vertex_count: mesh.vertex_count(),
    joint_indices: Array::make(mesh.vertex_count() * 4, 0),
    weights: Array::makei(mesh.vertex_count() * 4, i => {
      if i % 4 == 0 {
        1.0
      } else {
        0.0
      }
    }),
  }
  let asset = SkinnedMeshAsset::new(mesh, skin)
  let unused = SkinnedMeshAsset::new(mesh, skin)
  assert_eq(asset.cpu_skin_count(), 0)
  let bind = asset.packed_vertex_data.copy()
  let first = asset.skinned_mesh(0, [@math3d.Mat4::identity()])
  let original_x = first.vertex_data[0]
  ignore(asset.skinned_mesh(0, [@math3d.Mat4::identity()]))
  assert_eq(asset.cpu_skin_count(), 1)
  let moved = asset.skinned_mesh(1, [@math3d.Mat4::translation(2.0, 0.0, 0.0)])
  assert_true((moved.vertex_data[0] - original_x - 2.0).abs() < 0.00001)
  assert_eq(asset.cpu_skin_count(), 2)
  assert_eq(asset.packed_vertex_data, bind)
  assert_eq(unused.cpu_skin_count(), 0)
  // Returning to an earlier pose also invalidates; revision equality alone
  // identifies unchanged data, so animation seeks are supported.
  let reset = asset.skinned_mesh(0, [@math3d.Mat4::identity()])
  assert_eq(reset.vertex_data[0], original_x)
}
