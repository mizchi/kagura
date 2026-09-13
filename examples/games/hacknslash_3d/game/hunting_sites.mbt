///|
pub(all) enum HuntingSiteKind {
  Ruins
  Encampment
} derive(Eq, Debug)

///|
pub(all) struct HuntingSite {
  id : Int
  name : String
  kind : HuntingSiteKind
  x : Int
  z : Int
  room : Int
}

///|
pub let hunting_sites : Array[HuntingSite] = [
  { id: 0, name: "街道の宿場跡", kind: Ruins, x: 39, z: 26, room: -1, },
  {
    id: 1,
    name: "灰狼の野営地",
    kind: Encampment,
    x: 29,
    z: 32,
    room: -1,
  },
  { id: 2, name: "崩れた礼拝堂", kind: Ruins, x: 77, z: 48, room: 3, },
  {
    id: 3,
    name: "盗賊の野営地",
    kind: Encampment,
    x: 64,
    z: 61,
    room: -1,
  },
]

///|
pub(all) enum HuntingPropKind {
  RuinWall
  RuinColumn
  Tent
  Palisade
  Campfire
  SupplyCrate
  RoadSign
  BrokenCart
} derive(Eq, Debug)

///|
/// Tile-aligned occupied footprints are shared by navigation and visible geometry.
pub(all) struct HuntingProp {
  kind : HuntingPropKind
  x : Int
  z : Int
  width : Int
  depth : Int
  variant : Int
}

///|
pub fn hunting_site_props(seed : Int) -> Array[HuntingProp] {
  let props : Array[HuntingProp] = []
  fn add(kind : HuntingPropKind, x : Int, z : Int, w : Int, d : Int) -> Unit {
    props.push({
      kind,
      x,
      z,
      width: w,
      depth: d,
      variant: hunting_hash(x, z, seed),
    })
  }
  for site in hunting_sites {
    let x = site.x
    let z = site.z
    if site.kind == Ruins {
      for dx in -5..<6 {
        if dx.abs() > 1 {
          add(RuinWall, x + dx, z - 4, 1, 1)
          if dx != -3 {
            add(RuinWall, x + dx, z + 4, 1, 1)
          }
        }
      }
      for dz in -3..<4 {
        if dz.abs() > 1 {
          add(RuinWall, x - 5, z + dz, 1, 1)
          add(RuinWall, x + 5, z + dz, 1, 1)
        }
      }
      for dx in [-3, 3] {
        add(RuinColumn, x + dx, z - 2, 1, 1)
      }
      add(SupplyCrate, x - 3, z + 1, 1, 1)
    } else {
      add(Tent, x - 5, z - 5, 3, 2)
      add(Tent, x + 2, z - 5, 3, 2)
      add(Campfire, x, z, 1, 1)
      add(SupplyCrate, x + 4, z + 1, 1, 1)
      for dx in -6..<7 {
        if dx.abs() > 2 {
          add(Palisade, x + dx, z + 5, 1, 1)
        }
        if dx % 3 != 0 {
          add(Palisade, x + dx, z - 6, 1, 1)
        }
      }
      for dz in [-4, -3, 1, 2] {
        add(Palisade, x - 6, z + dz, 1, 1)
        add(Palisade, x + 6, z + dz, 1, 1)
      }
    }
  }
  for x in [12, 24, 56, 66, 90] {
    add(RoadSign, x, hunting_road_z(x).to_int() + 4, 1, 1)
  }
  add(BrokenCart, 58, hunting_road_z(58).to_int() - 5, 2, 2)
  props
}

///|
fn stamp_hunting_sites(grid : @terrain.Grid2D, seed : Int) -> Unit {
  for site in hunting_sites {
    for z in (site.z - 7)..<(site.z + 8) {
      for x in (site.x - 8)..<(site.x + 9) {
        grid.set(x, z, @terrain.Floor)
      }
    }
  }
  // Restore the through-road and join each southern entrance with a wide footpath.
  for x in 2..<(grid.width - 2) {
    let road = hunting_road_z(x).to_int()
    for z in (road - 2)..<(road + 3) {
      grid.set(x, z, @terrain.Corridor)
    }
  }
  for site in hunting_sites {
    let road = hunting_road_z(site.x).to_int()
    for z in site.z.min(road)..<(site.z.max(road) + 1) {
      for x in (site.x - 1)..<(site.x + 2) {
        grid.set(x, z, @terrain.Corridor)
      }
    }
  }
  stamp_hunting_chests(grid)
  for prop in hunting_site_props(seed) {
    for z in prop.z..<(prop.z + prop.depth) {
      for x in prop.x..<(prop.x + prop.width) {
        grid.set(x, z, @terrain.Wall)
      }
    }
  }
}

///|
pub fn hunting_prop_present(prop : HuntingProp, grid : @terrain.Grid2D) -> Bool {
  for z in prop.z..<(prop.z + prop.depth) {
    for x in prop.x..<(prop.x + prop.width) {
      if grid.get(x, z) != @terrain.Wall {
        return false
      }
    }
  }
  true
}

///|
fn append_hunting_site_enemies(
  enemies : Array[Enemy],
  dungeon : DungeonData,
  params : BalanceParams,
  floor : Int,
) -> Unit {
  for site in hunting_sites {
    for i, offset in [(-2, 1), (2, 1), (-2, -1), (0, 2)] {
      let kind : EnemyKind = if site.kind == Encampment {
        [EnemyKind::Wolf, EnemyKind::Wolf, Basic, Ranged][i]
      } else {
        [Fast, Basic, Ranged, Caster][i]
      }
      let config = find_enemy_type_config(kind)
      let enemy = make_enemy(
        (site.x + offset.0).to_double() * tile_size + tile_size / 2.0,
        (site.z + offset.1).to_double() * tile_size + tile_size / 2.0,
        kind,
        params.scale_enemy_hp_for_floor(
          (params.basic_hp * config.hp_param).to_int().max(1),
          floor,
        ),
        params.scale_enemy_speed_for_floor(
          params.enemy_speed_basic * config.speed_param,
          floor,
        ),
        config.size,
        room_index=site.room,
      )
      enemy.shoot_cooldown = 100
      enemies.push(enemy)
    }
  }
}

///|
fn remove_blocked_hunting_spawns(
  enemies : Array[Enemy],
  dungeon : DungeonData,
) -> Array[Enemy] {
  enemies.filter(e => !check_wall_collision(dungeon.grid, e.x, e.y, e.size))
}

///|
// Map upgrades retain old actors and loot while relocating anything covered by a new wall.
fn hunting_safe_position(
  dungeon : DungeonData,
  x : Double,
  y : Double,
  size : Double,
) -> (Double, Double) {
  if !check_wall_collision(dungeon.grid, x, y, size) {
    return (x, y)
  }
  let cx = (x / tile_size).to_int()
  let cz = (y / tile_size).to_int()
  for radius in 1..<10 {
    for dz in -radius..<(radius + 1) {
      for dx in -radius..<(radius + 1) {
        if dx.abs() != radius && dz.abs() != radius {
          continue
        }
        let px = (cx + dx).to_double() * tile_size + tile_size / 2.0
        let py = (cz + dz).to_double() * tile_size + tile_size / 2.0
        if !check_wall_collision(dungeon.grid, px, py, size) {
          return (px, py)
        }
      }
    }
  }
  (dungeon.start_x, dungeon.start_y)
}
