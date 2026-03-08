// Auto-play AI: room navigation, combat, skill activation

// Find which room an entity is in (returns room index or -1)
pub fn find_room_at(rooms : Array[@terrain.Room], x : Double, y : Double) -> Int {
  let p : @terrain.Point = { x: (x / tile_size).to_int(), y: (y / tile_size).to_int() }
  for i, room in rooms {
    if room.rect.contains(p) {
      return i
    }
  }
  -1
}

// Count alive enemies in a specific room
pub fn count_enemies_in_room(
  enemies : Array[Enemy],
  room : @terrain.Room,
) -> Int {
  let mut count = 0
  for enemy in enemies {
    if enemy.alive {
      let p : @terrain.Point = { x: (enemy.x / tile_size).to_int(), y: (enemy.y / tile_size).to_int() }
      if room.rect.contains(p) {
        count = count + 1
      }
    }
  }
  count
}

// Find nearest alive enemy within vision range (current room + adjacent rooms)
pub fn find_nearest_visible_enemy(world : GameWorld) -> (Int, Double) {
  // Returns (enemy_index, dist_sq), or (-1, max) if none
  let mut best_idx = -1
  let mut best_dist_sq = 1000000.0
  let player_room = find_room_at(world.dungeon.rooms, world.player.x, world.player.y)
  for i, enemy in world.enemies {
    if not(enemy.alive) {
      continue
    }
    let edx = enemy.x - world.player.x
    let edy = enemy.y - world.player.y
    let dist_sq = edx * edx + edy * edy
    // Vision: enemies in same room always visible
    let enemy_room = find_room_at(world.dungeon.rooms, enemy.x, enemy.y)
    let visible = if enemy_room == player_room && player_room >= 0 {
      true
    } else if dist_sq < world.params.chase_range * world.params.chase_range {
      // Also detect nearby enemies (in corridors / adjacent rooms)
      true
    } else {
      false
    }
    if visible && dist_sq < best_dist_sq {
      best_dist_sq = dist_sq
      best_idx = i
    }
  }
  (best_idx, best_dist_sq)
}

// Find the next uncleared room to visit
pub fn find_next_target_room(world : GameWorld) -> Int {
  let rooms = world.dungeon.rooms
  let player_room = find_room_at(rooms, world.player.x, world.player.y)
  // Mark current room as cleared if no enemies
  if player_room >= 0 && player_room < world.auto_cleared_rooms.length() {
    if count_enemies_in_room(world.enemies, rooms[player_room]) == 0 {
      world.auto_cleared_rooms[player_room] = true
    }
  }
  // Find nearest uncleared room with enemies
  let px = (world.player.x / tile_size).to_int()
  let py = (world.player.y / tile_size).to_int()
  let mut best_room = -1
  let mut best_dist = 100000
  for i, room in rooms {
    if i < world.auto_cleared_rooms.length() && world.auto_cleared_rooms[i] {
      continue
    }
    // Check if room has enemies
    if count_enemies_in_room(world.enemies, room) == 0 {
      if i < world.auto_cleared_rooms.length() {
        world.auto_cleared_rooms[i] = true
      }
      continue
    }
    let r = room.rect
    let cx = r.x + r.w / 2
    let cy = r.y + r.h / 2
    let dist = (cx - px).abs() + (cy - py).abs() // Manhattan distance
    if dist < best_dist {
      best_dist = dist
      best_room = i
    }
  }
  best_room
}

// Auto-play: compute desired movement direction
// Returns (dx, dy, enemy_idx, enemy_dist_sq) — also returns vision result to avoid recomputation
pub fn auto_play_input(world : GameWorld) -> (Double, Double, Int, Double) {
  // 1. Check for visible enemies — if found, move toward nearest
  let (enemy_idx, enemy_dist_sq) = find_nearest_visible_enemy(world)
  if enemy_idx >= 0 {
    let enemy = world.enemies[enemy_idx]
    // If close enough for bow, strafe slightly; otherwise approach
    if enemy_dist_sq < 80.0 * 80.0 {
      // In bow range — orbit around enemy at medium distance
      let edx = enemy.x - world.player.x
      let edy = enemy.y - world.player.y
      let dist = enemy_dist_sq.sqrt()
      if dist > 0.001 {
        // Strafe perpendicular to enemy direction (clockwise)
        let nx = edx / dist
        let ny = edy / dist
        // If too close, back away; if too far, close in
        let desired_range = 60.0
        let range_factor = if dist < desired_range * 0.6 {
          -0.5 // back away
        } else if dist > desired_range * 1.2 {
          0.8 // close in
        } else {
          0.0 // hold distance
        }
        let dx = -ny * 0.7 + nx * range_factor
        let dy = nx * 0.7 + ny * range_factor
        let mag = (dx * dx + dy * dy).sqrt()
        if mag > 0.001 {
          return (dx / mag, dy / mag, enemy_idx, enemy_dist_sq)
        }
      }
    } else {
      // Out of bow range — approach directly
      let edx = enemy.x - world.player.x
      let edy = enemy.y - world.player.y
      let dist = enemy_dist_sq.sqrt()
      if dist > 0.001 {
        return (edx / dist, edy / dist, enemy_idx, enemy_dist_sq)
      }
    }
  }
  // 2. No visible enemies — navigate to next room
  let target_room = find_next_target_room(world)
  if target_room < 0 {
    // All rooms cleared — stay put
    return (0.0, 0.0, enemy_idx, enemy_dist_sq)
  }
  let r = world.dungeon.rooms[target_room].rect
  let goal_tile : @terrain.Point = { x: r.x + r.w / 2, y: r.y + r.h / 2 }
  // Check if we need a new path
  let need_repath = match world.auto_nav_target {
    None => true
    Some(t) => t.x != goal_tile.x || t.y != goal_tile.y
  }
  if need_repath || world.auto_nav_index >= world.auto_nav_path.length() {
    let px = (world.player.x / tile_size).to_int()
    let py = (world.player.y / tile_size).to_int()
    let start : @terrain.Point = { x: px, y: py }
    match @pathfind.find_path(world.dungeon.grid, start, goal_tile) {
      Some(path) => {
        world.auto_nav_path = path
        world.auto_nav_index = 1 // skip start
        world.auto_nav_target = Some(goal_tile)
      }
      None => {
        world.auto_nav_path = []
        world.auto_nav_index = 0
        world.auto_nav_target = None
        return (0.0, 0.0, enemy_idx, enemy_dist_sq)
      }
    }
  }
  // Follow path
  if world.auto_nav_index < world.auto_nav_path.length() {
    let wp = world.auto_nav_path[world.auto_nav_index]
    let wx = wp.x.to_double() * tile_size + tile_size / 2.0
    let wy = wp.y.to_double() * tile_size + tile_size / 2.0
    let pdx = wx - world.player.x
    let pdy = wy - world.player.y
    let pdist = (pdx * pdx + pdy * pdy).sqrt()
    if pdist < tile_size / 2.0 {
      world.auto_nav_index = world.auto_nav_index + 1
      // Recurse to get next direction
      if world.auto_nav_index < world.auto_nav_path.length() {
        let nwp = world.auto_nav_path[world.auto_nav_index]
        let nwx = nwp.x.to_double() * tile_size + tile_size / 2.0
        let nwy = nwp.y.to_double() * tile_size + tile_size / 2.0
        let ndx = nwx - world.player.x
        let ndy = nwy - world.player.y
        let ndist = (ndx * ndx + ndy * ndy).sqrt()
        if ndist > 0.001 {
          return (ndx / ndist, ndy / ndist, enemy_idx, enemy_dist_sq)
        }
      }
    } else if pdist > 0.001 {
      return (pdx / pdist, pdy / pdist, enemy_idx, enemy_dist_sq)
    }
  }
  (0.0, 0.0, enemy_idx, enemy_dist_sq)
}

// Auto-play: activate skills when enemies are nearby
pub fn GameWorld::auto_activate_skills(self : GameWorld, enemy_idx : Int) -> Unit {
  if enemy_idx < 0 {
    return
  }
  // Try skills in priority order: Whirlwind (AoE) > Power Strike > Dash toward enemy
  if self.skills.get_level(Whirlwind) > 0 && self.attack_timer <= 0 {
    activate_skill(self, 1)
    return
  }
  if self.skills.get_level(PowerStrike) > 0 && self.attack_timer <= 0 {
    activate_skill(self, 0)
    return
  }
  // Dash toward enemy if available and far enough
  let enemy = self.enemies[enemy_idx]
  let edx = enemy.x - self.player.x
  let edy = enemy.y - self.player.y
  let dist_sq = edx * edx + edy * edy
  if self.skills.get_level(DashMastery) > 0 &&
    self.player.dash_cooldown_timer <= 0 &&
    dist_sq > 100.0 * 100.0 {
    let dist = dist_sq.sqrt()
    start_dash(self, edx / dist, edy / dist)
  }
}

// Auto-equip: automatically equip better items
pub fn GameWorld::auto_equip_best(self : GameWorld) -> Unit {
  for i in 0..<self.inventory.capacity {
    match self.inventory.items[i] {
      Some(item) => {
        let dominated = match item.slot {
          Weapon =>
            match self.equipment.weapon {
              Some(eq) => item.total_atk() > eq.total_atk()
              None => true
            }
          Armor =>
            match self.equipment.armor {
              Some(eq) => item.total_def() > eq.total_def()
              None => true
            }
          Accessory =>
            match self.equipment.accessory {
              Some(eq) => item.total_hp() > eq.total_hp()
              None => true
            }
        }
        if dominated {
          let prev = self.equipment.equip(item)
          self.inventory.items[i] = prev
          self.player_stats = compute_player_stats(self.equipment, self.skills)
          self.player.hp = @cmp.minimum(self.player.hp, self.player_stats.max_hp)
        }
      }
      None => ()
    }
  }
}

// Auto-learn: spend skill points automatically
pub fn GameWorld::auto_learn_skills(self : GameWorld) -> Unit {
  if self.skills.skill_points <= 0 {
    return
  }
  // Priority: Vitality > PowerStrike > CriticalHit > DashMastery > Whirlwind > LifeSteal
  let priority : Array[SkillId] = [
    Vitality, PowerStrike, CriticalHit, DashMastery, Whirlwind, LifeSteal,
  ]
  for id in priority {
    if self.skills.learn(id) {
      self.player_stats = compute_player_stats(self.equipment, self.skills)
      return
    }
  }
}
