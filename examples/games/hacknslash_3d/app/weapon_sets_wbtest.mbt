///|
test "species meshes contain no weapon sockets or embedded bow geometry" {
  let models = EnemyModels::new()
  for
    kind in [
      @game.Basic,
      @game.Fast,
      @game.Ranged,
      @game.Caster,
      @game.Tank,
      @game.Boss,
    ] {
    let body = models.get_mesh_data(kind)
    for joint in body.geometry.skin_data.joint_indices {
      assert_true(joint < 12)
    }
  }
  assert_eq(
    models.ranged.geometry.bind_mesh.vertex_count(),
    models.caster.geometry.bind_mesh.vertex_count(),
  )
}

///|
test "each weapon owns its motion and is reusable across species with cached material batches" {
  let models = EnemyModels::new()
  let before = models.basic.geometry.bind_mesh.vertex_count()
  for
    (i, id, motion) in [
      (0, "knuckles", @game.Punch),
      (1, "spear", @game.SpearThrust),
      (2, "focus", @game.CastSpell),
      (3, "bow", @game.BowShot),
    ] {
    let weapon = models.weapons[i]
    assert_eq(weapon.id, id)
    assert_eq(weapon.motion, motion)
    assert_eq(enemy_attack_clip_index(motion), i)
    assert_true(weapon.mesh.parts.length() > 0)
    for kind in [@game.Basic, @game.Fast, @game.Caster] {
      let equipped = models.get_equipped_mesh_data(kind, weapon_index=i)
      assert_eq(
        equipped.geometry.bind_mesh.vertex_count(),
        models.get_mesh_data(kind).geometry.bind_mesh.vertex_count() +
        weapon.mesh.geometry.bind_mesh.vertex_count(),
      )
      let _ = equipped.parts[0].geometry.skinned_mesh(
        0,
        models.compute_skinning(),
      )
      let cached = models.get_equipped_mesh_data(kind, weapon_index=i)
      let _ = cached.parts[0].geometry.skinned_mesh(
        0,
        models.compute_skinning(),
      )
      assert_eq(cached.parts[0].geometry.cpu_skin_count(), 1)
      assert_true(
        equipped.parts.length() <=
        models.get_mesh_data(kind).parts.length() + weapon.mesh.parts.length(),
      )
    }
  }
  assert_eq(models.basic.geometry.bind_mesh.vertex_count(), before)
  for
    kind in [
      @game.Basic,
      @game.Fast,
      @game.Caster,
      @game.Ranged,
      @game.Tank,
      @game.Boss,
    ] {
    assert_true(models.get_equipped_mesh_data(kind).parts.length() <= 5)
  }
}
