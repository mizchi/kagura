// ECS Demo - Player + Enemy chase game
// WASD/Arrow keys to move, enemies chase the player

///|
let screen_w : Int = 320

///|
let screen_h : Int = 240

///|
let player_speed : Double = 2.0

///|
let enemy_speed : Double = 0.8

///|
let entity_size : Double = 12.0

///|
let enemy_count : Int = 8

///|
let push_radius : Double = 14.0

///|
let push_strength : Double = 1.5

///|
fn pseudo_random(seed : Int) -> Double {
  let n = (seed * 1103515245 + 12345).land(0x7FFFFFFF)
  n.to_double() / 2147483647.0
}

///|
struct Game {
  world : @ecs.World
  input : @inpututil.InputHelper
  player_id : @ecs.EntityId
}

///|
fn Game::new() -> Game {
  let world = @ecs.World::new()
  // Spawn player at center
  let player_id = world.spawn_at(
    @transform3d.Transform3D::from_position(
      @math3d.Vec3::new(
        screen_w.to_double() / 2.0,
        screen_h.to_double() / 2.0,
        0.0,
      ),
    ),
  )
  world.add_tag(player_id, @ecs.Tag::Player)
  world.set_velocity(player_id, { x: 0.0, y: 0.0, z: 0.0 })
  // Spawn enemies
  for i in 0..<enemy_count {
    let ex = pseudo_random(i * 7 + 3) * (screen_w.to_double() - 20.0) + 10.0
    let ey = pseudo_random(i * 13 + 5) * (screen_h.to_double() - 20.0) + 10.0
    let eid = world.spawn_at(
      @transform3d.Transform3D::from_position(@math3d.Vec3::new(ex, ey, 0.0)),
    )
    world.add_tag(eid, @ecs.Tag::Enemy)
    world.set_velocity(eid, { x: 0.0, y: 0.0, z: 0.0 })
  }
  { world, input: @inpututil.new_input_helper(), player_id }
}

///|
fn Game::update(self : Game, input_snapshot : @core.InputSnapshot) -> Unit {
  @inpututil.update_input_helper(self.input, input_snapshot)
  let dt = 1.0 / 60.0
  // Player movement
  let mut dx = 0.0
  let mut dy = 0.0
  if @inpututil.is_move_up(self.input.key_state) {
    dy = dy - player_speed
  }
  if @inpututil.is_move_down(self.input.key_state) {
    dy = dy + player_speed
  }
  if @inpututil.is_move_left(self.input.key_state) {
    dx = dx - player_speed
  }
  if @inpututil.is_move_right(self.input.key_state) {
    dx = dx + player_speed
  }
  self.world.set_velocity(self.player_id, { x: dx / dt, y: dy / dt, z: 0.0 })
  // Enemy AI: chase player
  let player_pos = match self.world.get_transform(self.player_id) {
    Some(t) => t.position
    None => @math3d.Vec3::zero()
  }
  let enemies = self.world.entities_with_tag(@ecs.Tag::Enemy)
  for eid in enemies {
    match self.world.get_transform(eid) {
      Some(t) => {
        let ex = t.position.x
        let ey = t.position.y
        let ddx = player_pos.x - ex
        let ddy = player_pos.y - ey
        let dist = (ddx * ddx + ddy * ddy).sqrt()
        if dist > 1.0 {
          let vx = ddx / dist * enemy_speed / dt
          let vy = ddy / dist * enemy_speed / dt
          self.world.set_velocity(eid, { x: vx, y: vy, z: 0.0 })
        } else {
          self.world.set_velocity(eid, { x: 0.0, y: 0.0, z: 0.0 })
        }
      }
      None => ()
    }
  }
  // Movement system
  @ecs.system_movement(self.world, dt)
  // Collision separation
  self.resolve_collisions()
  // Clamp to screen bounds
  self.clamp_positions()
}

///|
fn Game::resolve_collisions(self : Game) -> Unit {
  let ids : Array[@ecs.EntityId] = []
  self.world.each_entity(fn(eid) { ids.push(eid) })
  for i in 0..<ids.length() {
    for j in (i + 1)..<ids.length() {
      let a = ids[i]
      let b = ids[j]
      match (self.world.get_transform(a), self.world.get_transform(b)) {
        (Some(ta), Some(tb)) => {
          let dx = tb.position.x - ta.position.x
          let dy = tb.position.y - ta.position.y
          let dist = (dx * dx + dy * dy).sqrt()
          if dist < push_radius && dist > 0.001 {
            let overlap = push_radius - dist
            let nx = dx / dist
            let ny = dy / dist
            let push = overlap * push_strength * 0.5
            self.world.set_transform(
              a,
              ta.with_position(
                @math3d.Vec3::new(
                  ta.position.x - nx * push,
                  ta.position.y - ny * push,
                  0.0,
                ),
              ),
            )
            self.world.set_transform(
              b,
              tb.with_position(
                @math3d.Vec3::new(
                  tb.position.x + nx * push,
                  tb.position.y + ny * push,
                  0.0,
                ),
              ),
            )
          }
        }
        _ => ()
      }
    }
  }
}

///|
fn Game::clamp_positions(self : Game) -> Unit {
  let sw = screen_w.to_double()
  let sh = screen_h.to_double()
  let half = entity_size / 2.0
  self.world.each_with_transform(fn(eid, t) {
    let mut x = t.position.x
    let mut y = t.position.y
    let mut clamped = false
    if x < half {
      x = half
      clamped = true
    } else if x > sw - half {
      x = sw - half
      clamped = true
    }
    if y < half {
      y = half
      clamped = true
    } else if y > sh - half {
      y = sh - half
      clamped = true
    }
    if clamped {
      self.world.set_transform(
        eid,
        t.with_position(@math3d.Vec3::new(x, y, 0.0)),
      )
    }
  })
}

///|
fn Game::view(self : Game) -> @scene.SceneNode {
  let sw = screen_w.to_double()
  let sh = screen_h.to_double()
  @scene.fragment([
    // Background
    @scene.rect(w=sw, h=sh, fill=0x1A1A2E),
    // Grid
    @scene.for_each(fn() {
      let lines : Array[@scene.SceneNode] = []
      let mut gx = 40.0
      while gx < sw {
        lines.push(@scene.line(x0=gx, y0=0.0, x1=gx, y1=sh, color=0x222244))
        gx = gx + 40.0
      }
      let mut gy = 40.0
      while gy < sh {
        lines.push(@scene.line(x0=0.0, y0=gy, x1=sw, y1=gy, color=0x222244))
        gy = gy + 40.0
      }
      lines
    }),
    // Entities
    @scene.for_each(fn() {
      let nodes : Array[@scene.SceneNode] = []
      self.world.each_with_transform(fn(eid, t) {
        let x = t.position.x - entity_size / 2.0
        let y = t.position.y - entity_size / 2.0
        let is_player = self.world.has_tag(eid, @ecs.Tag::Player)
        let fill = if is_player { 0x00FF88 } else { 0xFF4444 }
        nodes.push(@scene.rect(x~, y~, w=entity_size, h=entity_size, fill~))
        if is_player {
          nodes.push(
            @scene.rect_outline(
              x=x - 1.0,
              y=y - 1.0,
              w=entity_size + 2.0,
              h=entity_size + 2.0,
              color=0x00FFAA,
            ),
          )
        }
      })
      nodes
    }),
    // HUD
    @scene.label(x=sw / 2.0, y=8.0, content="ECS DEMO", color=0xFFFF00),
    @scene.label(x=4.0, y=sh - 8.0, content="WASD:MOVE", color=0x888888),
  ])
}

///|
impl @scene.SceneGame for Game with update_game(self, input) {
  self.update(input)
}

///|
impl @scene.SceneGame for Game with view_game(self) {
  self.view()
}

///|
fn main {
  @web_hooks.install("#app")
  let game = Game::new()
  @scene.run_game(
    game,
    width=screen_w,
    height=screen_h,
    title="ECS Demo",
    canvas="#app",
  )
}
