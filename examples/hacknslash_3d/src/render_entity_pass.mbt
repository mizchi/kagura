///|
struct EntityInstanceScratch {
  item_instances : Array[@scene3d.InstanceData]
  enemy_projectile_instances : Array[@scene3d.InstanceData]
  arrow_instances : Array[@scene3d.InstanceData]
  fireball_instances : Array[@scene3d.InstanceData]
}

///|
fn default_entity_instance_scratch() -> EntityInstanceScratch {
  {
    item_instances: [],
    enemy_projectile_instances: [],
    arrow_instances: [],
    fireball_instances: [],
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
  self.entity_instance_scratch.enemy_projectile_instances.clear()
  self.entity_instance_scratch.arrow_instances.clear()
  self.entity_instance_scratch.fireball_instances.clear()
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
    }
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
      let prx = col.to_double()
      let prz = row.to_double()
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
          @game.EnemyBolt => ()
        }
      } else {
        self.entity_instance_scratch.enemy_projectile_instances.push(
          @scene3d.InstanceData::new(
            transform=@transform3d.Transform3D::from_position(
              @math3d.Vec3::new(prx, base_y + 0.3, prz),
            ),
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
  push_item_instance_cmds(state, view_projection, dst, screen_w, screen_h, cmds)
  push_arrow_instance_cmds(
    state, view_projection, dst, screen_w, screen_h, cmds,
  )
  push_fireball_instance_cmds(
    state, view_projection, dst, screen_w, screen_h, cmds,
  )
  push_enemy_projectile_instance_cmds(
    state, view_projection, dst, screen_w, screen_h, cmds,
  )
}
