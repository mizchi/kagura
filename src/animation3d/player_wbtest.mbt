///|
test "player: update + loop wrapping" {
  let clip : AnimationClip = { name: "test", channels: [], duration: 2.0 }
  let player = AnimationPlayer::new(clip)
  // Advance past duration
  player.update(2.5)
  // Should wrap: 2.5 - 2.0 = 0.5
  assert_true((player.current_time() - 0.5).abs() < 1.0e-6)
}

///|
test "player: sample returns correct NodePose" {
  let clip : AnimationClip = {
    name: "test",
    channels: [
      {
        node_index: 0,
        target: Translation,
        interpolation: Linear,
        times: [0.0, 1.0],
        values: [0.0, 0.0, 0.0, 10.0, 0.0, 0.0],
      },
    ],
    duration: 1.0,
  }
  let player = AnimationPlayer::new(clip)
  player.set_time(0.5)
  let poses = player.sample()
  assert_eq(poses.length(), 1)
  assert_eq(poses[0].node_index, 0)
  match poses[0].translation {
    Some(v) =>
      assert_true(v.approx_eq(@math3d.Vec3::new(5.0, 0.0, 0.0), 1.0e-6))
    None => fail("Expected translation")
  }
}

///|
test "player: speed control" {
  let clip : AnimationClip = { name: "test", channels: [], duration: 4.0 }
  let player = AnimationPlayer::new(clip)
  player.set_speed(2.0)
  player.update(1.0) // effective dt = 2.0
  assert_true((player.current_time() - 2.0).abs() < 1.0e-6)
}

///|
test "apply_node_poses: applies translation/rotation/scale" {
  let poses : Array[@transform3d.Transform3D] = [
    @transform3d.Transform3D::new(),
    @transform3d.Transform3D::new(),
  ]
  let node_poses : Array[NodePose] = [
    {
      node_index: 0,
      translation: Some(@math3d.Vec3::new(1.0, 2.0, 3.0)),
      rotation: None,
      scale: None,
    },
    {
      node_index: 1,
      translation: None,
      rotation: None,
      scale: Some(@math3d.Vec3::new(2.0, 2.0, 2.0)),
    },
  ]
  apply_node_poses(poses, node_poses)
  assert_true(
    poses[0].position.approx_eq(@math3d.Vec3::new(1.0, 2.0, 3.0), 1.0e-6),
  )
  assert_true(
    poses[1].scale.approx_eq(@math3d.Vec3::new(2.0, 2.0, 2.0), 1.0e-6),
  )
}

///|
test "apply_node_poses: out of range index ignored" {
  let poses : Array[@transform3d.Transform3D] = [@transform3d.Transform3D::new()]
  let node_poses : Array[NodePose] = [
    {
      node_index: 5,
      translation: Some(@math3d.Vec3::new(1.0, 0.0, 0.0)),
      rotation: None,
      scale: None,
    },
  ]
  apply_node_poses(poses, node_poses)
  // Should not crash, pose unchanged
  assert_true(
    poses[0].position.approx_eq(@math3d.Vec3::zero(), 1.0e-6),
  )
}
