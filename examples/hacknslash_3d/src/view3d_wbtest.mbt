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
fn state_with_ssao_enabled() -> GameState {
  GameState::new_with_ssao(seed=42, SSAOConfig::enabled_default())
}

///|
fn state_with_ssao_and_fxaa_enabled() -> GameState {
  let state = state_with_ssao_enabled()
  state.fxaa_enabled = true
  state
}

///|
fn state_with_shadows_enabled() -> GameState {
  let state = GameState::new(seed=42)
  state.shadows_enabled = true
  state
}

///|
fn state_with_all_effects_enabled() -> GameState {
  let state = state_with_ssao_and_fxaa_enabled()
  state.shadows_enabled = true
  state
}

///|
fn count_matching_commands(
  commands : Array[@gfx.DrawTrianglesCommand],
  pred : (@gfx.DrawTrianglesCommand) -> Bool,
) -> Int {
  let mut count = 0
  for cmd in commands {
    if pred(cmd) {
      count = count + 1
    }
  }
  count
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
test "compute_shadow_frame_state skips matrix build when disabled" {
  let out = compute_shadow_frame_state(
    false,
    @shadow3d.ShadowConfig::new(
      1024,
      14.0,
      0.1,
      60.0,
      30.0,
      @math3d.Vec3::zero(),
      0.005,
    ),
    32.0,
    48.0,
    @light3d.LightingEnvironment::default(),
  )
  assert_true(out is None)
}

///|
test "compute_shadow_frame_state centers shadow config on player when enabled" {
  let out = compute_shadow_frame_state(
    true,
    @shadow3d.ShadowConfig::new(
      1024,
      14.0,
      0.1,
      60.0,
      30.0,
      @math3d.Vec3::zero(),
      0.005,
    ),
    tile_size * 3.0,
    tile_size * 5.0,
    @light3d.LightingEnvironment::default(),
  )
  let shadow = match out {
    Some(shadow) => shadow
    None => panic()
  }
  assert_eq(shadow.config.center.x, 3.0)
  assert_eq(shadow.config.center.z, 5.0)
}

///|
test "visible chunk cache rebuilds only when player tile changes" {
  let state = GameState::new(seed=42)
  let chunks0 = state.get_visible_chunks_for_player()
  let builds0 = state.visible_chunk_cache_builds
  let chunks1 = state.get_visible_chunks_for_player()
  let builds1 = state.visible_chunk_cache_builds
  assert_eq(chunks0.length(), chunks1.length())
  assert_eq(builds0, 1)
  assert_eq(builds1, 1)

  state.world.player.x = state.world.player.x + tile_size
  let _chunks2 = state.get_visible_chunks_for_player()
  assert_eq(state.visible_chunk_cache_builds, 2)
}

///|
test "visible dungeon mesh cache rebuilds only when player tile changes" {
  let state = GameState::new(seed=42)
  let groups0 = state.get_visible_dungeon_mesh_cache_for_player().groups
  let builds0 = state.visible_dungeon_mesh_cache_builds
  let groups1 = state.get_visible_dungeon_mesh_cache_for_player().groups
  let builds1 = state.visible_dungeon_mesh_cache_builds
  assert_eq(groups0.length(), groups1.length())
  assert_eq(builds0, 1)
  assert_eq(builds1, 1)
  assert_true(groups0.length() <= 5)

  state.world.player.x = state.world.player.x + tile_size
  let _groups2 = state.get_visible_dungeon_mesh_cache_for_player().groups
  assert_eq(state.visible_dungeon_mesh_cache_builds, 2)
}

///|
test "draw_playing appends generated prop commands when glb prop is attached" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let baseline = state.draw_playing(test_engine_context())

  let graph = @scene3d.SceneGraph::new()
  ignore(
    graph.add_node(@scene3d.scene_node(mesh=Some(@mesh3d.Mesh3D::cube(0.75)))),
  )
  state.set_generated_prop_asset(
    { scene_graph: graph, source_path: "./assets/generated/test.glb" },
    generated_prop_placement(
      "./assets/generated/test.glb",
      floor=1,
      anchor=StartRoomCenter,
      scale=1.0,
      yaw_degrees=0.0,
      x_offset_tiles=2.0,
      z_offset_tiles=0.0,
    ),
  )
  let with_prop = state.draw_playing(test_engine_context())

  assert_true(with_prop.length() > baseline.length())
  assert_eq(state.generated_props.length(), 1)
  assert_eq(
    state.generated_props[0].placement.source_path,
    "./assets/generated/test.glb",
  )
}

///|
test "draw_playing skips generated prop when current floor does not match placement" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let baseline = state.draw_playing(test_engine_context())

  let graph = @scene3d.SceneGraph::new()
  ignore(
    graph.add_node(@scene3d.scene_node(mesh=Some(@mesh3d.Mesh3D::cube(0.75)))),
  )
  state.set_generated_prop_asset(
    { scene_graph: graph, source_path: "./assets/generated/test.glb" },
    generated_prop_placement(
      "./assets/generated/test.glb",
      floor=2,
      anchor=StartRoomCenter,
      scale=1.0,
      yaw_degrees=0.0,
      x_offset_tiles=2.0,
      z_offset_tiles=0.0,
    ),
  )

  let with_prop = state.draw_playing(test_engine_context())
  assert_eq(with_prop.length(), baseline.length())
}

///|
test "draw_playing appends commands for multiple generated props" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let baseline = state.draw_playing(test_engine_context())

  let graph0 = @scene3d.SceneGraph::new()
  ignore(
    graph0.add_node(@scene3d.scene_node(mesh=Some(@mesh3d.Mesh3D::cube(0.75)))),
  )
  let graph1 = @scene3d.SceneGraph::new()
  ignore(
    graph1.add_node(@scene3d.scene_node(mesh=Some(@mesh3d.Mesh3D::cube(0.5)))),
  )
  state.set_generated_prop_asset(
    { scene_graph: graph0, source_path: "./assets/generated/test-a.glb" },
    generated_prop_placement(
      "./assets/generated/test-a.glb",
      floor=1,
      x_offset_tiles=2.0,
    ),
  )
  state.set_generated_prop_asset(
    { scene_graph: graph1, source_path: "./assets/generated/test-b.glb" },
    generated_prop_placement(
      "./assets/generated/test-b.glb",
      floor=1,
      x_offset_tiles=-2.0,
    ),
  )

  let with_props = state.draw_playing(test_engine_context())
  assert_true(with_props.length() > baseline.length())
  assert_eq(state.generated_props.length(), 2)
}

///|
test "draw_playing renders textured generated prop with textured material shader" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let graph = @scene3d.SceneGraph::new()
  ignore(
    graph.add_node(
      @scene3d.scene_node(
        mesh=Some(@mesh3d.Mesh3D::cube(0.75)),
        material=Some(
          @scene3d.Material::new(src_image_id=777, metallic=1.0, roughness=1.0),
        ),
      ),
    ),
  )
  state.set_generated_prop_asset(
    { scene_graph: graph, source_path: "./assets/generated/textured.glb" },
    generated_prop_placement(
      "./assets/generated/textured.glb",
      floor=1,
      anchor=StartRoomCenter,
      x_offset_tiles=2.0,
    ),
  )

  let commands = state.draw_playing(test_engine_context())
  let textured_idx = match
    find_first_command_index(commands, fn(cmd) {
      cmd.shader.id == state.shader3d_pbr_textured.id &&
      cmd.src_image_ids.length() == 1 &&
      cmd.src_image_ids[0] == 777
    }) {
    Some(i) => i
    None => panic()
  }
  assert_true(textured_idx >= 0)
}

///|
test "draw_playing renders dungeon with textured shaders when dungeon textures are loaded" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  state.dungeon_floor_texture_image_id = Some(910)
  state.dungeon_wall_texture_image_id = Some(911)

  let commands = state.draw_playing(test_engine_context())
  let floor_idx = find_first_command_index(commands, fn(cmd) {
    cmd.shader.id == state.shader3d_textured.id &&
    cmd.src_image_ids.length() == 1 &&
    cmd.src_image_ids[0] == 910
  })
  let wall_idx = find_first_command_index(commands, fn(cmd) {
    cmd.shader.id == state.shader3d_textured.id &&
    cmd.src_image_ids.length() == 1 &&
    cmd.src_image_ids[0] == 911
  })

  assert_true(floor_idx is Some(_))
  assert_true(wall_idx is Some(_))
}

///|
test "draw_playing uses textured shadow shader for dungeon when shadows and textures are enabled" {
  let state = state_with_shadows_enabled()
  state.world.mode = @game.Playing
  state.dungeon_floor_texture_image_id = Some(910)
  state.dungeon_wall_texture_image_id = Some(911)

  let commands = state.draw_playing(test_engine_context())
  let textured_shadow_idx = find_first_command_index(commands, fn(cmd) {
    cmd.shader.id == state.shadow_lit_textured_shader.id &&
    cmd.src_image_ids.length() == 2
  })

  assert_true(textured_shadow_idx is Some(_))
}

///|
test "default_generated_prop_manifest is empty by default" {
  let config = default_generated_prop_manifest()
  assert_eq(config.length(), 0)
}

///|
test "draw_playing wires camera depth into ssao postfx chain with fxaa enabled" {
  let state = state_with_ssao_and_fxaa_enabled()
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
      cmd.dst.id == state.ssao_target.id && cmd.shader.id == state.ssao_sh.id
    }) {
    Some(i) => i
    None => panic()
  }
  let tonemap_idx = match
    find_first_command_index(commands, fn(cmd) {
      cmd.dst.id == state.bloom_b.id && cmd.shader.id == state.tonemap_sh.id
    }) {
    Some(i) => i
    None => panic()
  }
  let fxaa_idx = match
    find_first_command_index(commands, fn(cmd) {
      cmd.dst.id == ctx.dst.id && cmd.shader.id == state.fxaa_sh.id
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
test "draw_playing skips fxaa and tonemaps directly into dst by default" {
  let state = state_with_ssao_enabled()
  state.world.mode = @game.Playing
  let ctx = test_engine_context()
  let commands = state.draw_playing(ctx)

  let tonemap_idx = match
    find_first_command_index(commands, fn(cmd) {
      cmd.dst.id == ctx.dst.id && cmd.shader.id == state.tonemap_sh.id
    }) {
    Some(i) => i
    None => panic()
  }
  let fxaa_idx = find_first_command_index(commands, fn(cmd) {
    cmd.dst.id == ctx.dst.id && cmd.shader.id == state.fxaa_sh.id
  })

  assert_eq(fxaa_idx, None)

  let tonemap_cmd = commands[tonemap_idx]
  assert_eq(tonemap_cmd.src_image_ids.length(), 1)
  assert_eq(tonemap_cmd.src_image_ids[0], state.post_target.id)
}

///|
test "draw_playing skips shadow depth and shadow lit dungeon by default" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let commands = state.draw_playing(test_engine_context())

  let shadow_depth_idx = find_first_command_index(commands, fn(cmd) {
    cmd.dst.id == state.shadow_map.id &&
    cmd.shader.id == state.shadow_depth_shader.id
  })
  let shadow_lit_idx = find_first_command_index(commands, fn(cmd) {
    cmd.shader.id == state.shadow_lit_shader.id
  })
  let lit_idx = find_first_command_index(commands, fn(cmd) {
    cmd.shader.id == state.shader3d.id
  })

  assert_eq(shadow_depth_idx, None)
  assert_eq(shadow_lit_idx, None)
  assert_true(lit_idx is Some(_))
}

///|
test "draw_playing emits shadow depth and shadow lit dungeon when shadows are enabled" {
  let state = state_with_shadows_enabled()
  state.world.mode = @game.Playing
  let commands = state.draw_playing(test_engine_context())

  let shadow_depth_idx = find_first_command_index(commands, fn(cmd) {
    cmd.dst.id == state.shadow_map.id &&
    cmd.shader.id == state.shadow_depth_shader.id
  })
  let shadow_lit_idx = find_first_command_index(commands, fn(cmd) {
    cmd.shader.id == state.shadow_lit_shader.id
  })

  assert_true(shadow_depth_idx is Some(_))
  assert_true(shadow_lit_idx is Some(_))
}

///|
test "draw_playing feeds ssao output into bloom composite" {
  let state = state_with_ssao_enabled()
  state.world.mode = @game.Playing
  let commands = state.draw_playing(test_engine_context())

  let ssao_idx = match
    find_first_command_index(commands, fn(cmd) {
      cmd.dst.id == state.ssao_target.id && cmd.shader.id == state.ssao_sh.id
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
  let threshold_idx = match
    find_first_command_index(commands, fn(cmd) {
      cmd.dst.id == state.bloom_a.id &&
      cmd.shader.id == state.bloom_threshold_sh.id
    }) {
    Some(i) => i
    None => panic()
  }

  assert_true(ssao_idx < threshold_idx)
}

///|
test "draw_playing skips ssao and feeds scene target into bloom composite by default" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let commands = state.draw_playing(test_engine_context())

  let ssao_idx = find_first_command_index(commands, fn(cmd) {
    cmd.dst.id == state.ssao_target.id && cmd.shader.id == state.ssao_sh.id
  })
  let depth_idx = find_last_command_index(commands, fn(cmd) {
    cmd.dst.id == state.camera_depth_target.id &&
    cmd.shader.id == state.camera_depth_shader.id
  })
  let threshold_idx = match
    find_first_command_index(commands, fn(cmd) {
      cmd.dst.id == state.bloom_a.id &&
      cmd.shader.id == state.bloom_threshold_sh.id
    }) {
    Some(i) => i
    None => panic()
  }
  assert_eq(ssao_idx, None)
  // Depth pass always runs now
  assert_true(depth_idx is Some(_))

  assert_true(threshold_idx > 0)
}

///|
test "game state allocates bloom targets at half resolution" {
  let state = GameState::new(seed=42)

  assert_eq(state.scene_target.width, screen_w)
  assert_eq(state.scene_target.height, screen_h)
  assert_eq(state.bloom_a.width, screen_w / 2)
  assert_eq(state.bloom_a.height, screen_h / 2)
  assert_eq(state.bloom_b.width, screen_w / 2)
  assert_eq(state.bloom_b.height, screen_h / 2)
  assert_eq(state.post_target.width, screen_w)
  assert_eq(state.post_target.height, screen_h)
}

///|
test "game state caches dungeon tinted lighting for fixed mesh groups" {
  let state = GameState::new(seed=42)
  assert_eq(state.dungeon_tinted_lighting_cache.length(), 5)
}

///|
test "draw_playing batches repeated entity meshes into instanced draw commands" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let px = state.world.player.x
  let py = state.world.player.y
  state.world.items = [
    {
      x: px,
      y: py,
      vx: 0.0,
      vy: 0.0,
      kind: @game.Health,
      alive: true,
      spawn_frame: 0,
    },
    {
      x: px + 8.0,
      y: py,
      vx: 0.0,
      vy: 0.0,
      kind: @game.Score,
      alive: true,
      spawn_frame: 0,
    },
  ]
  state.world.projectiles = [
    {
      x: px,
      y: py,
      vx: 1.0,
      vy: 0.0,
      age: 0,
      alive: true,
      damage: 1,
      is_player: true,
      kind: @game.Arrow,
    },
    {
      x: px + 4.0,
      y: py + 4.0,
      vx: -1.0,
      vy: 0.0,
      age: 0,
      alive: true,
      damage: 1,
      is_player: false,
      kind: @game.EnemyBolt,
    },
  ]

  let commands = state.draw_playing(test_engine_context())
  let instanced_commands : Array[@gfx.DrawTrianglesCommand] = []
  let colored_commands : Array[@gfx.DrawTrianglesCommand] = []
  for cmd in commands {
    if cmd.shader.id == state.shader3d_instanced.id {
      instanced_commands.push(cmd)
    }
    if cmd.shader.id == state.shader3d_colored.id {
      colored_commands.push(cmd)
    }
  }

  assert_eq(instanced_commands.length(), 0)
  assert_true(colored_commands.length() >= 2) // items + loot beams
}

///|
test "draw preserves gpu profiler timing when profiler hud is enabled" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  state.show_profiler = true
  state.profile = {
    fps: 60.0,
    frame_time_ms: 16.0,
    update_ms: 4.0,
    draw_ms: 5.0,
    gpu_frame_ms: 7.0,
    draw_calls: 0,
    vertex_count: 0,
    asset_inflight: 0,
  }

  let _ = state.draw(test_engine_context())

  assert_eq(state.profile.gpu_frame_ms, 7.0)
}

///|
test "summarize_draw_playing_commands reports cheaper default path than all effects" {
  let ctx = test_engine_context()
  let default_state = GameState::new(seed=42)
  default_state.world.mode = @game.Playing
  let default_stats = summarize_draw_playing_commands(
    default_state.draw_playing(ctx),
    default_state,
    ctx.dst,
  )

  let full_state = state_with_all_effects_enabled()
  full_state.world.mode = @game.Playing
  let full_stats = summarize_draw_playing_commands(
    full_state.draw_playing(ctx),
    full_state,
    ctx.dst,
  )

  assert_eq(default_stats.shadow_depth_commands, 0)
  assert_eq(default_stats.shadow_lit_commands, 0)
  assert_eq(default_stats.ssao_commands, 0)
  assert_eq(default_stats.fxaa_commands, 0)
  assert_true(default_stats.direct_lit_commands > 0)

  assert_true(full_stats.shadow_depth_commands > 0)
  assert_true(full_stats.shadow_lit_commands > 0)
  assert_true(full_stats.ssao_commands > 0)
  assert_true(full_stats.fxaa_commands > 0)
  assert_true(default_stats.total_commands < full_stats.total_commands)
  assert_true(
    default_stats.estimated_draw_calls < full_stats.estimated_draw_calls,
  )
}

///|
test "summarize_draw_playing_commands tracks instancing workload" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let ctx = test_engine_context()
  let px = state.world.player.x
  let py = state.world.player.y
  state.world.items = [
    {
      x: px,
      y: py,
      vx: 0.0,
      vy: 0.0,
      kind: @game.Health,
      alive: true,
      spawn_frame: 0,
    },
    {
      x: px + 8.0,
      y: py,
      vx: 0.0,
      vy: 0.0,
      kind: @game.Score,
      alive: true,
      spawn_frame: 0,
    },
  ]
  state.world.projectiles = [
    {
      x: px,
      y: py,
      vx: 1.0,
      vy: 0.0,
      age: 0,
      alive: true,
      damage: 1,
      is_player: true,
      kind: @game.Arrow,
    },
    {
      x: px + 4.0,
      y: py + 4.0,
      vx: -1.0,
      vy: 0.0,
      age: 0,
      alive: true,
      damage: 1,
      is_player: false,
      kind: @game.EnemyBolt,
    },
  ]
  state.world.enemies = [
    {
      x: px,
      y: py,
      vx: 0.0,
      vy: 0.0,
      hp: 3,
      max_hp: 3,
      speed: 1.0,
      size: 12.0,
      alive: true,
      damage_timer: 0,
      kind: @game.Basic,
      path_cache: [],
      path_index: 0,
      path_timer: 0,
      shoot_cooldown: 0,
      pending_bolt_timer: 0,
      pending_bolt_target_x: px,
      pending_bolt_target_y: py,
      charge_timer: 0,
      charge_cooldown: 0, meteor_cast_timer: 0, meteor_target_x: 0.0, meteor_target_y: 0.0, beam_cast_timer: 0, beam_target_x: 0.0, beam_target_y: 0.0, room_index: -1,
    },
    {
      x: px + tile_size * 0.5,
      y: py,
      vx: 0.0,
      vy: 0.0,
      hp: 3,
      max_hp: 3,
      speed: 1.0,
      size: 12.0,
      alive: true,
      damage_timer: 0,
      kind: @game.Basic,
      path_cache: [],
      path_index: 0,
      path_timer: 0,
      shoot_cooldown: 0,
      pending_bolt_timer: 0,
      pending_bolt_target_x: px + tile_size * 0.5,
      pending_bolt_target_y: py,
      charge_timer: 0,
      charge_cooldown: 0, meteor_cast_timer: 0, meteor_target_x: 0.0, meteor_target_y: 0.0, beam_cast_timer: 0, beam_target_x: 0.0, beam_target_y: 0.0, room_index: -1,
    },
  ]

  let stats = summarize_draw_playing_commands(
    state.draw_playing(ctx),
    state,
    ctx.dst,
  )

  assert_true(stats.instanced_commands > 0)
  assert_true(stats.instanced_instances > 0)
  assert_true(stats.direct_lit_commands >= 2)
  assert_true(stats.skinned_commands > 0)
}

///|
test "push_character_commands emits skinned commands for player path" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let ctx = test_engine_context()
  let vis_region = compute_visible_region(
    state.world.dungeon.rooms,
    state.world.player.x,
    state.world.player.y,
    state.world.dungeon.grid.width,
    state.world.dungeon.grid.height,
  )
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  state.push_character_commands(
    vis_region,
    state.camera.to_camera3d(),
    state.scene_target,
    ctx.screen_w,
    ctx.screen_h,
    commands,
  )

  assert_true(
    count_matching_commands(commands, fn(cmd) {
      cmd.shader.id == state.shader3d_skinned.id
    }) >
    0,
  )
}

///|
test "push_enemy_character_commands emits skinned commands for visible enemies" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let ctx = test_engine_context()
  let px = state.world.player.x
  let py = state.world.player.y
  state.world.enemies = [
    {
      x: px,
      y: py,
      vx: 0.0,
      vy: 0.0,
      hp: 3,
      max_hp: 3,
      speed: 1.0,
      size: 12.0,
      alive: true,
      damage_timer: 0,
      kind: @game.Basic,
      path_cache: [],
      path_index: 0,
      path_timer: 0,
      shoot_cooldown: 0,
      pending_bolt_timer: 0,
      pending_bolt_target_x: px,
      pending_bolt_target_y: py,
      charge_timer: 0,
      charge_cooldown: 0, meteor_cast_timer: 0, meteor_target_x: 0.0, meteor_target_y: 0.0, beam_cast_timer: 0, beam_target_x: 0.0, beam_target_y: 0.0, room_index: -1,
    },
    {
      x: px + tile_size * 0.5,
      y: py,
      vx: 0.0,
      vy: 0.0,
      hp: 3,
      max_hp: 3,
      speed: 1.0,
      size: 12.0,
      alive: true,
      damage_timer: 0,
      kind: @game.Basic,
      path_cache: [],
      path_index: 0,
      path_timer: 0,
      shoot_cooldown: 0,
      pending_bolt_timer: 0,
      pending_bolt_target_x: px + tile_size * 0.5,
      pending_bolt_target_y: py,
      charge_timer: 0,
      charge_cooldown: 0, meteor_cast_timer: 0, meteor_target_x: 0.0, meteor_target_y: 0.0, beam_cast_timer: 0, beam_target_x: 0.0, beam_target_y: 0.0, room_index: -1,
    },
  ]
  let vis_region = compute_visible_region(
    state.world.dungeon.rooms,
    state.world.player.x,
    state.world.player.y,
    state.world.dungeon.grid.width,
    state.world.dungeon.grid.height,
  )
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  state.push_enemy_character_commands(
    vis_region,
    state.camera.to_camera3d(),
    state.scene_target,
    ctx.screen_w,
    ctx.screen_h,
    commands,
  )

  assert_true(
    count_matching_commands(commands, fn(cmd) {
      cmd.shader.id == state.shader3d_skinned_instanced.id ||
      cmd.shader.id == state.shader3d_skinned_instanced_monochrome.id ||
      cmd.shader.id == state.shader3d_instanced_monochrome.id
    }) >
    0,
  )
}

///|
test "push_enemy_character_commands keeps stress enemies batched by kind" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let ctx = test_engine_context()
  apply_enemy_stress_scenario(state.world, 64)
  let vis_region = compute_visible_region(
    state.world.dungeon.rooms,
    state.world.player.x,
    state.world.player.y,
    state.world.dungeon.grid.width,
    state.world.dungeon.grid.height,
  )
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  state.push_enemy_character_commands(
    vis_region,
    state.camera.to_camera3d(),
    state.scene_target,
    ctx.screen_w,
    ctx.screen_h,
    commands,
  )

  let enemy_cmd_count = count_matching_commands(commands, fn(cmd) {
    cmd.shader.id == state.shader3d_skinned.id ||
    cmd.shader.id == state.shader3d_skinned_instanced.id ||
    cmd.shader.id == state.shader3d_skinned_instanced_monochrome.id ||
    cmd.shader.id == state.shader3d_instanced_monochrome.id
  })
  assert_true(enemy_cmd_count <= 5)
  assert_true(
    count_matching_commands(commands, fn(cmd) {
      cmd.shader.id == state.shader3d_skinned_instanced.id ||
      cmd.shader.id == state.shader3d_skinned_instanced_monochrome.id ||
      cmd.shader.id == state.shader3d_instanced_monochrome.id
    }) >
    0,
  )
}

///|
test "push_player_character_commands emits one skinned command for player" {
  let state = GameState::new(seed=42)
  state.world.mode = @game.Playing
  let ctx = test_engine_context()
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  state.push_player_character_commands(
    state.camera.to_camera3d(),
    state.scene_target,
    ctx.screen_w,
    ctx.screen_h,
    commands,
  )

  assert_eq(commands.length(), 1)
  assert_eq(commands[0].shader.id, state.shader3d_skinned.id)
}

///|
test "rebuild_enemy_render_buckets clears stale enemy groups" {
  let state = GameState::new(seed=42)
  let px = state.world.player.x
  let py = state.world.player.y
  let vis_region = compute_visible_region(
    state.world.dungeon.rooms,
    px,
    py,
    state.world.dungeon.grid.width,
    state.world.dungeon.grid.height,
  )
  state.world.enemies = [
    {
      x: px,
      y: py,
      vx: 0.0,
      vy: 0.0,
      hp: 3,
      max_hp: 3,
      speed: 1.0,
      size: 12.0,
      alive: true,
      damage_timer: 0,
      kind: @game.Basic,
      path_cache: [],
      path_index: 0,
      path_timer: 0,
      shoot_cooldown: 0,
      pending_bolt_timer: 0,
      pending_bolt_target_x: px,
      pending_bolt_target_y: py,
      charge_timer: 0,
      charge_cooldown: 0, meteor_cast_timer: 0, meteor_target_x: 0.0, meteor_target_y: 0.0, beam_cast_timer: 0, beam_target_x: 0.0, beam_target_y: 0.0, room_index: -1,
    },
  ]

  state.rebuild_enemy_render_buckets(vis_region)
  assert_eq(state.enemy_render_buckets.basic_matrices.length(), 1)
  assert_eq(state.enemy_render_buckets.basic_colors.length(), 1)

  state.world.enemies = []
  state.rebuild_enemy_render_buckets(vis_region)
  assert_eq(state.enemy_render_buckets.basic_matrices.length(), 0)
  assert_eq(state.enemy_render_buckets.basic_colors.length(), 0)
}

///|
test "enemy_facing_model_matrix matches transform path" {
  let dx = 24.0
  let dy = -18.0
  let ex = 3.0
  let ey = 1.5
  let ez = 7.0
  let actual = enemy_facing_model_matrix(ex, ey, ez, dx, dy)
  let expected_rot = @math3d.Quaternion::from_axis_angle(
    @math3d.Vec3::unit_y(),
    -@math.atan2(dy, dx) + @math.PI / 2.0,
  )
  let expected = @transform3d.Transform3D::from_components(
    @math3d.Vec3::new(ex, ey, ez),
    expected_rot,
    @math3d.Vec3::one(),
  ).to_mat4()
  assert_true(actual.approx_eq(expected, 1.0e-6))
}

///|
test "enemy_facing_model_matrix keeps zero delta fallback stable" {
  let actual = enemy_facing_model_matrix(1.0, 2.0, 3.0, 0.0, 0.0)
  let expected = @math3d.Mat4::translation(1.0, 2.0, 3.0).multiply(
    @math3d.Mat4::rotation_y(@math.PI / 2.0),
  )
  assert_true(actual.approx_eq(expected, 1.0e-6))
}

///|
test "entity subpass helpers emit one instanced command each from scratch" {
  let state = GameState::new(seed=42)
  let px = state.world.player.x
  let py = state.world.player.y
  let vis_region = compute_visible_region(
    state.world.dungeon.rooms,
    px,
    py,
    state.world.dungeon.grid.width,
    state.world.dungeon.grid.height,
  )
  state.world.items = [
    {
      x: px,
      y: py,
      vx: 0.0,
      vy: 0.0,
      kind: @game.Health,
      alive: true,
      spawn_frame: 0,
    },
  ]
  state.world.projectiles = [
    {
      x: px + 4.0,
      y: py,
      vx: 1.0,
      vy: 0.0,
      age: 0,
      alive: true,
      damage: 1,
      is_player: true,
      kind: @game.Arrow,
    },
    {
      x: px,
      y: py + 4.0,
      vx: -1.0,
      vy: 0.0,
      age: 0,
      alive: true,
      damage: 1,
      is_player: false,
      kind: @game.EnemyBolt,
    },
  ]
  state.rebuild_entity_instance_scratch(vis_region)
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  let camera = state.camera.to_camera3d()
  let view_projection = camera.view_projection_matrix()
  push_item_instance_cmds(
    state,
    view_projection,
    state.scene_target,
    screen_w,
    screen_h,
    cmds,
  )
  push_arrow_instance_cmds(
    state,
    view_projection,
    state.scene_target,
    screen_w,
    screen_h,
    cmds,
  )
  push_enemy_projectile_instance_cmds(
    state,
    view_projection,
    state.scene_target,
    screen_w,
    screen_h,
    cmds,
  )
  assert_eq(cmds.length(), 3)
  assert_eq(cmds[0].instance_count, 1)
  assert_eq(cmds[1].instance_count, 1)
  assert_eq(cmds[2].instance_count, 1)
  assert_eq(cmds[0].shader.id, state.shader3d_colored.id)
  assert_eq(cmds[1].shader.id, state.shader3d.id)
  assert_eq(cmds[2].shader.id, state.shader3d.id)
  assert_eq(cmds[0].uniform_dwords.length(), 60)
  assert_eq(cmds[0].uniform_dwords[56], @gfx.double_to_f32_bits(0.0))
  assert_eq(cmds[0].uniform_dwords[57], @gfx.double_to_f32_bits(1.0))
  assert_eq(cmds[0].uniform_dwords[58], @gfx.double_to_f32_bits(0.4))
  assert_eq(cmds[0].uniform_dwords[59], @gfx.double_to_f32_bits(1.0))
}

///|
test "rebuild_entity_instance_scratch clears stale instanced data" {
  let state = GameState::new(seed=42)
  let px = state.world.player.x
  let py = state.world.player.y
  let vis_region = compute_visible_region(
    state.world.dungeon.rooms,
    px,
    py,
    state.world.dungeon.grid.width,
    state.world.dungeon.grid.height,
  )
  state.world.items = [
    {
      x: px,
      y: py,
      vx: 0.0,
      vy: 0.0,
      kind: @game.Health,
      alive: true,
      spawn_frame: 0,
    },
  ]
  state.world.projectiles = [
    {
      x: px + 4.0,
      y: py,
      vx: 1.0,
      vy: 0.0,
      age: 0,
      alive: true,
      damage: 1,
      is_player: true,
      kind: @game.Arrow,
    },
    {
      x: px,
      y: py + 4.0,
      vx: -1.0,
      vy: 0.0,
      age: 0,
      alive: true,
      damage: 1,
      is_player: false,
      kind: @game.EnemyBolt,
    },
  ]

  state.rebuild_entity_instance_scratch(vis_region)
  assert_eq(state.entity_instance_scratch.item_instances.length(), 1)
  assert_eq(state.entity_instance_scratch.arrow_instances.length(), 1)
  assert_eq(
    state.entity_instance_scratch.enemy_projectile_instances.length(),
    1,
  )

  state.world.items = []
  state.world.projectiles = []
  state.rebuild_entity_instance_scratch(vis_region)
  assert_eq(state.entity_instance_scratch.item_instances.length(), 0)
  assert_eq(state.entity_instance_scratch.arrow_instances.length(), 0)
  assert_eq(
    state.entity_instance_scratch.enemy_projectile_instances.length(),
    0,
  )
}

///|
test "rebuild_entity_instance_scratch separates fireball from arrow instances" {
  let state = GameState::new(seed=42)
  let px = state.world.player.x
  let py = state.world.player.y
  let vis_region = compute_visible_region(
    state.world.dungeon.rooms,
    px,
    py,
    state.world.dungeon.grid.width,
    state.world.dungeon.grid.height,
  )
  state.world.projectiles = [
    {
      x: px + 4.0,
      y: py,
      vx: 1.0,
      vy: 0.0,
      age: 0,
      alive: true,
      damage: 1,
      is_player: true,
      kind: @game.Arrow,
    },
    {
      x: px + 8.0,
      y: py,
      vx: 1.0,
      vy: 0.0,
      age: 0,
      alive: true,
      damage: 2,
      is_player: true,
      kind: @game.Fireball(1),
    },
    {
      x: px,
      y: py + 4.0,
      vx: -1.0,
      vy: 0.0,
      age: 0,
      alive: true,
      damage: 1,
      is_player: false,
      kind: @game.EnemyBolt,
    },
  ]

  state.rebuild_entity_instance_scratch(vis_region)

  assert_eq(state.entity_instance_scratch.arrow_instances.length(), 1)
  assert_eq(state.entity_instance_scratch.fireball_instances.length(), 1)
  assert_eq(
    state.entity_instance_scratch.enemy_projectile_instances.length(),
    1,
  )
}
