///|
pub(all) struct ExpeditionValidation {
  unreachable_targets : Int
  max_walk_slope : Double
  ground_triangles : Int
  collision_tiles : Int
} derive(ToJson)

///|
/// Offline/authoring check. Never run graph searches in the frame loop.
pub fn validate_expedition(
  dungeon : DungeonData,
  region : Int,
) -> ExpeditionValidation {
  let (wx, wz) = world_waypoint_position(region)
  let start : @terrain.Point = {
    x: (wx / tile_size).to_int(),
    y: (wz / tile_size).to_int(),
  }
  let targets = hunting_sites.map(site => @terrain.Point::{
    x: site.x + 2,
    y: site.z + 1,
  })
  for
    (dx, dz, x, y) in [
      (-1, 0, 1, 40),
      (1, 0, 98, 40),
      (0, -1, 50, 1),
      (0, 1, 50, 78),
    ] {
    if region_neighbor(region, dx, dz) is Some(_) {
      targets.push({ x, y, })
    }
  }
  if dungeon.landscape is Some(land) {
    targets.push({ x: land.cave.ax.to_int(), y: land.cave.az.to_int(), })
    targets.push({ x: land.cave.bx.to_int(), y: land.cave.bz.to_int(), })
  }
  let mut unreachable_targets = 0
  for target in targets {
    if @pathfind.find_path(dungeon.grid, start, target) is None {
      unreachable_targets += 1
    }
  }
  let mut slope = 0.0
  let mut collisions = 0
  for z in 0..<map_rows {
    for x in 0..<map_cols {
      if dungeon.grid.get(x, z) == @terrain.Wall {
        collisions += 1
      } else if dungeon.terrain_surface is Some(field) {
        slope = slope.max(field.cell_slope(x, z))
      }
    }
  }
  {
    unreachable_targets,
    max_walk_slope: slope,
    ground_triangles: map_cols * map_rows * 2,
    collision_tiles: collisions,
  }
}
