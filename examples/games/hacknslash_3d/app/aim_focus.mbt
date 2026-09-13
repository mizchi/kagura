///|
// Normalized pointer coordinates are input state; camera offsets remain presentation state.
struct HunterAimState {
  mut pointer : (Double, Double)?
  mut native_cursor : (Double, Double)?
}

///|
fn HunterAimState::new() -> HunterAimState {
  { pointer: None, native_cursor: None, }
}

///|
fn GameState::update_aim_input(
  self : GameState,
  input : @core.InputSnapshot,
) -> Unit {
  if hunter_web_enabled() {
    let x = hunter_web_pointer_x()
    let y = hunter_web_pointer_y()
    self.aim.pointer = if x >= 0.0 && y >= 0.0 { Some((x, y)) } else { None }
    return
  }
  let cursor = (input.cursor_x, input.cursor_y)
  let moved = self.aim.native_cursor
    .map(p => (p.0 - cursor.0).abs() + (p.1 - cursor.1).abs() > 0.5)
    .or(false)
  self.aim.native_cursor = Some(cursor)
  if input.touches.length() > 0 ||
    (
      @inpututil.is_key_just_pressed(self.input.key_state, 74) &&
      !input.pressed_mouse_buttons.contains(0)
    ) {
    self.aim.pointer = None
  } else if !input.pressed_mouse_buttons.contains(2) &&
    (moved || input.pressed_mouse_buttons.contains(0)) {
    self.aim.pointer = Some(
      (
        input.cursor_x / screen_w.to_double(),
        input.cursor_y / screen_h.to_double(),
      ),
    )
  }
}

///|
fn hunter_auto_target(world : @game.GameWorld) -> @game.Enemy? {
  if world.player_weapon.is_melee() {
    world.melee_lock_target(world.player.facing_angle, world.player_weapon)
  } else {
    @game.find_nearest_enemy(world, 160.0)
  }
}

///|
fn GameState::pointer_aim_angle(self : GameState) -> Double? {
  self.aim.pointer.map(p => {
    hunter_aim_angle(
      self.camera,
      p.0 * screen_w.to_double(),
      p.1 * screen_h.to_double(),
      self.world.player.x,
      self.world.player.y,
      @game.get_tile_height(
        self.world.dungeon,
        self.world.player.x,
        self.world.player.y,
      ),
      self.world.player.facing_angle,
    )
  })
}

///|
fn GameState::combat_focus_offset(self : GameState) -> (Double, Double) {
  let p = self.world.player
  let target = match self.aim.pointer {
    Some((x, y)) => {
      let height = @game.get_tile_height(self.world.dungeon, p.x, p.y)
      // Solve against the centered camera so following the pointer cannot feed back into itself.
      let centered = self.camera.with_target(
        @math3d.Vec3::new(p.x / tile_size, height + 0.4, p.y / tile_size),
      )
      hunter_ground_point(
        centered,
        x * screen_w.to_double(),
        y * screen_h.to_double(),
        height,
      )
    }
    None => hunter_auto_target(self.world).map(e => (e.x, e.y))
  }
  guard target is Some((x, y)) else { return (0.0, 0.0) }
  let dx = (x - p.x) / tile_size * 0.25
  let dy = (y - p.y) / tile_size * 0.25
  let length = (dx * dx + dy * dy).sqrt()
  if length < 0.025 {
    return (0.0, 0.0)
  }
  let limit = self.camera.distance * 0.12
  let limit = limit.min(if self.aim.pointer is Some(_) { 2.0 } else { 1.2 })
  let scale = (limit / length).min(1.0)
  (dx * scale, dy * scale)
}
