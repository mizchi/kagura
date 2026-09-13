///|
test "boundary preload spreads mesh work across frames and reuses a completed area" {
  let state = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  state.world.mode = @game.Playing
  assert_false(state.update_region_streaming())
  assert_eq(state.region_chunks_built, 0)
  state.world.player.x = 80.0 * tile_size
  state.world.player.y = 40.0 * tile_size
  for _ in 0..<20 {
    let before = state.region_chunks_built
    assert_false(state.update_region_streaming())
    assert_eq(state.region_chunks_built, before + 1)
    assert_eq(state.world.atlas.unwrap().current, 0)
  }
  assert_true(state.region_mesh_ready(1))
  let ready = state.region_chunks_built
  for _ in 0..<5 {
    assert_false(state.update_region_streaming())
  }
  assert_eq(state.region_chunks_built, ready)
  state.world.player.x = 99.1 * tile_size
  assert_true(state.try_cross_region_boundary())
  assert_eq(state.world.atlas.unwrap().current, 1)
  assert_eq(state.region_chunks_built, ready)
  assert_eq(state.dungeon_chunks.length(), 20)
  state.world.player.x = 0.9 * tile_size
  assert_true(state.try_cross_region_boundary())
  assert_eq(state.world.atlas.unwrap().current, 0)
}

///|
test "stopped menus pause background preparation and waypoint cancellation never changes the active area" {
  let state = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  state.world.mode = @game.Playing
  state.world.player.x = 80.0 * tile_size
  state.world.ui_mode = @game.Inventory
  assert_false(state.update_region_streaming())
  assert_eq(state.region_chunks_built, 0)
  state.world.ui_mode = @game.Waypoints
  let atlas = state.world.atlas.unwrap()
  atlas.unlocked[1] = true
  let (x, y) = @game.world_waypoint_position(0)
  state.world.player.x = x
  state.world.player.y = y
  assert_true(state.world.request_waypoint(1))
  assert_false(state.update_region_streaming())
  assert_eq(state.region_chunks_built, 1)
  state.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [27]))
  assert_true(atlas.travel_target is None)
  assert_eq(atlas.current, 0)
  assert_false(state.region_mesh_ready(1))
}

///|
test "cached area meshes stay bounded while revisiting the connected world" {
  let state = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  state.world.mode = @game.Playing
  for id in [1, 3, 2, 0] {
    let atlas = state.world.atlas.unwrap()
    atlas.unlocked[id] = true
    state.world.ui_mode = @game.Waypoints
    let (x, y) = @game.world_waypoint_position(atlas.current)
    state.world.player.x = x
    state.world.player.y = y
    assert_true(state.world.request_waypoint(id))
    for _ in 0..<21 {
      ignore(state.update_region_streaming())
    }
    assert_eq(atlas.current, id)
    assert_true(
      state.region_meshes.filter(entry => entry is Some(_)).length() <= 3,
    )
  }
}
