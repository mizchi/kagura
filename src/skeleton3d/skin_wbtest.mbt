///|
test "cpu skin: single bone identity - position unchanged" {
  // Single triangle mesh
  let vertex_data : Array[Double] = [
    1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, // v0
     0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, // v1
     0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 0.0, // v2
  ]
  let mesh = @mesh3d.Mesh3D::new(vertex_data, [0, 1, 2])
  let skin : SkinData = {
    joint_indices: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    weights: [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0],
    vertex_count: 3,
  }
  let skinning = [@math3d.Mat4::identity()]
  let result = apply_skin(mesh, skin, skinning)
  // With identity skinning, position should be unchanged
  assert_true((result.vertex_data[0] - 1.0).abs() < 1.0e-6)
  assert_true((result.vertex_data[1] - 0.0).abs() < 1.0e-6)
  assert_true((result.vertex_data[2] - 0.0).abs() < 1.0e-6)
  assert_true((result.vertex_data[8] - 0.0).abs() < 1.0e-6)
  assert_true((result.vertex_data[9] - 1.0).abs() < 1.0e-6)
  assert_true((result.vertex_data[10] - 0.0).abs() < 1.0e-6)
}

///|
test "cpu skin: rotated bone - vertices rotate" {
  // Single vertex at (1, 0, 0) with normal (0, 1, 0)
  let vertex_data : Array[Double] = [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0]
  let mesh = @mesh3d.Mesh3D::new(vertex_data, [0])
  let skin : SkinData = {
    joint_indices: [0, 0, 0, 0],
    weights: [1.0, 0.0, 0.0, 0.0],
    vertex_count: 1,
  }
  // 90-degree rotation around Z axis: (1,0,0) -> (0,1,0)
  let rot_z_90 = @math3d.Mat4::rotation_z(@math.PI / 2.0)
  let result = apply_skin(mesh, skin, [rot_z_90])
  // Position should be approximately (0, 1, 0)
  assert_true((result.vertex_data[0] - 0.0).abs() < 1.0e-6)
  assert_true((result.vertex_data[1] - 1.0).abs() < 1.0e-6)
  assert_true((result.vertex_data[2] - 0.0).abs() < 1.0e-6)
  // Normal (0,1,0) rotated 90 deg around Z -> (-1, 0, 0)
  assert_true((result.vertex_data[3] - -1.0).abs() < 1.0e-6)
  assert_true((result.vertex_data[4] - 0.0).abs() < 1.0e-6)
  assert_true((result.vertex_data[5] - 0.0).abs() < 1.0e-6)
}

///|
test "cpu skin: normal is normalized" {
  // Single vertex with normal that will be scaled by skinning
  let vertex_data : Array[Double] = [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0]
  let mesh = @mesh3d.Mesh3D::new(vertex_data, [0])
  let skin : SkinData = {
    joint_indices: [0, 0, 0, 0],
    weights: [1.0, 0.0, 0.0, 0.0],
    vertex_count: 1,
  }
  // Non-uniform scale matrix: scale x by 2.0
  let scale_mat = @math3d.Mat4::scaling(2.0, 1.0, 1.0)
  let result = apply_skin(mesh, skin, [scale_mat])
  // Normal should still be normalized despite non-uniform scale
  let nx = result.vertex_data[3]
  let ny = result.vertex_data[4]
  let nz = result.vertex_data[5]
  let len = (nx * nx + ny * ny + nz * nz).sqrt()
  assert_true((len - 1.0).abs() < 1.0e-6)
}
