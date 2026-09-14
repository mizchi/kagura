///|
test "resting actors keep their feet still and standing up blends back to a standing pose" {
  let enemy = @game.make_enemy(0.0, 0.0, @game.Basic, 10, 1.0, 10.0)
  enemy.camp = Some({
    pack_id: 0,
    pose: @game.Sitting,
    awareness: @game.Resting,
  })
  let sitting = enemy_rest_key(enemy, 0)
  enemy.camp.unwrap().awareness = @game.Waking(36)
  let first = enemy_rest_key(enemy, 0)
  enemy.camp.unwrap().awareness = @game.Waking(1)
  let last = enemy_rest_key(enemy, 0)
  let sit = biped_rest_pose(-sitting - 1, false)
  let rise = biped_rest_pose(-first - 1, false)
  let stand = biped_rest_pose(-last - 1, false)
  assert_true((sit[0].position.y - rise[0].position.y).abs() < 0.01)
  assert_true(stand[0].position.y > rise[0].position.y + 0.1)
  let idle = biped_rest_pose(0, false)
  let breathing = biped_rest_pose(2, false)
  for joint in [7, 8, 9, 10] {
    assert_true(
      idle[joint].to_mat4().approx_eq(breathing[joint].to_mat4(), 0.000001),
    )
  }
  assert_false(idle[1].to_mat4().approx_eq(breathing[1].to_mat4(), 0.000001))
}

///|
test "ground cover never occupies a road and stays within its per-chunk triangle budget" {
  let w = @game.GameWorld::new(seed=42, hunting_grounds=true)
  let chunk = build_hunting_chunk(w.dungeon, w.seed, 1, 2, region=0)
  assert_true(chunk.groups[10].mesh.indices.length() / 3 <= 80 * 6)
  for z in 1..<79 {
    for x in 1..<99 {
      if w.dungeon.grid.get(x, z) == @terrain.Corridor {
        assert_false(woodland_grass_allowed(w.dungeon, x, z))
      }
    }
  }
}

///|
test "seated bipeds and curled wolves keep their visible geometry above the floor" {
  let models = EnemyModels::new()
  for
    (mesh, clip) in [
      (models.basic, biped_rest_clip),
      (wolf_mesh, wolf_camp_clip),
      (zombie_mesh, zombie_rest_clip),
    ] {
    let mut floor = 100.0
    for phase in 0..<clip.frame_count {
      let posed = mesh.geometry.skinned_mesh(160 + phase, clip.matrices(phase))
      for i in 0..<posed.vertex_count() {
        floor = floor.min(posed.vertex_data[i * 8 + 1])
      }
    }
    if floor <= -0.08 {
      fail("rest pose sinks below the floor: \{floor}")
    }
  }
}
