///|
test "baked skinning poses include both endpoints and reuse unchanged samples" {
  let skeleton = @skeleton3d.Skeleton::new(
    [
      {
        name: "root",
        parent: -1,
        local_transform: @transform3d.Transform3D::from_position(
          @math3d.Vec3::zero(),
        ),
      },
    ],
    [@math3d.Mat4::identity()],
  )
  let clip : @animation3d.AnimationClip = {
    name: "move",
    duration: 1.0,
    channels: [
      {
        node_index: 0,
        target: @animation3d.Translation,
        interpolation: @animation3d.Linear,
        times: [0.0, 1.0],
        values: [0.0, 0.0, 0.0, 2.0, 0.0, 0.0],
      },
    ],
  }
  let baked = BakedSkinningClip::new(skeleton, clip, 3)
  assert_eq(baked.frame_index(-1.0), 0)
  assert_eq(baked.frame_index(0.5), 1)
  assert_eq(baked.frame_index(2.0), 2)
  assert_true(baked.matrices(0)[0].approx_eq(@math3d.Mat4::identity(), 0.00001))
  assert_true(
    baked.matrices(1)[0].approx_eq(
      @math3d.Mat4::translation(1.0, 0.0, 0.0),
      0.00001,
    ),
  )
  assert_true(
    baked.matrices(2)[0].approx_eq(
      @math3d.Mat4::translation(2.0, 0.0, 0.0),
      0.00001,
    ),
  )
  assert_true(baked.matrices(0)[0].approx_eq(@math3d.Mat4::identity(), 0.00001))
}

///|
test "procedural poses bake a hierarchy once and retain inverse bind matrices" {
  let skeleton = @skeleton3d.Skeleton::new(
    [
      {
        name: "root",
        parent: -1,
        local_transform: @transform3d.Transform3D::from_position(
          @math3d.Vec3::zero(),
        ),
      },
      {
        name: "child",
        parent: 0,
        local_transform: @transform3d.Transform3D::from_position(
          @math3d.Vec3::new(0.0, 2.0, 0.0),
        ),
      },
    ],
    [@math3d.Mat4::identity(), @math3d.Mat4::translation(0.0, -2.0, 0.0)],
  )
  let mut calls = 0
  let baked = BakedSkinningClip::from_pose_sampler(skeleton, 3, i => {
    calls += 1
    let poses = skeleton.bones.map(b => b.local_transform)
    poses[0] = poses[0].with_position(
      @math3d.Vec3::new(i.to_double(), 0.0, 0.0),
    )
    poses
  })
  assert_eq(calls, 3)
  for i in 0..<3 {
    for matrix in baked.matrices(i) {
      assert_true(
        matrix.approx_eq(
          @math3d.Mat4::translation(i.to_double(), 0.0, 0.0),
          0.00001,
        ),
      )
    }
  }
  assert_true(
    baked.matrices(-1)[1].approx_eq(@math3d.Mat4::identity(), 0.00001),
  )
  assert_true(
    baked.matrices(99)[1].approx_eq(
      @math3d.Mat4::translation(2.0, 0.0, 0.0),
      0.00001,
    ),
  )
  assert_eq(calls, 3)
  let one = BakedSkinningClip::from_pose_sampler(skeleton, 0, _ => {
    skeleton.bones.map(b => b.local_transform)
  })
  assert_eq(one.frame_count, 1)
  assert_eq(one.frame_index(1.0), 0)
}
