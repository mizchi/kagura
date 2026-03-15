///|
struct EntityInstanceScratch {
  item_instances : Array[@scene3d.InstanceData]
  loot_beam_instances : Array[@scene3d.InstanceData]
  enemy_projectile_instances : Array[@scene3d.InstanceData]
  enemy_projectile_outline_instances : Array[@scene3d.InstanceData]
  arrow_instances : Array[@scene3d.InstanceData]
  fireball_instances : Array[@scene3d.InstanceData]
  homing_missile_instances : Array[@scene3d.InstanceData]
  telegraph_instances : Array[@scene3d.InstanceData]
}

///|
fn default_entity_instance_scratch() -> EntityInstanceScratch {
  {
    item_instances: [],
    loot_beam_instances: [],
    enemy_projectile_instances: [],
    enemy_projectile_outline_instances: [],
    arrow_instances: [],
    fireball_instances: [],
    homing_missile_instances: [],
    telegraph_instances: [],
  }
}

///|
fn is_tile_visible(region : VisibleRegion, col : Int, row : Int) -> Bool {
  col >= region.min_col &&
  col <= region.max_col &&
  row >= region.min_row &&
  row <= region.max_row
}

///|
fn height_at_tile(dungeon : @game.DungeonData, col : Int, row : Int) -> Double {
  dungeon.height_map[row * dungeon.grid.width + col]
}

///|
fn GameState::rebuild_entity_instance_scratch(
  self : GameState,
  region : VisibleRegion,
) -> Unit {
  self.entity_instance_scratch.item_instances.clear()
  self.entity_instance_scratch.loot_beam_instances.clear()
  self.entity_instance_scratch.telegraph_instances.clear()
  self.entity_instance_scratch.enemy_projectile_instances.clear()
  self.entity_instance_scratch.enemy_projectile_outline_instances.clear()
  self.entity_instance_scratch.arrow_instances.clear()
  self.entity_instance_scratch.fireball_instances.clear()
  self.entity_instance_scratch.homing_missile_instances.clear()
  let item_bob_offset = 0.1 *
    @math.sin(self.world.frame_count.to_double() * 0.1)
  let grid_w = self.world.dungeon.grid.width
  let grid_h = self.world.dungeon.grid.height
  for item in self.world.items {
    let col = (item.x / tile_size).to_int()
    let row = (item.y / tile_size).to_int()
    if item.alive &&
      col >= 0 &&
      col < grid_w &&
      row >= 0 &&
      row < grid_h &&
      is_tile_visible(region, col, row) {
      let ix = col.to_double()
      let iz = row.to_double()
      let base_y = height_at_tile(self.world.dungeon, col, row)
      let bob = base_y + 0.3 + item_bob_offset
      let color = match item.kind {
        @game.Health => color_item_health
        @game.Equipment(data) => hex_to_vec4(data.rarity.color())
        _ => color_item_score
      }
      self.entity_instance_scratch.item_instances.push(
        @scene3d.InstanceData::new(
          transform=@transform3d.Transform3D::from_position(
            @math3d.Vec3::new(ix, bob, iz),
          ),
          color~,
        ),
      )
      // Loot beam ("茶柱") for equipment drops - height and brightness by rarity
      match item.kind {
        @game.Equipment(data) => {
          let beam_color = match data.rarity {
            @game.Common => @math3d.Vec4::new(0.6, 0.6, 0.5, 1.0)
            @game.Uncommon => @math3d.Vec4::new(0.3, 0.7, 1.0, 1.0)
            @game.Rare => @math3d.Vec4::new(1.0, 0.85, 0.2, 1.0)
            @game.Epic => @math3d.Vec4::new(0.8, 0.3, 1.0, 1.0)
          }
          let beam_scale_y = match data.rarity {
            @game.Common => 0.5
            @game.Uncommon => 0.7
            @game.Rare => 1.0
            @game.Epic => 1.3
          }
          self.entity_instance_scratch.loot_beam_instances.push(
            @scene3d.InstanceData::new(
              transform=@transform3d.Transform3D::from_position(
                @math3d.Vec3::new(ix, base_y, iz),
              ).with_scale(
                @math3d.Vec3::new(1.0, beam_scale_y, 1.0),
              ),
              color=beam_color,
            ),
          )
        }
        _ => ()
      }
    }
  }
  // Telegraph markers: 3D floor discs that grow with cast progress
  for marker in self.world.telegraph_markers {
    let mx = marker.x / tile_size
    let mz = marker.y / tile_size
    let my = height_at_tile(
      self.world.dungeon,
      (marker.x / tile_size).to_int(),
      (marker.y / tile_size).to_int(),
    ) +
      0.02 // just above floor
    let progress = marker.progress()
    // Scale grows from 30% to 100% of radius
    let scale = marker.radius / tile_size * (0.3 + progress * 0.7)
    // Color: orange → red as progress increases
    let r = 0.8 + progress * 0.2
    let g = 0.3 * (1.0 - progress)
    let b = 0.05
    let a = 0.3 + progress * 0.4
    self.entity_instance_scratch.telegraph_instances.push(
      @scene3d.InstanceData::new(
        transform=@transform3d.Transform3D::from_position(
          @math3d.Vec3::new(mx, my, mz),
        ).with_scale(@math3d.Vec3::new(scale, 1.0, scale)),
        color=@math3d.Vec4::new(r, g, b, a),
      ),
    )
  }
  for proj in self.world.projectiles {
    let col = (proj.x / tile_size).to_int()
    let row = (proj.y / tile_size).to_int()
    if proj.alive &&
      col >= 0 &&
      col < grid_w &&
      row >= 0 &&
      row < grid_h &&
      is_tile_visible(region, col, row) {
      let prx = proj.x / tile_size
      let prz = proj.y / tile_size
      let base_y = height_at_tile(self.world.dungeon, col, row)
      if proj.is_player {
        match proj.kind {
          @game.Arrow => {
            let angle = @math.atan2(proj.vy, proj.vx)
            let rot = @math3d.Quaternion::from_axis_angle(
              @math3d.Vec3::unit_y(),
              -angle,
            )
            self.entity_instance_scratch.arrow_instances.push(
              @scene3d.InstanceData::new(
                transform=@transform3d.Transform3D::from_position_rotation(
                  @math3d.Vec3::new(prx, base_y + 0.3, prz),
                  rot,
                ),
                color=color_arrow,
              ),
            )
          }
          @game.Fireball(_) =>
            self.entity_instance_scratch.fireball_instances.push(
              @scene3d.InstanceData::new(
                transform=@transform3d.Transform3D::from_position(
                  @math3d.Vec3::new(prx, base_y + 0.34, prz),
                ).with_scale(@math3d.Vec3::new(1.05, 1.05, 1.05)),
                color=color_fireball,
              ),
            )
          @game.HomingMissile => {
            let arc_progress = @cmp.minimum(
              1.0,
              proj.age.to_double() / @game.homing_missile_arc_frames.to_double(),
            )
            let arc_height = @math.sin(arc_progress * @math.PI) * 0.82
            self.entity_instance_scratch.homing_missile_instances.push(
              @scene3d.InstanceData::new(
                transform=@transform3d.Transform3D::from_position_rotation(
                  @math3d.Vec3::new(prx, base_y + 0.24 + arc_height, prz),
                  @math3d.Quaternion::from_axis_angle(
                    @math3d.Vec3::unit_y(),
                    -@math.atan2(proj.vy, proj.vx),
                  ),
                ).with_scale(@math3d.Vec3::new(0.95, 0.95, 1.35)),
                color=@math3d.Vec4::new(0.2, 0.7, 1.0, 1.0), // cyan homing missile
              ),
            )
          }
          @game.EnemyBolt => ()
        }
      } else {
        // White outline (larger sphere behind)
        self.entity_instance_scratch.enemy_projectile_outline_instances.push(
          @scene3d.InstanceData::new(
            transform=@transform3d.Transform3D::from_position(
              @math3d.Vec3::new(prx, base_y + 0.3, prz),
            ).with_scale(@math3d.Vec3::new(1.6, 1.6, 1.6)),
            color=color_projectile_outline,
          ),
        )
        // Red core (normal size)
        self.entity_instance_scratch.enemy_projectile_instances.push(
          @scene3d.InstanceData::new(
            transform=@transform3d.Transform3D::from_position(
              @math3d.Vec3::new(prx, base_y + 0.3, prz),
            ).with_scale(@math3d.Vec3::new(1.3, 1.3, 1.3)),
            color=color_projectile,
          ),
        )
      }
    }
  }
}

///|
fn push_entity_instances_if_any(
  mesh : @mesh3d.Mesh3D,
  instances : Array[@scene3d.InstanceData],
  view_projection : @math3d.Mat4,
  lighting : @light3d.LightingEnvironment,
  dst : @gfx.ImageHandle,
  shader3d : @gfx.ShaderHandle,
  shader3d_instanced : @gfx.ShaderHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  if instances.length() == 0 {
    return
  }
  if instances.length() == 1 {
    let inst = instances[0]
    let dst_region = @gfx.new_dst_region(
      0,
      0,
      screen_w,
      screen_h,
      mesh.indices.length(),
    )
    cmds.push(
      @draw3d.new_lit_mesh_draw_command(
        dst,
        shader3d,
        dst_region,
        0,
        0,
        0,
        @gfx.blend_mode_from_int(1),
        mesh,
        inst.transform.to_mat4(),
        view_projection,
        lighting,
        [],
      ),
    )
    return
  }
  cmds.push(
    @scene3d.render_instanced_gpu_with_view_projection(
      mesh, instances, view_projection, lighting, dst, shader3d_instanced, screen_w,
      screen_h,
    ),
  )
}

///|
fn push_item_instance_cmds(
  state : GameState,
  view_projection : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let instances = state.entity_instance_scratch.item_instances
  if instances.length() == 0 {
    return
  }
  if instances.length() <= 2 {
    let dst_region = @gfx.new_dst_region(
      0,
      0,
      screen_w,
      screen_h,
      state.meshes.item.indices.length(),
    )
    for inst in instances {
      cmds.push(
        @draw3d.new_lit_colored_mesh_draw_command(
          dst,
          state.shader3d_colored,
          dst_region,
          0,
          0,
          0,
          @gfx.blend_mode_from_int(1),
          state.meshes.item,
          inst.transform.to_mat4(),
          view_projection,
          state.lighting,
          inst.color,
          [],
        ),
      )
    }
    return
  }
  push_entity_instances_if_any(
    state.meshes.item,
    instances,
    view_projection,
    state.lighting,
    dst,
    state.shader3d,
    state.shader3d_instanced,
    screen_w,
    screen_h,
    cmds,
  )
}

///|
fn push_arrow_instance_cmds(
  state : GameState,
  view_projection : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  push_entity_instances_if_any(
    state.meshes.arrow,
    state.entity_instance_scratch.arrow_instances,
    view_projection,
    state.lighting,
    dst,
    state.shader3d,
    state.shader3d_instanced,
    screen_w,
    screen_h,
    cmds,
  )
}

///|
fn push_fireball_instance_cmds(
  state : GameState,
  view_projection : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let instances = state.entity_instance_scratch.fireball_instances
  if instances.length() == 0 {
    return
  }
  if instances.length() <= 2 {
    let dst_region = @gfx.new_dst_region(
      0,
      0,
      screen_w,
      screen_h,
      state.meshes.projectile.indices.length(),
    )
    for inst in instances {
      cmds.push(
        @draw3d.new_lit_colored_mesh_draw_command(
          dst,
          state.shader3d_colored,
          dst_region,
          0,
          0,
          0,
          @gfx.blend_mode_from_int(1),
          state.meshes.projectile,
          inst.transform.to_mat4(),
          view_projection,
          state.lighting,
          inst.color,
          [],
        ),
      )
    }
    return
  }
  cmds.push(
    @scene3d.render_instanced_gpu_with_view_projection(
      state.meshes.projectile,
      instances,
      view_projection,
      state.lighting,
      dst,
      state.shader3d_instanced,
      screen_w,
      screen_h,
    ),
  )
}

///|
fn push_enemy_projectile_instance_cmds(
  state : GameState,
  view_projection : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  push_entity_instances_if_any(
    state.meshes.projectile,
    state.entity_instance_scratch.enemy_projectile_instances,
    view_projection,
    state.lighting,
    dst,
    state.shader3d,
    state.shader3d_instanced,
    screen_w,
    screen_h,
    cmds,
  )
}

///|
fn push_homing_missile_instance_cmds(
  state : GameState,
  view_projection : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let instances = state.entity_instance_scratch.homing_missile_instances
  if instances.length() == 0 {
    return
  }
  if instances.length() <= 2 {
    let dst_region = @gfx.new_dst_region(
      0,
      0,
      screen_w,
      screen_h,
      state.meshes.projectile.indices.length(),
    )
    for inst in instances {
      cmds.push(
        @draw3d.new_lit_colored_mesh_draw_command(
          dst,
          state.shader3d_colored,
          dst_region,
          0,
          0,
          0,
          @gfx.blend_mode_from_int(1),
          state.meshes.projectile,
          inst.transform.to_mat4(),
          view_projection,
          state.lighting,
          inst.color,
          [],
        ),
      )
    }
    return
  }
  cmds.push(
    @scene3d.render_instanced_gpu_with_view_projection(
      state.meshes.projectile,
      instances,
      view_projection,
      state.lighting,
      dst,
      state.shader3d_instanced,
      screen_w,
      screen_h,
    ),
  )
}

///|
///|
fn push_loot_beam_instance_cmds(
  state : GameState,
  view_projection : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let instances = state.entity_instance_scratch.loot_beam_instances
  if instances.length() == 0 {
    return
  }
  let dst_region = @gfx.new_dst_region(
    0,
    0,
    screen_w,
    screen_h,
    state.meshes.loot_beam.indices.length(),
  )
  for inst in instances {
    cmds.push(
      @draw3d.new_lit_colored_mesh_draw_command(
        dst,
        state.shader3d_colored,
        dst_region,
        0,
        0,
        0,
        @gfx.blend_mode_from_int(1), // additive blend
        state.meshes.loot_beam,
        inst.transform.to_mat4(),
        view_projection,
        state.lighting,
        inst.color,
        [],
      ),
    )
  }
}

///|
fn push_entity_instanced_cmds(
  state : GameState,
  region : VisibleRegion,
  camera : @camera3d.Camera3D,
  dst : @gfx.ImageHandle,
  screen_w : Int,
  screen_h : Int,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  state.rebuild_entity_instance_scratch(region)
  let view_projection = camera.view_projection_matrix()
  // Telegraph ground discs (rendered first, below everything)
  let telegraph_instances = state.entity_instance_scratch.telegraph_instances
  if telegraph_instances.length() > 0 {
    let dst_region = @gfx.new_dst_region(
      0,
      0,
      screen_w,
      screen_h,
      state.meshes.telegraph_disc.indices.length(),
    )
    for inst in telegraph_instances {
      cmds.push(
        @draw3d.new_lit_colored_mesh_draw_command(
          dst,
          state.shader3d_colored,
          dst_region,
          0,
          0,
          0,
          @gfx.blend_mode_from_int(1), // alpha blend
          state.meshes.telegraph_disc,
          inst.transform.to_mat4(),
          view_projection,
          state.lighting,
          inst.color,
          [],
        ),
      )
    }
  }
  push_loot_beam_instance_cmds(
    state, view_projection, dst, screen_w, screen_h, cmds,
  )
  push_item_instance_cmds(state, view_projection, dst, screen_w, screen_h, cmds)
  push_arrow_instance_cmds(
    state, view_projection, dst, screen_w, screen_h, cmds,
  )
  push_fireball_instance_cmds(
    state, view_projection, dst, screen_w, screen_h, cmds,
  )
  push_homing_missile_instance_cmds(
    state, view_projection, dst, screen_w, screen_h, cmds,
  )
  // Enemy projectile outlines first (white, behind red core)
  push_entity_instances_if_any(
    state.meshes.projectile,
    state.entity_instance_scratch.enemy_projectile_outline_instances,
    view_projection,
    state.lighting,
    dst,
    state.shader3d,
    state.shader3d_instanced,
    screen_w,
    screen_h,
    cmds,
  )
  push_enemy_projectile_instance_cmds(
    state, view_projection, dst, screen_w, screen_h, cmds,
  )
}
