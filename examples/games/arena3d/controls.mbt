///|
fn GameState::aim_direction(self : GameState) -> @math3d.Vec3 {
  self.camera.orientation().rotate_vec3(@math3d.Vec3::new(0.0, 0.0, -1.0))
}

///|
fn GameState::eye(self : GameState) -> @math3d.Vec3 {
  self.player.position.add(@math3d.Vec3::new(0.0, 0.8, 0.0))
}

///|
fn GameState::view_camera(self : GameState) -> @camera3d.Camera3D {
  let eye = self.eye()
  let direction = self.aim_direction()
  let desired = eye.sub(direction.scale(5.0))
  let distance = if self.first_person {
    0.0
  } else {
    @camera3d.sweep_camera_boom(eye, desired, fn(point) {
      for body in self.physics.bodies {
        // Moving props can cross the eye during an impact. Only scenery
        // shortens the boom, so knockback does not snap the view inside the avatar.
        if body.is_dynamic() {
          continue
        }
        if body.intersects_sphere(@collision3d.Sphere::new(point, 0.2)) {
          return true
        }
      }
      false
    })
  }
  @camera3d.Camera3D::new_perspective(
    eye.sub(direction.scale(distance * 5.0)),
    eye.add(direction.scale(10.0)),
    @math3d.Vec3::unit_y(),
    @math.PI / 3.0,
    self.camera.aspect,
    0.1,
    100.0,
  )
}

///|
fn GameState::update_controls(
  self : GameState,
  snapshot : @core.InputSnapshot,
) -> Unit {
  let keys = self.input.key_state
  if @inputstate.is_key_just_pressed(keys, 86) {
    self.first_person = !self.first_person
  }
  if @inputstate.is_key_just_pressed(keys, 82) {
    self.reset()
    self.mode = mode_playing
  }
  let mut yaw = 0.0
  let mut pitch = 0.0
  // Dragging works in embedded Studio without requiring pointer lock.
  if self.looking &&
    @inputstate.is_mouse_button_pressed(self.input.mouse_state, 2) {
    yaw = (snapshot.cursor_x - self.prev_cursor_x) * -0.005
    pitch = (snapshot.cursor_y - self.prev_cursor_y) * 0.005
  }
  self.looking = @inputstate.is_mouse_button_pressed(self.input.mouse_state, 2)
  self.prev_cursor_x = snapshot.cursor_x
  self.prev_cursor_y = snapshot.cursor_y
  if @inputstate.is_key_pressed(keys, 81) {
    yaw += 0.03
  }
  if @inputstate.is_key_pressed(keys, 69) {
    yaw -= 0.03
  }
  if @inputstate.is_key_pressed(keys, 73) {
    pitch -= 0.025
  }
  if @inputstate.is_key_pressed(keys, 75) {
    pitch += 0.025
  }
  self.camera = self.camera.orbit(yaw, pitch)
  if self.mode == mode_playing &&
    (
      @inputstate.is_mouse_button_just_pressed(self.input.mouse_state, 0) ||
      @inputstate.is_key_just_pressed(keys, 70)
    ) {
    self.fire_aimed_shot()
  }
}

///|
fn GameState::movement_direction(self : GameState) -> @math3d.Vec3 {
  let keys = self.input.key_state
  let forward = (if @inpututil.is_move_up(keys) { 1.0 } else { 0.0 }) -
    (if @inpututil.is_move_down(keys) { 1.0 } else { 0.0 })
  let right = (if @inpututil.is_move_right(keys) { 1.0 } else { 0.0 }) -
    (if @inpututil.is_move_left(keys) { 1.0 } else { 0.0 })
  let sy = @math.sin(self.camera.yaw)
  let cy = @math.cos(self.camera.yaw)
  @math3d.Vec3::new(right * cy - forward * sy, 0.0, -forward * cy - right * sy)
}
