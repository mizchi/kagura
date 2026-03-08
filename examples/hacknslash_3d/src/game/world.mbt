// GameWorld: pure game state and logic, no rendering dependencies

pub(all) struct GameWorld {
  params : BalanceParams
  mut mode : GameMode
  mut frame_count : Int
  mut seed : Int
  mut floor : Int
  mut score : Int
  player : Player
  mut enemies : Array[Enemy]
  mut items : Array[ItemDrop]
  mut projectiles : Array[Projectile]
  dungeon : DungeonData
  mut attack_timer : Int
  mut screen_flash : Int
  mut floor_announce_timer : Int
  inventory : Inventory
  equipment : Equipment
  skills : SkillTree
  mut player_stats : PlayerStats
  mut ui_mode : UIMode
  mut ui_cursor : Int
  mut auto_play : Bool
  mut auto_nav_target : @terrain.Point?
  mut auto_nav_path : Array[@terrain.Point]
  mut auto_nav_index : Int
  mut auto_cleared_rooms : Array[Bool]
  mut events : Array[GameEvent]
}

pub fn GameWorld::new(seed~ : Int, params~ : BalanceParams = BalanceParams::default()) -> GameWorld {
  let dungeon = generate_dungeon(seed)
  let equipment = Equipment::new()
  let skills = SkillTree::new()
  let player_stats = compute_player_stats(equipment, skills)
  let player : Player = {
    x: dungeon.start_x,
    y: dungeon.start_y,
    hp: player_stats.max_hp,
    max_hp: player_stats.max_hp,
    size: 12.0,
    damage_timer: 0,
    iframe_timer: 0,
    facing_angle: @math.PI / 2.0,
    dash_timer: 0,
    dash_cooldown_timer: 0,
    dash_vx: 0.0,
    dash_vy: 0.0,
  }
  let enemies = spawn_enemies_in_rooms_with_params(dungeon.rooms, 0, seed, params)
  {
    params,
    mode: Title,
    frame_count: 0,
    seed,
    floor: 1,
    score: 0,
    player,
    enemies,
    items: [],
    projectiles: [],
    dungeon,
    attack_timer: 0,
    screen_flash: 0,
    floor_announce_timer: 0,
    inventory: Inventory::new(20),
    equipment,
    skills,
    player_stats,
    ui_mode: UIMode::None,
    ui_cursor: 0,
    auto_play: false,
    auto_nav_target: None,
    auto_nav_path: [],
    auto_nav_index: 0,
    auto_cleared_rooms: Array::make(dungeon.rooms.length(), false),
    events: [],
  }
}

pub fn GameWorld::drain_events(self : GameWorld) -> Array[GameEvent] {
  let result = self.events
  self.events = []
  result
}

pub fn GameWorld::deal_player_damage(self : GameWorld, raw_dmg : Int) -> Unit {
  let actual_dmg = @cmp.maximum(1, raw_dmg - self.player_stats.def)
  self.player.hp = self.player.hp - actual_dmg
  self.player.damage_timer = damage_flash_duration
  self.player.iframe_timer = self.params.iframe_duration.to_int()
  self.screen_flash = 3
  self.events.push(PlayerHurt(self.player.x, self.player.y))
  self.events.push(HurtTriggered)
  if self.player.hp <= 0 {
    self.mode = GameOver
  }
}

pub fn GameWorld::apply_dungeon(self : GameWorld, seed : Int, floor : Int) -> Unit {
  let dungeon = generate_dungeon(seed)
  self.dungeon.grid = dungeon.grid
  self.dungeon.rooms.clear()
  for room in dungeon.rooms {
    self.dungeon.rooms.push(room)
  }
  self.dungeon.start_x = dungeon.start_x
  self.dungeon.start_y = dungeon.start_y
  self.dungeon.height_map.clear()
  for h in dungeon.height_map {
    self.dungeon.height_map.push(h)
  }
  self.player.x = dungeon.start_x
  self.player.y = dungeon.start_y
  self.enemies = spawn_enemies_for_floor_with_params(dungeon.rooms, 0, seed, floor, self.params)
  self.items = []
  self.projectiles = []
  // Reset auto-play navigation
  self.auto_cleared_rooms = Array::make(self.dungeon.rooms.length(), false)
  self.auto_nav_target = None
  self.auto_nav_path = []
  self.auto_nav_index = 0
}

pub fn GameWorld::reset_floor(self : GameWorld) -> Unit {
  self.seed = self.seed + 1
  self.floor = self.floor + 1
  self.apply_dungeon(self.seed, self.floor)
  self.floor_announce_timer = 120
}

pub fn compact_projectiles(arr : Array[Projectile]) -> Unit {
  let mut write = 0
  for read = 0; read < arr.length(); read = read + 1 {
    if arr[read].alive {
      if write != read {
        arr[write] = arr[read]
      }
      write = write + 1
    }
  }
  while arr.length() > write {
    let _ = arr.pop()
  }
}

pub fn compact_items(arr : Array[ItemDrop]) -> Unit {
  let mut write = 0
  for read = 0; read < arr.length(); read = read + 1 {
    if arr[read].alive {
      if write != read {
        arr[write] = arr[read]
      }
      write = write + 1
    }
  }
  while arr.length() > write {
    let _ = arr.pop()
  }
}

pub fn start_dash(world : GameWorld, dir_x : Double, dir_y : Double) -> Unit {
  let p = world.params
  world.player.dash_timer = p.dash_duration.to_int()
  world.player.dash_cooldown_timer = world.player_stats.dash_cooldown
  world.player.dash_vx = dir_x * p.player_speed * p.dash_speed_mult
  world.player.dash_vy = dir_y * p.player_speed * p.dash_speed_mult
  world.player.iframe_timer = p.dash_duration.to_int()
  world.events.push(DashTrail(world.player.x, world.player.y))
}

pub fn GameWorld::tick(self : GameWorld, dx : Double, dy : Double) -> Unit {
  // 1. Increment frame_count
  self.frame_count = self.frame_count + 1
  // 2. Floor announce timer decrement
  if self.floor_announce_timer > 0 {
    self.floor_announce_timer = self.floor_announce_timer - 1
  }
  // 3. Update facing angle from dx/dy
  if dx != 0.0 || dy != 0.0 {
    self.player.facing_angle = @math.atan2(dy, dx)
  }
  // 4. Dash cooldown decrement
  if self.player.dash_cooldown_timer > 0 {
    self.player.dash_cooldown_timer = self.player.dash_cooldown_timer - 1
  }
  // 5. If dashing: move with dash velocity, push DashTrail every 3 frames
  if self.player.dash_timer > 0 {
    self.player.dash_timer = self.player.dash_timer - 1
    if self.player.dash_timer % 3 == 0 {
      self.events.push(DashTrail(self.player.x, self.player.y))
    }
    let (px, py) = slide_move(
      self.dungeon.grid, self.player.x, self.player.y,
      self.player.dash_vx, self.player.dash_vy, self.player.size,
    )
    self.player.x = px
    self.player.y = py
  } else {
    // 6. Normal movement with slide_move
    let (px, py) = slide_move(
      self.dungeon.grid, self.player.x, self.player.y,
      dx * self.params.player_speed, dy * self.params.player_speed, self.player.size,
    )
    self.player.x = px
    self.player.y = py
  }
  // 7. Clamp to world bounds
  let half = self.player.size / 2.0
  self.player.x = @cmp.maximum(half, @cmp.minimum(world_w - half, self.player.x))
  self.player.y = @cmp.maximum(half, @cmp.minimum(world_h - half, self.player.y))
  // 8. Auto-shoot: find_nearest_enemy -> shoot_arrow + push AttackTriggered
  if self.attack_timer > 0 {
    self.attack_timer = self.attack_timer - 1
  } else {
    let target = find_nearest_enemy(self, self.params.arrow_range)
    if target is Some(_) {
      self.attack_timer = self.params.bow_cooldown.to_int()
      shoot_arrow(self, target)
      self.events.push(AttackTriggered)
    }
  }
  // 9. Update enemy AI
  update_enemy_ai(
    self.enemies, self.player, self.dungeon.grid,
    self.frame_count, self.projectiles, params=self.params,
  )
  // 10. Enemy movement + contact damage
  for enemy in self.enemies {
    if enemy.alive {
      let (ex, ey) = slide_move(
        self.dungeon.grid, enemy.x, enemy.y,
        enemy.vx, enemy.vy, enemy.size,
      )
      enemy.x = ex
      enemy.y = ey
      enemy.vx = 0.0
      enemy.vy = 0.0
      // Contact damage
      if self.player.iframe_timer <= 0 {
        if @vector.aabb_overlap_center(
          self.player.x, self.player.y,
          self.player.size / 2.0, self.player.size / 2.0,
          enemy.x, enemy.y,
          enemy.size / 2.0, enemy.size / 2.0,
        ) {
          self.deal_player_damage(1)
        }
      }
    }
    if enemy.damage_timer > 0 {
      enemy.damage_timer = enemy.damage_timer - 1
    }
  }
  // 11. Projectile movement + wall collision + enemy projectile->player hit
  for proj in self.projectiles {
    if proj.alive {
      proj.x = proj.x + proj.vx
      proj.y = proj.y + proj.vy
      if is_wall_at(self.dungeon.grid, proj.x, proj.y) {
        proj.alive = false
      }
      // Enemy projectiles hit player
      if proj.alive && not(proj.is_player) && self.player.iframe_timer <= 0 {
        let pdx = proj.x - self.player.x
        let pdy = proj.y - self.player.y
        if pdx * pdx + pdy * pdy < pickup_radius_sq {
          self.deal_player_damage(proj.damage)
          proj.alive = false
        }
      }
    }
  }
  // 12. Process player arrows + compact projectiles
  process_player_arrows(self)
  compact_projectiles(self.projectiles)
  // 13. Item collection
  for item in self.items {
    if item.alive {
      if self.frame_count - item.spawn_frame > 600 {
        item.alive = false
        continue
      }
      let idx = item.x - self.player.x
      let idy = item.y - self.player.y
      if idx * idx + idy * idy < pickup_radius_sq {
        item.alive = false
        let is_health = item.kind == Health
        self.events.push(ItemPickup(item.x, item.y, is_health))
        if is_health {
          self.player.hp = @cmp.minimum(self.player_stats.max_hp, self.player.hp + 2)
        } else {
          self.score = self.score + 5
        }
      }
    }
  }
  // 14. Compact items
  compact_items(self.items)
  // 15. Player-enemy separation (push physics)
  for enemy in self.enemies {
    if enemy.alive {
      let sep_dx = self.player.x - enemy.x
      let sep_dy = self.player.y - enemy.y
      let sep_dist_sq = sep_dx * sep_dx + sep_dy * sep_dy
      let min_dist = (self.player.size + enemy.size) / 2.0
      if sep_dist_sq < min_dist * min_dist && sep_dist_sq > 0.000001 {
        let sep_dist = sep_dist_sq.sqrt()
        let push = (min_dist - sep_dist) / 2.0
        let nx = sep_dx / sep_dist
        let ny = sep_dy / sep_dist
        let px_new = self.player.x + nx * push
        let py_new = self.player.y + ny * push
        if not(check_wall_collision(self.dungeon.grid, px_new, self.player.y, self.player.size)) {
          self.player.x = px_new
        } else {
          enemy.x = enemy.x - nx * push
        }
        if not(check_wall_collision(self.dungeon.grid, self.player.x, py_new, self.player.size)) {
          self.player.y = py_new
        } else {
          enemy.y = enemy.y - ny * push
        }
        let ex_new = enemy.x - nx * push
        let ey_new = enemy.y - ny * push
        if not(check_wall_collision(self.dungeon.grid, ex_new, enemy.y, enemy.size)) {
          enemy.x = ex_new
        }
        if not(check_wall_collision(self.dungeon.grid, enemy.x, ey_new, enemy.size)) {
          enemy.y = ey_new
        }
      }
    }
  }
  // 16. Enemy-enemy separation
  for i = 0; i < self.enemies.length(); i = i + 1 {
    for j = i + 1; j < self.enemies.length(); j = j + 1 {
      let a = self.enemies[i]
      let b = self.enemies[j]
      if a.alive && b.alive {
        let sep_dx = a.x - b.x
        let sep_dy = a.y - b.y
        let sep_dist_sq = sep_dx * sep_dx + sep_dy * sep_dy
        let min_dist = (a.size + b.size) / 2.0
        if sep_dist_sq < min_dist * min_dist && sep_dist_sq > 0.000001 {
          let sep_dist = sep_dist_sq.sqrt()
          let push = (min_dist - sep_dist) / 2.0
          let nx = sep_dx / sep_dist
          let ny = sep_dy / sep_dist
          let ax_new = a.x + nx * push
          let ay_new = a.y + ny * push
          if not(check_wall_collision(self.dungeon.grid, ax_new, a.y, a.size)) {
            a.x = ax_new
          }
          if not(check_wall_collision(self.dungeon.grid, a.x, ay_new, a.size)) {
            a.y = ay_new
          }
          let bx_new = b.x - nx * push
          let by_new = b.y - ny * push
          if not(check_wall_collision(self.dungeon.grid, bx_new, b.y, b.size)) {
            b.x = bx_new
          }
          if not(check_wall_collision(self.dungeon.grid, b.x, by_new, b.size)) {
            b.y = by_new
          }
        }
      }
    }
  }
  // 17. Floor completion check
  let mut all_dead = true
  for enemy in self.enemies {
    if enemy.alive {
      all_dead = false
      break
    }
  }
  if all_dead && self.mode == Playing {
    self.reset_floor()
    self.events.push(FloorComplete)
  }
  // 18. Decrement player damage_timer and iframe_timer
  if self.player.damage_timer > 0 {
    self.player.damage_timer = self.player.damage_timer - 1
  }
  if self.player.iframe_timer > 0 {
    self.player.iframe_timer = self.player.iframe_timer - 1
  }
  if self.screen_flash > 0 {
    self.screen_flash = self.screen_flash - 1
  }
}

pub fn GameWorld::tick_auto(self : GameWorld) -> Unit {
  // 1. Call auto_play_input() to get (dx, dy, enemy_idx, _)
  let (dx, dy, enemy_idx, _) = auto_play_input(self)
  // 2. Call auto_activate_skills(enemy_idx)
  self.auto_activate_skills(enemy_idx)
  // 3. Every 60 frames: auto_equip_best(), auto_learn_skills()
  if self.frame_count % 60 == 0 {
    self.auto_equip_best()
    self.auto_learn_skills()
  }
  // 4. Call tick(dx, dy)
  self.tick(dx, dy)
}
