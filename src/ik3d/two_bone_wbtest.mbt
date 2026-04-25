///|
/// Create a simple 3-bone arm skeleton: shoulder → elbow → hand
/// Bones are along +Y axis, each 1.0 unit long.
fn make_arm_skeleton() -> @skeleton3d.Skeleton {
  let bones : Array[@skeleton3d.Bone] = [
    {
      name: "shoulder",
      parent: -1,
      local_transform: @transform3d.Transform3D::new(),
    },
    {
      name: "elbow",
      parent: 0,
      local_transform: @transform3d.Transform3D::from_position(
        @math3d.Vec3::new(0.0, 1.0, 0.0),
      ),
    },
    {
      name: "hand",
      parent: 1,
      local_transform: @transform3d.Transform3D::from_position(
        @math3d.Vec3::new(0.0, 1.0, 0.0),
      ),
    },
  ]
  let ibm : Array[@math3d.Mat4] = [
    @math3d.Mat4::identity(),
    @math3d.Mat4::translation(0.0, -1.0, 0.0),
    @math3d.Mat4::translation(0.0, -2.0, 0.0),
  ]
  @skeleton3d.Skeleton::new(bones, ibm)
}

///|
fn make_arm_poses() -> Array[@transform3d.Transform3D] {
  [
    @transform3d.Transform3D::new(),
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(0.0, 1.0, 0.0)),
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(0.0, 1.0, 0.0)),
  ]
}

///|
test "two-bone IK: reachable target" {
  let skeleton = make_arm_skeleton()
  let poses = make_arm_poses()
  // Target at (1, 1, 0) - reachable (within 2.0 total length)
  let result = solve_two_bone_ik({
    skeleton,
    local_poses: poses,
    upper_bone: 0,
    lower_bone: 1,
    end_bone: 2,
    target: @math3d.Vec3::new(1.0, 1.0, 0.0),
    pole_target: None,
  })
  assert_true(result.success)
  // Verify end effector reaches near target
  let world = skeleton.compute_world_transforms(result.local_poses)
  let hand_pos = @math3d.Vec3::new(
    world[2].elements[12],
    world[2].elements[13],
    world[2].elements[14],
  )
  let error = hand_pos.distance(@math3d.Vec3::new(1.0, 1.0, 0.0))
  assert_true(error < 0.1)
}

///|
test "two-bone IK: unreachable target" {
  let skeleton = make_arm_skeleton()
  let poses = make_arm_poses()
  // Target at (0, 5, 0) - unreachable (total length = 2.0)
  let result = solve_two_bone_ik({
    skeleton,
    local_poses: poses,
    upper_bone: 0,
    lower_bone: 1,
    end_bone: 2,
    target: @math3d.Vec3::new(0.0, 5.0, 0.0),
    pole_target: None,
  })
  assert_true(!(result.success))
  // Chain should stretch toward target direction
  let world = skeleton.compute_world_transforms(result.local_poses)
  let hand_pos = @math3d.Vec3::new(
    world[2].elements[12],
    world[2].elements[13],
    world[2].elements[14],
  )
  // Hand should be roughly at (0, ~2, 0) stretched up
  assert_true(hand_pos.y > 1.5)
}

///|
test "two-bone IK: with pole target" {
  let skeleton = make_arm_skeleton()
  let poses = make_arm_poses()
  // Target at (0, 1.5, 0), pole at (0, 0, 1) to bend elbow toward +Z
  let result = solve_two_bone_ik({
    skeleton,
    local_poses: poses,
    upper_bone: 0,
    lower_bone: 1,
    end_bone: 2,
    target: @math3d.Vec3::new(0.0, 1.5, 0.0),
    pole_target: Some(@math3d.Vec3::new(0.0, 0.0, 1.0)),
  })
  assert_true(result.success)
  // Verify the elbow bends (not straight line)
  let world = skeleton.compute_world_transforms(result.local_poses)
  let elbow_pos = @math3d.Vec3::new(
    world[1].elements[12],
    world[1].elements[13],
    world[1].elements[14],
  )
  // The elbow should have some displacement (not just straight along Y)
  let elbow_dist_from_y = (elbow_pos.x * elbow_pos.x + elbow_pos.z * elbow_pos.z).sqrt()
  // With a target close enough to need bending, elbow should be off-axis
  assert_true(elbow_dist_from_y > 0.01 || elbow_pos.y < 1.9)
}

///|
test "two-bone IK: elbow not on straight line (visible bend)" {
  let skeleton = make_arm_skeleton()
  let poses = make_arm_poses()
  // Target at (0.6, 0.6, 0) - close enough to force significant bending
  let target = @math3d.Vec3::new(0.6, 0.6, 0.0)
  let result = solve_two_bone_ik({
    skeleton,
    local_poses: poses,
    upper_bone: 0,
    lower_bone: 1,
    end_bone: 2,
    target,
    pole_target: Some(@math3d.Vec3::new(0.0, 0.0, 1.0)),
  })
  assert_true(result.success)
  let world = skeleton.compute_world_transforms(result.local_poses)
  let p0 = @math3d.Vec3::new(
    world[0].elements[12],
    world[0].elements[13],
    world[0].elements[14],
  )
  let p1 = @math3d.Vec3::new(
    world[1].elements[12],
    world[1].elements[13],
    world[1].elements[14],
  )
  let p2 = @math3d.Vec3::new(
    world[2].elements[12],
    world[2].elements[13],
    world[2].elements[14],
  )
  // Print for debugging
  println("shoulder=\{p0}")
  println("elbow=\{p1}")
  println("hand=\{p2}")
  println("target=\{target}")
  println("hand_error=\{p2.distance(target)}")
  // Elbow should NOT be on the line from shoulder to hand
  // Compute distance from elbow to line shoulder→hand
  let sh = p2.sub(p0) // shoulder to hand
  let se = p1.sub(p0) // shoulder to elbow
  let t = se.dot(sh) / sh.dot(sh)
  let closest_on_line = p0.add(sh.scale(t))
  let elbow_off_line = p1.distance(closest_on_line)
  println("elbow_off_line_distance=\{elbow_off_line}")
  // With pole_target at Z, elbow should be offset in Z direction
  println("elbow_z=\{p1.z}")
  assert_true(elbow_off_line > 0.1) // significant bend
  // Bone lengths
  println("len_01=\{p0.distance(p1)}")
  println("len_12=\{p1.distance(p2)}")
  assert_true((p0.distance(p1) - 1.0).abs() < 0.01)
  assert_true((p1.distance(p2) - 1.0).abs() < 0.01)
}

///|
test "two-bone IK: compare with FABRIK same target" {
  let skeleton = make_arm_skeleton()
  let target = @math3d.Vec3::new(0.6, 0.6, 0.0)
  // Two-Bone IK
  let tb_result = solve_two_bone_ik({
    skeleton,
    local_poses: make_arm_poses(),
    upper_bone: 0,
    lower_bone: 1,
    end_bone: 2,
    target,
    pole_target: Some(@math3d.Vec3::new(0.0, 0.0, 1.0)),
  })
  let tb_world = skeleton.compute_world_transforms(tb_result.local_poses)
  // FABRIK
  let fab_result = solve_fabrik({
    skeleton,
    local_poses: make_arm_poses(),
    chain: [0, 1, 2],
    target,
    tolerance: 0.001,
    max_iterations: 50,
  })
  let fab_world = skeleton.compute_world_transforms(fab_result.local_poses)
  // Compare hand positions
  let tb_hand = @math3d.Vec3::new(
    tb_world[2].elements[12],
    tb_world[2].elements[13],
    tb_world[2].elements[14],
  )
  let fab_hand = @math3d.Vec3::new(
    fab_world[2].elements[12],
    fab_world[2].elements[13],
    fab_world[2].elements[14],
  )
  println("Two-Bone hand=\{tb_hand}")
  println("FABRIK hand=\{fab_hand}")
  // Both should reach the target
  assert_true(tb_hand.distance(target) < 0.1)
  assert_true(fab_hand.distance(target) < 0.1)
  // Compare elbow positions
  let tb_elbow = @math3d.Vec3::new(
    tb_world[1].elements[12],
    tb_world[1].elements[13],
    tb_world[1].elements[14],
  )
  let fab_elbow = @math3d.Vec3::new(
    fab_world[1].elements[12],
    fab_world[1].elements[13],
    fab_world[1].elements[14],
  )
  println("Two-Bone elbow=\{tb_elbow}")
  println("FABRIK elbow=\{fab_elbow}")
  // Compare rotation quaternions
  for i in 0..<3 {
    let tb_r = tb_result.local_poses[i].rotation
    let fab_r = fab_result.local_poses[i].rotation
    println(
      "bone[\{i}] TB_rot=(\{tb_r.x}, \{tb_r.y}, \{tb_r.z}, \{tb_r.w}) FAB_rot=(\{fab_r.x}, \{fab_r.y}, \{fab_r.z}, \{fab_r.w})",
    )
  }
}

///|
test "two-bone IK: bone lengths preserved after solve" {
  let skeleton = make_arm_skeleton()
  let poses = make_arm_poses()
  let result = solve_two_bone_ik({
    skeleton,
    local_poses: poses,
    upper_bone: 0,
    lower_bone: 1,
    end_bone: 2,
    target: @math3d.Vec3::new(1.0, 1.0, 0.0),
    pole_target: Some(@math3d.Vec3::new(0.0, 0.0, 1.0)),
  })
  let world = skeleton.compute_world_transforms(result.local_poses)
  let p0 = @math3d.Vec3::new(
    world[0].elements[12],
    world[0].elements[13],
    world[0].elements[14],
  )
  let p1 = @math3d.Vec3::new(
    world[1].elements[12],
    world[1].elements[13],
    world[1].elements[14],
  )
  let p2 = @math3d.Vec3::new(
    world[2].elements[12],
    world[2].elements[13],
    world[2].elements[14],
  )
  // Bone lengths should be preserved (1.0 each)
  let len01 = p0.distance(p1)
  let len12 = p1.distance(p2)
  assert_true((len01 - 1.0).abs() < 0.01)
  assert_true((len12 - 1.0).abs() < 0.01)
}
