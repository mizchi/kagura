///|
fn build_dungeon_tinted_lighting_cache(
  lighting : @light3d.LightingEnvironment,
) -> Array[@light3d.LightingEnvironment] {
  [
    tint_lighting(lighting, color_floor),
    tint_lighting(lighting, color_corridor),
    tint_lighting(lighting, color_door),
    tint_lighting(lighting, color_wall),
    tint_lighting(lighting, color_pillar),
  ]
}

///|
struct MeshAccumulator {
  vertices : Array[Double]
  indices : Array[Int]
}

///|
fn new_mesh_accumulator() -> MeshAccumulator {
  { vertices: [], indices: [] }
}

///|
fn same_dungeon_group_color(left : @math3d.Vec4, right : @math3d.Vec4) -> Bool {
  left.x == right.x &&
  left.y == right.y &&
  left.z == right.z &&
  left.w == right.w
}

///|
fn dungeon_surface_index(kind : DungeonSurfaceKind) -> Int {
  match kind {
    Floor => 0
    Corridor => 1
    Door => 2
    Wall => 3
    Pillar => 4
  }
}

///|
fn build_visible_dungeon_mesh_cache(
  visible_chunks : Array[DungeonChunk],
) -> VisibleDungeonMeshCache {
  let floor_acc = new_mesh_accumulator()
  let corridor_acc = new_mesh_accumulator()
  let door_acc = new_mesh_accumulator()
  let wall_acc = new_mesh_accumulator()
  let pillar_acc = new_mesh_accumulator()
  let all_acc = new_mesh_accumulator()
  let accumulators = [floor_acc, corridor_acc, door_acc, wall_acc, pillar_acc]
  for chunk in visible_chunks {
    if chunk.all_mesh.indices.length() > 0 {
      merge_mesh_at(
        all_acc.vertices,
        all_acc.indices,
        chunk.all_mesh,
        0.0,
        0.0,
        0.0,
      )
    }
    for group in chunk.groups {
      let idx = dungeon_surface_index(group.surface_kind)
      let acc = accumulators[idx]
      merge_mesh_at(acc.vertices, acc.indices, group.mesh, 0.0, 0.0, 0.0)
    }
  }
  let groups : Array[DungeonMeshGroup] = []
  fn push_group(
    acc : MeshAccumulator,
    color : @math3d.Vec4,
    surface_kind : DungeonSurfaceKind,
    groups : Array[DungeonMeshGroup],
  ) -> Unit {
    if acc.indices.length() == 0 {
      return
    }
    groups.push({
      mesh: @mesh3d.Mesh3D::new(acc.vertices, acc.indices),
      color,
      surface_kind,
      dst_region: @gfx.new_dst_region(
        0,
        0,
        screen_w,
        screen_h,
        acc.indices.length(),
      ),
    })
  }
  push_group(floor_acc, color_floor, Floor, groups)
  push_group(corridor_acc, color_corridor, Corridor, groups)
  push_group(door_acc, color_door, Door, groups)
  push_group(wall_acc, color_wall, Wall, groups)
  push_group(pillar_acc, color_pillar, Pillar, groups)
  { groups, all_mesh: @mesh3d.Mesh3D::new(all_acc.vertices, all_acc.indices) }
}

///|
fn GameState::dungeon_diffuse_image_id(
  self : GameState,
  surface_kind : DungeonSurfaceKind,
) -> Int? {
  match surface_kind {
    Floor | Corridor | Door => self.dungeon_floor_texture_image_id
    Wall | Pillar => self.dungeon_wall_texture_image_id
  }
}

///|
fn GameState::push_dungeon_chunk_commands(
  self : GameState,
  visible_groups : Array[DungeonMeshGroup],
  visible_all_mesh : @mesh3d.Mesh3D,
  view_projection : @math3d.Mat4,
  shadow_state : ShadowFrameState?,
  dst : @gfx.ImageHandle,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  let identity = @math3d.Mat4::identity()
  let tinted_cache = self.dungeon_tinted_lighting_cache
  match shadow_state {
    Some(shadow) => {
      if visible_all_mesh.indices.length() > 0 {
        cmds.push(
          @shadow3d.new_shadow_depth_command(
            self.shadow_map,
            self.shadow_depth_shader,
            visible_all_mesh,
            identity,
            shadow.light_vp,
          ),
        )
      }
      for group in visible_groups {
        let tinted = tinted_cache[dungeon_surface_index(group.surface_kind)]
        let blend = @gfx.blend_mode_from_int(0)
        match self.dungeon_diffuse_image_id(group.surface_kind) {
          Some(diffuse_image_id) =>
            cmds.push(
              @shadow3d.new_shadow_lit_mesh_draw_command(
                dst,
                self.shadow_lit_textured_shader,
                group.dst_region,
                0,
                0,
                0,
                blend,
                group.mesh,
                identity,
                view_projection,
                tinted,
                shadow.light_vp,
                shadow.config,
                diffuse_image_id,
                self.shadow_map.id,
              ),
            )
          None =>
            cmds.push(
              @shadow3d.new_shadow_lit_mesh_draw_command(
                dst,
                self.shadow_lit_shader,
                group.dst_region,
                0,
                0,
                0,
                blend,
                group.mesh,
                identity,
                view_projection,
                tinted,
                shadow.light_vp,
                shadow.config,
                self.shadow_map.id,
                self.shadow_map.id,
              ),
            )
        }
      }
    }
    None =>
      for group in visible_groups {
        let tinted = tinted_cache[dungeon_surface_index(group.surface_kind)]
        let blend = @gfx.blend_mode_from_int(0)
        match self.dungeon_diffuse_image_id(group.surface_kind) {
          Some(diffuse_image_id) =>
            cmds.push(
              @draw3d.new_lit_mesh_draw_command(
                dst,
                self.shader3d_textured,
                group.dst_region,
                0,
                0,
                0,
                blend,
                group.mesh,
                identity,
                view_projection,
                tinted,
                [diffuse_image_id],
              ),
            )
          None =>
            cmds.push(
              @draw3d.new_lit_mesh_draw_command(
                dst,
                self.shader3d,
                group.dst_region,
                0,
                0,
                0,
                blend,
                group.mesh,
                identity,
                view_projection,
                tinted,
                [],
              ),
            )
        }
      }
  }
}

///|
fn GameState::invalidate_visible_chunk_cache(self : GameState) -> Unit {
  self.visible_chunks_cache.clear()
  self.visible_chunk_cache_player_tile_x = -1
  self.visible_chunk_cache_player_tile_z = -1
  self.visible_dungeon_mesh_cache = {
    groups: [],
    all_mesh: @mesh3d.Mesh3D::new([], []),
  }
  self.visible_dungeon_mesh_cache_player_tile_x = -1
  self.visible_dungeon_mesh_cache_player_tile_z = -1
}

///|
fn GameState::get_visible_chunks_for_player(
  self : GameState,
) -> Array[DungeonChunk] {
  let player_tile_x = (self.world.player.x / tile_size).to_int()
  let player_tile_z = (self.world.player.y / tile_size).to_int()
  if self.visible_chunks_cache.is_empty() ||
    self.visible_chunk_cache_player_tile_x != player_tile_x ||
    self.visible_chunk_cache_player_tile_z != player_tile_z {
    self.visible_chunks_cache = get_visible_chunks(
      self.dungeon_chunks,
      player_tile_x,
      player_tile_z,
      1,
    )
    self.visible_chunk_cache_player_tile_x = player_tile_x
    self.visible_chunk_cache_player_tile_z = player_tile_z
    self.visible_chunk_cache_builds = self.visible_chunk_cache_builds + 1
  }
  self.visible_chunks_cache
}

///|
fn GameState::get_visible_dungeon_mesh_cache_for_player(
  self : GameState,
) -> VisibleDungeonMeshCache {
  let player_tile_x = (self.world.player.x / tile_size).to_int()
  let player_tile_z = (self.world.player.y / tile_size).to_int()
  if self.visible_dungeon_mesh_cache.groups.is_empty() ||
    self.visible_dungeon_mesh_cache_player_tile_x != player_tile_x ||
    self.visible_dungeon_mesh_cache_player_tile_z != player_tile_z {
    let visible_chunks = self.get_visible_chunks_for_player()
    self.visible_dungeon_mesh_cache = build_visible_dungeon_mesh_cache(
      visible_chunks,
    )
    self.visible_dungeon_mesh_cache_player_tile_x = player_tile_x
    self.visible_dungeon_mesh_cache_player_tile_z = player_tile_z
    self.visible_dungeon_mesh_cache_builds = self.visible_dungeon_mesh_cache_builds +
      1
  }
  self.visible_dungeon_mesh_cache
}
