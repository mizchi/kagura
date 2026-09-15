///|
let player_body_id : Int = 20000

///|
fn new_player_body(position : @math3d.Vec3) -> @physics3d.RigidBody {
  // A sphere matches the current avatar and rolls over the ramp tip. Its
  // rotation is locked; the motor, rather than rolling friction, drives it.
  {
    ..@physics3d.RigidBody::new_dynamic(
      player_body_id,
      position,
      2.0,
      SphereShape(@math3d.Vec3::zero(), 0.5),
    )
    .with_restitution(0.0)
    .with_friction(0.0)
    .with_damping(0.0),
    inv_inertia: 0.0,
  }
}

///|
fn GameState::drive_player(self : GameState) -> Unit {
  let index = self.player_body_index
  guard index >= 0 && index < self.physics.bodies.length() else { return }
  let body = self.physics.bodies[index]
  guard body.id == player_body_id else { return }
  let ground = @character3d.sphere_ground_contact(
    body,
    self.physics.bodies,
    self.motor,
  )
  self.on_ground = ground is Some(_)
  let jumping = self.on_ground &&
    @inputstate.is_key_just_pressed(self.input.key_state, 32)
  if jumping {
    let support_y = ground.unwrap().velocity.y
    let delta = (self.motor.jump_speed + support_y - body.velocity.y).max(0.0)
    self.physics.bodies[index] = body.apply_impulse(
      @math3d.Vec3::new(0.0, body.mass * delta, 0.0),
    )
    self.on_ground = false
  }
  let acceleration = @character3d.motor_acceleration(
    self.motor,
    self.physics.bodies[index].velocity,
    self.movement_direction(),
    if jumping {
      None
    } else {
      ground
    },
    self.physics.gravity,
    1.0 / 60.0,
  )
  if acceleration.length_squared() > 1.0e-10 {
    self.physics.bodies[index] = self.physics.bodies[index].apply_force(
      acceleration.scale(body.mass),
    )
  }
}

///|
/// Explicit scene placement/reset is the only position write outside physics.
fn GameState::teleport_player(
  self : GameState,
  position : @math3d.Vec3,
) -> Unit {
  let index = self.player_body_index
  self.physics.bodies[index] = new_player_body(position)
  self.physics.contact_cache.clear()
  self.player.position = position
  self.on_ground = @character3d.sphere_ground_contact(
      self.physics.bodies[index],
      self.physics.bodies,
      self.motor,
    )
    is Some(_)
}

///|
fn GameState::sync_player_physics(self : GameState) -> Unit {
  guard self.physics.get_body(player_body_id) is Some(body) else { return }
  if body.position.y < -15.0 {
    self.teleport_player(self.player_spawn)
    return
  }
  self.player.position = body.position
  self.on_ground = @character3d.sphere_ground_contact(
      body,
      self.physics.bodies,
      self.motor,
    )
    is Some(_)
}
