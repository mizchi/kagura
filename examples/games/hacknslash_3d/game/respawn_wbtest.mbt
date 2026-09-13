///|
test "death returns to the last touched waypoint across regions without losing progress" {
  let w = GameWorld::new(seed=42, hunting_grounds=true)
  w.mode = Playing
  assert_true(w.prepare_region(1))
  let (x, y) = world_waypoint_position(1)
  assert_true(w.enter_region(1, x, y))
  assert_true(w.activate_nearby_waypoint())
  assert_eq(w.atlas.unwrap().last_waypoint, 1)
  w.score = 1234
  w.skills.skill_points = 9
  w.chests[0].opened = true
  w.enemies[0].alive = false
  w.enemies[0].hp = 0
  assert_true(w.prepare_region(3))
  assert_true(w.enter_region(3, 50.0 * tile_size, 40.0 * tile_size))
  let progress = w.serialize_world_progress()
  let restored = GameWorld::new(seed=91, hunting_grounds=true)
  assert_true(restored.restore_world_progress(progress))
  assert_eq(restored.atlas.unwrap().last_waypoint, 1)
  w.player.hp = 0
  w.mode = GameOver
  w.arts.ground_cooldown = 100
  assert_true(w.respawn_at_waypoint())
  assert_true(w.mode == Playing)
  assert_eq(w.atlas.unwrap().current, 1)
  assert_eq((w.player.x, w.player.y), (x, y))
  assert_eq(w.player.hp, w.player_stats.max_hp)
  assert_true(w.player.iframe_timer >= 120)
  assert_eq(w.score, 1234)
  assert_eq(w.skills.skill_points, 9)
  assert_true(w.chests[0].opened)
  assert_false(w.enemies[0].alive)
  assert_eq(w.arts.ground_cooldown, 0)
  assert_true(w.weapon_attack is None && w.player_charge is None)
  assert_eq(w.projectiles.length(), 0)
}

///|
test "returning to an already unlocked waypoint updates the checkpoint only once" {
  let w = GameWorld::new(seed=42, hunting_grounds=true)
  w.mode = Playing
  assert_true(w.prepare_region(1))
  let (x, y) = world_waypoint_position(1)
  assert_true(w.enter_region(1, x, y))
  assert_true(w.activate_nearby_waypoint())
  let (x, y) = world_waypoint_position(0)
  assert_true(w.enter_region(0, x, y))
  assert_true(w.activate_nearby_waypoint())
  assert_eq(w.atlas.unwrap().last_waypoint, 0)
  assert_false(w.activate_nearby_waypoint())
  w.mode = GameOver
  assert_true(w.respawn_at_waypoint())
  assert_eq((w.player.x, w.player.y), (x, y))
}
