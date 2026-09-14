///|
test "outdoor TPS retains its boom through props but never passes underground" {
  let s = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  assert_true(s.apply_terrain_lab([0.0, 42.0, 4.0, 18.0, 0.5], persist=false))
  s.world.player.x = 20.5 * tile_size
  s.world.player.y = 50.5 * tile_size
  ignore(s.apply_camera_command([0.0, 1.0]))
  ignore(s.apply_camera_command([3.0, 0.0]))
  ignore(s.apply_camera_command([5.0, 0.0]))
  s.camera = s.camera.orbit(-s.camera.yaw, 0.0)
  for x in 18..<23 {
    s.world.dungeon.grid.set(x, 52, @terrain.Wall)
  }
  s.update_combat_camera()
  assert_true(s.camera.distance > 4.4)
  assert_eq(
    s.camera_clear_segment(
      @math3d.Vec3::new(20.5, 1.0, 50.5),
      @math3d.Vec3::new(20.5, -1.0, 51.5),
    ) <
    1.0,
    true,
  )
}
