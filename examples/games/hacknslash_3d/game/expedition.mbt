///|
/// Versioned semantic layout; generation and validation never depend on render state.
pub(all) struct ExpeditionPlan {
  version : Int
  name : String
  pads : Array[@terrain3d.TerrainPad]
  routes : Array[@terrain3d.TerrainRoute]
} derive(ToJson)

///|
pub fn expedition_plan(seed : Int, region : Int) -> ExpeditionPlan {
  let variation = hunting_hash(region, 71, seed)
  let lift = (variation % 3).to_double() * 0.5
  let pads : Array[@terrain3d.TerrainPad] = []
  fn node(x : Double, z : Double, h : Double, r : Double) -> Int {
    let id = pads.length()
    pads.push({ x, z, height: h, radius: r, })
    id
  }
  // Stable room/site IDs retain combat progress across saves. The connector
  // positions, relief and upper/lower loops vary independently of actor RNG.
  for i, room in hunting_clearings() {
    let p = room.rect.center()
    ignore(
      node(
        p.x.to_double() + 0.5,
        p.y.to_double() + 0.5,
        [0.0, 2.0, 6.0 + lift, 5.0 + lift, 0.0][i],
        6.5,
      ),
    )
  }
  for i, site in hunting_sites {
    ignore(
      node(
        site.x.to_double() + 0.5,
        site.z.to_double() + 0.5,
        [4.0 + lift, 1.5, 5.0 + lift, 1.0][i],
        8.0,
      ),
    )
  }
  let fork = node(33.0 + (variation % 4).to_double(), 49.0, 0.5, 3.0)
  let north = node(46.0 + (variation % 7).to_double(), 13.0, 4.0 + lift, 2.5)
  let south = node(83.0 + (variation % 5).to_double(), 64.0, 2.0, 3.0)
  let east = node(92.0, 40.0, 0.0, 3.0)
  let west = node(4.0, 40.0, 0.0, 3.0)
  let high_entry = node(61.0, 12.0, 3.0, 2.5)
  let routes : Array[@terrain3d.TerrainRoute] = []
  fn connect(a : Int, b : Int, width : Double) -> Unit {
    let a = pads[a]
    let b = pads[b]
    routes.push({
      ax: a.x,
      az: a.z,
      ah: a.height,
      bx: b.x,
      bz: b.z,
      bh: b.height,
      width,
    })
  }
  // Lower road: broad fighting spaces and supplies. Upper loop: exposed ascent,
  // ranged defenders and rare caches. Both loops reconnect, avoiding dead-end walks.
  for
    (a, b) in [
      (west, 0),
      (0, fork),
      (fork, 4),
      (4, 8),
      (8, south),
      (south, east),
    ] {
    connect(a, b, 2.8)
  }
  for
    (a, b) in [
      (0, 6),
      (6, 5),
      (5, north),
      (north, 2),
      (2, 7),
      (7, south),
      (fork, 1),
      (1, 5),
      (1, 2),
      (2, high_entry),
    ] {
    connect(a, b, 2.2)
  }
  for
    (dx, dz, x, z, via) in [
      (-1, 0, 0.0, 40.0, west),
      (1, 0, 100.0, 40.0, east),
      (0, -1, 50.0, 0.0, high_entry),
      (0, 1, 50.0, 80.0, 4),
    ] {
    if region_neighbor(region, dx, dz) is Some(_) {
      let gate = node(x, z, 0.0, 4.0)
      connect(via, gate, 3.5)
    }
  }
  connect(3, 7, 3.0) // The clearing and its ruined chapel share one plateau.
  let (wx, wz) = world_waypoint_position(region)
  let waypoint = node(
    wx / tile_size,
    wz / tile_size,
    [0.0, 0.0, 6.0 + lift, 5.0 + lift][region],
    4.0,
  )
  connect(waypoint, [0, 4, 2, 3][region], 3.0)
  {
    version: 2,
    name: [
      "尾根の回廊", "段丘の巡礼路", "湿地の高台", "鐘楼への登り道",
    ][region],
    pads,
    routes,
  }
}

///|
pub fn expedition_surface(seed : Int, region : Int) -> @terrain3d.HeightField {
  let plan = expedition_plan(seed, region)
  let field = @terrain3d.generate_height_field(map_cols, map_rows, {
    pattern: [
      @terrain3d.Hybrid,
      @terrain3d.Voronoi,
      @terrain3d.Perlin,
      @terrain3d.DiamondSquare,
    ][region],
    seed,
    amplitude: 7.0,
    scale: 14.0,
    roughness: 0.55,
  })
  for i in 0..<field.values.length() {
    field.values[i] += 7.0
  }
  field.grade_routes(plan.pads, plan.routes, blend=4.0)
  // Exact common seam collar. No region needs to generate its neighbor first.
  for z in 0..<=map_rows {
    for x in 0..<=map_cols {
      if x <= 2 || z <= 2 || x >= map_cols - 2 || z >= map_rows - 2 {
        field.set(x, z, 0.0)
      }
    }
  }
  // Repair steep grades deterministically. Rendering, grounding and targeting
  // all consume this repaired surface. Jumping is not required by the graph.
  field.limit_slope(0.45)
  field
}

///|
fn shape_expedition_region(
  dungeon : DungeonData,
  seed : Int,
  region : Int,
) -> Unit {
  let plan = expedition_plan(seed, region)
  let grid = dungeon.grid
  for z in 2..<(map_rows - 2) {
    for x in 2..<(map_cols - 2) {
      if grid.get(x, z) == @terrain.Corridor {
        grid.set(x, z, @terrain.Floor)
      }
      let px = x.to_double() + 0.5
      let pz = z.to_double() + 0.5
      if plan.routes.any(r => r.projection(px, pz).0 <= r.width) {
        grid.set(x, z, @terrain.Corridor)
      }
    }
  }
  // Keep the existing authored footprints, entrances, cache positions and IDs.
  for prop in hunting_site_props(seed) {
    for z in prop.z..<(prop.z + prop.depth) {
      for x in prop.x..<(prop.x + prop.width) {
        grid.set(x, z, @terrain.Wall)
      }
    }
  }
  stamp_hunting_chests(grid)
  dungeon.terrain_surface = Some(expedition_surface(seed, region))
}
