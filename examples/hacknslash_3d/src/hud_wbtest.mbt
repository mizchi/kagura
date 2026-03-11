///|
fn hud_test_engine_context() -> @engine.EngineContext {
  {
    dst: @gfx.new_image_handle(950, screen_w, screen_h),
    shader: @gfx.new_shader_handle(951, "ui"),
    screen_w,
    screen_h,
  }
}

///|
test "render_hud_cmds reuses minimap static cache when player tile is unchanged" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let ctx = hud_test_engine_context()

  let _ = state.render_hud_cmds(ctx.dst, ctx.shader)
  let first_builds = state.minimap_cache_builds
  let cached_len = state.minimap_static_cmds.length()

  let _ = state.render_hud_cmds(ctx.dst, ctx.shader)

  assert_eq(first_builds, 1)
  assert_eq(state.minimap_cache_builds, 1)
  assert_true(cached_len > 0)
  assert_true(cached_len <= 3)
  assert_eq(state.minimap_static_cmds.length(), cached_len)
}

///|
test "render_hud_cmds batches minimap static geometry by tile color" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let ctx = hud_test_engine_context()

  let _ = state.render_hud_cmds(ctx.dst, ctx.shader)

  assert_true(state.minimap_static_cmds.length() <= 3)
}

///|
test "render_hud_cmds rebuilds minimap static cache when player tile changes" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let ctx = hud_test_engine_context()

  let _ = state.render_hud_cmds(ctx.dst, ctx.shader)
  state.world.player.x = state.world.player.x + tile_size
  let _ = state.render_hud_cmds(ctx.dst, ctx.shader)

  assert_eq(state.minimap_cache_builds, 2)
}

///|
test "render_hud_cmds reuses hud static cache when floor is unchanged" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let ctx = hud_test_engine_context()

  let _ = state.render_hud_cmds(ctx.dst, ctx.shader)
  let first_builds = state.hud_static_cache_builds
  let cached_len = state.hud_static_cmds.length()

  let _ = state.render_hud_cmds(ctx.dst, ctx.shader)

  assert_eq(first_builds, 1)
  assert_eq(state.hud_static_cache_builds, 1)
  assert_true(cached_len > 0)
  assert_eq(state.hud_static_cmds.length(), cached_len)
}

///|
test "render_hud_cmds rebuilds hud static cache when floor changes" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let ctx = hud_test_engine_context()

  let _ = state.render_hud_cmds(ctx.dst, ctx.shader)
  state.world.floor = state.world.floor + 1
  let _ = state.render_hud_cmds(ctx.dst, ctx.shader)

  assert_eq(state.hud_static_cache_builds, 2)
}

///|
test "render_minimap batches enemy markers under stress scenario" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  apply_enemy_stress_scenario(state.world, 64)
  let ctx = state.make_hud_ctx(
    hud_test_engine_context().dst,
    hud_test_engine_context().shader,
  )
  let cmds : Array[@gfx.DrawTrianglesCommand] = []

  state.render_minimap(ctx, cmds)

  assert_true(cmds.length() <= 6)
}
