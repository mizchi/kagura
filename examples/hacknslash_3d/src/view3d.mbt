// 3D rendering: dungeon graph, entity graph, draw

// Colors (RGBA, 0-1 range) — natural field palette
let color_floor : @math3d.Vec4 = @math3d.Vec4::new(0.32, 0.40, 0.24, 1.0)

let color_corridor : @math3d.Vec4 = @math3d.Vec4::new(0.34, 0.31, 0.24, 1.0)

let color_wall : @math3d.Vec4 = @math3d.Vec4::new(0.45, 0.40, 0.32, 1.0)

let color_door : @math3d.Vec4 = @math3d.Vec4::new(0.50, 0.42, 0.20, 1.0)

let color_pillar : @math3d.Vec4 = @math3d.Vec4::new(0.50, 0.45, 0.35, 1.0)

let color_player : @math3d.Vec4 = @math3d.Vec4::new(0.0, 1.0, 0.8, 1.0)

let color_player_dash : @math3d.Vec4 = @math3d.Vec4::new(0.4, 0.87, 1.0, 1.0)

let color_player_hurt : @math3d.Vec4 = @math3d.Vec4::new(1.0, 1.0, 1.0, 1.0)

let color_enemy_basic : @math3d.Vec4 = @math3d.Vec4::new(0.8, 0.13, 0.13, 1.0)

let color_enemy_fast : @math3d.Vec4 = @math3d.Vec4::new(1.0, 0.53, 0.0, 1.0)

let color_enemy_tank : @math3d.Vec4 = @math3d.Vec4::new(0.53, 0.27, 0.8, 1.0)

let color_enemy_ranged : @math3d.Vec4 = @math3d.Vec4::new(0.27, 0.67, 1.0, 1.0)

let color_enemy_boss : @math3d.Vec4 = @math3d.Vec4::new(1.0, 0.13, 0.4, 1.0)

let color_item_health : @math3d.Vec4 = @math3d.Vec4::new(0.0, 1.0, 0.4, 1.0)

let color_item_score : @math3d.Vec4 = @math3d.Vec4::new(0.0, 1.0, 1.0, 1.0)

let color_projectile : @math3d.Vec4 = @math3d.Vec4::new(1.0, 0.27, 0.4, 1.0)

fn hex_to_vec4(hex : Int) -> @math3d.Vec4 {
  let r = ((hex >> 16) & 0xFF).to_double() / 255.0
  let g = ((hex >> 8) & 0xFF).to_double() / 255.0
  let b = (hex & 0xFF).to_double() / 255.0
  @math3d.Vec4::new(r, g, b, 1.0)
}

let color_arrow : @math3d.Vec4 = @math3d.Vec4::new(0.9, 0.85, 0.3, 1.0)

// Build entity draw commands directly (items/projectiles) — no SceneGraph overhead
fn build_entity_cmds(
  state : GameState,
  region : VisibleRegion,
  vp : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let lighting = state.lighting
  // Items with Y-axis bob
  for item in state.world.items {
    if item.alive && is_entity_visible(region, item.x, item.y) {
      let ix = item.x / tile_size
      let iz = item.y / tile_size
      let base_y = @game.get_tile_height(state.world.dungeon, item.x, item.y)
      let bob = base_y + 0.3 + 0.1 * @math.sin(state.world.frame_count.to_double() * 0.1)
      let c = match item.kind {
        @game.Health => color_item_health
        @game.Equipment(data) => hex_to_vec4(data.rarity.color())
        _ => color_item_score
      }
      let model = @math3d.Mat4::translation(ix, bob, iz)
      let tinted = tint_lighting(lighting, c)
      let dst_region = @gfx.new_dst_region(
        0, 0, screen_w, screen_h, state.meshes.item.indices.length(),
      )
      cmds.push(
        @draw3d.new_lit_mesh_draw_command(
          dst, shader, dst_region, 0, 0, 0,
          @gfx.blend_mode_from_int(1),
          state.meshes.item, model, vp, tinted, [],
        ),
      )
    }
  }
  // Projectiles (enemy spheres + player arrows)
  for proj in state.world.projectiles {
    if proj.alive && is_entity_visible(region, proj.x, proj.y) {
      let prx = proj.x / tile_size
      let prz = proj.y / tile_size
      let base_y = @game.get_tile_height(state.world.dungeon, proj.x, proj.y)
      if proj.is_player {
        // Player arrow: rotated to face movement direction
        let angle = @math.atan2(proj.vy, proj.vx)
        let rot = @math3d.Mat4::rotation_y(-angle)
        let trans = @math3d.Mat4::translation(prx, base_y + 0.3, prz)
        let model = trans.multiply(rot)
        let tinted = tint_lighting(lighting, color_arrow)
        let mesh = state.meshes.arrow
        let dst_region = @gfx.new_dst_region(
          0, 0, screen_w, screen_h, mesh.indices.length(),
        )
        cmds.push(
          @draw3d.new_lit_mesh_draw_command(
            dst, shader, dst_region, 0, 0, 0,
            @gfx.blend_mode_from_int(1),
            mesh, model, vp, tinted, [],
          ),
        )
      } else {
        let model = @math3d.Mat4::translation(prx, base_y + 0.3, prz)
        let tinted = tint_lighting(lighting, color_projectile)
        let dst_region = @gfx.new_dst_region(
          0, 0, screen_w, screen_h, state.meshes.projectile.indices.length(),
        )
        cmds.push(
          @draw3d.new_lit_mesh_draw_command(
            dst, shader, dst_region, 0, 0, 0,
            @gfx.blend_mode_from_int(1),
            state.meshes.projectile, model, vp, tinted, [],
          ),
        )
      }
    }
  }
}

// Pre-compute tinted lighting for a color (used for dungeon groups)
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
      draw_calls: result.length(),
      vertex_count: vtx_count,
      asset_inflight: 0,
    }
    @debugutil.build_profiler_hud(
      result, ctx.dst, ctx.shader, self.profile,
      ctx.screen_w.to_double(), ctx.screen_h.to_double(),
    )
  }
  self.flush_text_atlas()
  result
}

fn GameState::draw_playing(
  self : GameState,
  ctx : @engine.EngineContext,
) -> Array[@gfx.DrawTrianglesCommand] {
  let camera = self.camera.to_camera3d()
  let view_projection = camera.view_projection_matrix()
  // Shadow config centered on player
  let px3d = self.world.player.x / tile_size
  let pz3d = self.world.player.y / tile_size
  let shadow_config = @shadow3d.ShadowConfig::new(
    self.shadow_config.map_size,
    self.shadow_config.half_extent,
    self.shadow_config.near,
    self.shadow_config.far,
    self.shadow_config.distance,
    @math3d.Vec3::new(px3d, 0.0, pz3d),
    self.shadow_config.bias,
  )
  let lighting = self.lighting
  let light_vp = @shadow3d.light_space_matrix(
    lighting.directional.direction,
    shadow_config.center,
    shadow_config.distance,
    shadow_config.half_extent,
    shadow_config.near,
    shadow_config.far,
  )
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  let rt = self.scene_target
  let identity = @math3d.Mat4::identity()
  // Get visible chunks (larger chunks = fewer iterations)
  let player_tile_x = (self.world.player.x / tile_size).to_int()
  let player_tile_z = (self.world.player.y / tile_size).to_int()
  let visible_chunks = get_visible_chunks(
    self.dungeon_chunks, player_tile_x, player_tile_z, 1,
  )
  // === Pass 1: Shadow depth — 1 command per chunk using all_mesh ===
  for chunk in visible_chunks {
    if chunk.all_mesh.indices.length() > 0 {
      cmds.push(
        @shadow3d.new_shadow_depth_command(
          self.shadow_map, self.shadow_depth_shader,
          chunk.all_mesh, identity, light_vp,
        ),
      )
    }
  }
  // === Pass 2: Shadow-lit dungeon — pre-compute tinted lighting per color ===
  // Cache tinted lighting for each unique dungeon color (computed once per frame)
  let tl_floor = tint_lighting(lighting, color_floor)
  let tl_corridor = tint_lighting(lighting, color_corridor)
  let tl_door = tint_lighting(lighting, color_door)
  let tl_wall = tint_lighting(lighting, color_wall)
  let tl_pillar = tint_lighting(lighting, color_pillar)
  let tinted_cache : Array[@light3d.LightingEnvironment] = [
    tl_floor, tl_corridor, tl_door, tl_wall, tl_pillar,
  ]
  for chunk in visible_chunks {
    for gi in 0..<chunk.groups.length() {
      let group = chunk.groups[gi]
      let tinted = if gi < tinted_cache.length() {
        tinted_cache[gi]
      } else {
        tint_lighting(lighting, group.color)
      }
      let dst_region = @gfx.new_dst_region(
        0, 0, ctx.screen_w, ctx.screen_h, group.mesh.indices.length(),
      )
      cmds.push(
        @shadow3d.new_shadow_lit_mesh_draw_command(
          rt, self.shadow_lit_shader, dst_region,
          0, 0, 0, @gfx.blend_mode_from_int(0),
          group.mesh, identity, view_projection, tinted,
          light_vp, shadow_config,
          self.shadow_map.id, self.shadow_map.id,
        ),
      )
    }
  }
  // Compute visible region for occlusion culling
  let vis_region = compute_visible_region(
    self.world.dungeon.rooms, self.world.player.x, self.world.player.y,
    self.world.dungeon.grid.width, self.world.dungeon.grid.height,
  )
  // === Pass 3: Entities (items/projectiles) → direct draw commands ===
  build_entity_cmds(
    self, vis_region, view_projection, rt, self.shader3d,
    ctx.screen_w, ctx.screen_h, cmds,
  )
  // === Pass 4: Skinned enemies → scene_target ===
  let enemy_skinning = self.enemy_models.compute_skinning()
  let skinned_objects : Array[@scene3d.Object3D] = []
  for enemy in self.world.enemies {
    if enemy.alive && is_entity_visible(vis_region, enemy.x, enemy.y) {
      let ex = enemy.x / tile_size
      let ez = enemy.y / tile_size
      let ey = @game.get_tile_height(self.world.dungeon, enemy.x, enemy.y)
      let color = if enemy.damage_timer > 0 {
        color_player_hurt
      } else {
        match enemy.kind {
          @game.Fast => color_enemy_fast
          @game.Tank => color_enemy_tank
          @game.Ranged => color_enemy_ranged
          @game.Boss => color_enemy_boss
          @game.Basic => color_enemy_basic
        }
      }
      let mesh_data = self.enemy_models.get_mesh_data(enemy.kind)
      let dx = self.world.player.x - enemy.x
      let dy = self.world.player.y - enemy.y
      let face_angle = @math.atan2(dy, dx)
      let rot = @math3d.Quaternion::from_axis_angle(
        @math3d.Vec3::unit_y(),
        -face_angle + @math.PI / 2.0,
      )
      skinned_objects.push(
        @scene3d.object3d(
          mesh=mesh_data.bind_mesh,
          position=@math3d.Vec3::new(ex, ey, ez),
          rotation=rot,
          color=color,
          skinning=Some(
            @scene3d.SkinningState::new_with_packed(
              mesh_data.skin_data,
              enemy_skinning,
              mesh_data.packed_vertex_data,
            ),
          ),
        ),
      )
    }
  }
  if skinned_objects.length() > 0 {
    let enemy_scene = @scene3d.scene3d(
      objects=skinned_objects,
      camera~,
      lighting=self.lighting,
    )
    let enemy_cmds = @scene3d.render_scene3d_gpu(
      enemy_scene,
      rt,
      self.shader3d,
      ctx.screen_w,
      ctx.screen_h,
      shader3d_skinned=Some(self.shader3d_skinned),
    )
    for cmd in enemy_cmds {
      cmds.push(cmd)
    }
  }
  // === Pass 5: Player character ===
  let px = self.world.player.x / tile_size
  let pz = self.world.player.y / tile_size
  let py = @game.get_tile_height(self.world.dungeon, self.world.player.x, self.world.player.y)
  let player_color = if self.world.player.dash_timer > 0 {
    color_player_dash
  } else if self.world.player.damage_timer > 0 {
    color_player_hurt
  } else {
    color_player
  }
  let skinning_matrices = self.character.compute_skinning()
  let facing_rot = @math3d.Quaternion::from_axis_angle(
    @math3d.Vec3::unit_y(),
    -self.world.player.facing_angle + @math.PI / 2.0,
  )
  let player_objects : Array[@scene3d.Object3D] = [
    @scene3d.object3d(
      mesh=self.character.bind_mesh,
      position=@math3d.Vec3::new(px, py, pz),
      rotation=facing_rot,
      color=player_color,
      skinning=Some(
        @scene3d.SkinningState::new_with_packed(
          self.character.skin_data,
          skinning_matrices,
          self.character.packed_vertex_data,
        ),
      ),
    ),
  ]
  let player_scene = @scene3d.scene3d(
    objects=player_objects,
    camera~,
    lighting=self.lighting,
  )
  let player_cmds = @scene3d.render_scene3d_gpu(
    player_scene,
    rt,
    self.shader3d,
    ctx.screen_w,
    ctx.screen_h,
    shader3d_skinned=Some(self.shader3d_skinned),
  )
  for cmd in player_cmds {
    cmds.push(cmd)
  }
  // === Pass 6: Particles ===
  let particle_cmds = self.particle_manager.draw(
    rt, camera, ctx.screen_w, ctx.screen_h, self.world.frame_count,
  )
  for cmd in particle_cmds {
    cmds.push(cmd)
  }
  // === Pass 7: Camera depth for SSAO ===
  let casters : Array[@shadow3d.ShadowCaster] = []
  for chunk in visible_chunks {
    if chunk.all_mesh.indices.length() > 0 {
      casters.push(@shadow3d.ShadowCaster::new(chunk.all_mesh, identity))
    }
  }
  let depth_cmds = @shadow3d.camera_depth_pass_commands(
    self.camera_depth_target, self.camera_depth_shader,
    casters, view_projection,
  )
  for cmd in depth_cmds {
    cmds.push(cmd)
  }
  // === Pass 8: SSAO ===
  cmds.push(
    @postfx.new_ssao_command(
      self.ssao_target, self.ssao_sh,
      self.scene_target.id, self.camera_depth_target.id,
      0.5, 0.025, 1.0, ctx.screen_w, ctx.screen_h,
    ),
  )
  // === Pass 9: Bloom (threshold → hblur → vblur → composite) ===
  let bloom_cmds = @postfx.bloom_commands(
    self.post_target, self.ssao_target.id,
    self.bloom_a, self.bloom_b,
    self.bloom_threshold_sh, self.bloom_hblur_sh,
    self.bloom_vblur_sh, self.bloom_composite_sh,
    0.8, 0.3, ctx.screen_w, ctx.screen_h,
  )
  for cmd in bloom_cmds {
    cmds.push(cmd)
  }
  // === PostFX: tonemap → FXAA ===
  cmds.push(
    @postfx.new_tonemap_command(
      self.bloom_b, self.tonemap_sh, self.post_target.id, 1.0,
    ),
  )
  cmds.push(
    @postfx.new_fxaa_command(
      ctx.dst, self.fxaa_sh, self.bloom_b.id, ctx.screen_w, ctx.screen_h,
    ),
  )
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
