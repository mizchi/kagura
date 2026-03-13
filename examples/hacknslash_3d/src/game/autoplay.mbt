// Auto-play AI: room navigation, combat, skill activation

// Find which room an entity is in (returns room index or -1)

///|
pub fn find_room_at(
  rooms : Array[@terrain.Room],
  x : Double,
  y : Double,
) -> Int {
  let p : @terrain.Point = {
    x: (x / tile_size).to_int(),
    y: (y / tile_size).to_int(),
  }
  for i, room in rooms {
    if room.rect.contains(p) {
      return i
    }
  }
  -1
}

// Count alive enemies in a specific room

///|
pub fn count_enemies_in_room(
  enemies : Array[Enemy],
  room : @terrain.Room,
) -> Int {
  let mut count = 0
  for enemy in enemies {
    if enemy.alive {
      let p : @terrain.Point = {
        x: (enemy.x / tile_size).to_int(),
        y: (enemy.y / tile_size).to_int(),
      }
      if room.rect.contains(p) {
        count = count + 1
      }
    }
  }
  count
}

// Find nearest alive enemy within vision range (current room + adjacent rooms)

///|
fn find_nearest_visible_enemy_with_nav_grid(
  world : GameWorld,
  nav_grid : @terrain.Grid2D,
) -> (Int, Double) {
  let player_room = find_room_at(
    world.dungeon.rooms,
    world.player.x,
    world.player.y,
  )
  @physics2d.grid_find_nearest_visible_candidate_index(
    nav_grid,
    world.player.x,
    world.player.y,
    world.player.size,
    world.params.chase_range,
    world.enemies.length(),
    fn(i) {
      let enemy = world.enemies[i]
      if not(enemy.alive) {
        return false
      }
      let edx = enemy.x - world.player.x
      let edy = enemy.y - world.player.y
      let dist_sq = edx * edx + edy * edy
      let enemy_room = find_room_at(world.dungeon.rooms, enemy.x, enemy.y)
      (enemy_room == player_room && player_room >= 0) ||
      dist_sq < world.params.chase_range * world.params.chase_range
    },
    fn(i) { world.enemies[i].x },
    fn(i) { world.enemies[i].y },
    tile_size,
  )
}

///|
pub fn find_nearest_visible_enemy(world : GameWorld) -> (Int, Double) {
  find_nearest_visible_enemy_with_nav_grid(world, world.dungeon.grid)
}

///|
fn find_nearest_alive_enemy(world : GameWorld) -> (Int, Double) {
  let mut best_idx = -1
  let mut best_dist_sq = 100000000.0
  for i, enemy in world.enemies {
    if not(enemy.alive) {
      continue
    }
    let dx = enemy.x - world.player.x
    let dy = enemy.y - world.player.y
    let dist_sq = dx * dx + dy * dy
    if dist_sq < best_dist_sq {
      best_idx = i
      best_dist_sq = dist_sq
    }
  }
  (best_idx, best_dist_sq)
}

// Find the next uncleared room to visit

///|
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

///|
fn find_nearest_autoplay_pickup_item(world : GameWorld) -> ItemDrop? {
  let mut nearest : ItemDrop? = None
  let mut nearest_dist_sq = 100000000.0
  for item in world.items {
    if not(item.alive) {
      continue
    }
    let dx = item.x - world.player.x
    let dy = item.y - world.player.y
    let dist_sq = dx * dx + dy * dy
    if dist_sq < nearest_dist_sq {
      nearest_dist_sq = dist_sq
      nearest = Some(item)
    }
  }
  nearest
}

///|
pub fn GameWorld::collect_equipment_pickup(
  self : GameWorld,
  item : ItemData,
) -> Bool {
  let plan = @gameplay2d.plan_equipment_pickup(
    auto_play=self.auto_play,
    should_equip=self.equipment.should_equip(item),
    inventory_has_space=self.inventory.count() < self.inventory.capacity,
    has_previous_equipped=match self.equipment.item_for_slot(item.slot) {
      Some(_) => true
      None => false
    },
  )
  if plan.equip_incoming {
    let previous = self.equipment.equip(item)
    match (previous, plan.store_previous_equipped) {
      (Some(old_item), true) =>
        if plan.use_fifo_storage {
          ignore(self.inventory.add_fifo(old_item))
        } else {
          ignore(self.inventory.add(old_item))
        }
      (None, _) => ()
      _ => ()
    }
    self.player_stats = compute_player_stats(
      self.equipment,
      self.skills,
      base_hp=self.params.player_base_hp.to_int(),
    )
    self.player.hp = @cmp.minimum(self.player.hp, self.player_stats.max_hp)
    return true
  }
  if not(plan.store_incoming) {
    return false
  }
  if plan.use_fifo_storage {
    ignore(self.inventory.add_fifo(item))
  } else {
    ignore(self.inventory.add(item))
  }
  true
}

///|
fn auto_equip_inventory_item(
  world : GameWorld,
  index : Int,
  item : ItemData,
) -> Unit {
  if world.equipment.should_equip(item) {
    let prev = world.equipment.equip(item)
    world.inventory.items[index] = prev
    world.player_stats = compute_player_stats(
      world.equipment,
      world.skills,
      base_hp=world.params.player_base_hp.to_int(),
    )
    world.player.hp = @cmp.minimum(world.player.hp, world.player_stats.max_hp)
  }
}

///|
pub fn GameWorld::auto_equip_best(self : GameWorld) -> Unit {
  for i in 0..<self.inventory.capacity {
    match self.inventory.items[i] {
      Some(item) => auto_equip_inventory_item(self, i, item)
      None => ()
    }
  }
}

///|
fn levelup_offer_priority(id : SkillId) -> Int {
  match id {
    Vitality => 0
    PowerStrike => 1
    ChainLightning => 2
    IceNova => 3
    HomingMissile => 4
    SplittingFireball => 5
    CriticalHit => 6
    DashMastery => 7
    Whirlwind => 8
    LifeSteal => 9
  }
}

///|
pub fn GameWorld::auto_choose_levelup_offer(self : GameWorld) -> Unit {
  if self.level_progress.pending_choices <= 0 ||
    self.level_progress.current_offers.length() == 0 {
    return
  }
  let mut best_index = 0
  let mut best_priority = 999999
  for i, offer in self.level_progress.current_offers {
    let priority = levelup_offer_priority(offer)
    if priority < best_priority {
      best_priority = priority
      best_index = i
    }
  }
  ignore(
    self.apply_levelup_offer_choice(best_index, self.seed + self.frame_count),
  )
}

///|
fn autoplay_walkable_tile(tile : @terrain.Tile) -> Bool {
  match tile {
    @terrain.Floor
    | @terrain.Corridor
    | @terrain.Door
    | @terrain.Start
    | @terrain.Goal => true
    _ => false
  }
}

///|
fn resolve_autoplay_goal_path(
  nav_grid : @terrain.Grid2D,
  start : @terrain.Point,
  goal_tile : @terrain.Point,
) -> Array[@terrain.Point]? {
  match @pathfind.find_path(nav_grid, start, goal_tile) {
    Some(path) => return Some(path)
    None => ()
  }
  let max_radius = @cmp.maximum(nav_grid.width, nav_grid.height)
  for radius = 1; radius <= max_radius; radius = radius + 1 {
    let min_row = @cmp.maximum(0, goal_tile.y - radius)
    let max_row = @cmp.minimum(nav_grid.height - 1, goal_tile.y + radius)
    let min_col = @cmp.maximum(0, goal_tile.x - radius)
    let max_col = @cmp.minimum(nav_grid.width - 1, goal_tile.x + radius)
    for row = min_row; row <= max_row; row = row + 1 {
      for col = min_col; col <= max_col; col = col + 1 {
        let on_perimeter = row == min_row ||
          row == max_row ||
          col == min_col ||
          col == max_col
        if not(on_perimeter) {
          continue
        }
        if not(autoplay_walkable_tile(nav_grid.get(col, row))) {
          continue
        }
        match @pathfind.find_path(nav_grid, start, { x: col, y: row }) {
          Some(path) => return Some(path)
          None => ()
        }
      }
    }
  }
  None
}

///|
fn auto_play_direction_to_goal_tile(
  world : GameWorld,
  nav_grid : @terrain.Grid2D,
  goal_tile : @terrain.Point,
  enemy_idx : Int,
  enemy_dist_sq : Double,
) -> (Double, Double, Int, Double) {
  let need_repath = match world.auto_nav_target {
    None => true
    Some(t) => t.x != goal_tile.x || t.y != goal_tile.y
  }
  if need_repath || world.auto_nav_index >= world.auto_nav_path.length() {
    let px = (world.player.x / tile_size).to_int()
    let py = (world.player.y / tile_size).to_int()
    let start : @terrain.Point = { x: px, y: py }
    match resolve_autoplay_goal_path(nav_grid, start, goal_tile) {
      Some(path) => {
        world.auto_nav_path = path
        world.auto_nav_index = 1
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
  if world.auto_nav_index < world.auto_nav_path.length() {
    let wp = world.auto_nav_path[world.auto_nav_index]
    let wx = wp.x.to_double() * tile_size + tile_size / 2.0
    let wy = wp.y.to_double() * tile_size + tile_size / 2.0
    let pdx = wx - world.player.x
    let pdy = wy - world.player.y
    let pdist = (pdx * pdx + pdy * pdy).sqrt()
    if pdist < tile_size / 2.0 {
      world.auto_nav_index = world.auto_nav_index + 1
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

///|
fn auto_play_direction_to_world_target(
  world : GameWorld,
  target_x : Double,
  target_y : Double,
  enemy_idx : Int,
  enemy_dist_sq : Double,
) -> (Double, Double, Int, Double) {
  world.auto_nav_path = []
  world.auto_nav_index = 0
  world.auto_nav_target = None
  let dx = target_x - world.player.x
  let dy = target_y - world.player.y
  let dist = (dx * dx + dy * dy).sqrt()
  if dist > 0.001 {
    return (dx / dist, dy / dist, enemy_idx, enemy_dist_sq)
  }
  (0.0, 0.0, enemy_idx, enemy_dist_sq)
}

// Auto-play: compute desired movement direction
// Returns (dx, dy, enemy_idx, enemy_dist_sq) — also returns vision result to avoid recomputation

///|
pub fn auto_play_input(world : GameWorld) -> (Double, Double, Int, Double) {
  auto_play_input_with_nav_grid(world, world.dungeon.grid)
}

///|
fn auto_play_input_with_nav_grid(
  world : GameWorld,
  nav_grid : @terrain.Grid2D,
) -> (Double, Double, Int, Double) {
  // 1. Check for visible enemies — if found, move toward nearest
  let (enemy_idx, enemy_dist_sq) = find_nearest_visible_enemy_with_nav_grid(
    world, nav_grid,
  )
  if enemy_idx >= 0 {
    let enemy = world.enemies[enemy_idx]
    if enemy_direct_chase_path_blocked(
        nav_grid,
        world.player.x,
        world.player.y,
        enemy.x,
        enemy.y,
        world.player.size,
      ) {
      let goal_tile : @terrain.Point = {
        x: (enemy.x / tile_size).to_int(),
        y: (enemy.y / tile_size).to_int(),
      }
      return auto_play_direction_to_goal_tile(
        world, nav_grid, goal_tile, enemy_idx, enemy_dist_sq,
      )
    }
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
  // 2. No visible enemies — move toward nearby equipment pickup first
  match find_nearest_autoplay_pickup_item(world) {
    Some(item) => {
      let player_tile_x = (world.player.x / tile_size).to_int()
      let player_tile_y = (world.player.y / tile_size).to_int()
      let item_tile_x = (item.x / tile_size).to_int()
      let item_tile_y = (item.y / tile_size).to_int()
      if player_tile_x == item_tile_x && player_tile_y == item_tile_y {
        return auto_play_direction_to_world_target(
          world,
          item.x,
          item.y,
          enemy_idx,
          enemy_dist_sq,
        )
      }
      let goal_tile : @terrain.Point = {
        x: (item.x / tile_size).to_int(),
        y: (item.y / tile_size).to_int(),
      }
      return auto_play_direction_to_goal_tile(
        world, nav_grid, goal_tile, enemy_idx, enemy_dist_sq,
      )
    }
    None => ()
  }
  // 3. No visible enemies — navigate to next room
  let target_room = find_next_target_room(world)
  if target_room < 0 {
    let (fallback_enemy_idx, fallback_enemy_dist_sq) = find_nearest_alive_enemy(
      world,
    )
    if fallback_enemy_idx >= 0 {
      let fallback_enemy = world.enemies[fallback_enemy_idx]
      let goal_tile : @terrain.Point = {
        x: (fallback_enemy.x / tile_size).to_int(),
        y: (fallback_enemy.y / tile_size).to_int(),
      }
      return auto_play_direction_to_goal_tile(
        world, nav_grid, goal_tile, enemy_idx, fallback_enemy_dist_sq,
      )
    }
    return (0.0, 0.0, enemy_idx, enemy_dist_sq)
  }
  let r = world.dungeon.rooms[target_room].rect
  let goal_tile : @terrain.Point = { x: r.x + r.w / 2, y: r.y + r.h / 2 }
  auto_play_direction_to_goal_tile(
    world, nav_grid, goal_tile, enemy_idx, enemy_dist_sq,
  )
}

// Auto-play: activate skills when enemies are nearby

///|
pub fn GameWorld::auto_activate_skills(
  self : GameWorld,
  enemy_idx : Int,
) -> Unit {
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

///|
pub fn GameWorld::auto_activate_spell_slots(
  self : GameWorld,
  enemy_idx : Int,
  enemy_dist_sq : Double,
) -> Unit {
  if enemy_idx < 0 {
    return
  }
  let ice_auto_radius = ice_nova_radius * 0.9
  if self.skills.get_level(IceNova) > 0 &&
    enemy_dist_sq <= ice_auto_radius * ice_auto_radius &&
    cast_ice_nova(self) {
    return
  }
  if self.skills.get_level(ChainLightning) > 0 &&
    enemy_dist_sq <= chain_lightning_range * chain_lightning_range &&
    cast_chain_lightning(self) {
    return
  }
  if self.skills.get_level(HomingMissile) > 0 &&
    enemy_dist_sq <= homing_missile_range * homing_missile_range &&
    cast_homing_missile(self) {
    return
  }
  if self.skills.get_level(SplittingFireball) > 0 &&
    enemy_dist_sq <= self.params.arrow_range * self.params.arrow_range {
    ignore(cast_splitting_fireball(self))
  }
}
