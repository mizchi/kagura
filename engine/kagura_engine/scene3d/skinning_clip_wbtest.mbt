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
