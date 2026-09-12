///|
struct EnemyRenderBuckets {
  basic_matrices : Array[@math3d.Mat4]
  basic_colors : Array[@math3d.Vec4]
  fast_matrices : Array[@math3d.Mat4]
  fast_colors : Array[@math3d.Vec4]
  tank_matrices : Array[@math3d.Mat4]
  tank_colors : Array[@math3d.Vec4]
  ranged_matrices : Array[@math3d.Mat4]
  ranged_colors : Array[@math3d.Vec4]
  caster_matrices : Array[@math3d.Mat4]
  caster_colors : Array[@math3d.Vec4]
  boss_matrices : Array[@math3d.Mat4]
  boss_colors : Array[@math3d.Vec4]
}

///|
fn default_enemy_render_buckets() -> EnemyRenderBuckets {
  {
    basic_matrices: [],
    basic_colors: [],
    fast_matrices: [],
    fast_colors: [],
    tank_matrices: [],
    tank_colors: [],
    ranged_matrices: [],
    ranged_colors: [],
    caster_matrices: [],
    caster_colors: [],
    boss_matrices: [],
    boss_colors: [],
  }
}

///|
fn clear_enemy_render_buckets(buckets : EnemyRenderBuckets) -> Unit {
  buckets.basic_matrices.clear()
  buckets.basic_colors.clear()
  buckets.fast_matrices.clear()
  buckets.fast_colors.clear()
  buckets.tank_matrices.clear()
  buckets.tank_colors.clear()
  buckets.ranged_matrices.clear()
  buckets.ranged_colors.clear()
  buckets.caster_matrices.clear()
  buckets.caster_colors.clear()
  buckets.boss_matrices.clear()
  buckets.boss_colors.clear()
}

///|
fn enemy_facing_model_matrix(
  ex : Double,
  ey : Double,
  ez : Double,
  dx : Double,
  dy : Double,
  scale? : Double = 1.0,
) -> @math3d.Mat4 {
  let len_sq = dx * dx + dy * dy
  let (c, s) = if len_sq <= 1.0e-9 {
    (0.0, 1.0)
  } else {
    let inv_len = 1.0 / len_sq.sqrt()
    (dy * inv_len, dx * inv_len)
  }
  @math3d.Mat4::from_cols(
    @math3d.Vec4::new(c * scale, 0.0, -s * scale, 0.0),
    @math3d.Vec4::new(0.0, scale, 0.0, 0.0),
    @math3d.Vec4::new(s * scale, 0.0, c * scale, 0.0),
    @math3d.Vec4::new(ex, ey, ez, 1.0),
  )
}

///|
fn GameState::rebuild_enemy_render_buckets(
  self : GameState,
  vis_region : VisibleRegion,
) -> Unit {
  clear_enemy_render_buckets(self.enemy_render_buckets)
  for key in self.enemy_models.active_attack_keys {
    clear_enemy_render_buckets(self.enemy_models.attack_buckets[key])
  }
  self.enemy_models.active_attack_keys.clear()
  let dungeon = self.world.dungeon
  let dungeon_width = dungeon.grid.width
  let dungeon_height = dungeon.grid.height
  for enemy in self.world.enemies {
    if enemy.alive && is_entity_visible(vis_region, enemy.x, enemy.y) {
      let ex = enemy.x / tile_size
      let ez = enemy.y / tile_size
      let col = ex.to_int()
      let row = ez.to_int()
      let ey = if col < 0 ||
        col >= dungeon_width ||
        row < 0 ||
        row >= dungeon_height {
        0.0
      } else {
        dungeon.height_map[row * dungeon_width + col]
      }
      let color = if enemy.damage_timer > 0 {
        @math3d.Vec4::new(1.8, 1.35, 1.35, 1.0)
      } else {
        @math3d.Vec4::new(1.0, 1.0, 1.0, 1.0)
      }
      let clip_index = enemy_attack_clip_index(enemy.attack_motion)
      let buckets = if clip_index < 0 {
        self.enemy_render_buckets
      } else {
        let clip = self.enemy_models.attack_clips[clip_index]
        let key = clip_index * enemy_attack_pose_stride +
          clip.frame_index(enemy.attack_phase())
        let result = match self.enemy_models.attack_buckets.get(key) {
          Some(existing) => existing
          None => {
            let fresh = default_enemy_render_buckets()
            self.enemy_models.attack_buckets[key] = fresh
            fresh
          }
        }
        if result.basic_matrices.is_empty() &&
          result.fast_matrices.is_empty() &&
          result.tank_matrices.is_empty() &&
          result.ranged_matrices.is_empty() &&
          result.caster_matrices.is_empty() &&
          result.boss_matrices.is_empty() {
          self.enemy_models.active_attack_keys.push(key)
        }
        result
      }
      let dx = (if clip_index < 0 {
          self.world.player.x
        } else {
          enemy.attack_target_x
        }) -
        enemy.x
      let dy = (if clip_index < 0 {
          self.world.player.y
        } else {
          enemy.attack_target_y
        }) -
        enemy.y
      // The new models are authored at hunter scale, with feet at ground height.
      let scale = match enemy.kind {
        @game.Tank | @game.Berserker => 1.18
        @game.Boss => 1.65
        @game.Swarm => 0.78
        _ => 1.0
      }
      let model = enemy_facing_model_matrix(ex, ey, ez, dx, dy, scale~)
      match enemy.kind {
        @game.Fast | @game.Exploder | @game.Teleporter => {
          buckets.fast_matrices.push(model)
          buckets.fast_colors.push(color)
        }
        @game.Tank | @game.Berserker => {
          buckets.tank_matrices.push(model)
          buckets.tank_colors.push(color)
        }
        @game.Ranged => {
          buckets.ranged_matrices.push(model)
          buckets.ranged_colors.push(color)
        }
        @game.Summoner | @game.Caster => {
          buckets.caster_matrices.push(model)
          buckets.caster_colors.push(color)
        }
        @game.Boss => {
          buckets.boss_matrices.push(model)
          buckets.boss_colors.push(color)
        }
        @game.Basic | @game.Swarm => {
          buckets.basic_matrices.push(model)
          buckets.basic_colors.push(color)
        }
      }
    }
  }
}

///|
fn GameState::push_character_commands(
  self : GameState,
  vis_region : VisibleRegion,
  camera : @camera3d.Camera3D,
  dst : @gfx.ImageHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let view_projection = camera.view_projection_matrix()
  self.push_enemy_character_commands_with_view_projection(
    vis_region, view_projection, dst, screen_w, screen_h, cmds,
  )
  self.push_player_character_commands_with_view_projection(
    view_projection, dst, screen_w, screen_h, cmds,
  )
}

///|
fn GameState::push_enemy_character_commands(
  self : GameState,
  vis_region : VisibleRegion,
  camera : @camera3d.Camera3D,
  dst : @gfx.ImageHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  self.push_enemy_character_commands_with_view_projection(
    vis_region,
    camera.view_projection_matrix(),
    dst,
    screen_w,
    screen_h,
    cmds,
  )
}

///|
fn GameState::push_enemy_character_commands_with_view_projection(
  self : GameState,
  vis_region : VisibleRegion,
  view_projection : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let enemy_skinning = self.enemy_models.compute_skinning()
  self.rebuild_enemy_render_buckets(vis_region)
  self.push_enemy_render_bucket_groups_with_view_projection(
    self.enemy_render_buckets,
    enemy_skinning,
    view_projection,
    dst,
    screen_w,
    screen_h,
    cmds,
  )
  for key in self.enemy_models.active_attack_keys {
    let buckets = self.enemy_models.attack_buckets[key]
    let clip = self.enemy_models.attack_clips[key / enemy_attack_pose_stride]
    self.push_enemy_render_bucket_groups_with_view_projection(
      buckets,
      clip.matrices(key % enemy_attack_pose_stride),
      view_projection,
      dst,
      screen_w,
      screen_h,
      cmds,
      gpu_pose=true,
    )
  }
}

///|
fn GameState::push_enemy_render_bucket_groups_with_view_projection(
  self : GameState,
  buckets : EnemyRenderBuckets,
  enemy_skinning : Array[@math3d.Mat4],
  view_projection : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
  gpu_pose? : Bool = false,
) -> Unit {
  fn push_enemy_group(
    mesh_data : EnemyMeshData,
    matrices : Array[@math3d.Mat4],
    colors : Array[@math3d.Vec4],
  ) -> Unit {
    if matrices.is_empty() {
      return
    }
    // Skin once per material/pose, then instance the entire crowd in one draw.
    for part in mesh_data.parts {
      let part_colors = colors.map(fn(tint) {
        @math3d.Vec4::new(
          part.color.x * tint.x,
          part.color.y * tint.y,
          part.color.z * tint.z,
          part.color.w,
        )
      })
      match
        (if gpu_pose {
          None
        } else {
          @scene3d.uniform_instance_color(part_colors)
        }) {
        Some(_) =>
          @scene3d.push_instanced_mesh_gpu_commands_with_color_optimization_and_view_projection(
            part.geometry.skinned_mesh(
              self.enemy_models.pose_generation,
              enemy_skinning,
            ),
            matrices,
            part_colors,
            view_projection,
            self.lighting,
            dst,
            self.shader3d_colored,
            self.shader3d_instanced,
            self.shader3d_instanced_monochrome,
            screen_w,
            screen_h,
            cmds,
          )
        None => {
          @web_hooks.register_static_geometry(
            part.geometry.packed_vertex_data,
            part.geometry.bind_mesh.indices,
          )
          @scene3d.push_skinned_mesh_gpu_commands_with_color_optimization_and_view_projection(
            part.geometry.bind_mesh,
            matrices,
            part_colors,
            part.geometry.packed_vertex_data,
            enemy_skinning,
            view_projection,
            self.lighting,
            dst,
            self.shader3d_skinned,
            self.shader3d_skinned_instanced,
            self.shader3d_skinned_instanced_monochrome,
            screen_w,
            screen_h,
            cmds,
          )
        }
      }
    }
  }

  push_enemy_group(
    self.enemy_models.basic,
    buckets.basic_matrices,
    buckets.basic_colors,
  )
  push_enemy_group(
    self.enemy_models.fast,
    buckets.fast_matrices,
    buckets.fast_colors,
  )
  push_enemy_group(
    self.enemy_models.tank,
    buckets.tank_matrices,
    buckets.tank_colors,
  )
  push_enemy_group(
    self.enemy_models.ranged,
    buckets.ranged_matrices,
    buckets.ranged_colors,
  )
  push_enemy_group(
    self.enemy_models.caster,
    buckets.caster_matrices,
    buckets.caster_colors,
  )
  push_enemy_group(
    self.enemy_models.boss,
    buckets.boss_matrices,
    buckets.boss_colors,
  )
}

///|
fn GameState::push_player_character_commands(
  self : GameState,
  camera : @camera3d.Camera3D,
  dst : @gfx.ImageHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  self.push_player_character_commands_with_view_projection(
    camera.view_projection_matrix(),
    dst,
    screen_w,
    screen_h,
    cmds,
  )
}

///|
fn GameState::push_player_character_commands_with_view_projection(
  self : GameState,
  view_projection : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let px = self.world.player.x / tile_size
  let pz = self.world.player.y / tile_size
  let py = @game.get_tile_height(
    self.world.dungeon,
    self.world.player.x,
    self.world.player.y,
  )
  let skinning_matrices = self.character.compute_skinning()
  let facing_rot = @math3d.Quaternion::from_axis_angle(
    @math3d.Vec3::unit_y(),
    -self.world.player.facing_angle + @math.PI / 2.0,
  )
  let transform = @transform3d.Transform3D::from_components(
    @math3d.Vec3::new(px, py, pz),
    facing_rot,
    @math3d.Vec3::one(),
  )
  for part in self.character.parts {
    @web_hooks.register_static_geometry(part.packed, part.mesh.indices)
    let color = if self.world.player.damage_timer > 0 {
      color_player_hurt
    } else {
      part.color
    }
    @scene3d.push_single_skinned_mesh_gpu_command_with_view_projection(
      part.mesh,
      transform,
      color,
      part.packed,
      skinning_matrices,
      view_projection,
      self.lighting,
      dst,
      self.shader3d_skinned,
      screen_w,
      screen_h,
      cmds,
    )
  }
}
