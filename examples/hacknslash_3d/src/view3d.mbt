// 3D rendering: dungeon graph, entity graph, draw

// Colors (RGBA, 0-1 range) — natural field palette
let color_floor : @math3d.Vec4 = @math3d.Vec4::new(0.30, 0.38, 0.22, 1.0)

let color_floor_alt : @math3d.Vec4 = @math3d.Vec4::new(0.34, 0.42, 0.25, 1.0)

let color_corridor : @math3d.Vec4 = @math3d.Vec4::new(0.35, 0.32, 0.25, 1.0)

let color_corridor_alt : @math3d.Vec4 = @math3d.Vec4::new(0.32, 0.29, 0.22, 1.0)

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

// Build static dungeon scene graph (cached, rebuilt on floor reset)
fn build_dungeon_graph(dungeon : DungeonData, meshes : Meshes3D) -> @scene3d.SceneGraph {
  let graph = @scene3d.SceneGraph::new()
  let w = dungeon.grid.width
  for row = 0; row < dungeon.grid.height; row = row + 1 {
    for col = 0; col < w; col = col + 1 {
      let tile = dungeon.grid.get(col, row)
      let x = col.to_double()
      let z = row.to_double()
      let y = dungeon.height_map[row * w + col]
      match tile {
        Floor | Start | Goal => {
          let checker = (col + row) % 2
          let c = if tile == @terrain.Start {
            @math3d.Vec4::new(0.2, 0.45, 0.25, 1.0)
          } else if tile == @terrain.Goal {
            @math3d.Vec4::new(0.45, 0.2, 0.15, 1.0)
          } else if checker == 0 {
            color_floor
          } else {
            color_floor_alt
          }
          graph.add_node(
            @scene3d.scene_node(
              mesh=Some(meshes.floor_tile),
              position=@math3d.Vec3::new(x, y, z),
              color=c,
            ),
          ) |> ignore
        }
        Corridor => {
          let stripe = (col + row) % 3
          let c = if stripe == 0 { color_corridor } else { color_corridor_alt }
          graph.add_node(
            @scene3d.scene_node(
              mesh=Some(meshes.floor_tile),
              position=@math3d.Vec3::new(x, y, z),
              color=c,
            ),
          ) |> ignore
        }
        Door => {
          graph.add_node(
            @scene3d.scene_node(
              mesh=Some(meshes.floor_tile),
              position=@math3d.Vec3::new(x, y, z),
              color=color_door,
            ),
          ) |> ignore
          // Door frame pillars
          graph.add_node(
            @scene3d.scene_node(
              mesh=Some(meshes.pillar),
              position=@math3d.Vec3::new(x - 0.4, y, z),
              color=color_pillar,
            ),
          ) |> ignore
          graph.add_node(
            @scene3d.scene_node(
              mesh=Some(meshes.pillar),
              position=@math3d.Vec3::new(x + 0.4, y, z),
              color=color_pillar,
            ),
          ) |> ignore
        }
        Wall => {
          // Only render edge walls (adjacent to walkable)
          if has_adjacent_walkable(dungeon.grid, col, row) {
            graph.add_node(
              @scene3d.scene_node(
                mesh=Some(meshes.wall),
                position=@math3d.Vec3::new(x, y, z),
                color=color_wall,
              ),
            ) |> ignore
          }
        }
        _ => ()
      }
    }
  }
  graph
}

// Build dynamic entity scene graph (per frame, items/projectiles only)
fn build_entity_graph(state : GameState, region : VisibleRegion) -> @scene3d.SceneGraph {
  let graph = @scene3d.SceneGraph::new()
  // Items with Y-axis bob
  for item in state.items {
    if item.alive && is_entity_visible(region, item.x, item.y) {
      let ix = item.x / tile_size
      let iz = item.y / tile_size
      let base_y = get_tile_height(state.dungeon, item.x, item.y)
      let bob = base_y + 0.3 + 0.1 * @math.sin(state.frame_count.to_double() * 0.1)
      let c = if item.kind == item_health { color_item_health } else { color_item_score }
      graph.add_node(
        @scene3d.scene_node(
          mesh=Some(state.meshes.item),
          position=@math3d.Vec3::new(ix, bob, iz),
          color=c,
        ),
      ) |> ignore
    }
  }
  // Projectiles
  for proj in state.projectiles {
    if proj.alive && is_entity_visible(region, proj.x, proj.y) {
      let prx = proj.x / tile_size
      let prz = proj.y / tile_size
      let base_y = get_tile_height(state.dungeon, proj.x, proj.y)
      graph.add_node(
        @scene3d.scene_node(
          mesh=Some(state.meshes.projectile),
          position=@math3d.Vec3::new(prx, base_y + 0.3, prz),
          color=color_projectile,
        ),
      ) |> ignore
    }
  }
  graph
}

fn GameState::draw(
  self : GameState,
  ctx : @engine.EngineContext,
) -> Array[@gfx.DrawTrianglesCommand] {
  let result = match self.mode {
    m if m == mode_title => self.render_title_cmds(ctx.dst, ctx.shader)
    m if m == mode_gameover => self.render_gameover_cmds(ctx.dst, ctx.shader)
    _ => self.draw_playing(ctx)
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
  let sw = ctx.screen_w.to_double()
  let sh = ctx.screen_h.to_double()
  let camera = self.camera.to_camera3d()
  let view_projection = camera.view_projection_matrix()
  // Shadow config centered on player
  let px3d = self.player.x / tile_size
  let pz3d = self.player.y / tile_size
  let shadow_config = @shadow3d.ShadowConfig::new(
    self.shadow_config.map_size,
    self.shadow_config.half_extent,
    self.shadow_config.near,
    self.shadow_config.far,
    self.shadow_config.distance,
    @math3d.Vec3::new(px3d, 0.0, pz3d),
    self.shadow_config.bias,
  ) // center follows player each frame
  let lighting = self.lighting
  // Compute light-space VP matrix
  let light_vp = @shadow3d.light_space_matrix(
    lighting.directional.direction,
    shadow_config.center,
    shadow_config.distance,
    shadow_config.half_extent,
    shadow_config.near,
    shadow_config.far,
  )
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  // Render target: all 3D content goes to scene_target (offscreen)
  let rt = self.scene_target
  // === Pass 1: Shadow depth pass (all dungeon tiles as casters) ===
  let identity = @math3d.Mat4::identity()
  let casters : Array[@shadow3d.ShadowCaster] = []
  for group in self.dungeon_mesh_groups {
    casters.push(@shadow3d.ShadowCaster::new(group.mesh, identity))
  }
  let depth_cmds = @shadow3d.shadow_depth_pass_commands(
    self.shadow_map,
    self.shadow_depth_shader,
    casters,
    lighting,
    shadow_config,
  )
  for cmd in depth_cmds {
    cmds.push(cmd)
  }
  // === Pass 1.5: Camera depth pass (for SSAO) ===
  let cam_depth_cmds = @shadow3d.camera_depth_pass_commands(
    self.camera_depth_target,
    self.camera_depth_shader,
    casters,
    view_projection,
  )
  for cmd in cam_depth_cmds {
    cmds.push(cmd)
  }
  // === Pass 2: Shadow-lit dungeon (batched mesh groups) → scene_target ===
  for group in self.dungeon_mesh_groups {
    // Tint lighting with object color
    let col = group.color
    let tinted_lighting = @light3d.LightingEnvironment::new(
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
    let dst_region = @gfx.new_dst_region(
      0, 0, ctx.screen_w, ctx.screen_h, group.mesh.indices.length(),
    )
    let cmd = @shadow3d.new_shadow_lit_mesh_draw_command(
      rt,
      self.shadow_lit_shader,
      dst_region,
      0,
      0,
      0,
      @gfx.blend_mode_from_int(0),
      group.mesh,
      identity,
      view_projection,
      tinted_lighting,
      light_vp,
      shadow_config,
      self.shadow_map.id,
      self.shadow_map.id,
    )
    cmds.push(cmd)
  }
  // Compute visible region for occlusion culling
  let vis_region = compute_visible_region(
    self.dungeon.rooms, self.player.x, self.player.y,
    self.dungeon.grid.width, self.dungeon.grid.height,
  )
  // === Pass 3: Entities (items/projectiles) → scene_target ===
  let entity_graph = build_entity_graph(self, vis_region)
  let entity_cmds = @scene3d.render_scene3d_graph_gpu(
    entity_graph,
    camera,
    lighting=self.lighting,
    rt,
    self.shader3d,
    ctx.screen_w,
    ctx.screen_h,
  )
  for cmd in entity_cmds {
    cmds.push(cmd)
  }
  // === Pass 4: Skinned enemies → scene_target ===
  let enemy_skinning = self.enemy_models.compute_skinning()
  let skinned_objects : Array[@scene3d.Object3D] = []
  for enemy in self.enemies {
    if enemy.alive && is_entity_visible(vis_region, enemy.x, enemy.y) {
      let ex = enemy.x / tile_size
      let ez = enemy.y / tile_size
      let ey = get_tile_height(self.dungeon, enemy.x, enemy.y)
      let color = if enemy.damage_timer > 0 {
        color_player_hurt
      } else {
        match enemy.kind {
          k if k == kind_fast => color_enemy_fast
          k if k == kind_tank => color_enemy_tank
          k if k == kind_ranged => color_enemy_ranged
          k if k == kind_boss => color_enemy_boss
          _ => color_enemy_basic
        }
      }
      let mesh_data = self.enemy_models.get_mesh_data(enemy.kind)
      // Face toward player
      let dx = self.player.x - enemy.x
      let dy = self.player.y - enemy.y
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
  // Render skinned player character → scene_target
  let px = self.player.x / tile_size
  let pz = self.player.y / tile_size
  let py = get_tile_height(self.dungeon, self.player.x, self.player.y)
  let player_color = if self.player.dash_timer > 0 {
    color_player_dash
  } else if self.player.damage_timer > 0 {
    color_player_hurt
  } else {
    color_player
  }
  let skinning_matrices = self.character.compute_skinning()
  // Rotate character to face movement direction
  let facing_rot = @math3d.Quaternion::from_axis_angle(
    @math3d.Vec3::unit_y(),
    -self.player.facing_angle + @math.PI / 2.0,
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
  // === Pass 6: Particles → scene_target (additive blend, feeds into Bloom) ===
  let particle_cmds = self.particle_manager.draw(
    rt, camera, ctx.screen_w, ctx.screen_h, self.frame_count,
  )
  for cmd in particle_cmds {
    cmds.push(cmd)
  }
  // === PostFX chain: scene_target → bloom → tonemap → FXAA → ctx.dst ===
  // Bloom: scene_target → post_target (via bloom_a/bloom_b ping-pong)
  let bloom_cmds = @postfx.bloom_commands(
    self.post_target,
    self.scene_target.id,
    self.bloom_a,
    self.bloom_b,
    self.bloom_threshold_sh,
    self.bloom_hblur_sh,
    self.bloom_vblur_sh,
    self.bloom_composite_sh,
    0.6, // threshold (lower = more bloom on bright surfaces)
    1.5, // intensity
    screen_w,
    screen_h,
  )
  for cmd in bloom_cmds {
    cmds.push(cmd)
  }
  // SSAO: post_target + camera_depth → ssao_target
  let ssao_cmd = @postfx.new_ssao_command(
    self.ssao_target,
    self.ssao_sh,
    self.post_target.id,
    self.camera_depth_target.id,
    8.0,  // radius
    0.02, // bias
    0.6,  // intensity
    screen_w,
    screen_h,
  )
  cmds.push(ssao_cmd)
  // Tonemap: ssao_target → scene_target (reuse as intermediate)
  let tonemap_cmd = @postfx.new_tonemap_command(
    self.scene_target, self.tonemap_sh, self.ssao_target.id, 1.0,
  )
  cmds.push(tonemap_cmd)
  // FXAA: scene_target → ctx.dst
  let fxaa_cmd = @postfx.new_fxaa_command(
    ctx.dst, self.fxaa_sh, self.scene_target.id, screen_w, screen_h,
  )
  cmds.push(fxaa_cmd)
  // Render 2D HUD overlay (after postfx, directly to ctx.dst)
  let hud_cmds = self.render_hud_cmds(ctx.dst, ctx.shader)
  for cmd in hud_cmds {
    cmds.push(cmd)
  }
  // RPG UI overlay (inventory/skill tree)
  if self.ui_mode != ui_mode_none {
    let ui_cmds = self.render_rpg_ui_cmds(ctx.dst, ctx.shader)
    for cmd in ui_cmds {
      cmds.push(cmd)
    }
  }
  cmds
}
