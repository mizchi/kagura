// Render work is incremental; the game owns area state and activation rules.

///|
struct RegionMeshCache {
  region : Int
  seed : Int
  chunks : Array[DungeonChunk]
  total : Int
  mut last_used : Int
}

///|
fn RegionMeshCache::ready(self : RegionMeshCache) -> Bool {
  self.chunks.length() == self.total
}

///|
fn world_region_palette(region : Int) -> Array[@math3d.Vec4] {
  let colors = hunting_palette.copy()
  let overrides = match region {
    1 =>
      [
        (0, 0x403126),
        (1, 0x4C392B),
        (2, 0x63503B),
        (4, 0x5A4A2D),
        (5, 0x786243),
        (6, 0x736258),
        (10, 0x8B7751),
        (12, 0x2A241E),
      ]
    2 =>
      [
        (0, 0x1B3030),
        (1, 0x223B3D),
        (2, 0x475253),
        (4, 0x20404A),
        (5, 0x467078),
        (6, 0x6D7E81),
        (10, 0x5C8B82),
        (12, 0x122A2A),
      ]
    3 =>
      [
        (0, 0x302C35),
        (1, 0x37333C),
        (2, 0x5F5860),
        (4, 0x3D3B49),
        (5, 0x626274),
        (6, 0x878188),
        (10, 0x747065),
        (12, 0x211E2A),
      ]
    _ => []
  }
  for (index, hex) in overrides {
    colors[index] = hex_to_vec4(hex)
  }
  colors
}

///|
fn GameState::region_mesh_ready(self : GameState, id : Int) -> Bool {
  if id < 0 || id >= self.region_meshes.length() {
    return false
  }
  match self.region_meshes[id] {
    Some(cache) => cache.ready()
    None => false
  }
}

///|
fn GameState::update_region_streaming(self : GameState) -> Bool {
  guard self.world.atlas is Some(atlas) else { return false }
  if self.motion_preview ||
    self.world.authored_scene is Some(_) ||
    self.world.mode != @game.Playing {
    return false
  }
  let current = atlas.current
  let total = (@game.map_cols + chunk_size - 1) /
    chunk_size *
    ((@game.map_rows + chunk_size - 1) / chunk_size)
  let current_cache = self.region_meshes[current]
  if current_cache is None || current_cache.unwrap().seed != self.world.seed {
    self.region_meshes[current] = Some({
      region: current,
      seed: self.world.seed,
      chunks: self.dungeon_chunks,
      total,
      last_used: self.region_mesh_stamp,
    })
  }
  if atlas.travel_target is None &&
    (self.paused || self.world.ui_mode != @game.UIMode::None) {
    return false
  }
  if !self.paused && self.world.activate_nearby_waypoint() {
    self.save_game()
  }
  let requests = self.world.preload_regions()
  // At most three area meshes (active + two neighbors). Eviction never discards simulation progress.
  for id in requests {
    if !self.world.prepare_region(id) {
      continue
    }
    self.region_mesh_stamp += 1
    if self.region_meshes[id] is None {
      let resident = self.region_meshes
        .filter(entry => entry is Some(_))
        .length()
      if resident >= 3 {
        let mut oldest = -1
        let mut stamp = self.region_mesh_stamp + 1
        for i, entry in self.region_meshes {
          if i != current && !requests.contains(i) {
            if entry is Some(cache) {
              if cache.last_used < stamp {
                oldest = i
                stamp = cache.last_used
              }
            }
          }
        }
        if oldest >= 0 {
          self.region_meshes[oldest] = None
        }
      }
      let region = atlas.regions[id].unwrap()
      self.region_meshes[id] = Some({
        region: id,
        seed: region.seed,
        chunks: [],
        total,
        last_used: self.region_mesh_stamp,
      })
    }
    let cache = self.region_meshes[id].unwrap()
    cache.last_used = self.region_mesh_stamp
    if cache.ready() {
      continue
    }
    let region = atlas.regions[id].unwrap()
    let columns = (@game.map_cols + chunk_size - 1) / chunk_size
    let next = cache.chunks.length()
    cache.chunks.push(
      build_hunting_chunk(
        region.dungeon,
        region.seed,
        next % columns,
        next / columns,
        region=id,
      ),
    )
    self.region_chunks_built += 1
    break // One chunk per simulation update. Repeated proximity never rebuilds completed work.
  }
  if atlas.travel_target is Some(id) {
    if self.world.ui_mode != @game.Waypoints {
      atlas.travel_target = None
      return false
    }
    if self.region_mesh_ready(id) {
      let (x, y) = @game.world_waypoint_position(id)
      if self.world.enter_region(id, x, y) {
        ignore(self.world.activate_nearby_waypoint())
        self.adopt_region_mesh(id, waypoint=true)
        return true
      }
      atlas.travel_target = None
    }
  }
  false
}

///|
fn GameState::adopt_region_mesh(
  self : GameState,
  id : Int,
  waypoint? : Bool = false,
) -> Unit {
  self.refresh_terrain_stats()
  self.dungeon_chunks = self.region_meshes[id].unwrap().chunks
  self.invalidate_visible_chunk_cache()
  self.invalidate_minimap_cache()
  self.ground_targeting = false
  self.combat_visuals.clear()
  self.active_effects.clear()
  self.damage_popups.clear()
  self.particle_manager.emitters.clear()
  if waypoint {
    self.character.set_moving(false)
    self.character.anim_state = Idle
    self.character.action_time = 0.0
  } else {
    self.character.anim_state = if self.character.moving {
      Running
    } else {
      Idle
    }
    self.character.update(1.0 / 60.0)
  }
  self.character.skinning_cache_dirty = true
  self.camera = self.camera.with_target(
    @math3d.Vec3::new(
      self.world.player.x / tile_size,
      0.3,
      self.world.player.y / tile_size,
    ),
  )
  self.refresh_generated_props_for_current_floor()
  self.save_game()
}

///|
fn GameState::try_cross_region_boundary(self : GameState) -> Bool {
  if self.paused {
    return false
  }
  guard self.world.boundary_destination() is Some((id, x, y)) else {
    return false
  }
  if !self.region_mesh_ready(id) {
    return false
  }
  if !self.world.enter_region(id, x, y) {
    return false
  }
  self.adopt_region_mesh(id)
  true
}

///|
fn GameState::push_neighbor_region_commands(
  self : GameState,
  vp : @math3d.Mat4,
  dst : @gfx.ImageHandle,
  cmds : Array[@gfx.DrawTrianglesCommand],
) -> Unit {
  guard self.world.atlas is Some(atlas) else { return }
  if self.motion_preview || self.world.authored_scene is Some(_) {
    return
  }
  let region = @game.world_regions[atlas.current]
  for entry in self.region_meshes {
    guard entry is Some(cache) else { continue }
    let neighbor = @game.world_regions[cache.region]
    if (neighbor.x - region.x).abs() + (neighbor.z - region.z).abs() != 1 {
      continue
    }
    let ox = (neighbor.x - region.x).to_double() *
      (@game.map_cols - 2).to_double()
    let oz = (neighbor.z - region.z).to_double() *
      (@game.map_rows - 2).to_double()
    let px = self.world.player.x / tile_size - ox
    let pz = self.world.player.y / tile_size - oz
    if px < -28.0 ||
      px > @game.map_cols.to_double() + 28.0 ||
      pz < -28.0 ||
      pz > @game.map_rows.to_double() + 28.0 {
      continue
    }
    let model = @transform3d.Transform3D::from_position(
      @math3d.Vec3::new(ox, 0.0, oz),
    ).to_mat4()
    for chunk in cache.chunks {
      if (chunk.cx.to_double() * chunk_size.to_double() + 12.0 - px).abs() >
        40.0 ||
        (chunk.cz.to_double() * chunk_size.to_double() + 12.0 - pz).abs() > 40.0 {
        continue
      }
      for group in chunk.groups {
        if group.mesh.indices.is_empty() {
          continue
        }
        @web_hooks.register_static_geometry(
          group.mesh.vertex_data,
          group.mesh.indices,
        )
        cmds.push(
          @draw3d.new_lit_colored_mesh_draw_command(
            dst,
            self.shader3d_colored,
            group.dst_region,
            0,
            0,
            0,
            @gfx.BlendMode::from_int(0),
            group.mesh,
            model,
            vp,
            self.lighting,
            group.color,
            [],
          ),
        )
      }
    }
  }
}
