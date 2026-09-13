///|
pub(all) struct HuntingElevation {
  config : @terrain3d.TerrainConfig
  surface : @terrain3d.HeightField
}

///|
fn apply_region_elevation(
  atlas : WorldAtlas,
  dungeon : DungeonData,
  id : Int,
) -> Unit {
  dungeon.terrain_surface = match atlas.elevation {
    Some(elevation) if elevation.config.pattern != @terrain3d.Flat => {
      let region = world_regions[id]
      Some(
        elevation.surface.crop(
          region.x * (map_cols - 2),
          region.z * (map_rows - 2),
          map_cols,
          map_rows,
        ),
      )
    }
    _ => None
  }
}

///|
/// One shared world height field keeps overlap rows identical for streaming.
/// Roads, built sites and waypoints are cut to a common grade; an exact slope
/// envelope blends the surrounding hills into those pads without ledges.
pub fn GameWorld::set_hunting_terrain(
  self : GameWorld,
  requested : @terrain3d.TerrainConfig,
) -> Bool {
  guard self.atlas is Some(atlas) else { return false }
  if self.authored_scene is Some(_) || !self.hunting_grounds {
    return false
  }
  let config = requested.validated()
  if atlas.elevation is Some(elevation) && elevation.config == config {
    return false
  }
  if config.pattern == @terrain3d.Flat && atlas.elevation is None {
    return false
  }
  let surface = @terrain3d.generate_height_field(
    map_cols * 2 - 2,
    map_rows * 2 - 2,
    config,
  )
  if config.pattern != @terrain3d.Flat {
    for region in world_regions {
      let ox = region.x * (map_cols - 2)
      let oz = region.z * (map_rows - 2)
      let seed = region_seed(atlas.world_seed, region.id)
      let dungeon = generate_world_region(seed, region.id)
      fn pad(x0 : Int, z0 : Int, x1 : Int, z1 : Int) -> Unit {
        for z in z0.max(0)..<=z1.min(map_rows) {
          for x in x0.max(0)..<=x1.min(map_cols) {
            surface.set(ox + x, oz + z, 0.0)
          }
        }
      }
      for z in 0..<map_rows {
        for x in 0..<map_cols {
          if dungeon.grid.get(x, z) == @terrain.Corridor {
            pad(x, z, x + 1, z + 1)
          }
        }
      }
      for room in hunting_clearings() {
        let r = room.rect
        pad(r.x - 1, r.y - 1, r.x + r.w + 1, r.y + r.h + 1)
      }
      for site in hunting_sites {
        pad(site.x - 7, site.z - 7, site.x + 8, site.z + 7)
      }
      for prop in hunting_site_props(seed) {
        pad(
          prop.x - 1,
          prop.z - 1,
          prop.x + prop.width + 1,
          prop.z + prop.depth + 1,
        )
      }
      let (wx, wz) = world_waypoint_position(region.id)
      pad(
        (wx / tile_size).to_int() - 4,
        (wz / tile_size).to_int() - 4,
        (wx / tile_size).to_int() + 5,
        (wz / tile_size).to_int() + 5,
      )
    }
    surface.limit_slope(0.45)
  }
  atlas.elevation = Some({ config, surface, })
  apply_region_elevation(atlas, self.dungeon, atlas.current)
  for region in atlas.regions {
    if region is Some(region) {
      apply_region_elevation(atlas, region.dungeon, region.id)
    }
  }
  true
}
