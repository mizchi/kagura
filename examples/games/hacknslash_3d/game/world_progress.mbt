// Durable progress: inactive areas keep their loot, slain enemies and one-time rewards.

///|
struct RegionEnemyProgress {
  camp : EnemyCamp?
  kind : EnemyKind
  x : Double
  y : Double
  hp : Int
  max_hp : Int
  speed : Double
  size : Double
  alive : Bool
  room : Int
} derive(ToJson, FromJson)

///|
struct RegionProgress {
  id : Int
  enemies : Array[RegionEnemyProgress]
  items : Array[ItemDrop]
  discovered : Array[Bool]
  rewarded : Array[Bool]
  cleared : Array[Bool]
  opened_chests : Array[Int]?
} derive(ToJson, FromJson)

///|
struct WorldProgress {
  version : Int
  generator_version : Int?
  plains_relief : Double?
  seed : Int
  current : Int
  last_waypoint : Int?
  x : Double
  y : Double
  unlocked : Array[Bool]
  regions : Array[RegionProgress]
} derive(ToJson, FromJson)

///|
pub fn GameWorld::serialize_world_progress(self : GameWorld) -> String {
  guard self.atlas is Some(atlas) else { return "" }
  if self.authored_scene is Some(_) {
    return ""
  }
  self.capture_region()
  let regions : Array[RegionProgress] = []
  for id, state in atlas.regions {
    if atlas.visited[id] {
      if state is Some(state) {
        regions.push({
          id,
          items: state.items,
          discovered: state.discovered,
          rewarded: state.rewarded,
          cleared: state.cleared,
          opened_chests: Some(state.chests.filter(c => c.opened).map(c => c.id)),
          enemies: state.enemies.map(enemy => {
            camp: enemy.camp,
            kind: enemy.kind,
            x: enemy.x,
            y: enemy.y,
            hp: enemy.hp,
            max_hp: enemy.max_hp,
            speed: enemy.speed,
            size: enemy.size,
            alive: enemy.alive,
            room: enemy.room_index,
          }),
        })
      }
    }
  }
  WorldProgress::{
    version: 4,
    generator_version: Some(atlas.generator_version),
    plains_relief: Some(atlas.plains_relief),
    seed: atlas.world_seed,
    current: atlas.current,
    last_waypoint: Some(atlas.last_waypoint),
    x: self.player.x,
    y: self.player.y,
    unlocked: atlas.unlocked,
    regions,
  }
  .to_json()
  .stringify()
}

///|
fn parse_world_progress(source : String) -> WorldProgress? {
  try {
    let progress : WorldProgress = @json.from_json(@json.parse(source))
    if (progress.version < 1 || progress.version > 4) ||
      progress.current < 0 ||
      progress.current >= 4 ||
      progress.unlocked.length() != 4 ||
      progress.regions.length() > 4 ||
      progress.x < 0.0 ||
      progress.y < 0.0 ||
      progress.x >= map_cols.to_double() * tile_size ||
      progress.y >= map_rows.to_double() * tile_size {
      return None
    }
    if (progress.version >= 4 && progress.generator_version is None) ||
      progress.generator_version.or(1) < 1 ||
      progress.generator_version.or(1) > 3 {
      return None
    }
    if progress.plains_relief is Some(relief) {
      if relief.is_nan() || relief < 0.0 || relief > 1.0 {
        return None
      }
    }
    let ids : Array[Int] = []
    if progress.last_waypoint is Some(id) {
      if id < 0 || id >= 4 || !progress.unlocked[id] {
        return None
      }
    }
    for region in progress.regions {
      for enemy in region.enemies {
        if enemy.camp is Some(camp) {
          if camp.pack_id < 0 || camp.pack_id > 8 {
            return None
          }
          if camp.awareness is Waking(n) && (n < 1 || n > 36) {
            return None
          }
        }
      }
      if region.id < 0 ||
        region.id >= 4 ||
        ids.contains(region.id) ||
        region.enemies.length() > 2048 ||
        region.items.length() > 4096 ||
        region.discovered.length() != 5 ||
        region.rewarded.length() != 5 ||
        region.cleared.length() != 5 {
        return None
      }
      let opened = region.opened_chests.or([])
      if (progress.version >= 2 && region.opened_chests is None) ||
        opened.length() > hunting_sites.length() {
        return None
      }
      let seen : Array[Int] = []
      for id in opened {
        if id < 0 || id >= hunting_sites.length() || seen.contains(id) {
          return None
        }
        seen.push(id)
      }
      ids.push(region.id)
    }
    if !ids.contains(progress.current) {
      return None
    }
    Some(progress)
  } catch {
    _ => None
  }
}

///|
pub fn GameWorld::restore_world_progress(
  self : GameWorld,
  source : String,
) -> Bool {
  if !self.hunting_grounds || self.authored_scene is Some(_) {
    return false
  }
  guard parse_world_progress(source) is Some(progress) else { return false }
  let atlas = WorldAtlas::new(
    progress.seed,
    generator_version=progress.generator_version.or(1),
  )
  atlas.plains_relief = progress.plains_relief.or(1.0)
  for state in progress.regions {
    let seed = region_seed(progress.seed, state.id)
    let dungeon = generate_world_region(
      seed,
      state.id,
      generator_version=atlas.generator_version,
      plains_relief=atlas.plains_relief,
    )
    let enemies = state.enemies.map(saved => {
      let (x, y) = hunting_safe_position(dungeon, saved.x, saved.y, saved.size)
      let enemy = make_enemy(
        x,
        y,
        saved.kind,
        saved.max_hp.max(1),
        saved.speed,
        saved.size,
        room_index=saved.room,
      )
      enemy.hp = saved.hp.min(enemy.max_hp)
      enemy.alive = saved.alive && enemy.hp > 0
      enemy.camp = saved.camp
      enemy
    })
    if progress.version < 3 {
      let additions : Array[Enemy] = []
      append_hunting_site_enemies(
        additions,
        dungeon,
        self.params,
        world_regions[state.id].tier,
      )
      let (wx, wy) = world_waypoint_position(state.id)
      for enemy in additions {
        if progress.version == 2 && enemy.kind != Zombie {
          continue
        }
        let dx = enemy.x - wx
        let dy = enemy.y - wy
        let px = enemy.x - progress.x
        let py = enemy.y - progress.y
        if dx * dx + dy * dy > tile_size * tile_size * 25.0 &&
          (
            state.id != progress.current ||
            px * px + py * py > tile_size * tile_size * 16.0
          ) {
          enemies.push(enemy)
        }
      }
    }
    let enemies = remove_blocked_hunting_spawns(enemies, dungeon)
    configure_enemy_camps(enemies, seed)
    let chests = hunting_chests()
    for chest in chests {
      chest.opened = state.opened_chests.or([]).contains(chest.id)
    }
    for item in state.items {
      item.pickup_id = Some(self.allocate_pickup_id())
      let (x, y) = hunting_safe_position(dungeon, item.x, item.y, 4.0)
      item.x = x
      item.y = y
    }
    atlas.regions[state.id] = Some({
      id: state.id,
      seed,
      dungeon,
      enemies,
      items: state.items,
      chests,
      discovered: state.discovered,
      rewarded: state.rewarded,
      cleared: state.cleared,
    })
    atlas.visited[state.id] = true
  }
  for i in 0..<4 {
    atlas.unlocked[i] = progress.unlocked[i] && atlas.visited[i]
  }
  atlas.unlocked[0] = true
  let checkpoint = progress.last_waypoint.or(
    if atlas.unlocked[progress.current] {
      progress.current
    } else {
      0
    },
  )
  atlas.last_waypoint = if atlas.unlocked[checkpoint] { checkpoint } else { 0 }
  // Avoid capturing the old world's active arrays into the restored atlas.
  let region = atlas.regions[progress.current].unwrap()
  atlas.current = progress.current
  self.atlas = Some(atlas)
  self.dungeon = region.dungeon
  self.enemies = region.enemies
  self.items = region.items
  self.chests = region.chests
  self.discovered_rooms = region.discovered
  self.reward_cleared_rooms = region.rewarded
  self.auto_cleared_rooms = region.cleared
  self.seed = region.seed
  self.floor = world_regions[progress.current].tier
  let (x, y) = if check_wall_collision(
      region.dungeon.grid,
      progress.x,
      progress.y,
      self.player.size,
    ) {
    world_waypoint_position(progress.current)
  } else {
    (progress.x, progress.y)
  }
  self.player.x = x
  self.player.y = y
  self.discovered_rooms_version += 1
  true
}
