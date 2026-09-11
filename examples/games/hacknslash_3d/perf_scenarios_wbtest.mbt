///|
test "apply_enemy_stress_scenario replaces enemies with requested visible count" {
  let world = @game.GameWorld::new(seed=42)
  apply_enemy_stress_scenario(world, 9)
  assert_eq(world.enemies.length(), 9)
  let first = world.enemies[0]
  let last = world.enemies[8]
  assert_true(first.alive)
  assert_true(last.alive)
  assert_true(first.kind == @game.Basic)
  assert_true(world.enemies[1].kind == @game.Fast)
  assert_true(world.enemies[2].kind == @game.Tank)
  assert_true(world.enemies[3].kind == @game.Ranged)
  assert_true(world.enemies[4].kind == @game.Boss)
}

///|
test "enemy_stress_grid_side rounds up to cover requested count" {
  assert_eq(enemy_stress_grid_side(1), 1)
  assert_eq(enemy_stress_grid_side(2), 2)
  assert_eq(enemy_stress_grid_side(4), 2)
  assert_eq(enemy_stress_grid_side(5), 3)
  assert_eq(enemy_stress_grid_side(16), 4)
}
