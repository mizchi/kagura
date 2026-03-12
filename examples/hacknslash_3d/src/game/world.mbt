// GameWorld: pure game state and logic, no rendering dependencies

///|
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
  mut chain_lightning_cooldown_timer : Int
  mut splitting_fireball_cooldown_timer : Int
  mut ice_nova_cooldown_timer : Int
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
  mut enemy_separation_cell_heads : Array[Int]
  mut enemy_separation_next_indices : Array[Int]
  mut enemy_separation_cell_indices : Array[Int]
}

///|
pub fn GameWorld::new(
  seed~ : Int,
  params? : BalanceParams = BalanceParams::default(),
) -> GameWorld {
  let dungeon = generate_dungeon(seed)
  let equipment = Equipment::new()
  let skills = SkillTree::new()
  let player_stats = compute_player_stats(
    equipment,
    skills,
    base_hp=params.player_base_hp.to_int(),
  )
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
  let enemies = spawn_enemies_in_rooms_with_params(
    dungeon.rooms,
    0,
    seed,
    params,
  )
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
    chain_lightning_cooldown_timer: 0,
    splitting_fireball_cooldown_timer: 0,
    ice_nova_cooldown_timer: 0,
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
    enemy_separation_cell_heads: Array::make(
      enemy_separation_grid_cols() * enemy_separation_grid_rows(),
      -1,
    ),
    enemy_separation_next_indices: [],
    enemy_separation_cell_indices: [],
  }
}

///|
pub fn GameWorld::drain_events(self : GameWorld) -> Array[GameEvent] {
  let result = self.events
  self.events = []
  result
}

///|
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

///|
pub fn GameWorld::apply_dungeon(
  self : GameWorld,
  seed : Int,
  floor : Int,
) -> Unit {
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
  self.enemies = spawn_enemies_for_floor_with_params(
    dungeon.rooms,
    0,
    seed,
    floor,
    self.params,
  )
  self.items = []
  self.projectiles = []
  self.chain_lightning_cooldown_timer = 0
  self.splitting_fireball_cooldown_timer = 0
  self.ice_nova_cooldown_timer = 0
  // Reset auto-play navigation
  self.auto_cleared_rooms = Array::make(self.dungeon.rooms.length(), false)
  self.auto_nav_target = None
  self.auto_nav_path = []
  self.auto_nav_index = 0
}

///|
pub fn GameWorld::reset_floor(self : GameWorld) -> Unit {
  self.seed = self.seed + 1
  self.floor = self.floor + 1
  self.apply_dungeon(self.seed, self.floor)
  self.floor_announce_timer = 120
}

///|
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

///|
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

///|

///|
fn enemy_separation_grid_cols() -> Int {
  world_w.to_int() / 20 + 2
}

///|
fn enemy_separation_grid_rows() -> Int {
  world_h.to_int() / 20 + 2
}

///|
fn enemy_separation_grid_axis_index(pos : Double, max_cells : Int) -> Int {
  let raw = (pos / 20.0).to_int()
  @cmp.maximum(0, @cmp.minimum(max_cells - 1, raw))
}

///|
fn enemy_separation_grid_index(
  x : Double,
  y : Double,
  cols : Int,
  rows : Int,
) -> Int {
  let col = enemy_separation_grid_axis_index(x, cols)
  let row = enemy_separation_grid_axis_index(y, rows)
  row * cols + col
}

///|
fn resolve_enemy_enemy_pair(
  enemies : Array[Enemy],
  grid : @terrain.Grid2D,
  a_idx : Int,
  b_idx : Int,
) -> Unit {
  let a = enemies[a_idx]
  let b = enemies[b_idx]
  let min_dist = (a.size + b.size) / 2.0
  let sep_dx = a.x - b.x
  if sep_dx.abs() >= min_dist {
    return
  }
  let sep_dy = a.y - b.y
  if sep_dy.abs() >= min_dist {
    return
  }
  let sep_dist_sq = sep_dx * sep_dx + sep_dy * sep_dy
  if sep_dist_sq < min_dist * min_dist && sep_dist_sq > 0.000001 {
    let sep_dist = sep_dist_sq.sqrt()
    let push = (min_dist - sep_dist) / 2.0
    let nx = sep_dx / sep_dist
    let ny = sep_dy / sep_dist
    let ax_new = a.x + nx * push
    let ay_new = a.y + ny * push
    if not(check_wall_collision(grid, ax_new, a.y, a.size)) {
      a.x = ax_new
    }
    if not(check_wall_collision(grid, a.x, ay_new, a.size)) {
      a.y = ay_new
    }
    let bx_new = b.x - nx * push
    let by_new = b.y - ny * push
    if not(check_wall_collision(grid, bx_new, b.y, b.size)) {
      b.x = bx_new
    }
    if not(check_wall_collision(grid, b.x, by_new, b.size)) {
      b.y = by_new
    }
  }
}

///|
fn GameWorld::prepare_enemy_separation_scratch(self : GameWorld) -> Unit {
  for i = 0; i < self.enemy_separation_cell_heads.length(); i = i + 1 {
    self.enemy_separation_cell_heads[i] = -1
  }
  while self.enemy_separation_next_indices.length() < self.enemies.length() {
    self.enemy_separation_next_indices.push(-1)
  }
  while self.enemy_separation_cell_indices.length() < self.enemies.length() {
    self.enemy_separation_cell_indices.push(0)
  }
}

///|
fn GameWorld::resolve_enemy_enemy_cell_neighbors(
  self : GameWorld,
  a_idx : Int,
  cell : Int,
  cols : Int,
  rows : Int,
) -> Unit {
  let col = cell % cols
  let row = cell / cols
  let mut b_idx = self.enemy_separation_next_indices[a_idx]
  while b_idx >= 0 {
    resolve_enemy_enemy_pair(self.enemies, self.dungeon.grid, a_idx, b_idx)
    b_idx = self.enemy_separation_next_indices[b_idx]
  }
  if col + 1 < cols {
    let mut east_idx = self.enemy_separation_cell_heads[cell + 1]
    while east_idx >= 0 {
      resolve_enemy_enemy_pair(self.enemies, self.dungeon.grid, a_idx, east_idx)
      east_idx = self.enemy_separation_next_indices[east_idx]
    }
  }
  if row + 1 < rows {
    let south = cell + cols
    let mut south_idx = self.enemy_separation_cell_heads[south]
    while south_idx >= 0 {
      resolve_enemy_enemy_pair(
        self.enemies,
        self.dungeon.grid,
        a_idx,
        south_idx,
      )
      south_idx = self.enemy_separation_next_indices[south_idx]
    }
    if col > 0 {
      let mut southwest_idx = self.enemy_separation_cell_heads[south - 1]
      while southwest_idx >= 0 {
        resolve_enemy_enemy_pair(
          self.enemies,
          self.dungeon.grid,
          a_idx,
          southwest_idx,
        )
        southwest_idx = self.enemy_separation_next_indices[southwest_idx]
      }
    }
    if col + 1 < cols {
      let mut southeast_idx = self.enemy_separation_cell_heads[south + 1]
      while southeast_idx >= 0 {
        resolve_enemy_enemy_pair(
          self.enemies,
          self.dungeon.grid,
          a_idx,
          southeast_idx,
        )
        southeast_idx = self.enemy_separation_next_indices[southeast_idx]
      }
    }
  }
}

///|
pub fn GameWorld::resolve_enemy_enemy_separation(self : GameWorld) -> Unit {
  self.prepare_enemy_separation_scratch()
  let cols = enemy_separation_grid_cols()
  let rows = enemy_separation_grid_rows()
  for enemy_index = 0
      enemy_index < self.enemies.length()
      enemy_index = enemy_index + 1 {
    if not(self.enemies[enemy_index].alive) {
      self.enemy_separation_next_indices[enemy_index] = -1
      continue
    }
    let cell = enemy_separation_grid_index(
      self.enemies[enemy_index].x,
      self.enemies[enemy_index].y,
      cols,
      rows,
    )
    self.enemy_separation_cell_indices[enemy_index] = cell
    self.enemy_separation_next_indices[enemy_index] = self.enemy_separation_cell_heads[cell]
    self.enemy_separation_cell_heads[cell] = enemy_index
  }
  for enemy_index = 0
      enemy_index < self.enemies.length()
      enemy_index = enemy_index + 1 {
    if not(self.enemies[enemy_index].alive) {
      continue
    }
    self.resolve_enemy_enemy_cell_neighbors(
      enemy_index,
      self.enemy_separation_cell_indices[enemy_index],
      cols,
      rows,
    )
  }
}

///|
pub fn start_dash(world : GameWorld, dir_x : Double, dir_y : Double) -> Unit {
  let p = world.params
  world.player.dash_timer = p.dash_duration.to_int()
  world.player.dash_cooldown_timer = world.player_stats.dash_cooldown
  world.player.dash_vx = dir_x * p.player_speed * p.dash_speed_mult
  world.player.dash_vy = dir_y * p.player_speed * p.dash_speed_mult
  world.player.iframe_timer = p.dash_duration.to_int()
  world.events.push(DashTrail(world.player.x, world.player.y))
}

///|
pub fn GameWorld::tick_enemy_ai_phase(self : GameWorld) -> Unit {
  self.tick_enemy_ai_phase_with_grid(self.dungeon.grid)
}

///|
pub fn GameWorld::tick_enemy_ai_phase_with_grid(
  self : GameWorld,
  collision_grid : @terrain.Grid2D,
) -> Unit {
  update_enemy_ai(
    self.enemies,
    self.player,
    collision_grid,
    self.dungeon.rooms,
    self.frame_count,
    self.projectiles,
    params=self.params,
  )
}

///|
pub fn GameWorld::tick_enemy_movement_and_contact_phase(
  self : GameWorld,
) -> Unit {
  let player_x = self.player.x
  let player_y = self.player.y
  let player_half = self.player.size / 2.0
  let mut can_contact_player = self.player.iframe_timer <= 0
  let enemy_contact_damage = self.params.enemy_contact_damage.to_int()
  for enemy in self.enemies {
    if enemy.alive {
      if enemy.vx != 0.0 || enemy.vy != 0.0 {
        let (ex, ey) = slide_move(
          self.dungeon.grid,
          enemy.x,
          enemy.y,
          enemy.vx,
          enemy.vy,
          enemy.size,
        )
        enemy.x = ex
        enemy.y = ey
      }
      enemy.vx = 0.0
      enemy.vy = 0.0
      if can_contact_player {
        let overlap_half = player_half + enemy.size / 2.0
        let dx = (player_x - enemy.x).abs()
        if dx < overlap_half {
          let dy = (player_y - enemy.y).abs()
          if dy < overlap_half {
            self.deal_player_damage(enemy_contact_damage)
            can_contact_player = false
          }
        }
      }
    }
    if enemy.damage_timer > 0 {
      enemy.damage_timer = enemy.damage_timer - 1
    }
  }
}

///|
pub fn GameWorld::tick_projectiles_phase(self : GameWorld) -> Unit {
  let spawned_projectiles : Array[Projectile] = []
  for proj in self.projectiles {
    if proj.alive {
      proj.x = proj.x + proj.vx
      proj.y = proj.y + proj.vy
      if proj.is_player &&
        self.frame_count % splitting_fireball_trail_interval == 0 {
        match proj.kind {
          Fireball(_) => self.events.push(FireballTrail(proj.x, proj.y))
          _ => ()
        }
      }
      if is_wall_at(self.dungeon.grid, proj.x, proj.y) {
        match proj.kind {
          Fireball(remaining_splits) if proj.is_player =>
            explode_player_fireball(
              self, proj, spawned_projectiles, remaining_splits,
            )
          _ => proj.alive = false
        }
      }
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
  process_player_projectiles(self, spawned_projectiles)
  for projectile in spawned_projectiles {
    self.projectiles.push(projectile)
  }
  compact_projectiles(self.projectiles)
}

///|
pub fn GameWorld::tick_items_phase(self : GameWorld) -> Unit {
  for item in self.items {
    if item.alive {
      if item.vx != 0.0 || item.vy != 0.0 {
        let (nx, ny) = slide_move(
          self.dungeon.grid,
          item.x,
          item.y,
          item.vx,
          item.vy,
          4.0,
        )
        item.x = nx
        item.y = ny
        item.vx = item.vx * 0.85
        item.vy = item.vy * 0.85
        if item.vx * item.vx + item.vy * item.vy < 0.01 {
          item.vx = 0.0
          item.vy = 0.0
        }
      }
      if self.frame_count - item.spawn_frame > 600 {
        item.alive = false
        continue
      }
      let idx = item.x - self.player.x
      let idy = item.y - self.player.y
      if idx * idx + idy * idy < pickup_radius_sq {
        match item.kind {
          Health => {
            item.alive = false
            self.events.push(ItemPickup(item.x, item.y, true))
            self.player.hp = @cmp.minimum(
              self.player_stats.max_hp,
              self.player.hp + 2,
            )
          }
          Score => {
            item.alive = false
            self.events.push(ItemPickup(item.x, item.y, false))
            self.score = self.score + 5
          }
          Equipment(data) =>
            if self.collect_equipment_pickup(data) {
              item.alive = false
              self.events.push(ItemPickup(item.x, item.y, false))
            }
        }
      }
    }
  }
  compact_items(self.items)
}

///|
pub fn GameWorld::tick_player_enemy_separation_phase(self : GameWorld) -> Unit {
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
        if not(
            check_wall_collision(
              self.dungeon.grid,
              px_new,
              self.player.y,
              self.player.size,
            ),
          ) {
          self.player.x = px_new
        } else {
          enemy.x = enemy.x - nx * push
        }
        if not(
            check_wall_collision(
              self.dungeon.grid,
              self.player.x,
              py_new,
              self.player.size,
            ),
          ) {
          self.player.y = py_new
        } else {
          enemy.y = enemy.y - ny * push
        }
        let ex_new = enemy.x - nx * push
        let ey_new = enemy.y - ny * push
        if not(
            check_wall_collision(self.dungeon.grid, ex_new, enemy.y, enemy.size),
          ) {
          enemy.x = ex_new
        }
        if not(
            check_wall_collision(self.dungeon.grid, enemy.x, ey_new, enemy.size),
          ) {
          enemy.y = ey_new
        }
      }
    }
  }
}

///|
pub fn GameWorld::tick_floor_completion_phase(self : GameWorld) -> Unit {
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
}

///|
pub fn GameWorld::tick_player_timers_phase(self : GameWorld) -> Unit {
  if self.player.damage_timer > 0 {
    self.player.damage_timer = self.player.damage_timer - 1
  }
  if self.player.iframe_timer > 0 {
    self.player.iframe_timer = self.player.iframe_timer - 1
  }
  if self.screen_flash > 0 {
    self.screen_flash = self.screen_flash - 1
  }
  if self.chain_lightning_cooldown_timer > 0 {
    self.chain_lightning_cooldown_timer = self.chain_lightning_cooldown_timer -
      1
  }
  if self.splitting_fireball_cooldown_timer > 0 {
    self.splitting_fireball_cooldown_timer = self.splitting_fireball_cooldown_timer -
      1
  }
  if self.ice_nova_cooldown_timer > 0 {
    self.ice_nova_cooldown_timer = self.ice_nova_cooldown_timer - 1
  }
}

///|
pub fn GameWorld::tick(self : GameWorld, dx : Double, dy : Double) -> Unit {
  self.tick_with_enemy_ai_grid(dx, dy, self.dungeon.grid)
}

///|
pub fn GameWorld::tick_with_enemy_ai_grid(
  self : GameWorld,
  dx : Double,
  dy : Double,
  enemy_ai_grid : @terrain.Grid2D,
) -> Unit {
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
      self.dungeon.grid,
      self.player.x,
      self.player.y,
      self.player.dash_vx,
      self.player.dash_vy,
      self.player.size,
    )
    self.player.x = px
    self.player.y = py
  } else {
    // 6. Normal movement with slide_move
    let effective_speed = self.params.player_speed *
      (1.0 + self.player_stats.speed_bonus)
    let (px, py) = slide_move(
      self.dungeon.grid,
      self.player.x,
      self.player.y,
      dx * effective_speed,
      dy * effective_speed,
      self.player.size,
    )
    self.player.x = px
    self.player.y = py
  }
  // 7. Clamp to world bounds
  let half = self.player.size / 2.0
  self.player.x = @cmp.maximum(
    half,
    @cmp.minimum(world_w - half, self.player.x),
  )
  self.player.y = @cmp.maximum(
    half,
    @cmp.minimum(world_h - half, self.player.y),
  )
  // 8. Auto-cast spell slots based on nearest visible enemy
  let (skill_enemy_idx, skill_enemy_dist_sq) = find_nearest_visible_enemy(self)
  self.auto_activate_spell_slots(skill_enemy_idx, skill_enemy_dist_sq)
  // 9. Auto-shoot: find_nearest_enemy -> shoot_arrow + push AttackTriggered
  if self.attack_timer > 0 {
    self.attack_timer = self.attack_timer - 1
  } else {
    let target = find_nearest_enemy(self, self.params.arrow_range)
    if target is Some(_) {
      let cdr = self.player_stats.cooldown_reduction
      let effective_cd = self.params.bow_cooldown * (1.0 - cdr)
      self.attack_timer = @cmp.maximum(3, effective_cd.to_int())
      shoot_arrow(self, target)
      self.events.push(AttackTriggered)
    }
  }
  // 10. Update enemy AI
  self.tick_enemy_ai_phase_with_grid(enemy_ai_grid)
  // 11. Enemy movement + contact damage
  self.tick_enemy_movement_and_contact_phase()
  // 12-13. Projectiles
  self.tick_projectiles_phase()
  // 14-15. Items
  self.tick_items_phase()
  // 16. Player-enemy separation (push physics)
  self.tick_player_enemy_separation_phase()
  // 17. Enemy-enemy separation
  self.resolve_enemy_enemy_separation()
  // 18. Floor completion check
  self.tick_floor_completion_phase()
  // 19. Decrement player damage_timer and iframe_timer
  self.tick_player_timers_phase()
}

///|
pub fn GameWorld::tick_auto(self : GameWorld) -> Unit {
  self.tick_auto_with_enemy_ai_grid(self.dungeon.grid)
}

///|
pub fn GameWorld::tick_auto_with_enemy_ai_grid(
  self : GameWorld,
  enemy_ai_grid : @terrain.Grid2D,
) -> Unit {
  // 1. Call auto_play_input() to get (dx, dy, enemy_idx, _)
  let (dx, dy, enemy_idx, _) = auto_play_input_with_nav_grid(
    self, enemy_ai_grid,
  )
  // 2. Call auto_activate_skills(enemy_idx)
  self.auto_activate_skills(enemy_idx)
  // 3. Every 60 frames: auto_equip_best(), auto_learn_skills()
  if self.frame_count % 60 == 0 {
    self.auto_equip_best()
    self.auto_learn_skills()
  }
  // 4. Call tick(dx, dy)
  self.tick_with_enemy_ai_grid(dx, dy, enemy_ai_grid)
}
