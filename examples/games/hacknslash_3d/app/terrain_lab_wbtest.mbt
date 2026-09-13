///|
test "terrain lab keeps simulation and camera orientation while changing real ground" {
  let s = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  s.world.mode = @game.Playing
  s.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [78]))
  assert_true(s.paused && s.terrain_lab.editing)
  let frame = s.world.frame_count
  let position = (s.world.player.x, s.world.player.y)
  let enemies = s.world.enemies.length()
  let camera = s.camera
  assert_true(s.apply_terrain_lab([4.0, 42.0, 6.0, 18.0, 0.5]))
  assert_true(s.terrain_lab.stats.maximum > 1.0)
  assert_eq(s.camera.yaw, camera.yaw)
  assert_eq(s.camera.pitch, camera.pitch)
  assert_eq(s.world.enemies.length(), enemies)
  assert_eq((s.world.player.x, s.world.player.y), position)
  s.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [87, 74]))
  assert_eq(s.world.frame_count, frame)
  let config = s.terrain_lab.config
  assert_false(s.apply_terrain_lab([9.0, 42.0, 4.0, 18.0, 0.5]))
  assert_false(s.apply_terrain_lab([1.0]))
  s.restore_terrain_lab("invalid")
  assert_true(s.terrain_lab.config == config)
  let saved = config.to_json().stringify()
  assert_true(s.apply_terrain_lab([0.0, 42.0, 6.0, 18.0, 0.5]))
  assert_true(s.world.dungeon.terrain_surface is None)
  s.restore_terrain_lab(saved)
  assert_true(s.world.dungeon.terrain_surface is Some(_))
  s.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [27]))
  assert_true(s.paused && !s.terrain_lab.editing)
}

///|
test "terrain pointer picking and contact effects agree with rendered surface" {
  let s = aim_test_state()
  let field = @terrain3d.HeightField::new(
    20,
    20,
    Array::makei(21 * 21, i => (i % 21).to_double() * 0.2),
  )
  s.world.dungeon.terrain_surface = Some(field)
  let position = @math3d.Vec3::new(9.5, field.sample(9.5, 8.5), 8.5)
  s.camera = s.camera.with_target(position)
  let (px, py) = project_world_label_position(
    s.camera.to_camera3d(),
    position,
    screen_w.to_double(),
    screen_h.to_double(),
  ).unwrap()
  let hit = hunter_ground_point(
    s.camera,
    px,
    py,
    0.0,
    dungeon=Some(s.world.dungeon),
  ).unwrap()
  assert_true((hit.0 / tile_size - position.x).abs() < 0.001)
  assert_true((hit.1 / tile_size - position.z).abs() < 0.001)
  let mesh = surface_effect_mesh(
    combat_ring,
    combat_transform(9.5, 0.055, 8.5, 2.0, 1.0, 2.0),
    s.world.dungeon,
  )
  for asset in hunting_assets {
    for part in asset.parts {
      let planted = hunting_grounded_asset(part.mesh, s.world.dungeon, 9.5, 8.5)
      for i = 0; i < planted.vertex_data.length(); i = i + 8 {
        let original = part.mesh.vertex_data
        if original[i + 1].abs() < 0.0001 {
          assert_true(
            (planted.vertex_data[i + 1] +
            position.y -
            field.sample(9.5 + original[i], 8.5 + original[i + 2])).abs() <
            0.00001,
          )
        }
      }
    }
  }
  for i = 0; i < mesh.vertex_data.length(); i = i + 8 {
    let v = mesh.vertex_data
    assert_true(
      (v[i + 1] - field.sample(v[i], v[i + 2]) - 0.055).abs() < 0.00001,
    )
  }
  s.queue_fireball_burst_effect(9.5 * tile_size, 8.5 * tile_size)
  assert_true(
    (s.active_effects[0].placement.origin.y - position.y - 0.35).abs() < 0.00001,
  )
}
