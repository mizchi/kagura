// Input-to-camera mapping is pure; world movement uses the resulting yaw.

///|
fn hunter_render_size(width : Double, height : Double) -> (Int, Int) {
  let w = @cmp.maximum(1.0, width)
  let h = @cmp.maximum(1.0, height)
  let scale = @cmp.minimum(1.25, (921600.0 / (w * h)).sqrt())
  (@cmp.maximum(1, (w * scale).to_int()), @cmp.maximum(1, (h * scale).to_int()))
}

///|
fn hunter_responsive_camera(
  camera : @camera3d.OrbitCamera,
  width : Double,
  height : Double,
  tps? : Bool = false,
) -> @camera3d.OrbitCamera {
  let aspect = width / @cmp.maximum(1.0, height)
  let portrait = @cmp.minimum(1.6, @cmp.maximum(1.0, 1.0 / aspect))
  @camera3d.OrbitCamera::new(
    camera.target,
    camera.distance,
    camera.yaw,
    camera.pitch,
    (if tps { @math.PI / 3.0 } else { @math.PI / 5.0 }) *
    (if tps { portrait.min(1.25) } else { portrait }),
    aspect,
    camera.near,
    camera.far,
  )
}

///|
fn hunter_assisted_aim(world : @game.GameWorld) -> Double {
  match hunter_auto_target(world) {
    Some(enemy) =>
      @math.atan2(enemy.y - world.player.y, enemy.x - world.player.x)
    None => world.player.facing_angle
  }
}

///|
fn hunter_camera_input(
  camera : @camera3d.OrbitCamera,
  input : @core.InputSnapshot,
  previous_x : Double,
  previous_y : Double,
  was_dragging : Bool,
  scale_x : Double,
  scale_y : Double,
  tps? : Bool = false,
) -> @camera3d.OrbitCamera {
  let dragging = input.pressed_mouse_buttons.contains(1)
  let yaw_delta = (if input.pressed_keys.contains(81) { 0.025 } else { 0.0 }) +
    (if input.pressed_keys.contains(69) { -0.025 } else { 0.0 }) +
    (if dragging && was_dragging {
      (input.cursor_x * scale_x - previous_x) * 0.008
    } else {
      0.0
    })
  let pitch_delta = if dragging && was_dragging {
    (input.cursor_y * scale_y - previous_y) * 0.006
  } else {
    0.0
  }
  if input.pressed_keys.contains(82) {
    return @camera3d.OrbitCamera::new(
      camera.target,
      if tps {
        4.5
      } else {
        18.0
      },
      if tps {
        camera.yaw
      } else {
        @math.PI / 4.0
      },
      if tps {
        18.0 * @math.PI / 180.0
      } else {
        0.78
      },
      camera.fov_y_rad,
      camera.aspect,
      camera.near,
      camera.far,
    )
  }
  @camera3d.OrbitCamera::new(
    camera.target,
    @cmp.maximum(
      if tps {
        2.0
      } else {
        8.0
      },
      @cmp.minimum(
        if tps {
          8.0
        } else {
          26.0
        },
        camera.distance + input.wheel_y * (if tps { 0.005 } else { 0.015 }),
      ),
    ),
    camera.yaw + yaw_delta,
    @cmp.maximum(
      (if tps { 5.0 } else { 20.0 }) * @math.PI / 180.0,
      @cmp.minimum(
        (if tps { 60.0 } else { 80.0 }) * @math.PI / 180.0,
        camera.pitch + pitch_delta,
      ),
    ),
    camera.fov_y_rad,
    camera.aspect,
    camera.near,
    camera.far,
  )
}

///|
// Unproject onto the rendered terrain, falling back to the authored ground plane.
fn hunter_aim_angle(
  camera : @camera3d.OrbitCamera,
  cursor_x : Double,
  cursor_y : Double,
  player_x : Double,
  player_y : Double,
  ground_y : Double,
  fallback : Double,
  dungeon? : @game.DungeonData? = None,
) -> Double {
  guard hunter_ground_point(camera, cursor_x, cursor_y, ground_y, dungeon~)
    is Some((x, y)) else {
    return fallback
  }
  let dx = x - player_x
  let dy = y - player_y
  if dx * dx + dy * dy < 0.64 {
    return fallback
  }
  @math.atan2(dy, dx)
}

///|
fn GameState::update_camera_controls(
  self : GameState,
  input : @core.InputSnapshot,
  previous_x : Double,
  previous_y : Double,
  was_dragging : Bool,
  scale_x : Double,
  scale_y : Double,
) -> Unit {
  if @inpututil.is_key_just_pressed(self.input.key_state, 90) {
    ignore(
      self.apply_camera_command([
        0.0,
        (1 - self.camera_settings.mode).to_double(),
      ]),
    )
  }
  if @inpututil.is_key_just_pressed(self.input.key_state, 82) {
    ignore(self.apply_camera_command([6.0, 0.0]))
  }
  let previous_pitch = self.camera.pitch
  let previous_distance = if self.camera_settings.mode == 1 {
    self.camera_settings.active().distance
  } else {
    self.camera.distance
  }
  self.camera = hunter_camera_input(
    self.camera.with_distance(previous_distance),
    input,
    previous_x,
    previous_y,
    was_dragging,
    scale_x,
    scale_y,
    tps=self.camera_settings.mode == 1,
  )
  let look = hunter_web_camera_look()
  if look.length() == 2 && self.camera_settings.mode == 1 {
    self.camera = self.camera.orbit(look[0], look[1])
    self.camera = self.camera.orbit(
      0.0,
      self.camera.pitch.clamp(min=5.0 * @math.PI / 180.0, max=@math.PI / 3.0) -
      self.camera.pitch,
    )
  }
  if self.camera.pitch != previous_pitch ||
    self.camera.distance != previous_distance {
    self.camera_settings.set_active({
      ..self.camera_settings.active(),
      tilt: self.camera.pitch * 180.0 / @math.PI,
      distance: self.camera.distance,
    })
    hunter_save_camera_preferences(self.camera_settings.serialize())
  }
}

///|
fn hunter_camera_relative_vector(
  yaw : Double,
  x : Double,
  y : Double,
) -> (Double, Double) {
  let c = @math.cos(yaw)
  let s = @math.sin(yaw)
  (x * c + y * s, -x * s + y * c)
}
