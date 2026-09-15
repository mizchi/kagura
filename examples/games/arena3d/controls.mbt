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
        if body
          .world_aabb()
          .intersects_sphere(@collision3d.Sphere::new(point, 0.2)) {
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
    self.fire_ray(self.eye(), self.aim_direction())
  }
}

///|
fn GameState::move_player(self : GameState) -> Unit {
  let keys = self.input.key_state
  let mut forward = 0.0
  let mut right = 0.0
  if @inpututil.is_move_up(keys) {
    forward += 1.0
  }
  if @inpututil.is_move_down(keys) {
    forward -= 1.0
  }
  if @inpututil.is_move_left(keys) {
    right -= 1.0
  }
  if @inpututil.is_move_right(keys) {
    right += 1.0
  }
  let length = (forward * forward + right * right).sqrt()
  let speed = if length > 0.0 { player_speed / length } else { 0.0 }
  let sy = @math.sin(self.camera.yaw)
  let cy = @math.cos(self.camera.yaw)
  let dx = (right * cy - forward * sy) * speed
  let dz = (-forward * cy - right * sy) * speed
  let previous = self.player.position
  let mut next_x = previous.x + dx
  let mut next_z = previous.z + dz
  if self.authored is Some(session) {
    let mut supported = false
    for entity in session.scene().entities {
      if entity.kind == "floor" &&
        (next_x - entity.position[0]).abs() + 0.5 <= entity.scale[0] / 2.0 &&
        (next_z - entity.position[2]).abs() + 0.5 <= entity.scale[2] / 2.0 {
        supported = true
      }
    }
    if !supported {
      next_x = previous.x
      next_z = previous.z
    }
  } else {
    next_x = clamp_arena(next_x)
    next_z = clamp_arena(next_z)
  }
  if @inputstate.is_key_just_pressed(keys, 32) && self.on_ground {
    self.velocity_y = 5.2
    self.on_ground = false
  }
  self.velocity_y -= 9.81 / 60.0
  let mut y = previous.y + self.velocity_y / 60.0
  self.on_ground = false
  if y < self.floor_y {
    y = self.floor_y
    self.velocity_y = 0.0
    self.on_ground = true
  }
  if self.velocity_y <= 0.0 {
    for body in self.physics.bodies {
      let box = body.world_aabb()
      let x = next_x
      let z = next_z
      if x >= box.min.x &&
        x <= box.max.x &&
        z >= box.min.z &&
        z <= box.max.z &&
        previous.y - 0.5 >= box.max.y - 0.01 &&
        y - 0.5 <= box.max.y {
        y = box.max.y + 0.5
        self.velocity_y = 0.0
        self.on_ground = true
      }
    }
  }
  let candidate = @math3d.Vec3::new(next_x, y, next_z)
  // The same geometry stops player movement, shots and the third-person camera.
  let mut blocked = false
  for body in self.physics.bodies {
    let box = body.world_aabb()
    if box.max.y <= self.floor_y - 0.01 {
      continue
    }
    if box.intersects_sphere(@collision3d.Sphere::new(candidate, 0.45)) {
      blocked = true
      if body.is_dynamic() && length > 0.0 {
        self.physics.apply_impulse(
          body.id,
          @math3d.Vec3::new(dx * 18.0, 0.0, dz * 18.0),
        )
      }
    }
  }
  self.player.position = if blocked {
    @math3d.Vec3::new(previous.x, y, previous.z)
  } else {
    candidate
  }
}
