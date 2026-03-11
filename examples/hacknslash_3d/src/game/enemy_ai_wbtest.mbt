///|
test "tick_enemy_ai_phase uses direct chase for same-room basic enemy" {
  let world = GameWorld::new(seed=42)
  world.enemies = [
    make_enemy(world.player.x + 32.0, world.player.y, Basic, 3, 1.0, 10.0),
  ]
  world.tick_enemy_ai_phase()
  assert_eq(world.enemies[0].path_cache.length(), 0)
  assert_true(world.enemies[0].vx < 0.0)
  assert_true(world.enemies[0].vy.abs() < 1.0e-9)
}
