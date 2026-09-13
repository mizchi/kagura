///|
test "hunter faces positive Z with the sword in anatomical right and the bow in anatomical left" {
  let actor = CharacterModel::new()
  let rig = actor.skeleton
  let rest = rig.compute_world_transforms(rig.bones.map(b => b.local_transform))
  let origin = @math3d.Vec4::new(0.0, 0.0, 0.0, 1.0)
  assert_true(rest[2].mul_vec4(origin).x < 0.0)
  assert_true(rest[4].mul_vec4(origin).x < -0.3)
  assert_true(rest[6].mul_vec4(origin).x > 0.0)
  assert_true(rest[14].mul_vec4(origin).x > 0.3)
  for
    kind in [@game.Cleaver, @game.Spear, @game.Knuckles, @game.Focus, @game.Bow] {
    actor.equip_weapon(kind)
    if kind == @game.Focus {
      // The source focus prop and gesture used the left forearm. Both must
      // transfer to the main hand, not merely reflect the entire silhouette.
      assert_true(
        actor.weapon.parts.any(part => part.skin.joint_indices.contains(3)),
      )
      assert_false(
        actor.weapon.parts.any(part => part.skin.joint_indices.contains(7)),
      )
    }
    for part in actor.weapon.parts {
      for i in 0..<part.skin.vertex_count {
        if part.skin.joint_indices[i * 4] == 4 {
          assert_true(part.mesh.vertex_data[i * 8] < 0.0)
        }
      }
    }
    actor.trigger_attack()
    actor.update(kind.profile().windup.to_double() / 60.0)
    ignore(actor.compute_skinning())
    assert_true(actor.local_poses[2].position.x < 0.0)
    assert_true(actor.local_poses[6].position.x > 0.0)
  }
}

///|
test "mirroring hunter geometry keeps front face winding aligned with its normals" {
  let g = @procedural3d.RigidGeometry::new()
  g.triangle(
    @math3d.Vec3::new(0.3, 0.0, 0.0),
    @math3d.Vec3::new(0.3, 1.0, 0.0),
    @math3d.Vec3::new(0.3, 0.0, 1.0),
    4,
  )
  let p = finish_hunter_part(g, "test", 0xFFFFFF)
  let v = p.mesh.vertex_data
  assert_true(v[0] < 0.0)
  assert_true(v[3] < 0.0)
  let points = p.mesh.indices.map(i => {
    @math3d.Vec3::new(v[i * 8], v[i * 8 + 1], v[i * 8 + 2])
  })
  let normal = points[1].sub(points[0]).cross(points[2].sub(points[0]))
  assert_true(normal.x < 0.0)
}
