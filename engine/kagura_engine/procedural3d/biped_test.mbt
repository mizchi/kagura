///|
test "biped base has independent limbs and identity skinning at rest" {
  let body = @procedural3d.build_biped_base(
    @procedural3d.default_biped_proportions(),
  )
  let rig = body.skeleton
  assert_eq(rig.bones.length(), 12)
  let poses = rig.bones.map(fn(bone) { bone.local_transform })
  let skinning = rig.compute_skinning_matrices(
    rig.compute_world_transforms(poses),
  )
  for geometry in [body.head, body.torso, body.arms, body.legs] {
    let mesh = geometry.build_mesh()
    let skinned = @skeleton3d.apply_skin(mesh, geometry.build_skin(), skinning)
    assert_eq(mesh.vertex_count(), skinned.vertex_count())
    for i in 0..<mesh.vertex_data.length() {
      assert_true(
        (mesh.vertex_data[i] - skinned.vertex_data[i]).abs() < 0.00001,
      )
    }
  }
  for joint in [3, 4, 5, 6] {
    assert_true(body.arms.joints.contains(joint))
  }
  for joint in [7, 8, 9, 10] {
    assert_true(body.legs.joints.contains(joint))
  }
}

///|
test "biped proportions alter silhouette while preserving the rig contract" {
  let narrow = @procedural3d.default_biped_proportions()
  let broad = { ..narrow, head_width: 0.36, limb_radius: 0.09, }
  let first = @procedural3d.build_biped_base(narrow)
  let second = @procedural3d.build_biped_base(broad)
  assert_eq(first.skeleton.bones.length(), second.skeleton.bones.length())
  let mut narrow_width = 0.0
  let mut broad_width = 0.0
  for i in 0..<(first.head.vertices.length() / 8) {
    narrow_width = narrow_width.max(first.head.vertices[i * 8].abs())
    broad_width = broad_width.max(second.head.vertices[i * 8].abs())
  }
  assert_true(broad_width > narrow_width * 1.4)
  assert_true(second.arms.vertices != first.arms.vertices)
}
