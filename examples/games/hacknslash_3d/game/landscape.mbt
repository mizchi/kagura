///|
/// Navigation semantics are independent of meshes. A bridge has a walking
/// surface above its bed; a cave has a floor below a removable visual canopy.
pub(all) enum LandscapeKind {
  Land
  Sea
  River
  Mountain
  Bridge
  CaveFloor
} derive(Eq, Debug)
///|
pub extend LandscapeKind with Eq::{not_equal, equal}
///|
pub extend LandscapeKind with @moonbitlang/core/debug.Debug::{to_repr}
///|
pub(all) struct Landscape {
  region : Int
  bed : @terrain3d.HeightField
  walk : @terrain3d.HeightField
  kinds : Array[LandscapeKind]
  bridges : Array[@terrain3d.TerrainRoute]
  cave : @terrain3d.TerrainRoute
}

///|
pub fn Landscape::kind(self : Landscape, x : Int, z : Int) -> LandscapeKind {
  self.kinds[z.clamp(min=0, max=map_rows - 1) * map_cols +
  x.clamp(min=0, max=map_cols - 1)]
}

///|
pub fn landscape_river_x(z : Double) -> Double {
  let points = [
    (0.0, 54.0),
    (26.0, 53.0),
    (38.0, 46.0),
    (50.0, 30.0),
    (68.0, 25.0),
    (78.0, 32.0),
    (94.0, 52.0),
    (108.0, 52.0),
    (136.0, 29.0),
    (158.0, 40.0),
  ]
  for i in 1..<points.length() {
    let (a, x) = points[i - 1]
    let (b, y) = points[i]
    if z <= b {
      let t = ((z - a) / (b - a)).clamp(min=0.0, max=1.0)
      return x + (y - x) * t * t * (3.0 - 2.0 * t)
    }
  }
  40.0
}

///|
pub fn landscape_coast_distance(x : Double, z : Double) -> Double {
  (x - (8.0 + 3.0 * @math.sin(z * 0.073))).min(
    150.0 + 3.0 * @math.sin(x * 0.06) - z,
  )
}

///|
pub fn landscape_river_distance(x : Double, z : Double) -> Double {
  // The tributary on the region seam has the same world-space definition on
  // both sides. Roads cross it on a deck instead of interrupting the water.
  ((x - landscape_river_x(z)).abs() - 2.4).min((z - 78.0).abs() - 2.4)
}

///|
pub fn landscape_mountain_height(x : Double, z : Double) -> Double {
  let local_z = if z > 78.0 { z - 78.0 } else { z }
  let saddle = ((local_z - 40.0).abs() - 7.0).clamp(min=0.0, max=6.0) / 6.0
  let ridge = (7.0 - (x - 98.0).abs()).max(0.0) * 1.2 * saddle
  let north = (11.0 + 2.5 * @math.sin(x * 0.09) - z).max(0.0) * 1.1
  let east = (x - 184.0 + 3.0 * @math.sin(z * 0.07)).max(0.0) * 0.9
  ridge.max(north).max(east)
}

///|
pub fn landscape_cave() -> @terrain3d.TerrainRoute {
  { ax: 61.5, az: 26.5, ah: 4.5, bx: 61.5, bz: 10.5, bh: 3.0, width: 2.2, }
}

///|
/// Find bridge spans from semantic roads before carving water. No bridge is
/// chosen by visual decoration RNG. Keep two tiles of dry approach at each end.
fn landscape_bridges(
  plan : ExpeditionPlan,
  region : Int,
) -> Array[@terrain3d.TerrainRoute] {
  let ox = world_regions[region].x.to_double() * 98.0
  let oz = world_regions[region].z.to_double() * 78.0
  let spans : Array[@terrain3d.TerrainRoute] = []
  for r in plan.routes {
    let length = ((r.bx - r.ax) * (r.bx - r.ax) + (r.bz - r.az) * (r.bz - r.az)).sqrt()
    if length < 2.0 {
      continue
    }
    let steps = (length * 2.0).to_int()
    let mut first = -1
    let mut last = -1
    for i in 0..<=steps {
      let t = i.to_double() / steps.to_double()
      if landscape_river_distance(
          ox + r.ax + (r.bx - r.ax) * t,
          oz + r.az + (r.bz - r.az) * t,
        ) <
        1.0 {
        if first < 0 {
          first = i
        }
        last = i
      }
    }
    if first >= 0 {
      let a = ((first.to_double() - 5.0) / steps.to_double()).max(0.0)
      let b = ((last.to_double() + 5.0) / steps.to_double()).min(1.0)
      spans.push({
        ax: r.ax + (r.bx - r.ax) * a,
        az: r.az + (r.bz - r.az) * a,
        ah: r.ah + (r.bh - r.ah) * a,
        bx: r.ax + (r.bx - r.ax) * b,
        bz: r.az + (r.bz - r.az) * b,
        bh: r.ah + (r.bh - r.ah) * b,
        width: r.width,
      })
    }
  }
  spans
}

///|
pub fn landscape_plan(seed : Int, region : Int) -> ExpeditionPlan {
  let old = expedition_plan(seed, region)
  let fork = old.pads[9]
  let pads = old.pads.copy()
  // Put the junction on the dry bank, leaving distinct, unobstructed crossings.
  pads[9] = { ..fork, x: 40.5, z: 49.5, }
  let routes = old.routes.map(r => {
    let a = r.ax == fork.x && r.az == fork.z
    let b = r.bx == fork.x && r.bz == fork.z
    {
      ..r,
      ax: if a {
        40.5
      } else {
        r.ax
      },
      az: if a {
        49.5
      } else {
        r.az
      },
      bx: if b {
        40.5
      } else {
        r.bx
      },
      bz: if b {
        49.5
      } else {
        r.bz
      },
    }
  })
  let approach : @terrain3d.TerrainPad = {
    x: 75.5,
    z: 40.5,
    height: 3.5,
    radius: 2.8,
  }
  pads.push(approach)
  for (a, b) in [(pads[2], approach), (approach, pads[12])] {
    routes.push({
      ax: a.x,
      az: a.z,
      ah: a.height,
      bx: b.x,
      bz: b.z,
      bh: b.height,
      width: 2.8,
    })
  }
  {
    version: 3,
    pads,
    routes,
    name: [
      "潮風の渡し路", "赤錆の峠道", "霧の河岸段丘", "鐘楼の入江",
    ][region],
  }
}

///|
pub fn generate_landscape(
  seed : Int,
  region : Int,
  plains_relief? : Double = 1.0,
) -> Landscape {
  let plan = landscape_plan(seed, region)
  let cave = landscape_cave()
  let base = expedition_surface(seed, region, plains_relief~)
  base.grade_routes(plan.pads, plan.routes, blend=4.0)
  // A switchback meets both cave mouths, creating a traversable shortcut.
  let cave_exit : @terrain3d.TerrainRoute = {
    ax: cave.bx,
    az: cave.bz,
    ah: cave.bh,
    bx: 50.0,
    bz: 13.0,
    bh: 4.0,
    width: 2.4,
  }
  base.grade_routes([], [cave, cave_exit], blend=3.5)
  for z in 0..<=map_rows {
    for x in 0..<=map_cols {
      if x <= 2 || z <= 2 || x >= map_cols - 2 || z >= map_rows - 2 {
        base.set(x, z, 0.0)
      }
    }
  }
  base.limit_slope(0.45)
  let bed = @terrain3d.HeightField::new(map_cols, map_rows, base.values.copy())
  let bridges = landscape_bridges(plan, region)
  let ox = world_regions[region].x.to_double() * 98.0
  let oz = world_regions[region].z.to_double() * 78.0
  for z in 0..<=map_rows {
    for x in 0..<=map_cols {
      let px = x.to_double()
      let pz = z.to_double()
      let coast = landscape_coast_distance(px + ox, pz + oz)
      let river = landscape_river_distance(px + ox, pz + oz)
      let d = coast.min(river)
      let h = base.at(x, z)
      let mut ground = h.max(landscape_mountain_height(px + ox, pz + oz))
      if d < 2.0 {
        let t = ((d + 0.7) / 2.7).clamp(min=0.0, max=1.0)
        ground = -4.0 + (ground + 4.0) * t * t * (3.0 - 2.0 * t)
      }
      bed.set(x, z, ground)
    }
  }
  for z in 8..<=29 {
    for x in 48..<=65 {
      let px = x.to_double()
      let pz = z.to_double()
      if cave.projection(px, pz).0 < cave.width + 1.2 ||
        cave_exit.projection(px, pz).0 < cave_exit.width + 1.2 {
        bed.set(x, z, base.at(x, z))
      }
    }
  }
  let walk = @terrain3d.HeightField::new(map_cols, map_rows, bed.values.copy())
  for z in 0..<=map_rows {
    for x in 0..<=map_cols {
      if bridges.any(b => {
          b.projection(x.to_double(), z.to_double()).0 <= b.width + 1.2
        }) {
        walk.set(x, z, base.at(x, z))
      }
    }
  }
  // Exact deck/bed collars at the shared tributary. Opposite approach roads
  // may turn differently, but the overlapping geometry must not.
  for z in 0..<=map_rows {
    for x in 0..<=map_cols {
      let wz = z.to_double() + oz
      if wz >= 78.0 && wz <= 80.0 {
        walk.set(x, z, if (x - 50).abs() <= 5 { 0.0 } else { bed.at(x, z) })
      }
    }
  }
  let kinds = Array::make(map_cols * map_rows, Land)
  for z in 0..<map_rows {
    for x in 0..<map_cols {
      let px = x.to_double() + 0.5
      let pz = z.to_double() + 0.5
      let coast = landscape_coast_distance(px + ox, pz + oz)
      let river = landscape_river_distance(px + ox, pz + oz)
      let on_bridge = if pz + oz >= 78.0 && pz + oz <= 80.0 {
        (px - 50.0).abs() < 3.0
      } else {
        bridges.any(b => b.projection(px, pz).0 <= b.width - 0.3)
      }
      let cave_d = cave.projection(px, pz).0
      kinds[z * map_cols + x] = if coast < 1.3 {
        Sea
      } else if walk.cell_slope(x, z) > 0.72 {
        Mountain
      } else if on_bridge {
        Bridge
      } else if river < 1.3 {
        River
      } else if cave_d < cave.width && pz > 10.0 && pz < 27.0 {
        CaveFloor
      } else if cave_d < 5.5 && pz > 12.0 && pz < 24.0 {
        Mountain
      } else if walk.cell_slope(x, z) > 0.72 {
        Mountain
      } else {
        Land
      }
    }
  }
  { region, bed, walk, kinds, bridges, cave, }
}

///|
fn shape_landscape_region(
  dungeon : DungeonData,
  seed : Int,
  region : Int,
  plains_relief? : Double = 1.0,
) -> Unit {
  let land = generate_landscape(seed, region, plains_relief~)
  let plan = landscape_plan(seed, region)
  let grid = dungeon.grid
  for z in 0..<map_rows {
    for x in 0..<map_cols {
      let px = x.to_double() + 0.5
      let pz = z.to_double() + 0.5
      let kind = land.kind(x, z)
      let route = plan.routes.any(r => r.projection(px, pz).0 <= r.width) ||
        (pz < 15.0 && px > 49.0 && px < 64.0) ||
        land.cave.projection(px, pz).0 <= land.cave.width
      let clearing = plan.pads.any(p => {
        (px - p.x) * (px - p.x) + (pz - p.z) * (pz - p.z) <
        (p.radius + 0.5) * (p.radius + 0.5)
      })
      let mut tile = if kind == Sea || kind == River || kind == Mountain {
        @terrain.Wall
      } else if route || kind == Bridge || kind == CaveFloor {
        @terrain.Corridor
      } else {
        @terrain.Floor
      }
      // Jittered deterministic groves, rather than a three-tile lattice.
      if tile == @terrain.Floor &&
        !clearing &&
        landscape_coast_distance(
          px + world_regions[region].x.to_double() * 98.0,
          pz + world_regions[region].z.to_double() * 78.0,
        ) >
        5.0 {
        let hash = hunting_hash(x, z, seed)
        if hash % 31 < 3 &&
          hunting_hash(x - 1, z, seed) % 31 >= 3 &&
          hunting_hash(x, z - 1, seed) % 31 >= 3 {
          tile = @terrain.Wall
        }
      }
      grid.set(x, z, tile)
    }
  }
  for prop in landscape_props(seed) {
    for z in prop.z..<(prop.z + prop.depth) {
      for x in prop.x..<(prop.x + prop.width) {
        grid.set(x, z, @terrain.Wall)
      }
    }
  }
  for z in 54..<58 {
    for x in 14..<18 {
      grid.set(x, z, @terrain.Wall)
    }
  }
  stamp_hunting_chests(grid)
  dungeon.terrain_surface = Some(land.walk)
  dungeon.landscape = Some(land)
}

///|
/// Authored roadside modules share one placement list with collision. The old
/// cart location intersects the new high crossing; park it beside the gallery.
pub fn landscape_props(seed : Int) -> Array[HuntingProp] {
  hunting_site_props(seed).map(p => {
    if p.kind == BrokenCart {
      { ..p, x: 67, z: 27, }
    } else {
      p
    }
  })
}
