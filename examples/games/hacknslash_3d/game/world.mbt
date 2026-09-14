// GameWorld: pure game state and logic, no rendering dependencies

///|
pub(all) struct GameWorld {
  hunting_grounds : Bool
  mut atlas : WorldAtlas?
  mut authored_scene : AuthoredScene?
  params : BalanceParams
  mut archetype : CharacterArchetype
  build_policy : ArchetypeBuildPolicy
  mut mode : GameMode
  mut frame_count : Int
  mut seed : Int
  mut floor : Int
  mut score : Int
  player : Player
  mut enemies : Array[Enemy]
  mut chests : Array[TreasureChest]
  mut items : Array[ItemDrop]
  mut next_pickup_id : Int
  mut projectiles : Array[Projectile]
  mut dungeon : DungeonData
  mut attack_timer : Int
  mut player_weapon : PlayerWeaponKind
  mut hunter_preset : HunterPreset
  mut hunter_slots : Array[Int]
  mut cleaver_next : CleaverComboStep
  mut cleaver_combo_timer : Int
  mut weapon_attack : PlayerWeaponAttack?
  mut player_charge : PlayerCharge?
  summons : PlayerSummons
  arts : HunterArts
  mut charge_cooldown : Int
  mut screen_flash : Double
  mut floor_announce_timer : Int
  mut chain_lightning_cooldown_timer : Int
  mut homing_missile_cooldown_timer : Int
  mut splitting_fireball_cooldown_timer : Int
  mut ice_nova_cooldown_timer : Int
  inventory : Inventory
  equipment : Equipment
  skills : SkillTree
  mut level_progress : LevelProgression
  mut player_stats : PlayerStats
  mut ui_mode : UIMode
  mut ui_cursor : Int
  mut manual_combat : Bool
  mut auto_play : Bool
  mut auto_nav_target : @terrain.Point?
  mut auto_nav_path : Array[@terrain.Point]
  mut auto_nav_index : Int
  mut auto_cleared_rooms : Array[Bool]
  mut reward_cleared_rooms : Array[Bool]
  mut discovered_rooms : Array[Bool]
  mut discovered_rooms_version : Int
  mut select_cursor : Int
  mut cursor_x : Double
  mut cursor_y : Double
  mut telegraph_markers : Array[TelegraphMarker]
  mut item_log : Array[ItemLogEntry]
  mut events : Array[GameEvent]
  mut enemy_separation_cell_heads : Array[Int]
  mut enemy_separation_next_indices : Array[Int]
  mut enemy_separation_cell_indices : Array[Int]
}

///|
fn initial_discovered_rooms_for_dungeon(
  dungeon : DungeonData,
) -> (Array[Bool], Int) {
  let discovered = Array::make(dungeon.rooms.length(), false)
  let start_room = find_room_at(dungeon.rooms, dungeon.start_x, dungeon.start_y)
  if start_room >= 0 {
    discovered[start_room] = true
    return (discovered, 1)
  }
  (discovered, 0)
}

///|
pub fn GameWorld::new(
  seed~ : Int,
  params? : BalanceParams = BalanceParams::default(),
  archetype? : CharacterArchetype = default_character_archetype(),
  build_policy? : ArchetypeBuildPolicy = default_archetype_build_policy(),
  hunting_grounds? : Bool = false,
) -> GameWorld {
  let dungeon = if hunting_grounds {
    generate_world_region(seed, 0)
  } else {
    generate_dungeon(seed, params~)
  }
  let equipment = Equipment::new()
  if hunting_grounds {
    for item in archetype.starting_equipment() {
      ignore(equipment.equip(item))
    }
  }
  let skills = SkillTree::new_for_archetype(archetype)
  if hunting_grounds {
    equip_hunter_skills(skills, archetype~)
    skills.skill_points = 3
  }
  let player_stats = compute_player_stats(
    equipment,
    skills,
    base_hp=params.player_base_hp.to_int(),
    archetype=Some(archetype),
  )
  let level_progress = LevelProgression::new(config=params.levelup_config())
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
    counter_timer: 0,
    counter_cooldown_timer: 0,
  }
  let enemies = spawn_enemies_in_rooms_with_params(
    dungeon.rooms,
    0,
    seed,
    params,
  )
  if hunting_grounds {
    append_hunting_approach_enemies(enemies, dungeon, params, 1)
    append_hunting_site_enemies(enemies, dungeon, params, 1)
    configure_enemy_camps(enemies, seed)
  }
  let (discovered_rooms, discovered_rooms_version) = initial_discovered_rooms_for_dungeon(
    dungeon,
  )
  let world : GameWorld = {
    params,
    hunting_grounds,
    atlas: None,
    authored_scene: None,
    archetype,
    build_policy,
    mode: Title,
    frame_count: 0,
    seed,
    floor: 1,
    score: 0,
    player,
    enemies: if hunting_grounds {
      remove_blocked_hunting_spawns(enemies, dungeon)
    } else {
      enemies
    },
    chests: if hunting_grounds {
      hunting_chests()
    } else {
      []
    },
    items: [],
    next_pickup_id: 1,
    projectiles: [],
    dungeon,
    attack_timer: 0,
    hunter_preset: default_hunter_preset(archetype),
    hunter_slots: default_hunter_preset(archetype).profile().keys.copy(),
    player_weapon: default_hunter_preset(archetype).profile().weapon,
    cleaver_next: Opening,
    cleaver_combo_timer: 0,
    weapon_attack: None,
    player_charge: None,
    arts: HunterArts::new(),
    summons: PlayerSummons::new(),
    charge_cooldown: 0,
    screen_flash: 0.0,
    floor_announce_timer: 0,
    chain_lightning_cooldown_timer: 0,
    homing_missile_cooldown_timer: 0,
    splitting_fireball_cooldown_timer: 0,
    ice_nova_cooldown_timer: 0,
    inventory: if hunting_grounds {
      new_hunter_inventory(archetype~)
    } else {
      Inventory::new(20)
    },
    equipment,
    skills,
    level_progress,
    player_stats,
    ui_mode: UIMode::None,
    ui_cursor: 0,
    manual_combat: false,
    auto_play: false,
    auto_nav_target: None,
    auto_nav_path: [],
    auto_nav_index: 0,
    auto_cleared_rooms: Array::make(dungeon.rooms.length(), false),
    reward_cleared_rooms: Array::make(dungeon.rooms.length(), false),
    discovered_rooms,
    discovered_rooms_version,
    select_cursor: 0,
    cursor_x: 0.0,
    cursor_y: 0.0,
    telegraph_markers: [],
    item_log: [],
    events: [],
    enemy_separation_cell_heads: Array::make(
      enemy_separation_grid_cols() * enemy_separation_grid_rows(),
      -1,
    ),
    enemy_separation_next_indices: [],
    enemy_separation_cell_indices: [],
  }
  world.reset_world_atlas(seed)
  world
}

///|
pub fn GameWorld::apply_archetype(
  self : GameWorld,
  archetype : CharacterArchetype,
) -> Unit {
  self.archetype = archetype
  self.hunter_preset = default_hunter_preset(archetype)
  self.hunter_slots = self.hunter_preset.profile().keys.copy()
  self.player_weapon = self.hunter_preset.profile().weapon
  self.cancel_hunter_action()
  self.arts.strike = None
  self.weapon_attack = None
  self.reset_cleaver_combo()
  self.player_charge = None
  // Reset skills and apply archetype starting skills
  for node in self.skills.nodes {
    node.level = 0
  }
  self.skills.skill_points = 0
  for skill_id in archetype.starting_skill_ids() {
    let index = self.skills.find_index(skill_id)
    if index >= 0 {
      self.skills.nodes[index].level = 1
    }
  }
  // Recompute stats with new archetype
  if self.hunting_grounds {
    equip_hunter_skills(self.skills, archetype~)
    self.skills.skill_points = 3
  }
  self.player_stats = compute_player_stats(
    self.equipment,
    self.skills,
    base_hp=self.params.player_base_hp.to_int(),
    archetype=Some(archetype),
  )
  self.player.hp = self.player_stats.max_hp
}

///|
pub fn GameWorld::drain_events(self : GameWorld) -> Array[GameEvent] {
  let result = self.events
  self.events = []
  result
}

///|
pub fn GameWorld::deal_player_damage(
  self : GameWorld,
  raw_dmg : Int,
  source? : (Double, Double),
) -> Unit {
  // Counter stance: immune to all damage
  if self.player.counter_timer > 0 {
    return
  }
  let actual_dmg = self.guard_damage(
    @cmp.maximum(1, raw_dmg - self.player_stats.def),
    source,
  )
  if actual_dmg == 0 {
    return
  }
  self.player.hp = self.player.hp - actual_dmg
  self.player.damage_timer = damage_flash_duration
  self.player.iframe_timer = self.params.iframe_duration.to_int()
  self.screen_flash = 1.0
  self.events.push(PlayerHurt(self.player.x, self.player.y))
  self.events.push(PlayerDamageNumber(self.player.x, self.player.y, actual_dmg))
  self.events.push(HurtTriggered)
  if self.player.hp <= 0 {
    self.cancel_hunter_action()
    self.arts.strike = None
    self.summons.clear()
    self.mode = GameOver
  }
}

///|
pub fn GameWorld::apply_dungeon(
  self : GameWorld,
  seed : Int,
  floor : Int,
) -> Unit {
  self.summons.clear()
  self.cancel_hunter_action()
  self.arts.strike = None
  self.weapon_attack = None
  self.reset_cleaver_combo()
  self.player_charge = None
  let dungeon = match self.authored_scene {
    Some(scene) => scene_dungeon(scene)
    None =>
      if self.hunting_grounds {
        generate_world_region(seed, 0)
      } else {
        generate_dungeon(seed, floor~, params=self.params)
      }
  }
  self.dungeon.grid = dungeon.grid
  self.dungeon.terrain_surface = dungeon.terrain_surface
  self.dungeon.landscape = dungeon.landscape
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
  self.enemies = match self.authored_scene {
    Some(scene) => scene_enemies(scene, dungeon)
    None =>
      spawn_enemies_for_floor_with_params(
        dungeon.rooms,
        0,
        seed,
        floor,
        self.params,
      )
  }
  if self.hunting_grounds && self.authored_scene is None {
    append_hunting_approach_enemies(self.enemies, dungeon, self.params, floor)
    append_hunting_site_enemies(self.enemies, dungeon, self.params, floor)
    self.enemies = remove_blocked_hunting_spawns(self.enemies, dungeon)
    configure_enemy_camps(self.enemies, seed)
  }
  self.chests = if self.hunting_grounds && self.authored_scene is None {
    hunting_chests()
  } else {
    []
  }
  self.items = []
  self.projectiles = []
  self.chain_lightning_cooldown_timer = 0
  self.homing_missile_cooldown_timer = 0
  self.splitting_fireball_cooldown_timer = 0
  self.ice_nova_cooldown_timer = 0
  // Reset auto-play navigation
  self.auto_cleared_rooms = Array::make(self.dungeon.rooms.length(), false)
  self.reward_cleared_rooms = Array::make(self.dungeon.rooms.length(), false)
  let (discovered_rooms, discovered_rooms_version) = initial_discovered_rooms_for_dungeon(
    self.dungeon,
  )
  self.discovered_rooms = discovered_rooms
  self.discovered_rooms_version = discovered_rooms_version
  self.auto_nav_target = None
  self.auto_nav_path = []
  self.auto_nav_index = 0
  self.reset_world_atlas(seed)
}

///|
pub fn GameWorld::refresh_player_stats(self : GameWorld) -> Unit {
  self.player_stats = compute_player_stats(
    self.equipment,
    self.skills,
    base_hp=self.params.player_base_hp.to_int(),
    archetype=Some(self.archetype),
  )
  self.player.hp = @cmp.minimum(self.player.hp, self.player_stats.max_hp)
}

///|
pub fn GameWorld::open_levelup_ui_if_needed(self : GameWorld) -> Unit {
  if self.auto_play {
    return
  }
  if self.level_progress.pending_choices <= 0 ||
    self.level_progress.current_offers.length() == 0 {
    if self.ui_mode == LevelUp {
      self.ui_mode = UIMode::None
    }
    return
  }
  self.ui_mode = LevelUp
  self.ui_cursor = @cmp.maximum(
    0,
    @cmp.minimum(
      self.ui_cursor,
      self.level_progress.current_offers.length() - 1,
    ),
  )
}

///|
pub fn GameWorld::apply_levelup_offer_choice(
  self : GameWorld,
  offer_index : Int,
  offer_seed : Int,
) -> Bool {
  if !self.level_progress.choose_offer(
      self.skills,
      self.archetype,
      self.build_policy,
      offer_index,
      offer_seed,
    ) {
    return false
  }
  self.refresh_player_stats()
  if self.level_progress.pending_choices > 0 &&
    self.level_progress.current_offers.length() > 0 {
    self.ui_mode = LevelUp
    self.ui_cursor = 0
  } else if self.ui_mode == LevelUp {
    self.ui_mode = UIMode::None
    self.ui_cursor = 0
  }
  true
}

///|
pub fn GameWorld::mark_current_room_discovered(self : GameWorld) -> Unit {
  let room_index = find_room_at(
    self.dungeon.rooms,
    self.player.x,
    self.player.y,
  )
  if room_index >= 0 &&
    room_index < self.discovered_rooms.length() &&
    !self.discovered_rooms[room_index] {
    self.discovered_rooms[room_index] = true
    self.discovered_rooms_version = self.discovered_rooms_version + 1
  }
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
  resolve_creature_pair(enemies[a_idx], enemies[b_idx], grid)
}

///|
fn resolve_creature_pair(a : Enemy, b : Enemy, grid : @terrain.Grid2D) -> Unit {
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
  if sep_dist_sq < min_dist * min_dist {
    let sep_dist = sep_dist_sq.sqrt()
    let push = (min_dist - sep_dist) / 2.0
    let nx = if sep_dist > 0.000001 { sep_dx / sep_dist } else { 1.0 }
    let ny = if sep_dist > 0.000001 { sep_dy / sep_dist } else { 0.0 }
    let ax_new = a.x + nx * push
    let ay_new = a.y + ny * push
    if !check_wall_collision(grid, ax_new, a.y, a.size) {
      a.x = ax_new
    }
    if !check_wall_collision(grid, a.x, ay_new, a.size) {
      a.y = ay_new
    }
    let bx_new = b.x - nx * push
    let by_new = b.y - ny * push
    if !check_wall_collision(grid, bx_new, b.y, b.size) {
      b.x = bx_new
    }
    if !check_wall_collision(grid, b.x, by_new, b.size) {
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
    if !self.enemies[enemy_index].alive {
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
    if !self.enemies[enemy_index].alive {
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
  world.cancel_hunter_action()
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
    self.events,
    params=self.params,
    floor=self.floor,
    zombies=self.summons.zombies,
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
  let enemy_contact_damage = self.params.scale_enemy_damage_for_floor(
    self.params.enemy_contact_damage.to_int(),
    self.floor,
  )
  for enemy in self.enemies {
    if enemy.alive {
      if enemy.kind == Zombie && enemy.attack_motion == NoAttack {
        let shuffle = zombie_shuffle_speed(enemy)
        enemy.vx *= shuffle
        enemy.vy *= shuffle
      }
      let previous_x = enemy.x
      let previous_y = enemy.y
      if enemy.vx != 0.0 || enemy.vy != 0.0 {
        let (ex, ey) = slide_move(
          self.dungeon.grid,
          enemy.x,
          enemy.y,
          enemy.vx,
          enemy.vy,
          enemy.size,
        )
        if enemy.pounce_airborne() &&
          (
            (ex - enemy.x - enemy.vx).abs() > 0.01 ||
            (ey - enemy.y - enemy.vy).abs() > 0.01
          ) {
          enemy.stop_pounce()
        }
        if enemy.is_charging() &&
          (
            (ex - enemy.x - enemy.vx).abs() > 0.01 ||
            (ey - enemy.y - enemy.vy).abs() > 0.01
          ) {
          enemy.stop_charge()
        }
        enemy.x = ex
        enemy.y = ey
      }
      let moved_x = enemy.x - previous_x
      let moved_y = enemy.y - previous_y
      enemy.move_speed = (moved_x * moved_x + moved_y * moved_y).sqrt()
      if enemy.move_speed > 0.001 {
        enemy.move_angle = @math.atan2(moved_y, moved_x)
        enemy.travel_distance += enemy.move_speed
      }
      // Recoil is separate from AI velocity and survives every chase/cast update.
      if enemy.knockback_x.abs() + enemy.knockback_y.abs() > 0.05 {
        let (x, y) = slide_move(
          self.dungeon.grid,
          enemy.x,
          enemy.y,
          enemy.knockback_x,
          enemy.knockback_y,
          enemy.size,
        )
        enemy.x = x
        enemy.y = y
        enemy.knockback_x *= 0.65
        enemy.knockback_y *= 0.65
      } else {
        enemy.knockback_x = 0.0
        enemy.knockback_y = 0.0
      }
      enemy.vx = 0.0
      enemy.vy = 0.0
      if enemy.attack_hit_pending {
        enemy.attack_hit_pending = false
        for zombie in self.summons.zombies {
          if zombie.body.alive &&
            enemy_melee_hits(
              enemy,
              zombie.body.combat_target(),
              self.dungeon.grid,
            ) {
            hurt_summoned_zombie(zombie, enemy_contact_damage)
          }
        }
        if can_contact_player &&
          enemy_melee_hits(
            enemy,
            self.player.combat_target(),
            self.dungeon.grid,
          ) {
          self.deal_player_damage(
            enemy_contact_damage,
            source=(enemy.x, enemy.y),
          )
          can_contact_player = false
        }
      }
      if enemy.is_charging() {
        for zombie in self.summons.zombies {
          let body = zombie.body
          let half = (body.size + enemy.size) / 2.0
          if body.alive &&
            (body.x - enemy.x).abs() < half &&
            (body.y - enemy.y).abs() < half {
            hurt_summoned_zombie(zombie, enemy_contact_damage)
            enemy.stop_charge()
            break
          }
        }
      }
      // Body contact is damaging only during an active charge.
      if can_contact_player && enemy.is_charging() {
        let overlap_half = player_half + enemy.size / 2.0
        let dx = (player_x - enemy.x).abs()
        if dx < overlap_half {
          let dy = (player_y - enemy.y).abs()
          if dy < overlap_half {
            self.deal_player_damage(
              enemy_contact_damage,
              source=(enemy.x, enemy.y),
            )
            enemy.stop_charge()
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
      let prev_x = proj.x
      let prev_y = proj.y
      let homing = if proj.is_player {
        proj.kind.homing_profile()
      } else {
        None
      }
      if homing is Some(profile) {
        self.steer_projectile(proj, profile)
      }
      proj.x = proj.x + proj.vx
      proj.y = proj.y + proj.vy
      proj.age = proj.age + 1
      if proj.is_player &&
        self.frame_count % splitting_fireball_trail_interval == 0 {
        match proj.kind {
          Fireball(_) => self.events.push(FireballTrail(proj.x, proj.y))
          HomingMissile =>
            self.events.push(HomingMissileTrail(prev_x, prev_y, proj.x, proj.y))
          _ => ()
        }
      }
      if homing is Some(profile) && proj.age > profile.lifetime {
        proj.alive = false
        match proj.kind {
          HomingMissile => self.events.push(HomingMissileImpact(proj.x, proj.y))
          Fireball(_) => self.events.push(FireballBurst(proj.x, proj.y))
          _ => ()
        }
        // Expiration is visual only: no split, blast damage or duplicate impact.
        continue
      }
      if segment_hits_wall(
          self.dungeon.grid,
          prev_x,
          prev_y,
          proj.x,
          proj.y,
          0.0,
        ) {
        match proj.kind {
          Fireball(remaining_splits) if proj.is_player =>
            explode_player_fireball(
              self, proj, spawned_projectiles, remaining_splits,
            )
          HomingMissile if proj.is_player => {
            proj.alive = false
            self.events.push(HomingMissileImpact(proj.x, proj.y))
          }
          _ => proj.alive = false
        }
      }
      self.intercept_summon_projectile(proj, prev_x, prev_y)
      if proj.alive && !proj.is_player && self.player.iframe_timer <= 0 {
        let pdx = proj.x - self.player.x
        let pdy = proj.y - self.player.y
        if pdx * pdx + pdy * pdy < pickup_radius_sq {
          if self.player.counter_timer > 0 {
            // Counter: reflect the projectile back
            proj.vx = -proj.vx
            proj.vy = -proj.vy
            proj.is_player = true
            proj.damage = proj.damage * 2
            self.events.push(HitSparks(proj.x, proj.y))
          } else {
            self.deal_player_damage(
              proj.damage,
              source=(prev_x - proj.vx, prev_y - proj.vy),
            )
            proj.alive = false
          }
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
      if (self.atlas is None || self.authored_scene is Some(_)) &&
        self.frame_count - item.spawn_frame > 600 {
        item.alive = false
        continue
      }
      let idx = item.x - self.player.x
      let idy = item.y - self.player.y
      if item.pickup_blocked.or(false) {
        if idx * idx + idy * idy >= pickup_radius_sq {
          item.pickup_blocked = None
        }
        continue
      }
      if idx * idx + idy * idy < pickup_radius_sq {
        ignore(self.collect_ground_drop(item))
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
        if !check_wall_collision(
            self.dungeon.grid,
            px_new,
            self.player.y,
            self.player.size,
          ) {
          self.player.x = px_new
        } else {
          enemy.x = enemy.x - nx * push
        }
        if !check_wall_collision(
            self.dungeon.grid,
            self.player.x,
            py_new,
            self.player.size,
          ) {
          self.player.y = py_new
        } else {
          enemy.y = enemy.y - ny * push
        }
        let ex_new = enemy.x - nx * push
        let ey_new = enemy.y - ny * push
        if !check_wall_collision(self.dungeon.grid, ex_new, enemy.y, enemy.size) {
          enemy.x = ex_new
        }
        if !check_wall_collision(self.dungeon.grid, enemy.x, ey_new, enemy.size) {
          enemy.y = ey_new
        }
      }
    }
  }
}

///|
pub fn GameWorld::tick_meteor_damage_phase(self : GameWorld) -> Unit {
  for event in self.events {
    match event {
      // Create persistent telegraph markers from events
      MeteorCastStart(x, y, radius) =>
        add_telegraph_circle(self, x, y, radius, meteor_cast_frames)
      EnemyTelegraphRing(x, y, radius) =>
        add_telegraph_circle(self, x, y, radius, 40)
      GroundTelegraphLine(x0, y0, x1, y1) =>
        add_telegraph_line(self, x0, y0, x1, y1, beam_width, beam_cast_frames)
      BeamFire(x0, y0, x1, y1, is_player) =>
        if !is_player {
          for zombie in self.summons.zombies {
            if segment_circle_contact(
                x0,
                y0,
                x1,
                y1,
                zombie.body.x,
                zombie.body.y,
                beam_width / 2.0,
              )
              is Some(_) {
              hurt_summoned_zombie(
                zombie,
                self.params.scale_enemy_damage_for_floor(
                  self.params.enemy_contact_damage.to_int() * beam_damage_mult,
                  self.floor,
                ),
              )
            }
          }
          // Enemy beam: damage player if within beam width
          let beam_dx = x1 - x0
          let beam_dy = y1 - y0
          let beam_len_sq = beam_dx * beam_dx + beam_dy * beam_dy
          if beam_len_sq > 0.001 {
            let beam_len = beam_len_sq.sqrt()
            let nx = beam_dx / beam_len
            let ny = beam_dy / beam_len
            let px = self.player.x - x0
            let py = self.player.y - y0
            let proj = px * nx + py * ny
            if proj > 0.0 && proj < beam_len {
              let perp = (px * ny - py * nx).abs()
              if perp < beam_width / 2.0 && self.player.iframe_timer <= 0 {
                let dmg = self.params.scale_enemy_damage_for_floor(
                  self.params.enemy_contact_damage.to_int() * beam_damage_mult,
                  self.floor,
                )
                self.deal_player_damage(dmg)
              }
            }
          }
        } else {
          // Player beam: damage enemies along the line
          let beam_dx = x1 - x0
          let beam_dy = y1 - y0
          let beam_len_sq = beam_dx * beam_dx + beam_dy * beam_dy
          if beam_len_sq > 0.001 {
            let beam_len = beam_len_sq.sqrt()
            let nx = beam_dx / beam_len
            let ny = beam_dy / beam_len
            for enemy in self.enemies {
              if !enemy.alive {
                continue
              }
              let ex = enemy.x - x0
              let ey = enemy.y - y0
              let proj = ex * nx + ey * ny
              if proj > 0.0 && proj < beam_len {
                let perp = (ex * ny - ey * nx).abs()
                if perp < beam_width / 2.0 + enemy.size / 2.0 {
                  let dmg = self.player_stats.spell_power * beam_damage_mult
                  apply_player_damage_to_enemy(self, enemy, dmg, x0, y0)
                }
              }
            }
          }
        }
      EnemyAreaDamage(x, y, radius, damage) => {
        self.damage_summons_circle(x, y, radius, damage)
        let dx = self.player.x - x
        let dy = self.player.y - y
        if dx * dx + dy * dy <= radius * radius && self.player.iframe_timer <= 0 {
          self.deal_player_damage(damage)
        }
      }
      MeteorImpact(x, y, radius) => {
        self.damage_summons_circle(
          x,
          y,
          radius,
          self.params.scale_enemy_damage_for_floor(
            self.params.enemy_contact_damage.to_int() * meteor_damage_mult,
            self.floor,
          ),
        )
        let pdx = self.player.x - x
        let pdy = self.player.y - y
        if pdx * pdx + pdy * pdy <= radius * radius &&
          self.player.iframe_timer <= 0 {
          let meteor_dmg = self.params.scale_enemy_damage_for_floor(
            self.params.enemy_contact_damage.to_int() * meteor_damage_mult,
            self.floor,
          )
          self.deal_player_damage(meteor_dmg)
        }
      }
      _ => ()
    }
  }
}

///|
pub fn GameWorld::tick_floor_completion_phase(self : GameWorld) -> Unit {
  // Authored scenes are finite levels. Do not silently generate a new dungeon on completion.
  if self.authored_scene is Some(_) || self.atlas is Some(_) {
    return
  }
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
let room_clear_reward_area_threshold : Int = 80

///|
let room_clear_large_area_threshold : Int = 150

///|
pub fn GameWorld::tick_room_clear_rewards(self : GameWorld) -> Unit {
  // Check each room to see if all its enemies are dead
  for room_idx = 0
      room_idx < self.dungeon.rooms.length()
      room_idx = room_idx + 1 {
    if self.reward_cleared_rooms[room_idx] {
      continue
    }
    let room = self.dungeon.rooms[room_idx]
    let area = room.rect.w * room.rect.h
    if area < room_clear_reward_area_threshold {
      continue // small rooms don't get rewards
    }
    // Check if any enemy in this room is still alive
    let mut has_alive = false
    let mut had_enemies = false
    for enemy in self.enemies {
      if enemy.room_index == room_idx {
        had_enemies = true
        if enemy.alive {
          has_alive = true
          break
        }
      }
    }
    if !had_enemies || has_alive {
      continue
    }
    // Room cleared! Mark and spawn rewards
    self.reward_cleared_rooms[room_idx] = true
    let cx = (room.rect.x.to_double() + room.rect.w.to_double() / 2.0) *
      tile_size
    let cy = (room.rect.y.to_double() + room.rect.h.to_double() / 2.0) *
      tile_size
    self.events.push(RoomCleared(room_idx, cx, cy))
    // Reward: scale with room size
    let reward_count = if area >= room_clear_large_area_threshold {
      4 // large room: generous loot
    } else {
      2 // medium room: modest reward
    }
    let drop_seed = self.seed * 31 + room_idx * 97 + self.floor * 13
    for di = 0; di < reward_count; di = di + 1 {
      let item_seed = drop_seed + di * 37
      let angle = (item_seed % 628).to_double() / 100.0
      let scatter_speed = 1.0 + (item_seed % 80).to_double() / 100.0
      spawn_scatter_item(
        self,
        cx,
        cy,
        roll_drop_item_kind(self, item_seed),
        angle,
        scatter_speed,
      )
    }
    self.push_item_log("ROOM CLEAR!", 0xFFDD44)
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
  if self.player.counter_timer > 0 {
    self.player.counter_timer = self.player.counter_timer - 1
  }
  if self.player.counter_cooldown_timer > 0 {
    self.player.counter_cooldown_timer = self.player.counter_cooldown_timer - 1
  }
  if self.screen_flash > 0.01 {
    self.screen_flash = self.screen_flash * 0.92
  } else {
    self.screen_flash = 0.0
  }
  if self.chain_lightning_cooldown_timer > 0 {
    self.chain_lightning_cooldown_timer = self.chain_lightning_cooldown_timer -
      1
  }
  if self.homing_missile_cooldown_timer > 0 {
    self.homing_missile_cooldown_timer = self.homing_missile_cooldown_timer - 1
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
let item_log_duration : Int = 180 // ~3 seconds at 60fps

///|
let item_log_max_entries : Int = 8

///|
pub fn GameWorld::push_item_log(
  self : GameWorld,
  text : String,
  color : Int,
) -> Unit {
  self.item_log.push({ text, color, frames_remaining: item_log_duration, })
  // Trim oldest if over limit
  for ;; {
    if self.item_log.length() <= item_log_max_entries {
      break
    }
    ignore(self.item_log.remove(0))
  }
}

///|
pub fn GameWorld::tick_item_log(self : GameWorld) -> Unit {
  let still_active : Array[ItemLogEntry] = []
  for entry in self.item_log {
    entry.frames_remaining = entry.frames_remaining - 1
    if entry.frames_remaining > 0 {
      still_active.push(entry)
    }
  }
  self.item_log = still_active
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
  // 3. Update facing angle: aim at nearest enemy (twin-stick style)
  // Fall back to movement direction only when no enemy is in range
  let aim_target : Enemy? = if self.manual_combat && !self.auto_play {
    None
  } else {
    find_nearest_enemy(self, self.params.arrow_range)
  }
  match aim_target {
    Some(enemy) => {
      let adx = enemy.x - self.player.x
      let ady = enemy.y - self.player.y
      if adx * adx + ady * ady > 0.001 {
        self.player.facing_angle = @math.atan2(ady, adx)
      }
    }
    None =>
      if (dx != 0.0 || dy != 0.0) &&
        (!self.manual_combat || self.attack_timer <= 0) &&
        !self.hunter_action_locked() {
        self.player.facing_angle = @math.atan2(dy, dx)
      }
  }
  if self.charge_cooldown > 0 {
    self.charge_cooldown -= 1
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
  } else if self.player_charge is Some(_) || self.arts.action is Some(_) {
    // Charge owns movement until recovery ends.
  } else {
    // 6. Normal movement with slide_move
    let effective_speed = self.params.player_speed *
      (1.0 + self.player_stats.speed_bonus) *
      (if self.arts.guarding {
        0.35
      } else if self.arts.whirlwind.active {
        0.75
      } else {
        1.0
      })
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
  self.tick_player_charge(enemy_ai_grid)
  self.tick_hunter_arts(enemy_ai_grid)
  self.mark_current_room_discovered()
  self.tick_player_weapon_attack()
  // 8. Auto-cast spell slots based on nearest visible enemy
  let (skill_enemy_idx, skill_enemy_dist_sq) = find_nearest_visible_enemy(self)
  if (!self.manual_combat || self.auto_play) &&
    self.weapon_attack is None &&
    self.player_charge is None {
    self.auto_activate_spell_slots(skill_enemy_idx, skill_enemy_dist_sq)
  }
  // 9. Auto-attack: archetype-specific basic attack
  if self.attack_timer > 0 {
    self.attack_timer = self.attack_timer - 1
  } else if self.manual_combat && self.auto_play {
    let target = find_nearest_enemy(self, self.player_weapon.profile().reach)
    if target is Some(enemy) {
      let _ = self.request_basic_attack(
        @math.atan2(enemy.y - self.player.y, enemy.x - self.player.x),
      )
    }
  } else if !self.manual_combat {
    match self.archetype {
      Melee => {
        // Melee: circular AoE slash around player
        let target = find_nearest_enemy(self, melee_slash_radius)
        if target is Some(_) {
          let cdr = self.player_stats.cooldown_reduction
          let effective_cd = self.params.bow_cooldown * (1.0 - cdr)
          self.attack_timer = @cmp.maximum(3, effective_cd.to_int())
          melee_slash(self)
          self.events.push(AttackTriggered)
        }
      }
      Mage => {
        // Mage: chain lightning as basic attack
        let target = find_nearest_enemy(self, chain_lightning_range)
        if target is Some(_) {
          if cast_chain_lightning(self) {
            self.events.push(AttackTriggered)
          }
        }
      }
      _ => {
        // Ranged: shoot arrow at target
        let target = find_nearest_enemy(self, self.params.arrow_range)
        if target is Some(_) {
          let cdr = self.player_stats.cooldown_reduction
          let effective_cd = self.params.bow_cooldown * (1.0 - cdr)
          self.attack_timer = @cmp.maximum(3, effective_cd.to_int())
          shoot_arrow(self, target)
          self.events.push(AttackTriggered)
        }
      }
    }
  }
  self.tick_player_summons_with_grid(enemy_ai_grid)
  // 10. Update enemy AI
  self.tick_enemy_ai_phase_with_grid(enemy_ai_grid)
  // 10b. Process meteor impacts (damage in game logic, not render layer)
  self.tick_meteor_damage_phase()
  // 10c. Tick telegraph markers
  tick_telegraph_markers(self)
  // 10d. Tick item log
  self.tick_item_log()
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
  self.resolve_summon_separation()
  // 17b. Room clear rewards (treasure drops for cleared large rooms)
  self.tick_room_clear_rewards()
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
  }
  // 4. Call tick(dx, dy)
  self.tick_with_enemy_ai_grid(dx, dy, enemy_ai_grid)
  if self.frame_count % 60 == 0 {
    self.auto_choose_levelup_offer()
  }
}
