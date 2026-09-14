///|
test "distant world has bounded coarse geometry and never spawns neighboring simulation" {
  let world = @game.GameWorld::new(seed=42, hunting_grounds=true)
  let cache = build_scenery_cache(world).unwrap()
  assert_eq(cache.regions.length(), 4)
  assert_eq(world.atlas.unwrap().regions.filter(r => r is Some(_)).length(), 1)
  for r in cache.regions {
    assert_true(r.mesh.indices.length() / 3 < 2400)
    assert_eq(r.ranges.length(), 20)
    assert_eq(r.ranges.fold(init=0, (n, r) => n + r.1), r.mesh.indices.length())
  }
  assert_true(cache.backdrop.indices.length() / 3 < 6500)
}

///|
test "LOD partitions each chunk exactly once and coalesces distant index ranges" {
  let ranges = [(0, 30), (30, 60), (90, 30), (120, 60), (180, 30)]
  assert_eq(scenery_index_runs(ranges, [true, true, false, true, true]), [
    (0, 90),
    (120, 90),
  ])
  assert_eq(scenery_index_runs(ranges, [false, false, false, false, false]), [])
  assert_eq(scenery_index_runs(ranges, [true, true, true, true, true]), [
    (0, 210),
  ])
}

///|
test "cave ceiling hides only when a quarter-view player enters the gallery" {
  let state = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  assert_false(state.cave_roof_hidden())
  state.world.player.x = 61.5 * tile_size
  state.world.player.y = 18.5 * tile_size
  assert_true(state.cave_roof_hidden())
  state.camera_settings.mode = 1
  assert_false(state.cave_roof_hidden())
}

///|
test "outdoor sky remains available without generated landscape" {
  let state = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  assert_true(state.apply_terrain_lab([0.0, 42.0, 4.0, 18.0, 0.5]))
  assert_true(state.world.dungeon.landscape is None)
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  state.push_sky_commands(
    state.camera.to_camera3d(),
    @gfx.new_image_handle(1, screen_w, screen_h),
    cmds,
  )
  assert_eq(cmds.length(), 1)
  assert_eq(cmds[0].indices.length(), 36)
  state.motion_preview = true
  cmds.clear()
  state.push_sky_commands(
    state.camera.to_camera3d(),
    @gfx.new_image_handle(1, screen_w, screen_h),
    cmds,
  )
  assert_eq(cmds.length(), 0)
}
