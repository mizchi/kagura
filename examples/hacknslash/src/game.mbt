// Hack & Slash - Constants, State, Update, View

// === Constants ===

let screen_w : Int = 320

let screen_h : Int = 240

let tile_size : Double = 16.0

let map_cols : Int = 40

let map_rows : Int = 30

let world_w : Double = 640.0

let world_h : Double = 480.0

let player_speed : Double = 2.0

let enemy_speed_basic : Double = 0.8

let enemy_speed_fast : Double = 1.2

let enemy_speed_tank : Double = 0.4

let attack_range : Double = 24.0

let attack_cooldown : Int = 20

let damage_flash_duration : Int = 10

let chase_range : Double = 120.0

let knockback_strength : Double = 4.0

let iframe_duration : Int = 30

let path_update_interval : Int = 60

// Game mode constants
let mode_title : Int = 0

let mode_playing : Int = 1

let mode_gameover : Int = 2

// Enemy kind constants
let kind_basic : Int = 0

let kind_fast : Int = 1

let kind_tank : Int = 2

let kind_ranged : Int = 3

let kind_boss : Int = 4

// Item kind constants
let item_health : Int = 0

let item_score : Int = 1

// Dash constants
let dash_duration : Int = 8

let dash_cooldown : Int = 40

let dash_speed_mult : Double = 4.0

// === Data Structures ===

struct Player {
  mut x : Double
  mut y : Double
  mut hp : Int
  max_hp : Int
  size : Double
  mut damage_timer : Int
  mut iframe_timer : Int
  mut facing_angle : Double
  mut dash_timer : Int
  mut dash_cooldown_timer : Int
  mut dash_vx : Double
  mut dash_vy : Double
}

struct ItemDrop {
  x : Double
  y : Double
  kind : Int
  mut alive : Bool
  spawn_frame : Int
}

struct Projectile {
  mut x : Double
  mut y : Double
  vx : Double
  vy : Double
  mut alive : Bool
  damage : Int
}

struct Enemy {
  mut x : Double
  mut y : Double
  mut vx : Double
  mut vy : Double
  mut hp : Int
  max_hp : Int
  speed : Double
  size : Double
  mut alive : Bool
  mut damage_timer : Int
  kind : Int
  mut path_cache : Array[@terrain.Point]
  mut path_index : Int
  mut path_timer : Int
  mut shoot_cooldown : Int
  mut charge_timer : Int
  mut charge_cooldown : Int
}

// === Main Game State ===

struct GameState {
  mut mode : Int
  mut frame_count : Int
  mut seed : Int
  mut floor : Int
  mut score : Int
  player : Player
  mut enemies : Array[Enemy]
  mut items : Array[ItemDrop]
  mut projectiles : Array[Projectile]
  dungeon : DungeonData
  camera : @camera2d.Camera2D
  input : @inpututil.InputHelper
  mut attack_timer : Int
  mut screen_flash : Int
  mut floor_announce_timer : Int
}

// === Constructor ===

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
  let camera = @camera2d.Camera2D::new(
    screen_w.to_double(),
    screen_h.to_double(),
    world_w,
    world_h,
  )
  camera.follow_target(player.x, player.y)
  let enemies = spawn_enemies_in_rooms(dungeon.rooms, 0, seed)
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
    camera,
    input: @inpututil.new_input_helper(),
    attack_timer: 0,
    screen_flash: 0,
    floor_announce_timer: 0,
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
  self.camera.follow_target(self.player.x, self.player.y)
}

// === Update Logic ===

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
    self.camera.follow_target(self.player.x, self.player.y)
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
    // During dash: use dash velocity
    self.player.dash_timer = self.player.dash_timer - 1
    let next_x = self.player.x + self.player.dash_vx
    let next_y = self.player.y + self.player.dash_vy
    if !(check_wall_collision(self.dungeon.grid, next_x, self.player.y, self.player.size)) {
      self.player.x = next_x
    }
    if !(check_wall_collision(self.dungeon.grid, self.player.x, next_y, self.player.size)) {
      self.player.y = next_y
    }
  } else {
    // Normal movement
    // Initiate dash on Shift press
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
      if !(check_wall_collision(self.dungeon.grid, next_x, self.player.y, self.player.size)) {
        self.player.x = next_x
      }
      if !(check_wall_collision(self.dungeon.grid, self.player.x, next_y, self.player.size)) {
        self.player.y = next_y
      }
    }
  }
  // Clamp to world bounds
  let half = self.player.size / 2.0
  self.player.x = @cmp.maximum(half, @cmp.minimum(world_w - half, self.player.x))
  self.player.y = @cmp.maximum(half, @cmp.minimum(world_h - half, self.player.y))
  // Camera follow
  self.camera.follow_target(self.player.x, self.player.y)
  // Attack
  if self.attack_timer > 0 {
    self.attack_timer = self.attack_timer - 1
  }
  if @inpututil.is_confirm_just_pressed(self.input) && self.attack_timer <= 0 {
    self.attack_timer = attack_cooldown
    self.screen_flash = 2
    try_attack(self)
  }
  // Enemy AI
  update_enemy_ai(self.enemies, self.player, self.dungeon.grid, self.frame_count, self.projectiles)
  // Apply enemy movement + collision
  for enemy in self.enemies {
    if enemy.alive {
      let enx = enemy.x + enemy.vx
      let eny = enemy.y + enemy.vy
      if !(check_wall_collision(self.dungeon.grid, enx, enemy.y, enemy.size)) {
        enemy.x = enx
      }
      if !(check_wall_collision(self.dungeon.grid, enemy.x, eny, enemy.size)) {
        enemy.y = eny
      }
      enemy.vx = 0.0
      enemy.vy = 0.0
      // Contact damage (skip if player dashing)
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
      // Wall collision
      if is_wall_at(self.dungeon.grid, proj.x, proj.y) {
        proj.alive = false
      }
      // Player hit
      if proj.alive && self.player.iframe_timer <= 0 {
        let pdx = proj.x - self.player.x
        let pdy = proj.y - self.player.y
        if pdx * pdx + pdy * pdy < 64.0 {
          // 8.0^2
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
  // Remove dead projectiles
  self.projectiles = self.projectiles.filter(fn(p) { p.alive })
  // Item collection
  for item in self.items {
    if item.alive {
      // Expire after 600 frames
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
  // Player-enemy separation (with wall check)
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
        // Try pushing player, fall back to pushing enemy more
        let px_new = self.player.x + nx * push
        let py_new = self.player.y + ny * push
        if !(check_wall_collision(self.dungeon.grid, px_new, self.player.y, self.player.size)) {
          self.player.x = px_new
        } else {
          enemy.x = enemy.x - nx * push
        }
        if !(check_wall_collision(self.dungeon.grid, self.player.x, py_new, self.player.size)) {
          self.player.y = py_new
        } else {
          enemy.y = enemy.y - ny * push
        }
        // Try pushing enemy
        let ex_new = enemy.x - nx * push
        let ey_new = enemy.y - ny * push
        if !(check_wall_collision(self.dungeon.grid, ex_new, enemy.y, enemy.size)) {
          enemy.x = ex_new
        }
        if !(check_wall_collision(self.dungeon.grid, enemy.x, ey_new, enemy.size)) {
          enemy.y = ey_new
        }
      }
    }
  }
  // Enemy-enemy separation (with wall check)
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
          if !(check_wall_collision(self.dungeon.grid, ax_new, a.y, a.size)) {
            a.x = ax_new
          }
          if !(check_wall_collision(self.dungeon.grid, a.x, ay_new, a.size)) {
            a.y = ay_new
          }
          let bx_new = b.x - nx * push
          let by_new = b.y - ny * push
          if !(check_wall_collision(self.dungeon.grid, bx_new, b.y, b.size)) {
            b.x = bx_new
          }
          if !(check_wall_collision(self.dungeon.grid, b.x, by_new, b.size)) {
            b.y = by_new
          }
        }
      }
    }
  }
  // Decrement player timers
  if self.player.damage_timer > 0 {
    self.player.damage_timer = self.player.damage_timer - 1
  }
  if self.player.iframe_timer > 0 {
    self.player.iframe_timer = self.player.iframe_timer - 1
  }
  if self.screen_flash > 0 {
    self.screen_flash = self.screen_flash - 1
  }
  // Check all enemies dead → next floor
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

// Shift key code
let key_shift : Int = 16

// === View ===

fn GameState::view(self : GameState) -> @scene.SceneNode {
  match self.mode {
    m if m == mode_title => self.view_title()
    m if m == mode_playing => self.view_playing()
    m if m == mode_gameover => self.view_gameover()
    _ => @scene.rect(w=screen_w.to_double(), h=screen_h.to_double(), fill=0x000000)
  }
}

fn GameState::view_title(self : GameState) -> @scene.SceneNode {
  @scene.fragment([
    @scene.rect(w=screen_w.to_double(), h=screen_h.to_double(), fill=0x1A1A2E),
    @scene.label(
      x=screen_w.to_double() / 2.0,
      y=screen_h.to_double() / 2.0 - 30.0,
      content="HACK N SLASH",
      scale=2.0,
      color=0xFF4444,
    ),
    @scene.show(fn() { self.frame_count / 30 % 2 == 0 }, fn() {
      @scene.label(
        x=screen_w.to_double() / 2.0,
        y=screen_h.to_double() / 2.0 + 20.0,
        content="PRESS SPACE",
        color=0xFFCC00,
      )
    }),
  ])
}

fn GameState::view_gameover(self : GameState) -> @scene.SceneNode {
  @scene.fragment([
    @scene.rect(w=screen_w.to_double(), h=screen_h.to_double(), fill=0x2E0000),
    @scene.label(
      x=screen_w.to_double() / 2.0,
      y=screen_h.to_double() / 2.0 - 30.0,
      content="GAME OVER",
      color=0xFF0000,
      scale=2.0,
    ),
    @scene.label(
      x=screen_w.to_double() / 2.0,
      y=screen_h.to_double() / 2.0 + 5.0,
      content="FLOOR " + self.floor.to_string(),
      color=0xFFCC00,
    ),
    @scene.label(
      x=screen_w.to_double() / 2.0,
      y=screen_h.to_double() / 2.0 + 25.0,
      content="SCORE " + self.score.to_string(),
      scale=1.5,
    ),
    @scene.show(fn() { self.frame_count / 30 % 2 == 0 }, fn() {
      @scene.label(
        x=screen_w.to_double() / 2.0,
        y=screen_h.to_double() / 2.0 + 55.0,
        content="PRESS SPACE",
        color=0x888888,
      )
    }),
  ])
}

fn GameState::view_playing(self : GameState) -> @scene.SceneNode {
  let sw = screen_w.to_double()
  let sh = screen_h.to_double()
  let view_left = self.camera.x
  let view_top = self.camera.y
  let px = self.player.x - view_left
  let py = self.player.y - view_top
  let phs = self.player.size / 2.0
  let player_fill = if self.player.dash_timer > 0 {
    0x66DDFF
  } else if self.player.damage_timer > 0 {
    0xFFFFFF
  } else {
    0x00FFCC
  }
  @scene.fragment([
    // Background
    @scene.rect(w=sw, h=sh, fill=0x1A1A2E),
    // Tilemap with variation
    @scene.for_each(fn() {
      let nodes : Array[@scene.SceneNode] = []
      let start_col = @cmp.maximum(0, (view_left / tile_size).to_int())
      let end_col = @cmp.minimum(map_cols, ((view_left + sw) / tile_size).to_int() + 1)
      let start_row = @cmp.maximum(0, (view_top / tile_size).to_int())
      let end_row = @cmp.minimum(map_rows, ((view_top + sh) / tile_size).to_int() + 1)
      for row = start_row; row < end_row; row = row + 1 {
        for col = start_col; col < end_col; col = col + 1 {
          let tile = self.dungeon.grid.get(col, row)
          let sx = col.to_double() * tile_size - view_left
          let sy = row.to_double() * tile_size - view_top
          nodes.push(
            @scene.rect(x=sx, y=sy, w=tile_size, h=tile_size, fill=tile_color_varied(tile, col, row)),
          )
          // Wall shadow: add shadow on floor tiles adjacent to wall above
          if tile != @terrain.Wall && row > 0 && self.dungeon.grid.get(col, row - 1) == @terrain.Wall {
            nodes.push(
              @scene.rect(x=sx, y=sy, w=tile_size, h=1.0, fill=0x000000, alpha=0.3),
            )
          }
        }
      }
      nodes
    }),
    // Items
    @scene.for_each(fn() {
      let nodes : Array[@scene.SceneNode] = []
      for item in self.items {
        if item.alive {
          let ix = item.x - view_left
          let iy = item.y - view_top
          if ix >= -10.0 && ix <= sw + 10.0 && iy >= -10.0 && iy <= sh + 10.0 {
            let pulse = (0.6 + 0.4 * @math.sin(self.frame_count.to_double() * 0.1))
            let color = if item.kind == item_health { 0x00FF66 } else { 0x00FFFF }
            nodes.push(
              @scene.rect(x=ix - 3.0, y=iy - 3.0, w=6.0, h=6.0, fill=color, alpha=pulse),
            )
          }
        }
      }
      nodes
    }),
    // Projectiles
    @scene.for_each(fn() {
      let nodes : Array[@scene.SceneNode] = []
      for proj in self.projectiles {
        if proj.alive {
          let prx = proj.x - view_left
          let pry = proj.y - view_top
          if prx >= -5.0 && prx <= sw + 5.0 && pry >= -5.0 && pry <= sh + 5.0 {
            nodes.push(
              @scene.rect(x=prx - 2.0, y=pry - 2.0, w=4.0, h=4.0, fill=0xFF4466),
            )
          }
        }
      }
      nodes
    }),
    // Enemies with differentiated rendering
    @scene.for_each(fn() {
      let nodes : Array[@scene.SceneNode] = []
      for enemy in self.enemies {
        if enemy.alive {
          let sx = enemy.x - view_left
          let sy = enemy.y - view_top
          if sx >= -25.0 && sx <= sw + 25.0 && sy >= -25.0 && sy <= sh + 25.0 {
            let ehs = enemy.size / 2.0
            let fill = if enemy.damage_timer > 0 {
              0xFFFFFF
            } else {
              match enemy.kind {
                k if k == kind_fast => 0xFF8800
                k if k == kind_tank => 0x8844CC
                k if k == kind_ranged => 0x44AAFF
                k if k == kind_boss => 0xFF2266
                _ => 0xCC2222
              }
            }
            // Enemy body
            nodes.push(
              @scene.rect(x=sx - ehs, y=sy - ehs, w=enemy.size, h=enemy.size, fill=fill),
            )
            // Kind-specific decorations
            match enemy.kind {
              k if k == kind_fast => {
                // Small corner dots for diamond-like feel
                nodes.push(@scene.rect(x=sx - 1.0, y=sy - ehs - 2.0, w=2.0, h=2.0, fill=fill))
                nodes.push(@scene.rect(x=sx - 1.0, y=sy + ehs, w=2.0, h=2.0, fill=fill))
              }
              k if k == kind_tank => {
                // Cross mark in center
                nodes.push(@scene.line(x0=sx - ehs + 2.0, y0=sy, x1=sx + ehs - 2.0, y1=sy, color=0x220044))
                nodes.push(@scene.line(x0=sx, y0=sy - ehs + 2.0, x1=sx, y1=sy + ehs - 2.0, color=0x220044))
              }
              k if k == kind_ranged => {
                // Forward triangle indicator
                let angle = @math.atan2(self.player.y - enemy.y, self.player.x - enemy.x)
                let tx = sx + @math.cos(angle) * (ehs + 3.0)
                let ty = sy + @math.sin(angle) * (ehs + 3.0)
                nodes.push(@scene.rect(x=tx - 1.5, y=ty - 1.5, w=3.0, h=3.0, fill=0x44AAFF))
              }
              k if k == kind_boss => {
                // Outline + pulse
                nodes.push(@scene.rect_outline(x=sx - ehs - 2.0, y=sy - ehs - 2.0, w=enemy.size + 4.0, h=enemy.size + 4.0, color=0xFF2266))
                let pulse = (0.5 + 0.5 * @math.sin(self.frame_count.to_double() * 0.08))
                nodes.push(@scene.rect(x=sx - ehs, y=sy - ehs, w=enemy.size, h=enemy.size, fill=0xFF4488, alpha=pulse * 0.3))
                // Boss name
                nodes.push(@scene.label(x=sx, y=sy - ehs - 12.0, content="BOSS", color=0xFF2266, scale=0.5))
              }
              _ => ()
            }
            // HP bar bg
            nodes.push(
              @scene.rect(x=sx - ehs, y=sy - ehs - 4.0, w=enemy.size, h=2.0, fill=0x440000),
            )
            // HP bar fill
            let ehp_ratio = enemy.hp.to_double() / enemy.max_hp.to_double()
            nodes.push(
              @scene.rect(
                x=sx - ehs, y=sy - ehs - 4.0,
                w=enemy.size * ehp_ratio, h=2.0, fill=0xCC0000,
              ),
            )
          }
        }
      }
      nodes
    }),
    // Dash afterimage
    @scene.show(fn() { self.player.dash_timer > 0 }, fn() {
      @scene.for_each(fn() {
        let nodes : Array[@scene.SceneNode] = []
        for i = 1; i < 4; i = i + 1 {
          let t = i.to_double() * 3.0
          let ax = px - self.player.dash_vx / player_speed * t
          let ay = py - self.player.dash_vy / player_speed * t
          let a = 0.3 - i.to_double() * 0.08
          nodes.push(
            @scene.rect(x=ax - phs, y=ay - phs, w=self.player.size, h=self.player.size, fill=0x66DDFF, alpha=a),
          )
        }
        nodes
      })
    }),
    // Player
    @scene.rect(
      x=px - phs, y=py - phs,
      w=self.player.size, h=self.player.size,
      fill=player_fill,
    ),
    // Attack sweep
    @scene.show(fn() { self.attack_timer > attack_cooldown - 8 }, fn() {
      let swing_frames = 8.0
      let elapsed = (attack_cooldown - self.attack_timer).to_double()
      let progress = elapsed / swing_frames
      let angle = self.player.facing_angle + (-1.0472 + progress * 2.0944)
      let cos_a = @math.cos(angle)
      let sin_a = @math.sin(angle)
      let fade = 1.0 - progress
      @scene.for_each(fn() {
        let nodes : Array[@scene.SceneNode] = []
        for i = 0; i < 8; i = i + 1 {
          let dist = 6.0 + i.to_double() * 2.5
          let sx = px + cos_a * dist
          let sy = py + sin_a * dist
          let size = if i < 2 { 3.0 } else if i < 6 { 2.0 } else { 1.0 }
          let color = if i < 2 { 0x888888 } else { 0xCCDDFF }
          nodes.push(
            @scene.rect(
              x=sx - size / 2.0, y=sy - size / 2.0,
              w=size, h=size,
              fill=color, alpha=fade * 0.8,
            ),
          )
        }
        nodes
      })
    }),
    // Screen flash
    @scene.show(fn() { self.screen_flash > 0 }, fn() {
      let flash_alpha = self.screen_flash.to_double() / 5.0 * 0.15
      if self.player.damage_timer > 0 {
        @scene.rect(w=sw, h=sh, fill=0xFF0000, alpha=flash_alpha)
      } else {
        @scene.rect(w=sw, h=sh, fill=0xFFFFFF, alpha=flash_alpha)
      }
    }),
    // Floor announce overlay
    @scene.show(fn() { self.floor_announce_timer > 0 }, fn() {
      let alpha = self.floor_announce_timer.to_double() / 120.0
      @scene.fragment([
        @scene.rect(w=sw, h=sh, fill=0x000000, alpha=alpha * 0.5),
        @scene.label(
          x=sw / 2.0,
          y=sh / 2.0,
          content="FLOOR " + self.floor.to_string(),
          color=0xFFCC00,
          scale=2.0,
        ),
      ])
    }),
    // HUD
    render_hud(self),
  ])
}
