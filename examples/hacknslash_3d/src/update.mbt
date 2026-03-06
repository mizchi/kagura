// Game state construction, update logic, reset

fn GameState::new(seed~ : Int) -> GameState {
  let dungeon = generate_dungeon(seed)
  let player : Player = {
    x: dungeon.start_x,
    y: dungeon.start_y,
    hp: 10,
    max_hp: 10,
    size: 12.0,
    damage_timer: 0,
    iframe_timer: 0,
    facing_angle: 1.5708,
    dash_timer: 0,
    dash_cooldown_timer: 0,
    dash_vx: 0.0,
    dash_vy: 0.0,
  }
  let sw = screen_w.to_double()
  let sh = screen_h.to_double()
  let camera = @camera3d.OrbitCamera::new(
    @math3d.Vec3::new(player.x / tile_size, 0.0, player.y / tile_size),
    18.0,
    0.785, // yaw 45 degrees
    0.96,  // pitch ~55 degrees
    @math.PI / 5.0,
    sw / sh,
    0.1,
    100.0,
  )
  let lighting = @light3d.LightingEnvironment::new(
    @light3d.DirectionalLight::new(
      @math3d.Vec3::new(-0.3, -1.0, -0.5),
      @math3d.Vec3::one(),
      0.8,
    ),
    @light3d.AmbientLight::new(@math3d.Vec3::one(), 0.3),
  )
  let meshes = Meshes3D::new()
  let enemies = spawn_enemies_in_rooms(dungeon.rooms, 0, seed)
  let dungeon_graph = build_dungeon_graph(dungeon, meshes)
  {
    mode: mode_title,
    frame_count: 0,
    seed,
    floor: 1,
    score: 0,
    player,
    enemies,
    items: [],
    projectiles: [],
    dungeon,
    input: @inpututil.new_input_helper(),
    attack_timer: 0,
    screen_flash: 0,
    floor_announce_timer: 0,
    camera,
    lighting,
    shader3d: @gfx.new_shader_handle(100, @draw3d.shader3d_lit_untextured_wgsl()),
    shader3d_skinned: @gfx.new_shader_handle(101, @draw3d.shader3d_lit_skinned_wgsl()),
    meshes,
    dungeon_graph,
    character: PlayerCharacter::new(),
    enemy_models: EnemyModels::new(),
  }
}

fn GameState::reset_floor(self : GameState) -> Unit {
  self.seed = self.seed + 1
  let dungeon = generate_dungeon(self.seed)
  self.dungeon.grid = dungeon.grid
  self.dungeon.rooms.clear()
  for room in dungeon.rooms {
    self.dungeon.rooms.push(room)
  }
  self.dungeon.start_x = dungeon.start_x
  self.dungeon.start_y = dungeon.start_y
  self.player.x = dungeon.start_x
  self.player.y = dungeon.start_y
  self.floor = self.floor + 1
  self.enemies = spawn_enemies_for_floor(dungeon.rooms, 0, self.seed, self.floor)
  self.items = []
  self.projectiles = []
  self.floor_announce_timer = 120
  self.camera = self.camera.with_target(
    @math3d.Vec3::new(self.player.x / tile_size, 0.0, self.player.y / tile_size),
  )
  self.dungeon_graph = build_dungeon_graph(self.dungeon, self.meshes)
}

fn GameState::update(self : GameState, input : @core.InputSnapshot) -> Unit {
  self.frame_count = self.frame_count + 1
  @inpututil.update_input_helper(self.input, input)
  match self.mode {
    m if m == mode_title => self.update_title()
    m if m == mode_playing => self.update_playing()
    m if m == mode_gameover => self.update_gameover()
    _ => ()
  }
}

fn GameState::update_title(self : GameState) -> Unit {
  if @inpututil.is_confirm_just_pressed(self.input) {
    self.mode = mode_playing
  }
}

fn GameState::update_gameover(self : GameState) -> Unit {
  if @inpututil.is_confirm_just_pressed(self.input) {
    self.mode = mode_title
    self.floor = 1
    self.score = 0
    self.seed = 42
    let dungeon = generate_dungeon(self.seed)
    self.dungeon.grid = dungeon.grid
    self.dungeon.rooms.clear()
    for room in dungeon.rooms {
      self.dungeon.rooms.push(room)
    }
    self.dungeon.start_x = dungeon.start_x
    self.dungeon.start_y = dungeon.start_y
    self.player.x = dungeon.start_x
    self.player.y = dungeon.start_y
    self.player.hp = self.player.max_hp
    self.player.damage_timer = 0
    self.player.iframe_timer = 0
    self.enemies = spawn_enemies_for_floor(dungeon.rooms, 0, self.seed, 1)
    self.items = []
    self.projectiles = []
    self.floor_announce_timer = 0
    self.player.dash_timer = 0
    self.player.dash_cooldown_timer = 0
    self.camera = self.camera.with_target(
      @math3d.Vec3::new(self.player.x / tile_size, 0.0, self.player.y / tile_size),
    )
    self.dungeon_graph = build_dungeon_graph(self.dungeon, self.meshes)
  }
}

fn GameState::update_playing(self : GameState) -> Unit {
  // Floor announce timer
  if self.floor_announce_timer > 0 {
    self.floor_announce_timer = self.floor_announce_timer - 1
  }
  // Player movement
  let mut dx = 0.0
  let mut dy = 0.0
  if @inpututil.is_move_up(self.input.key_state) {
    dy = dy - 1.0
  }
  if @inpututil.is_move_down(self.input.key_state) {
    dy = dy + 1.0
  }
  if @inpututil.is_move_left(self.input.key_state) {
    dx = dx - 1.0
  }
  if @inpututil.is_move_right(self.input.key_state) {
    dx = dx + 1.0
  }
  // Normalize diagonal
  if dx != 0.0 && dy != 0.0 {
    let v = @vector.Vec2::new(dx, dy).normalize()
    dx = v.x
    dy = v.y
  }
  // Update facing
  if dx != 0.0 || dy != 0.0 {
    self.player.facing_angle = @math.atan2(dy, dx)
  }
  // Dash
  if self.player.dash_cooldown_timer > 0 {
    self.player.dash_cooldown_timer = self.player.dash_cooldown_timer - 1
  }
  if self.player.dash_timer > 0 {
    self.player.dash_timer = self.player.dash_timer - 1
    let next_x = self.player.x + self.player.dash_vx
    let next_y = self.player.y + self.player.dash_vy
    if not(check_wall_collision(self.dungeon.grid, next_x, self.player.y, self.player.size)) {
      self.player.x = next_x
    }
    if not(check_wall_collision(self.dungeon.grid, self.player.x, next_y, self.player.size)) {
      self.player.y = next_y
    }
  } else {
    let shift_pressed = @inpututil.is_key_just_pressed(self.input.key_state, 16)
    if shift_pressed && self.player.dash_cooldown_timer <= 0 && (dx != 0.0 || dy != 0.0) {
      self.player.dash_timer = dash_duration
      self.player.dash_cooldown_timer = dash_cooldown
      self.player.dash_vx = dx * player_speed * dash_speed_mult
      self.player.dash_vy = dy * player_speed * dash_speed_mult
      self.player.iframe_timer = dash_duration
    } else {
      let next_x = self.player.x + dx * player_speed
      let next_y = self.player.y + dy * player_speed
      if not(check_wall_collision(self.dungeon.grid, next_x, self.player.y, self.player.size)) {
        self.player.x = next_x
      }
      if not(check_wall_collision(self.dungeon.grid, self.player.x, next_y, self.player.size)) {
        self.player.y = next_y
      }
    }
  }
  // Clamp to world bounds
  let half = self.player.size / 2.0
  self.player.x = @cmp.maximum(half, @cmp.minimum(world_w - half, self.player.x))
  self.player.y = @cmp.maximum(half, @cmp.minimum(world_h - half, self.player.y))
  // Camera follow (3D: convert 2D coords to 3D)
  self.camera = self.camera.with_target(
    @math3d.Vec3::new(self.player.x / tile_size, 0.0, self.player.y / tile_size),
  )
  // Attack
  if self.attack_timer > 0 {
    self.attack_timer = self.attack_timer - 1
  }
  if @inpututil.is_confirm_just_pressed(self.input) && self.attack_timer <= 0 {
    self.attack_timer = attack_cooldown
    self.screen_flash = 2
    try_attack(self)
    self.character.trigger_attack()
  }
  // Update character animation
  self.character.update(1.0 / 60.0)
  self.enemy_models.update(1.0 / 60.0)
  // Enemy AI
  update_enemy_ai(self.enemies, self.player, self.dungeon.grid, self.frame_count, self.projectiles)
  // Apply enemy movement + collision
  for enemy in self.enemies {
    if enemy.alive {
      let enx = enemy.x + enemy.vx
      let eny = enemy.y + enemy.vy
      if not(check_wall_collision(self.dungeon.grid, enx, enemy.y, enemy.size)) {
        enemy.x = enx
      }
      if not(check_wall_collision(self.dungeon.grid, enemy.x, eny, enemy.size)) {
        enemy.y = eny
      }
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
          self.player.hp = self.player.hp - 1
          self.player.damage_timer = damage_flash_duration
          self.player.iframe_timer = iframe_duration
          self.screen_flash = 3
          if self.player.hp <= 0 {
            self.mode = mode_gameover
          }
        }
      }
    }
    if enemy.damage_timer > 0 {
      enemy.damage_timer = enemy.damage_timer - 1
    }
  }
  // Update projectiles
  let mut pi = 0
  while pi < self.projectiles.length() {
    let proj = self.projectiles[pi]
    if proj.alive {
      proj.x = proj.x + proj.vx
      proj.y = proj.y + proj.vy
      if is_wall_at(self.dungeon.grid, proj.x, proj.y) {
        proj.alive = false
      }
      if proj.alive && self.player.iframe_timer <= 0 {
        let pdx = proj.x - self.player.x
        let pdy = proj.y - self.player.y
        if pdx * pdx + pdy * pdy < 64.0 {
          self.player.hp = self.player.hp - proj.damage
          self.player.damage_timer = damage_flash_duration
          self.player.iframe_timer = iframe_duration
          self.screen_flash = 3
          proj.alive = false
          if self.player.hp <= 0 {
            self.mode = mode_gameover
          }
        }
      }
    }
    pi = pi + 1
  }
  self.projectiles = self.projectiles.filter(fn(p) { p.alive })
  // Item collection
  for item in self.items {
    if item.alive {
      if self.frame_count - item.spawn_frame > 600 {
        item.alive = false
        continue
      }
      let idx = item.x - self.player.x
      let idy = item.y - self.player.y
      if idx * idx + idy * idy < 64.0 {
        item.alive = false
        if item.kind == item_health {
          self.player.hp = @cmp.minimum(self.player.max_hp, self.player.hp + 2)
        } else {
          self.score = self.score + 5
        }
      }
    }
  }
  self.items = self.items.filter(fn(it) { it.alive })
  // Player-enemy separation
  for enemy in self.enemies {
    if enemy.alive {
      let sep_dx = self.player.x - enemy.x
      let sep_dy = self.player.y - enemy.y
      let sep_dist = (sep_dx * sep_dx + sep_dy * sep_dy).sqrt()
      let min_dist = (self.player.size + enemy.size) / 2.0
      if sep_dist < min_dist && sep_dist > 0.001 {
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
  // Enemy-enemy separation
  for i = 0; i < self.enemies.length(); i = i + 1 {
    for j = i + 1; j < self.enemies.length(); j = j + 1 {
      let a = self.enemies[i]
      let b = self.enemies[j]
      if a.alive && b.alive {
        let sep_dx = a.x - b.x
        let sep_dy = a.y - b.y
        let sep_dist = (sep_dx * sep_dx + sep_dy * sep_dy).sqrt()
        let min_dist = (a.size + b.size) / 2.0
        if sep_dist < min_dist && sep_dist > 0.001 {
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
  // Decrement timers
  if self.player.damage_timer > 0 {
    self.player.damage_timer = self.player.damage_timer - 1
  }
  if self.player.iframe_timer > 0 {
    self.player.iframe_timer = self.player.iframe_timer - 1
  }
  if self.screen_flash > 0 {
    self.screen_flash = self.screen_flash - 1
  }
  // Check all enemies dead -> next floor
  let mut all_dead = true
  for enemy in self.enemies {
    if enemy.alive {
      all_dead = false
      break
    }
  }
  if all_dead {
    self.reset_floor()
  }
}
