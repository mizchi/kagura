///|
fn aim_test_state() -> GameState {
  let s = GameState::new(seed=42)
  s.world.mode = @game.Playing
  s.world.player.x = 120.0
  s.world.player.y = 120.0
  s.world.enemies.clear()
  for y in 2..<14 {
    for x in 2..<14 {
      s.world.dungeon.grid.set(x, y, @terrain.Floor)
    }
  }
  s
}

///|
test "pointer focus stays bounded and stable regardless of facing and camera follow" {
  let s = aim_test_state()
  for viewport in [(1280.0, 900.0), (390.0, 844.0)] {
    s.camera = hunter_responsive_camera(s.camera, viewport.0, viewport.1)
    s.aim.pointer = Some((0.12, 0.4))
    let yaw = s.camera.yaw
    for _ in 0..<100 {
      s.update_combat_camera()
    }
    let (x, y) = (s.combat_feedback.look_x, s.combat_feedback.look_y)
    // Camera screen-right is world (cos(yaw), -sin(yaw)).
    assert_true(x * @math.cos(yaw) - y * @math.sin(yaw) < -0.2)
    assert_true((x * x + y * y).sqrt() <= 2.001)
    s.world.player.facing_angle += @math.PI
    s.world.player.x += 8.0
    s.world.player.y += 8.0
    for _ in 0..<100 {
      s.update_combat_camera()
    }
    assert_true((s.combat_feedback.look_x - x).abs() < 0.001)
    assert_true((s.combat_feedback.look_y - y).abs() < 0.001)
    assert_eq(s.camera.yaw, yaw)
    s.aim.pointer = Some((0.88, 0.4))
    for _ in 0..<100 {
      s.update_combat_camera()
    }
    assert_true(
      s.combat_feedback.look_x * @math.cos(yaw) -
      s.combat_feedback.look_y * @math.sin(yaw) >
      0.2,
    )
  }
}

///|
test "automatic camera focus follows its target instead of facing, and recenters without enemies" {
  let s = aim_test_state()
  s.world.player_weapon = @game.Bow
  s.world.player.facing_angle = 0.0
  s.world.enemies = [
    @game.make_enemy(
      s.world.player.x - 64.0,
      s.world.player.y,
      @game.Basic,
      100,
      0.0,
      8.0,
    ),
  ]
  for _ in 0..<90 {
    s.update_combat_camera()
  }
  assert_true(s.camera.target.x < s.world.player.x / tile_size - 0.5)
  s.world.enemies.clear()
  for _ in 0..<90 {
    s.update_combat_camera()
  }
  assert_true((s.camera.target.x - s.world.player.x / tile_size).abs() < 0.001)
  assert_true((s.camera.target.z - s.world.player.y / tile_size).abs() < 0.001)
}
