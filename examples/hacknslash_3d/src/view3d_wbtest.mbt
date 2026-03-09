///|
fn test_engine_context() -> @engine.EngineContext {
  {
    dst: @gfx.new_image_handle(900, screen_w, screen_h),
    shader: @gfx.new_shader_handle(901, "ui"),
    screen_w,
    screen_h,
  }
}

///|
fn find_first_command_index(
  commands : Array[@gfx.DrawTrianglesCommand],
  pred : (@gfx.DrawTrianglesCommand) -> Bool,
) -> Int? {
  for i, cmd in commands {
    if pred(cmd) {
      return Some(i)
    }
  }
  None
}

///|
fn find_last_command_index(
  commands : Array[@gfx.DrawTrianglesCommand],
  pred : (@gfx.DrawTrianglesCommand) -> Bool,
) -> Int? {
  let mut out : Int? = None
  for i, cmd in commands {
    if pred(cmd) {
      out = Some(i)
    }
  }
  out
}

///|
test "draw_playing wires camera depth into SSAO postfx chain" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let ctx = test_engine_context()
  let commands = state.draw_playing(ctx)

  let depth_idx = match
    find_last_command_index(commands, fn(cmd) {
      cmd.dst.id == state.camera_depth_target.id &&
      cmd.shader.id == state.camera_depth_shader.id
    }) {
    Some(i) => i
    None => panic()
  }
  let ssao_idx = match
    find_first_command_index(commands, fn(cmd) {
      cmd.dst.id == state.ssao_target.id &&
      cmd.shader.id == state.ssao_sh.id
    }) {
    Some(i) => i
    None => panic()
  }
  let tonemap_idx = match
    find_first_command_index(commands, fn(cmd) {
      cmd.dst.id == state.bloom_b.id &&
      cmd.shader.id == state.tonemap_sh.id
    }) {
    Some(i) => i
    None => panic()
  }
  let fxaa_idx = match
    find_first_command_index(commands, fn(cmd) {
      cmd.dst.id == ctx.dst.id &&
      cmd.shader.id == state.fxaa_sh.id
    }) {
    Some(i) => i
    None => panic()
  }

  assert_true(depth_idx < ssao_idx)
  assert_true(ssao_idx < tonemap_idx)
  assert_true(tonemap_idx < fxaa_idx)

  let ssao_cmd = commands[ssao_idx]
  assert_eq(ssao_cmd.src_image_ids.length(), 2)
  assert_eq(ssao_cmd.src_image_ids[0], state.scene_target.id)
  assert_eq(ssao_cmd.src_image_ids[1], state.camera_depth_target.id)
  assert_true(ssao_cmd.src_image_ids[1] != state.shadow_map.id)
}

///|
test "draw_playing feeds ssao output into bloom composite" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let commands = state.draw_playing(test_engine_context())

  let ssao_idx = match
    find_first_command_index(commands, fn(cmd) {
      cmd.dst.id == state.ssao_target.id &&
      cmd.shader.id == state.ssao_sh.id
    }) {
    Some(i) => i
    None => panic()
  }
  let threshold_idx = match
    find_first_command_index(commands, fn(cmd) {
      cmd.dst.id == state.bloom_a.id &&
      cmd.shader.id == state.bloom_threshold_sh.id
    }) {
    Some(i) => i
    None => panic()
  }
  let composite_idx = match
    find_first_command_index(commands, fn(cmd) {
      cmd.dst.id == state.post_target.id &&
      cmd.shader.id == state.bloom_composite_sh.id
    }) {
    Some(i) => i
    None => panic()
  }

  assert_true(ssao_idx < threshold_idx)
  assert_true(threshold_idx < composite_idx)

  let threshold_cmd = commands[threshold_idx]
  assert_eq(threshold_cmd.src_image_ids.length(), 1)
  assert_eq(threshold_cmd.src_image_ids[0], state.ssao_target.id)

  let composite_cmd = commands[composite_idx]
  assert_eq(composite_cmd.src_image_ids.length(), 2)
  assert_eq(composite_cmd.src_image_ids[0], state.ssao_target.id)
  assert_eq(composite_cmd.src_image_ids[1], state.bloom_a.id)
}
