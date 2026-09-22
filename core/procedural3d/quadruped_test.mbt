///|
test "quadruped rig keeps its four legs, jaw and tail independently bound" {
  let skeleton = @procedural3d.build_quadruped_skeleton(
    @procedural3d.default_quadruped_proportions(),
  )
  assert_eq(skeleton.bones.length(), 15)
  let rest = skeleton.bones.map(b => b.local_transform)
  let skin = skeleton.compute_skinning_matrices(
    skeleton.compute_world_transforms(rest),
  )
  for matrix in skin {
    assert_true(matrix.approx_eq(@math3d.Mat4::identity(), 0.00001))
  }
  assert_eq(skeleton.bones[4].parent, 3)
  for joint in [7, 9, 11, 13] {
    assert_eq(skeleton.bones[joint + 1].parent, joint)
  }
}
