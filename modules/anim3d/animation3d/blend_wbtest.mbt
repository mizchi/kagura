///|
test "blend_poses: weight=0 returns poses_a" {
  let a : Array[@transform3d.Transform3D] = [
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(1.0, 0.0, 0.0)),
  ]
  let b : Array[@transform3d.Transform3D] = [
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(5.0, 0.0, 0.0)),
  ]
  let result = blend_poses(a, b, 0.0)
  assert_true(
    result[0].position.approx_eq(@math3d.Vec3::new(1.0, 0.0, 0.0), 1.0e-6),
  )
}

///|
test "blend_poses: weight=1 returns poses_b" {
  let a : Array[@transform3d.Transform3D] = [
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(1.0, 0.0, 0.0)),
  ]
  let b : Array[@transform3d.Transform3D] = [
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(5.0, 0.0, 0.0)),
  ]
  let result = blend_poses(a, b, 1.0)
  assert_true(
    result[0].position.approx_eq(@math3d.Vec3::new(5.0, 0.0, 0.0), 1.0e-6),
  )
}

///|
test "blend_poses: weight=0.5 interpolates" {
  let a : Array[@transform3d.Transform3D] = [
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(0.0, 0.0, 0.0)),
  ]
  let b : Array[@transform3d.Transform3D] = [
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(10.0, 0.0, 0.0)),
  ]
  let result = blend_poses(a, b, 0.5)
  assert_true(
    result[0].position.approx_eq(@math3d.Vec3::new(5.0, 0.0, 0.0), 1.0e-6),
  )
}

///|
test "blend_poses: rotation slerp" {
  let pi = 3.14159265358979
  let q_a = @math3d.Quaternion::identity()
  let q_b = @math3d.Quaternion::from_axis_angle(@math3d.Vec3::unit_y(), pi)
  let a : Array[@transform3d.Transform3D] = [
    @transform3d.Transform3D::new().with_rotation(q_a),
  ]
  let b : Array[@transform3d.Transform3D] = [
    @transform3d.Transform3D::new().with_rotation(q_b),
  ]
  let result = blend_poses(a, b, 0.5)
  // Half-way slerp between identity and 180deg Y should be 90deg Y
  let expected = @math3d.Quaternion::from_axis_angle(
    @math3d.Vec3::unit_y(),
    pi / 2.0,
  )
  assert_true(result[0].rotation.approx_eq(expected, 1.0e-3))
}

///|
test "blend_node_poses: merges by node_index" {
  let a : Array[NodePose] = [
    {
      node_index: 0,
      translation: Some(@math3d.Vec3::new(0.0, 0.0, 0.0)),
      rotation: None,
      scale: None,
    },
  ]
  let b : Array[NodePose] = [
    {
      node_index: 0,
      translation: Some(@math3d.Vec3::new(10.0, 0.0, 0.0)),
      rotation: None,
      scale: None,
    },
    {
      node_index: 1,
      translation: Some(@math3d.Vec3::new(5.0, 5.0, 5.0)),
      rotation: None,
      scale: None,
    },
  ]
  let result = blend_node_poses(a, b, 0.5)
  // node 0 should be blended
  let mut found0 = false
  let mut found1 = false
  for p in result {
    if p.node_index == 0 {
      found0 = true
      match p.translation {
        Some(v) =>
          assert_true(v.approx_eq(@math3d.Vec3::new(5.0, 0.0, 0.0), 1.0e-6))
        None => fail("Expected translation for node 0")
      }
    }
    if p.node_index == 1 {
      found1 = true
    }
  }
  assert_true(found0)
  assert_true(found1)
}
