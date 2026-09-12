///|
test "manual hunter attacks empty space once, respects cooldown and cannot attack while dodging" {
  let world = GameWorld::new(seed=42)
  world.mode = Playing
  world.manual_combat = true
  world.enemies.clear()
  assert_true(world.request_basic_attack(0.7))
  assert_eq(world.player.facing_angle, 0.7)
  assert_true(world.attack_timer > 0)
  assert_true(!world.request_basic_attack(0.7))
  let events = world.drain_events()
  assert_eq(events.filter(fn(e) { e is AttackTriggered }).length(), 1)
  world.attack_timer = 0
  start_dash(world, 1.0, 0.0)
  assert_true(!world.request_basic_attack(0.7))
}

///|
test "manual combat does not attack automatically and recovers after cooldown" {
  let world = GameWorld::new(seed=42)
  world.mode = Playing
  world.manual_combat = true
  world.enemies.clear()
  let _ = world.request_basic_attack(0.0)
  let _ = world.drain_events()
  for _ in 0..<120 {
    world.tick(0.0, 0.0)
  }
  assert_eq(
    world.drain_events().filter(fn(e) { e is AttackTriggered }).length(),
    0,
  )
  assert_true(world.request_basic_attack(1.0))
}
