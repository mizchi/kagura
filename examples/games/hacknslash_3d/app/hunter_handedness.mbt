///|
/// The original authored assets use +X for right. With +Z forward and +Y up,
/// anatomical right is -X. Convert rigid assets once, before caching GPU data.
fn right_handed_hunter_part(part : CharacterPart) -> CharacterPart {
  let vertices = part.mesh.vertex_data.copy()
  let indices = part.mesh.indices.copy()
  for i in 0..<part.skin.vertex_count {
    vertices[i * 8] = -vertices[i * 8]
    vertices[i * 8 + 3] = -vertices[i * 8 + 3]
  }
  for i in 0..<(indices.length() / 3) {
    let b = indices[i * 3 + 1]
    indices[i * 3 + 1] = indices[i * 3 + 2]
    indices[i * 3 + 2] = b
  }
  let mesh = @mesh3d.Mesh3D::new(vertices, indices)
  {
    ..part,
    mesh,
    packed: @skeleton3d.build_skinned_vertex_data(mesh, part.skin),
  }
}

///|
/// S * transform * S: preserve positive scale and reflect both translation and rotation.
fn reflect_hunter_pose(
  pose : @transform3d.Transform3D,
) -> @transform3d.Transform3D {
  let p = pose.position
  let q = pose.rotation
  pose
  .with_position(@math3d.Vec3::new(-p.x, p.y, p.z))
  .with_rotation(@math3d.Quaternion::new(q.x, -q.y, -q.z, q.w))
}

///|
/// HY's focus clip casts with its left hand. Transfer that gesture to the main hand.
fn CharacterModel::use_right_hand_for_focus(self : CharacterModel) -> Unit {
  for (right, left) in [(2, 6), (3, 7)] {
    let r = self.local_poses[right].rotation
    let l = self.local_poses[left].rotation
    self.local_poses[right] = self.local_poses[right].with_rotation(
      @math3d.Quaternion::new(l.x, -l.y, -l.z, l.w),
    )
    self.local_poses[left] = self.local_poses[left].with_rotation(
      @math3d.Quaternion::new(r.x, -r.y, -r.z, r.w),
    )
  }
  for i in [1, 5] {
    let q = self.local_poses[i].rotation
    self.local_poses[i] = self.local_poses[i].with_rotation(
      @math3d.Quaternion::new(q.x, -q.y, -q.z, q.w),
    )
  }
}
