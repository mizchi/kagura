///|
/// Create a 4-bone chain skeleton (along +Y axis, 1.0 unit each)
fn make_chain_skeleton() -> @skeleton3d.Skeleton {
  let bones : Array[@skeleton3d.Bone] = [
    {
      name: "base",
      parent: -1,
      local_transform: @transform3d.Transform3D::new(),
    },
    {
      name: "seg1",
      parent: 0,
      local_transform: @transform3d.Transform3D::from_position(
        @math3d.Vec3::new(0.0, 1.0, 0.0),
      ),
    },
    {
      name: "seg2",
      parent: 1,
      local_transform: @transform3d.Transform3D::from_position(
        @math3d.Vec3::new(0.0, 1.0, 0.0),
      ),
    },
    {
      name: "tip",
      parent: 2,
      local_transform: @transform3d.Transform3D::from_position(
        @math3d.Vec3::new(0.0, 1.0, 0.0),
      ),
    },
  ]
  let ibm : Array[@math3d.Mat4] = [
    @math3d.Mat4::identity(),
    @math3d.Mat4::translation(0.0, -1.0, 0.0),
    @math3d.Mat4::translation(0.0, -2.0, 0.0),
    @math3d.Mat4::translation(0.0, -3.0, 0.0),
  ]
  @skeleton3d.Skeleton::new(bones, ibm)
}

///|
fn make_chain_poses() -> Array[@transform3d.Transform3D] {
  [
    @transform3d.Transform3D::new(),
    @transform3d.Transform3D::from_position(
      @math3d.Vec3::new(0.0, 1.0, 0.0),
    ),
    @transform3d.Transform3D::from_position(
      @math3d.Vec3::new(0.0, 1.0, 0.0),
    ),
    @transform3d.Transform3D::from_position(
      @math3d.Vec3::new(0.0, 1.0, 0.0),
    ),
  ]
}

///|
test "FABRIK: 4-bone chain convergence" {
  let skeleton = make_chain_skeleton()
  let poses = make_chain_poses()
  // Target at (1, 2, 0) - reachable (total length = 3.0)
  let result = solve_fabrik(
    {
      skeleton,
      local_poses: poses,
      chain: [0, 1, 2, 3],
      target: @math3d.Vec3::new(1.0, 2.0, 0.0),
      tolerance: 0.01,
      max_iterations: 20,
    },
  )
  assert_true(result.success)
  // Verify tip reaches near target
  let world = skeleton.compute_world_transforms(result.local_poses)
  let tip_pos = @math3d.Vec3::new(
    world[3].elements[12],
    world[3].elements[13],
    world[3].elements[14],
  )
  let error = tip_pos.distance(@math3d.Vec3::new(1.0, 2.0, 0.0))
  assert_true(error < 0.2)
}

///|
test "FABRIK: unreachable target stretches toward target" {
  let skeleton = make_chain_skeleton()
  let poses = make_chain_poses()
  // Target at (0, 10, 0) - unreachable (total length = 3.0)
  let result = solve_fabrik(
    {
      skeleton,
      local_poses: poses,
      chain: [0, 1, 2, 3],
      target: @math3d.Vec3::new(0.0, 10.0, 0.0),
      tolerance: 0.01,
      max_iterations: 10,
    },
  )
  assert_true(not(result.success))
  // Chain should stretch toward target (upward)
  let world = skeleton.compute_world_transforms(result.local_poses)
  let tip_pos = @math3d.Vec3::new(
    world[3].elements[12],
    world[3].elements[13],
    world[3].elements[14],
  )
  // Tip should be at approximately y=3.0 (fully stretched)
  assert_true(tip_pos.y > 2.0)
}

///|
test "FABRIK: bone lengths preserved after solve" {
  let skeleton = make_chain_skeleton()
  let poses = make_chain_poses()
  let result = solve_fabrik(
    {
      skeleton,
      local_poses: poses,
      chain: [0, 1, 2, 3],
      target: @math3d.Vec3::new(1.0, 2.0, 0.0),
      tolerance: 0.01,
      max_iterations: 20,
    },
  )
  let world = skeleton.compute_world_transforms(result.local_poses)
  // Check all bone lengths are preserved
  for i in 0..<3 {
    let p0 = @math3d.Vec3::new(
      world[i].elements[12],
      world[i].elements[13],
      world[i].elements[14],
    )
    let p1 = @math3d.Vec3::new(
      world[i + 1].elements[12],
      world[i + 1].elements[13],
      world[i + 1].elements[14],
    )
    let len = p0.distance(p1)
    // Each segment should be 1.0
    assert_true((len - 1.0).abs() < 0.05)
  }
}

///|
test "FABRIK: already at target" {
  let skeleton = make_chain_skeleton()
  let poses = make_chain_poses()
  // Target at (0, 3, 0) - exactly at current tip position
  let result = solve_fabrik(
    {
      skeleton,
      local_poses: poses,
      chain: [0, 1, 2, 3],
      target: @math3d.Vec3::new(0.0, 3.0, 0.0),
      tolerance: 0.01,
      max_iterations: 10,
    },
  )
  assert_true(result.success)
  assert_true(result.iterations <= 1)
}
