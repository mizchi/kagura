///|
test "hierarchy: 2-bone chain world transforms" {
  let bones = [
    {
      name: "root",
      parent: -1,
      local_transform: @transform3d.Transform3D::new(),
    },
    {
      name: "child",
      parent: 0,
      local_transform: @transform3d.Transform3D::new(),
    },
  ]
  let ibms = [@math3d.Mat4::identity(), @math3d.Mat4::identity()]
  let skel = Skeleton::new(bones, ibms)
  assert_eq(skel.bone_count(), 2)
  // Root translated by (1,0,0), child translated by (0,2,0)
  let poses = [
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(1.0, 0.0, 0.0)),
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(0.0, 2.0, 0.0)),
  ]
  let world = skel.compute_world_transforms(poses)
  // Root world = (1,0,0) translation
  assert_true(
    @math3d.Mat4::translation(1.0, 0.0, 0.0).approx_eq(world[0], 1.0e-6),
  )
  // Child world = parent * child = translate(1,0,0) * translate(0,2,0) = translate(1,2,0)
  assert_true(
    @math3d.Mat4::translation(1.0, 2.0, 0.0).approx_eq(world[1], 1.0e-6),
  )
}

///|
test "hierarchy: 3-bone branch world transforms" {
  let bones = [
    {
      name: "root",
      parent: -1,
      local_transform: @transform3d.Transform3D::new(),
    },
    {
      name: "left",
      parent: 0,
      local_transform: @transform3d.Transform3D::new(),
    },
    {
      name: "right",
      parent: 0,
      local_transform: @transform3d.Transform3D::new(),
    },
  ]
  let ibms = [
    @math3d.Mat4::identity(),
    @math3d.Mat4::identity(),
    @math3d.Mat4::identity(),
  ]
  let skel = Skeleton::new(bones, ibms)
  let poses = [
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(0.0, 1.0, 0.0)),
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(1.0, 0.0, 0.0)),
    @transform3d.Transform3D::from_position(
      @math3d.Vec3::new(-1.0, 0.0, 0.0),
    ),
  ]
  let world = skel.compute_world_transforms(poses)
  // left = root * left = translate(0,1,0) * translate(1,0,0) = translate(1,1,0)
  assert_true(
    @math3d.Mat4::translation(1.0, 1.0, 0.0).approx_eq(world[1], 1.0e-6),
  )
  // right = root * right = translate(0,1,0) * translate(-1,0,0) = translate(-1,1,0)
  assert_true(
    @math3d.Mat4::translation(-1.0, 1.0, 0.0).approx_eq(world[2], 1.0e-6),
  )
}

///|
test "skinning matrix: identity bind pose" {
  let bones = [
    {
      name: "root",
      parent: -1,
      local_transform: @transform3d.Transform3D::new(),
    },
  ]
  let ibms = [@math3d.Mat4::identity()]
  let skel = Skeleton::new(bones, ibms)
  let world = [@math3d.Mat4::translation(2.0, 0.0, 0.0)]
  let skinning = skel.compute_skinning_matrices(world)
  // skinning = world * ibm = translate(2,0,0) * identity = translate(2,0,0)
  assert_true(
    @math3d.Mat4::translation(2.0, 0.0, 0.0).approx_eq(skinning[0], 1.0e-6),
  )
}
