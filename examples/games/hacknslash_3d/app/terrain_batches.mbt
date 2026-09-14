///|
/// Build a material atlas once, outside rendering. Each source chunk owns an
/// index span in a shared mesh; empty chunks retain their source index.
fn RegionMeshCache::prepare_next_terrain_batch(self : RegionMeshCache) -> Bool {
  let material = self.terrain_batches.length()
  if !self.ready() || material >= hunting_palette.length() {
    return false
  }
  self.terrain_batches.push(
    @scene3d.StaticMeshBatch::new(
      self.chunks.map(chunk => chunk.groups[material].mesh),
    ).unwrap(),
  )
  true
}

///|
fn GameState::select_visible_terrain(
  self : GameState,
  chunks : Array[DungeonChunk],
) -> VisibleDungeonMeshCache {
  let groups : Array[DungeonMeshGroup] = []
  let cache = match self.world.atlas {
    Some(atlas) => self.region_meshes[atlas.current]
    None => None
  }
  let prepared = cache.map(c => c.terrain_batches.length()).or(0)
  if cache is Some(region) {
    let selected = region.chunks.map(source => {
      chunks.any(c => c.cx == source.cx && c.cz == source.cz)
    })
    for material, batch in region.terrain_batches {
      let source = region.chunks[0].groups[material]
      for span in batch.select(i => selected[i]) {
        groups.push({
          mesh: batch.mesh,
          color: source.color,
          surface_kind: source.surface_kind,
          index_offset: span.first_index,
          dst_region: @gfx.new_dst_region(
            0,
            0,
            screen_w,
            screen_h,
            span.index_count,
          ),
        })
      }
    }
  }
  // An incomplete atlas uses the original chunks for the remaining materials.
  // Pausing, early travel and native capture all have complete geometry.
  for chunk in chunks {
    for i in prepared..<chunk.groups.length() {
      if !chunk.groups[i].mesh.indices.is_empty() {
        groups.push(chunk.groups[i])
      }
    }
  }
  {
    groups,
    all_mesh: @mesh3d.Mesh3D::new([], []),
    depth_meshes: chunks.map(c => c.all_mesh),
  }
}
