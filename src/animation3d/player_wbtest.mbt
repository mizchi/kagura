///|
test "player: update + loop wrapping" {
  let clip : AnimationClip = {
    name: "test",
    channels: [],
    duration: 2.0,
  }
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
    Some(v) => assert_true(v.approx_eq(@math3d.Vec3::new(5.0, 0.0, 0.0), 1.0e-6))
    None => fail("Expected translation")
  }
}

///|
test "player: speed control" {
  let clip : AnimationClip = {
    name: "test",
    channels: [],
    duration: 4.0,
  }
  let player = AnimationPlayer::new(clip)
  player.set_speed(2.0)
  player.update(1.0) // effective dt = 2.0
  assert_true((player.current_time() - 2.0).abs() < 1.0e-6)
}
