///|
let rain_interval : Int = 54

///|
let rain_capacity : Int = 24

///|
/// A slide prefab's position and scale describe its axis-aligned bounds. Its
/// deck and rails share the same rotation in physics and rendering.
fn GameState::add_slide(
  self : GameState,
  id : Int,
  key : String,
  position : @math3d.Vec3,
  size : @math3d.Vec3,
) -> Unit {
  let rotation = @math3d.Quaternion::from_axis_angle(
    @math3d.Vec3::unit_x(),
    @math.atan2(size.y, size.z),
  )
  let up = rotation.rotate_vec3(@math3d.Vec3::unit_y())
  let length = (size.y * size.y + size.z * size.z).sqrt()
  self.add_stage_part(
    id,
    key + "-deck",
    position.sub(up.scale(0.09)),
    @math3d.Vec3::new(size.x, 0.18, length),
    rotation,
    0x53C7D8,
  )
  for i in 0..<2 {
    let side = if i == 0 { -1.0 } else { 1.0 }
    self.add_stage_part(
      id - i - 1,
      key + "-rail-\{i}",
      position
      .add(@math3d.Vec3::new(side * size.x * 0.5, 0.0, 0.0))
      .add(up.scale(0.22)),
      @math3d.Vec3::new(0.14, 0.6, length),
      rotation,
      0xFFD36B,
    )
    self.add_stage_part(
      id - i - 3,
      key + "-support-\{i}",
      position.add(
        @math3d.Vec3::new(
          side * (size.x * 0.5 - 0.2),
          -0.1,
          -size.z * 0.5 + 0.2,
        ),
      ),
      @math3d.Vec3::new(0.18, (size.y - 0.2).max(0.1), 0.18),
      @math3d.Quaternion::identity(),
      0x536273,
    )
  }
}

///|
fn GameState::add_stage_part(
  self : GameState,
  id : Int,
  key : String,
  position : @math3d.Vec3,
  scale : @math3d.Vec3,
  rotation : @math3d.Quaternion,
  color : Int,
) -> Unit {
  self.physics.add_body({
    ..@physics3d.RigidBody::new_static(
      id,
      position,
      BoxShape(scale.scale(0.5), @math3d.Vec3::zero()),
    )
    .with_restitution(0.15)
    .with_friction(0.3),
    rotation,
  })
  self.stage_nodes.push(
    @scene3d.mesh(
      key~,
      mesh=self.meshes.wall,
      position~,
      scale~,
      rotation~,
      color=scene_color(color),
    ),
  )
}

///|
fn GameState::add_dropper(
  self : GameState,
  key : String,
  position : @math3d.Vec3,
) -> Unit {
  self.emitters.push(position)
  // An open square frame makes the source visible without blocking its balls.
  for i in 0..<4 {
    let (offset, scale) = match i {
      0 =>
        (@math3d.Vec3::new(-0.65, 0.0, 0.0), @math3d.Vec3::new(0.12, 0.18, 1.4))
      1 =>
        (@math3d.Vec3::new(0.65, 0.0, 0.0), @math3d.Vec3::new(0.12, 0.18, 1.4))
      2 =>
        (@math3d.Vec3::new(0.0, 0.0, -0.65), @math3d.Vec3::new(1.2, 0.18, 0.12))
      _ =>
        (@math3d.Vec3::new(0.0, 0.0, 0.65), @math3d.Vec3::new(1.2, 0.18, 0.12))
    }
    self.stage_nodes.push(
      @scene3d.mesh(
        key=key + "-\{i}",
        mesh=self.meshes.wall,
        position=position.add(offset),
        scale~,
        color=scene_color(0xFFD36B),
      ),
    )
  }
}

///|
fn GameState::update_physics(self : GameState) -> Unit {
  if !self.emitters.is_empty() {
    self.rain_ticks += 1
    if self.rain_ticks >= rain_interval {
      self.rain_ticks = 0
      self.drop_ball()
    }
  }
  self.drive_player()
  self.physics.step(1.0 / 60.0)
  self.sync_player_physics()
}

///|
fn GameState::drop_ball(self : GameState) -> Unit {
  let slot = self.rain_count % rain_capacity
  let emitter = self.emitters[self.rain_count % self.emitters.length()]
  let jitter = ((self.rain_count * 7 % 5).to_double() - 2.0) * 0.12
  let position = emitter.add(@math3d.Vec3::new(jitter, -0.35, 0.0))
  if self.rain_slots.length() < rain_capacity {
    self.rain_slots.push(self.physics.bodies.length())
    self.add_physics_prop(
      10000 + slot,
      "rain-\{slot}",
      position,
      @math3d.Vec3::new(0.8, 0.8, 0.8),
      true,
      scene_color(if slot % 2 == 0 { 0xFFCC66 } else { 0x79D5E8 }),
    )
  } else {
    // Body IDs and array indices remain stable: the world's body index is
    // append-only. Replacing the value also resets velocity and sleep state.
    let index = self.rain_slots[slot]
    let id = self.physics.bodies[index].id
    self.physics.bodies[index] = @physics3d.RigidBody::new_dynamic(
        id,
        position,
        1.0,
        SphereShape(@math3d.Vec3::zero(), 0.4),
      )
      .with_restitution(0.42)
      .with_friction(0.55)
      .with_damping(0.08)
    self.physics.contact_cache.clear()
  }
  self.rain_count += 1
}
