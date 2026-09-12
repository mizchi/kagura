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
) -> @camera3d.OrbitCamera {
  let aspect = width / @cmp.maximum(1.0, height)
  let portrait = @cmp.minimum(1.6, @cmp.maximum(1.0, 1.0 / aspect))
  @camera3d.OrbitCamera::new(
    camera.target,
    camera.distance,
    camera.yaw,
    camera.pitch,
    @math.PI / 5.0 * portrait,
    aspect,
    camera.near,
    camera.far,
  )
}

///|
fn hunter_assisted_aim(world : @game.GameWorld) -> Double {
  match @game.find_nearest_enemy(world, 160.0) {
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
) -> @camera3d.OrbitCamera {
  let dragging = input.pressed_mouse_buttons.contains(2)
  let yaw_delta = (if input.pressed_keys.contains(81) { -0.025 } else { 0.0 }) +
    (if input.pressed_keys.contains(69) { 0.025 } else { 0.0 }) +
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
      18.0,
      @math.PI / 4.0,
      0.78,
      camera.fov_y_rad,
      camera.aspect,
      camera.near,
      camera.far,
    )
  }
  @camera3d.OrbitCamera::new(
    camera.target,
    @cmp.maximum(
      8.0,
      @cmp.minimum(26.0, camera.distance + input.wheel_y * 0.015),
    ),
    camera.yaw + yaw_delta,
    @cmp.maximum(0.4, @cmp.minimum(1.15, camera.pitch + pitch_delta)),
    camera.fov_y_rad,
    camera.aspect,
    camera.near,
    camera.far,
  )
}

///|
// Unproject the pointer onto the player's ground plane, so aim survives orbit/zoom.
fn hunter_aim_angle(
  camera : @camera3d.OrbitCamera,
  cursor_x : Double,
  cursor_y : Double,
  player_x : Double,
  player_y : Double,
  ground_y : Double,
  fallback : Double,
) -> Double {
  let inv = camera.to_camera3d().view_projection_matrix().inverse()
  let x = cursor_x / screen_w.to_double() * 2.0 - 1.0
  let y = 1.0 - cursor_y / screen_h.to_double() * 2.0
  let clip = inv.mul_vec4(@math3d.Vec4::new(x, y, 1.0, 1.0))
  if clip.w.abs() < 0.00001 {
    return fallback
  }
  let far = @math3d.Vec3::new(clip.x / clip.w, clip.y / clip.w, clip.z / clip.w)
  let origin = camera.position()
  let direction = far.sub(origin)
  if direction.y.abs() < 0.00001 {
    return fallback
  }
  let t = (ground_y - origin.y) / direction.y
  if t <= 0.0 {
    return fallback
  }
  let target = origin.add(direction.scale(t))
  let dx = target.x - player_x / tile_size
  let dz = target.z - player_y / tile_size
  if dx * dx + dz * dz < 0.0025 {
    return fallback
  }
  @math.atan2(dz, dx)
}
