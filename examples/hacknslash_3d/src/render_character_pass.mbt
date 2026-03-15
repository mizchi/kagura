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
) -> @math3d.Mat4 {
  let len_sq = dx * dx + dy * dy
  let (c, s) = if len_sq <= 1.0e-9 {
    (0.0, 1.0)
  } else {
    let inv_len = 1.0 / len_sq.sqrt()
    (dy * inv_len, dx * inv_len)
  }
  @math3d.Mat4::from_cols(
    @math3d.Vec4::new(c, 0.0, -s, 0.0),
    @math3d.Vec4::new(0.0, 1.0, 0.0, 0.0),
    @math3d.Vec4::new(s, 0.0, c, 0.0),
    @math3d.Vec4::new(ex, ey, ez, 1.0),
  )
}

///|
fn GameState::rebuild_enemy_render_buckets(
  self : GameState,
  vis_region : VisibleRegion,
) -> Unit {
  let buckets = self.enemy_render_buckets
  clear_enemy_render_buckets(buckets)
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
        color_player_hurt
      } else {
        match enemy.kind {
          @game.Fast | @game.Teleporter => color_enemy_fast
          @game.Exploder => @math3d.Vec4::new(1.0, 0.4, 0.1, 1.0) // orange
          @game.Tank | @game.Berserker => color_enemy_tank
          @game.Ranged | @game.Summoner => color_enemy_ranged
          @game.Swarm => @math3d.Vec4::new(0.5, 0.5, 0.3, 1.0) // pale
          @game.Boss => color_enemy_boss
          @game.Basic => color_enemy_basic
        }
      }
      let dx = self.world.player.x - enemy.x
      let dy = self.world.player.y - enemy.y
      let model = enemy_facing_model_matrix(ex, ey, ez, dx, dy)
      match enemy.kind {
        @game.Fast | @game.Exploder | @game.Teleporter => {
          buckets.fast_matrices.push(model)
          buckets.fast_colors.push(color)
        }
        @game.Tank | @game.Berserker => {
          buckets.tank_matrices.push(model)
          buckets.tank_colors.push(color)
        }
        @game.Ranged | @game.Summoner => {
          buckets.ranged_matrices.push(model)
          buckets.ranged_colors.push(color)
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
) -> Unit {
  fn push_enemy_group(
    kind : @game.EnemyKind,
    mesh_data : EnemyMeshData,
    matrices : Array[@math3d.Mat4],
    colors : Array[@math3d.Vec4],
  ) -> Unit {
    match @scene3d.uniform_instance_color(colors) {
      Some(_) => {
        let skinned_mesh = self.enemy_models.get_skinned_mesh(kind)
        @scene3d.push_instanced_mesh_gpu_commands_with_color_optimization_and_view_projection(
          skinned_mesh,
          matrices,
          colors,
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
      }
      None =>
        @scene3d.push_skinned_mesh_gpu_commands_with_color_optimization_and_view_projection(
          mesh_data.bind_mesh,
          matrices,
          colors,
          mesh_data.packed_vertex_data,
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
  push_enemy_group(
    @game.Basic,
    self.enemy_models.basic,
    buckets.basic_matrices,
    buckets.basic_colors,
  )
  push_enemy_group(
    @game.Fast,
    self.enemy_models.fast,
    buckets.fast_matrices,
    buckets.fast_colors,
  )
  push_enemy_group(
    @game.Tank,
    self.enemy_models.tank,
    buckets.tank_matrices,
    buckets.tank_colors,
  )
  push_enemy_group(
    @game.Ranged,
    self.enemy_models.ranged,
    buckets.ranged_matrices,
    buckets.ranged_colors,
  )
  push_enemy_group(
    @game.Boss,
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
  @scene3d.push_single_skinned_mesh_gpu_command_with_view_projection(
    self.character.bind_mesh,
    @transform3d.Transform3D::from_components(
      @math3d.Vec3::new(px, py, pz),
      facing_rot,
      @math3d.Vec3::one(),
    ),
    player_color,
    self.character.packed_vertex_data,
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
