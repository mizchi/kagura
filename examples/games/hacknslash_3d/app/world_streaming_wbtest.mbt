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
  assert_false(state.update_region_streaming())
  assert_eq(state.region_chunks_built, 0)
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
  assert_eq(state.region_chunks_built, 0)
  assert_true(state.world.atlas.unwrap().regions[1] is Some(_))
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

///|
test "prepared neighbor batches retain visible geometry with bounded draws and no stationary rebuilds" {
  let state = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  state.world.mode = @game.Playing
  state.world.player.x = 80.0 * tile_size
  state.world.player.y = 40.0 * tile_size
  ignore(state.update_region_streaming())
  assert_eq(state.region_chunks_built, 0)
  for _ in 0..<20 {
    ignore(state.update_region_streaming())
  }
  let cache = state.region_meshes[1].unwrap()
  for _ in 0..<10 {
    assert_true(cache.prepare_next_batch())
  }
  assert_false(cache.prepare_next_batch())
  let visible = cache.visible_groups(-18.0, 40.0)
  assert_true(visible.length() <= hunting_palette.length() * 2)
  let mut expected = 0
  for chunk in cache.chunks {
    if neighbor_chunk_visible(chunk, -18.0, 40.0) {
      for group in chunk.groups {
        expected += group.mesh.indices.length()
      }
    }
  }
  assert_eq(
    visible.fold(init=0, (n, g) => n + g.mesh.indices.length()),
    expected,
  )
  assert_eq(cache.visible_builds, 10)
  ignore(cache.visible_groups(-17.9, 40.0))
  assert_eq(cache.visible_builds, 10)
  ignore(cache.visible_groups(70.0, 40.0))
  assert_eq(cache.visible_builds, 10)
}
