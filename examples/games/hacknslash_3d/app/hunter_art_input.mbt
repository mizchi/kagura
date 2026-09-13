///|
fn hunter_pointer_ground(
  camera : @camera3d.OrbitCamera,
  x : Double,
  y : Double,
) -> (Double, Double)? {
  let inv = camera.to_camera3d().view_projection_matrix().inverse()
  let clip = inv.mul_vec4(
    @math3d.Vec4::new(
      x / screen_w.to_double() * 2.0 - 1.0,
      1.0 - y / screen_h.to_double() * 2.0,
      1.0,
      1.0,
    ),
  )
  if clip.w.abs() < 0.00001 {
    return None
  }
  let far = @math3d.Vec3::new(clip.x / clip.w, clip.y / clip.w, clip.z / clip.w)
  let origin = camera.position()
  let direction = far.sub(origin)
  if direction.y.abs() < 0.00001 {
    return None
  }
  let t = -origin.y / direction.y
  if t <= 0.0 {
    return None
  }
  let p = origin.add(direction.scale(t))
  Some((p.x * tile_size, p.z * tile_size))
}

///|
fn GameState::update_hunter_art_input(
  self : GameState,
  dx : Double,
  dy : Double,
) -> Bool {
  let w = self.world
  w.set_whirlwind(
    !self.ground_targeting &&
    (
      hunter_web_whirling() ||
      @inpututil.is_key_pressed(self.input.key_state, key_2)
    ),
    pressed=hunter_web_whirlwind_pressed() ||
      @inpututil.is_key_just_pressed(self.input.key_state, key_2),
  )
  let held = hunter_web_guarding() ||
    @inpututil.is_key_pressed(self.input.key_state, 70)
  let angle = if dx * dx + dy * dy > 0.001 {
    @math.atan2(dy, dx)
  } else {
    hunter_assisted_aim(w)
  }
  w.set_guard(held && !self.ground_targeting, angle)
  if @inpututil.is_key_just_pressed(self.input.key_state, 86) &&
    !self.ground_targeting {
    if w.request_dash_strike(angle) {
      self.play_sound_cue(SfxDodge)
    }
  }
  if @inpututil.is_key_just_pressed(self.input.key_state, 84) {
    if self.ground_targeting {
      self.ground_targeting = false
      return true
    }
    if w.arts.ground_cooldown <= 0 &&
      !w.hunter_action_locked() &&
      w.weapon_attack is None &&
      w.player_charge is None &&
      w.player.dash_timer <= 0 &&
      w.attack_timer <= 0 {
      self.ground_targeting = true
      self.ground_target_x = w.player.x + @math.cos(angle) * 64.0
      self.ground_target_y = w.player.y + @math.sin(angle) * 64.0
    }
  }
  if !self.ground_targeting {
    return false
  }
  let tx = hunter_web_target_x()
  let ty = hunter_web_target_y()
  let pointer_x = if tx >= 0.0 { tx * screen_w.to_double() } else { w.cursor_x }
  let pointer_y = if ty >= 0.0 { ty * screen_h.to_double() } else { w.cursor_y }
  if hunter_pointer_ground(self.camera, pointer_x, pointer_y) is Some((x, y)) {
    let (x, y) = w.ground_strike_target(x, y)
    self.ground_target_x = x
    self.ground_target_y = y
  }
  if hunter_web_target_confirmed() ||
    @inpututil.is_mouse_button_just_pressed(self.input.mouse_state, 0) ||
    @inpututil.is_key_just_pressed(self.input.key_state, 13) {
    if w.request_ground_strike(self.ground_target_x, self.ground_target_y) {
      self.ground_targeting = false
      self.play_sound_cue(SfxSpellHomingMissile)
    }
  }
  true
}
