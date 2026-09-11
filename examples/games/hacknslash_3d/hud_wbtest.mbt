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
  assert_true(cached_len <= 4)
  assert_eq(state.minimap_static_cmds.length(), cached_len)
}

///|
test "render_hud_cmds batches minimap static geometry by tile color" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let ctx = hud_test_engine_context()

  let _ = state.render_hud_cmds(ctx.dst, ctx.shader)

  assert_true(state.minimap_static_cmds.length() <= 4)
}

///|
test "render_hud_cmds adds minimap fog for undiscovered rooms" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let ctx = hud_test_engine_context()
  let base_room = @game.find_room_at(
    state.world.dungeon.rooms,
    state.world.player.x,
    state.world.player.y,
  )
  for i in 0..<state.world.discovered_rooms.length() {
    state.world.discovered_rooms[i] = i == base_room
  }

  let _ = state.render_hud_cmds(ctx.dst, ctx.shader)

  assert_true(state.minimap_static_cmds.length() >= 4)
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
test "render_hud_cmds rebuilds minimap static cache when discovery changes" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let ctx = hud_test_engine_context()

  let _ = state.render_hud_cmds(ctx.dst, ctx.shader)
  let first_builds = state.minimap_cache_builds
  let player_room = @game.find_room_at(
    state.world.dungeon.rooms,
    state.world.player.x,
    state.world.player.y,
  )
  for i in 0..<state.world.discovered_rooms.length() {
    if i != player_room {
      state.world.discovered_rooms[i] = true
      state.world.discovered_rooms_version = state.world.discovered_rooms_version +
        1
      break
    }
  }

  let _ = state.render_hud_cmds(ctx.dst, ctx.shader)

  assert_eq(first_builds, 1)
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

  assert_true(cmds.length() <= 7)
}

///|
test "render_hud_cmds adds spell cooldown widgets when spell timers are active" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let ctx = hud_test_engine_context()

  let base_cmds = state.render_hud_cmds(ctx.dst, ctx.shader)
  state.world.chain_lightning_cooldown_timer = 20
  state.world.splitting_fireball_cooldown_timer = 18
  state.world.ice_nova_cooldown_timer = 12
  let cooldown_cmds = state.render_hud_cmds(ctx.dst, ctx.shader)

  assert_true(cooldown_cmds.length() > base_cmds.length())
}

///|
test "render_hud_cmds adds dropped item labels for visible equipment" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let ctx = hud_test_engine_context()

  let base_cmds = state.render_hud_cmds(ctx.dst, ctx.shader)
  state.world.items = [
    {
      x: state.world.player.x + 8.0,
      y: state.world.player.y,
      vx: 0.0,
      vy: 0.0,
      kind: @game.Equipment({
        name: "Iron Charm",
        rarity: @game.Epic,
        slot: @game.Accessory,
        atk_bonus: 0,
        def_bonus: 0,
        hp_bonus: 4,
        str_bonus: 0,
        int_bonus: 0,
        dex_bonus: 0,
        str_scaling: 0.0,
        int_scaling: 0.0,
        dex_scaling: 0.0,
        prefix: None,
        suffix: None,
        icon_id: 0,
      }),
      alive: true,
      spawn_frame: state.world.frame_count,
    },
  ]
  let labeled_cmds = state.render_hud_cmds(ctx.dst, ctx.shader)

  assert_true(labeled_cmds.length() > base_cmds.length())
}

///|
test "hp_bar_ratio_clamped clamps overflow and underflow" {
  assert_eq(hp_bar_ratio_clamped(15, 10), 1.0)
  assert_eq(hp_bar_ratio_clamped(-2, 10), 0.0)
  assert_eq(hp_bar_ratio_clamped(5, 10), 0.5)
}

///|
test "hp_status_text shows current and max hp" {
  assert_eq(hp_status_text(7, 10), "7/10")
  assert_eq(hp_status_text(14, 10), "10/10")
  assert_eq(hp_status_text(-3, 10), "0/10")
}

///|
test "render_hud_cmds adds damage popups for active damage popup state" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let ctx = hud_test_engine_context()

  let base_cmds = state.render_hud_cmds(ctx.dst, ctx.shader)
  state.damage_popups = [
    {
      x: state.world.player.x,
      y: state.world.player.y,
      amount: 12,
      color_hex: 0xFF4444,
      ttl: 24,
      rise: 0.0,
    },
  ]
  let popup_cmds = state.render_hud_cmds(ctx.dst, ctx.shader)

  assert_true(popup_cmds.length() > base_cmds.length())
}
