// Bounded outdoor world. Simulation state is retained independently of render resources.

///|
pub(all) struct WorldRegion {
  id : Int
  name : String
  subtitle : String
  x : Int
  z : Int
  tier : Int
} derive(ToJson)

///|
pub let world_regions : Array[WorldRegion] = [
  {
    id: 0,
    name: "灰の森",
    subtitle: "灯火の旧街道",
    x: 0,
    z: 0,
    tier: 1,
  },
  {
    id: 1,
    name: "赤錆の荒野",
    subtitle: "風に錆びる巡礼路",
    x: 1,
    z: 0,
    tier: 2,
  },
  {
    id: 2,
    name: "霧の湿地",
    subtitle: "沈んだ祈りの水辺",
    x: 0,
    z: 1,
    tier: 2,
  },
  {
    id: 3,
    name: "鐘楼の廃墟",
    subtitle: "鐘のない夜の終着地",
    x: 1,
    z: 1,
    tier: 3,
  },
]

///|
pub(all) struct RegionState {
  id : Int
  seed : Int
  dungeon : DungeonData
  enemies : Array[Enemy]
  items : Array[ItemDrop]
  chests : Array[TreasureChest]
  discovered : Array[Bool]
  rewarded : Array[Bool]
  cleared : Array[Bool]
}

///|
pub(all) struct WorldAtlas {
  mut elevation : HuntingElevation?
  world_seed : Int
  mut current : Int
  regions : Array[RegionState?]
  unlocked : Array[Bool]
  visited : Array[Bool]
  mut travel_target : Int?
  mut revision : Int
}

///|
pub fn WorldAtlas::new(seed : Int) -> WorldAtlas {
  {
    elevation: None,
    world_seed: seed,
    current: 0,
    regions: [None, None, None, None],
    unlocked: [true, false, false, false],
    visited: [true, false, false, false],
    travel_target: None,
    revision: 0,
  }
}

///|
pub fn region_neighbor(id : Int, dx : Int, dz : Int) -> Int? {
  if id < 0 || id >= world_regions.length() || dx.abs() + dz.abs() != 1 {
    return None
  }
  let region = world_regions[id]
  for other in world_regions {
    if other.x == region.x + dx && other.z == region.z + dz {
      return Some(other.id)
    }
  }
  None
}

///|
pub fn region_seed(seed : Int, id : Int) -> Int {
  seed + id * 1013
}

///|
pub fn world_waypoint_position(id : Int) -> (Double, Double) {
  let (x, z) = match id {
    1 => (43.5, 62.5)
    2 => (59.5, 29.5)
    3 => (77.5, 47.5)
    _ => (20.5, 49.5)
  }
  (x * tile_size, z * tile_size)
}

///|
pub fn generate_world_region(seed : Int, id : Int) -> DungeonData {
  let dungeon = generate_hunting_grounds(seed)
  let grid = dungeon.grid
  for (dx, dz) in [(-1, 0), (1, 0), (0, -1), (0, 1)] {
    if region_neighbor(id, dx, dz) is None {
      continue
    }
    if dx != 0 {
      let start = if dx < 0 { 0 } else { map_cols - 22 }
      let end = if dx < 0 { 22 } else { map_cols }
      for x in start..<end {
        let blend = if dx < 0 {
          (x.to_double() / 20.0).min(1.0)
        } else {
          ((map_cols - 1 - x).to_double() / 20.0).min(1.0)
        }
        let z = (40.0 * (1.0 - blend) + hunting_road_z(x) * blend).to_int()
        for row in (z - 4)..<(z + 5) {
          grid.set(x, row, @terrain.Corridor)
        }
      }
    } else {
      let start = if dz < 0 { 0 } else { 28 }
      let end = if dz < 0 { 36 } else { map_rows }
      for z in start..<end {
        for x in 47..<54 {
          grid.set(x, z, @terrain.Corridor)
        }
      }
    }
  }
  let (wx, wz) = world_waypoint_position(id)
  for z in ((wz / tile_size).to_int() - 3)..<((wz / tile_size).to_int() + 4) {
    for x in ((wx / tile_size).to_int() - 3)..<((wx / tile_size).to_int() + 4) {
      grid.set(x, z, @terrain.Floor)
    }
  }
  stamp_hunting_chests(grid)
  dungeon
}

///|
pub fn GameWorld::capture_region(self : GameWorld) -> Unit {
  guard self.atlas is Some(atlas) else { return }
  atlas.regions[atlas.current] = Some({
    id: atlas.current,
    seed: self.seed,
    dungeon: self.dungeon,
    enemies: self.enemies,
    items: self.items,
    chests: self.chests,
    discovered: self.discovered_rooms,
    rewarded: self.reward_cleared_rooms,
    cleared: self.auto_cleared_rooms,
  })
}

///|
pub fn GameWorld::reset_world_atlas(self : GameWorld, seed : Int) -> Unit {
  self.atlas = if self.hunting_grounds && self.authored_scene is None {
    Some(WorldAtlas::new(seed))
  } else {
    None
  }
  if self.atlas is Some(_) {
    self.seed = seed
  }
  self.capture_region()
}

///|
pub fn GameWorld::prepare_region(self : GameWorld, id : Int) -> Bool {
  guard self.atlas is Some(atlas) else { return false }
  if self.authored_scene is Some(_) || id < 0 || id >= world_regions.length() {
    return false
  }
  if atlas.regions[id] is Some(_) {
    return true
  }
  let seed = region_seed(atlas.world_seed, id)
  let dungeon = generate_world_region(seed, id)
  apply_region_elevation(atlas, dungeon, id)
  let tier = world_regions[id].tier
  let enemies = spawn_enemies_for_floor_with_params(
    dungeon.rooms,
    0,
    seed,
    tier,
    self.params,
  )
  append_hunting_approach_enemies(enemies, dungeon, self.params, tier)
  append_hunting_site_enemies(enemies, dungeon, self.params, tier)
  let (wx, wy) = world_waypoint_position(id)
  let enemies = enemies.filter(enemy => {
    let dx = enemy.x - wx
    let dy = enemy.y - wy
    dx * dx + dy * dy > tile_size * tile_size * 25.0 &&
    !check_wall_collision(dungeon.grid, enemy.x, enemy.y, enemy.size)
  })
  atlas.regions[id] = Some({
    id,
    seed,
    dungeon,
    enemies,
    items: [],
    chests: hunting_chests(),
    discovered: Array::make(dungeon.rooms.length(), false),
    rewarded: Array::make(dungeon.rooms.length(), false),
    cleared: Array::make(dungeon.rooms.length(), false),
  })
  true
}

///|
/// Only nearby neighbors are requested. Generating one never activates or discovers it.
pub fn GameWorld::preload_regions(self : GameWorld) -> Array[Int] {
  guard self.atlas is Some(atlas) else { return [] }
  if self.authored_scene is Some(_) {
    return []
  }
  if atlas.travel_target is Some(id) {
    return [id]
  }
  let x = self.player.x / tile_size
  let z = self.player.y / tile_size
  let requests : Array[Int] = []
  for
    (dx, dz, close) in [
      (-1, 0, x < 24.0),
      (1, 0, x > map_cols.to_double() - 24.0),
      (0, -1, z < 24.0),
      (0, 1, z > map_rows.to_double() - 24.0),
    ] {
    if close {
      if region_neighbor(atlas.current, dx, dz) is Some(id) {
        requests.push(id)
      }
    }
  }
  requests
}

///|
pub fn GameWorld::boundary_destination(
  self : GameWorld,
) -> (Int, Double, Double)? {
  guard self.atlas is Some(atlas) else { return None }
  if self.arts.guarding ||
    self.arts.action is Some(_) ||
    self.mode != Playing ||
    self.ui_mode != UIMode::None ||
    self.authored_scene is Some(_) {
    return None
  }
  let x = self.player.x / tile_size
  let z = self.player.y / tile_size
  for
    (dx, dz, cross) in [
      (-1, 0, x < 1.0),
      (1, 0, x >= map_cols.to_double() - 1.0),
      (0, -1, z < 1.0),
      (0, 1, z >= map_rows.to_double() - 1.0),
    ] {
    if cross {
      if region_neighbor(atlas.current, dx, dz) is Some(id) {
        return Some(
          (
            id,
            self.player.x -
            dx.to_double() * (map_cols - 2).to_double() * tile_size,
            self.player.y -
            dz.to_double() * (map_rows - 2).to_double() * tile_size,
          ),
        )
      }
    }
  }
  None
}

///|
pub fn GameWorld::near_waypoint(self : GameWorld) -> Bool {
  guard self.atlas is Some(atlas) else { return false }
  if self.authored_scene is Some(_) {
    return false
  }
  let (x, y) = world_waypoint_position(atlas.current)
  let dx = self.player.x - x
  let dy = self.player.y - y
  dx * dx + dy * dy <= tile_size * tile_size * 9.0
}

///|
pub fn GameWorld::activate_nearby_waypoint(self : GameWorld) -> Bool {
  guard self.atlas is Some(atlas) else { return false }
  if self.hunter_action_locked() ||
    self.mode != Playing ||
    !self.near_waypoint() ||
    atlas.unlocked[atlas.current] {
    return false
  }
  atlas.unlocked[atlas.current] = true
  atlas.revision += 1
  true
}

///|
pub fn GameWorld::request_waypoint(self : GameWorld, id : Int) -> Bool {
  guard self.atlas is Some(atlas) else { return false }
  if self.hunter_action_locked() ||
    self.mode != Playing ||
    self.ui_mode != Waypoints ||
    !self.near_waypoint() ||
    id < 0 ||
    id >= world_regions.length() ||
    id == atlas.current ||
    !atlas.unlocked[id] ||
    self.weapon_attack is Some(_) ||
    self.player_charge is Some(_) ||
    self.player.dash_timer > 0 {
    return false
  }
  atlas.travel_target = Some(id)
  true
}

///|
/// Render ownership stays outside the game. The app commits only once its prepared mesh is ready.
pub fn GameWorld::enter_region(
  self : GameWorld,
  id : Int,
  x : Double,
  y : Double,
) -> Bool {
  guard self.atlas is Some(atlas) else { return false }
  if id < 0 || id >= atlas.regions.length() || self.authored_scene is Some(_) {
    return false
  }
  guard atlas.regions[id] is Some(region) else { return false }
  if check_wall_collision(region.dungeon.grid, x, y, self.player.size) {
    return false
  }
  self.capture_region()
  atlas.current = id
  atlas.visited[id] = true
  atlas.travel_target = None
  atlas.revision += 1
  self.dungeon = region.dungeon
  self.seed = region.seed
  self.floor = world_regions[id].tier
  self.enemies = region.enemies
  self.items = region.items
  self.chests = region.chests
  self.discovered_rooms = region.discovered
  self.reward_cleared_rooms = region.rewarded
  self.auto_cleared_rooms = region.cleared
  self.discovered_rooms_version += 1
  self.player.x = x
  self.player.y = y
  self.player.iframe_timer = self.player.iframe_timer.max(60)
  self.cancel_hunter_action()
  self.arts.strike = None
  self.player.dash_timer = 0
  self.weapon_attack = None
  self.reset_cleaver_combo()
  self.player_charge = None
  self.projectiles = []
  self.telegraph_markers = []
  self.events = []
  self.auto_nav_target = None
  self.auto_nav_path = []
  self.auto_nav_index = 0
  self.ui_mode = UIMode::None
  self.floor_announce_timer = 120
  true
}
