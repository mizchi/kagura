// 3D rendering: dungeon graph, entity graph, draw

// Colors (RGBA, 0-1 range) — natural field palette

///|
let color_floor : @math3d.Vec4 = @math3d.Vec4::new(0.32, 0.40, 0.24, 1.0)

///|
let color_corridor : @math3d.Vec4 = @math3d.Vec4::new(0.34, 0.31, 0.24, 1.0)

///|
let color_wall : @math3d.Vec4 = @math3d.Vec4::new(0.45, 0.40, 0.32, 1.0)

///|
let color_door : @math3d.Vec4 = @math3d.Vec4::new(0.50, 0.42, 0.20, 1.0)

///|
let color_pillar : @math3d.Vec4 = @math3d.Vec4::new(0.50, 0.45, 0.35, 1.0)

///|
let color_player : @math3d.Vec4 = @math3d.Vec4::new(0.0, 1.0, 0.8, 1.0)

///|
let color_player_dash : @math3d.Vec4 = @math3d.Vec4::new(0.4, 0.87, 1.0, 1.0)

///|
let color_player_hurt : @math3d.Vec4 = @math3d.Vec4::new(1.0, 1.0, 1.0, 1.0)

///|
let color_enemy_basic : @math3d.Vec4 = @math3d.Vec4::new(0.8, 0.13, 0.13, 1.0)

///|
let color_enemy_fast : @math3d.Vec4 = @math3d.Vec4::new(1.0, 0.53, 0.0, 1.0)

///|
let color_enemy_tank : @math3d.Vec4 = @math3d.Vec4::new(0.53, 0.27, 0.8, 1.0)

///|
let color_enemy_ranged : @math3d.Vec4 = @math3d.Vec4::new(0.27, 0.67, 1.0, 1.0)

///|
let color_enemy_boss : @math3d.Vec4 = @math3d.Vec4::new(1.0, 0.13, 0.4, 1.0)

///|
let color_item_health : @math3d.Vec4 = @math3d.Vec4::new(0.0, 1.0, 0.4, 1.0)

///|
let color_item_score : @math3d.Vec4 = @math3d.Vec4::new(0.0, 1.0, 1.0, 1.0)

///|
let color_projectile : @math3d.Vec4 = @math3d.Vec4::new(1.0, 0.27, 0.4, 1.0)

///|
fn hex_to_vec4(hex : Int) -> @math3d.Vec4 {
  let r = ((hex >> 16) & 0xFF).to_double() / 255.0
  let g = ((hex >> 8) & 0xFF).to_double() / 255.0
  let b = (hex & 0xFF).to_double() / 255.0
  @math3d.Vec4::new(r, g, b, 1.0)
}

///|
let color_arrow : @math3d.Vec4 = @math3d.Vec4::new(0.9, 0.85, 0.3, 1.0)

///|
struct ShadowFrameState {
  config : @shadow3d.ShadowConfig
  light_vp : @math3d.Mat4
}

///|
fn compute_shadow_frame_state(
  enabled : Bool,
  base_config : @shadow3d.ShadowConfig,
  player_x : Double,
  player_y : Double,
  lighting : @light3d.LightingEnvironment,
) -> ShadowFrameState? {
  if !enabled {
    return None
  }
  let px3d = player_x / tile_size
  let pz3d = player_y / tile_size
  let config = @shadow3d.ShadowConfig::new(
    base_config.map_size,
    base_config.half_extent,
    base_config.near,
    base_config.far,
    base_config.distance,
    @math3d.Vec3::new(px3d, 0.0, pz3d),
    base_config.bias,
  )
  let light_vp = @shadow3d.light_space_matrix(
    lighting.directional.direction,
    config.center,
    config.distance,
    config.half_extent,
    config.near,
    config.far,
  )
  Some({ config, light_vp })
}

// Pre-compute tinted lighting for a color (used for dungeon groups)

///|
fn tint_lighting(
  lighting : @light3d.LightingEnvironment,
  col : @math3d.Vec4,
) -> @light3d.LightingEnvironment {
  @light3d.LightingEnvironment::new(
    @light3d.DirectionalLight::new(
      lighting.directional.direction,
      @math3d.Vec3::new(
        lighting.directional.color.x * col.x,
        lighting.directional.color.y * col.y,
        lighting.directional.color.z * col.z,
      ),
      lighting.directional.intensity,
    ),
    @light3d.AmbientLight::new(
      @math3d.Vec3::new(
        lighting.ambient.color.x * col.x,
        lighting.ambient.color.y * col.y,
        lighting.ambient.color.z * col.z,
      ),
      lighting.ambient.intensity,
    ),
  )
}

///|
fn GameState::draw(
  self : GameState,
  ctx : @engine.EngineContext,
) -> Array[@gfx.DrawTrianglesCommand] {
  let result = match self.world.mode {
    @game.Title => self.render_title_cmds(ctx.dst, ctx.shader)
    @game.GameOver => self.render_gameover_cmds(ctx.dst, ctx.shader)
    @game.Playing => self.draw_playing(ctx)
  }
  // Profiler HUD (after all other rendering)
  if self.show_profiler {
    // Count stats from commands
    let mut vtx_count = 0
    for cmd in result {
      vtx_count = vtx_count + cmd.indices.length()
    }
    self.profile = {
      fps: self.profile.fps,
      frame_time_ms: self.profile.frame_time_ms,
      update_ms: self.profile.update_ms,
      draw_ms: self.profile.draw_ms,
      gpu_frame_ms: self.profile.gpu_frame_ms,
      draw_calls: result.length(),
      vertex_count: vtx_count,
      asset_inflight: 0,
    }
    @debugutil.build_profiler_hud(
      result,
      ctx.dst,
      ctx.shader,
      self.profile,
      ctx.screen_w.to_double(),
      ctx.screen_h.to_double(),
    )
  }
  self.flush_text_atlas()
  result
}

///|
fn GameState::draw_playing(
  self : GameState,
  ctx : @engine.EngineContext,
) -> Array[@gfx.DrawTrianglesCommand] {
  let camera = self.camera.to_camera3d()
  let view_projection = camera.view_projection_matrix()
  let shadow_state = compute_shadow_frame_state(
    self.shadows_enabled,
    self.shadow_config,
    self.world.player.x,
    self.world.player.y,
    self.lighting,
  )
  let lighting = self.lighting
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  let rt = self.scene_target
  let identity = @math3d.Mat4::identity()
  let visible_dungeon_cache = self.get_visible_dungeon_mesh_cache_for_player()
  // === Pass 1-2: Dungeon shadow/depth + shaded geometry ===
  self.push_dungeon_chunk_commands(
    visible_dungeon_cache.groups,
    visible_dungeon_cache.all_mesh,
    view_projection,
    shadow_state,
    rt,
    cmds,
  )
  // Compute visible region for occlusion culling
  let vis_region = compute_visible_region(
    self.world.dungeon.rooms,
    self.world.player.x,
    self.world.player.y,
    self.world.dungeon.grid.width,
    self.world.dungeon.grid.height,
  )
  // === Pass 3: Entities (items/projectiles) → instanced draw commands ===
  push_entity_instanced_cmds(
    self,
    vis_region,
    camera,
    rt,
    ctx.screen_w,
    ctx.screen_h,
    cmds,
  )
  // === Pass 4-5: Enemies + player character ===
  self.push_character_commands(
    vis_region,
    camera,
    rt,
    ctx.screen_w,
    ctx.screen_h,
    cmds,
  )
  // === Pass 6: Particles ===
  self.particle_manager.append_draw_commands(
    cmds,
    rt,
    camera,
    ctx.screen_w,
    ctx.screen_h,
    self.world.frame_count,
  )
  let bloom_input_id = if self.ssao_config.enabled {
    // === Pass 7: Camera depth for SSAO ===
    let casters : Array[@shadow3d.ShadowCaster] = []
    if visible_dungeon_cache.all_mesh.indices.length() > 0 {
      casters.push(
        @shadow3d.ShadowCaster::new(visible_dungeon_cache.all_mesh, identity),
      )
    }
    let depth_cmds = @shadow3d.camera_depth_pass_commands(
      self.camera_depth_target,
      self.camera_depth_shader,
      casters,
      view_projection,
    )
    for cmd in depth_cmds {
      cmds.push(cmd)
    }
    // === Pass 8: SSAO ===
    cmds.push(
      @postfx.new_ssao_command(
        self.ssao_target,
        self.ssao_sh,
        self.scene_target.id,
        self.camera_depth_target.id,
        self.ssao_config.radius,
        self.ssao_config.bias,
        self.ssao_config.intensity,
        ctx.screen_w,
        ctx.screen_h,
      ),
    )
    self.ssao_target.id
  } else {
    self.scene_target.id
  }
  // === Pass 9: Bloom (threshold → hblur → vblur → composite) ===
  let bloom_cmds = @postfx.bloom_commands(
    self.post_target,
    bloom_input_id,
    self.bloom_a,
    self.bloom_b,
    self.bloom_threshold_sh,
    self.bloom_hblur_sh,
    self.bloom_vblur_sh,
    self.bloom_composite_sh,
    0.8,
    0.3,
    ctx.screen_w,
    ctx.screen_h,
  )
  for cmd in bloom_cmds {
    cmds.push(cmd)
  }
  // === PostFX: tonemap → optional FXAA ===
  if self.fxaa_enabled {
    cmds.push(
      @postfx.new_tonemap_command(
        self.bloom_b,
        self.tonemap_sh,
        self.post_target.id,
        1.0,
      ),
    )
    cmds.push(
      @postfx.new_fxaa_command(
        ctx.dst,
        self.fxaa_sh,
        self.bloom_b.id,
        ctx.screen_w,
        ctx.screen_h,
      ),
    )
  } else {
    cmds.push(
      @postfx.new_tonemap_command(
        ctx.dst,
        self.tonemap_sh,
        self.post_target.id,
        1.0,
      ),
    )
  }
  // 2D HUD overlay
  let hud_cmds = self.render_hud_cmds(ctx.dst, ctx.shader)
  for cmd in hud_cmds {
    cmds.push(cmd)
  }
  if self.world.ui_mode != @game.UIMode::None {
    let ui_cmds = self.render_rpg_ui_cmds(ctx.dst, ctx.shader)
    for cmd in ui_cmds {
      cmds.push(cmd)
    }
  }
  cmds
}
