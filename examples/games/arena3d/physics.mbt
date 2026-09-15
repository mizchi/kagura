///|
/// Rendering metadata is separate from the physics world's mutable body state.
struct PhysicsProp {
  id : Int
  key : String
  sphere : Bool
  scale : @math3d.Vec3
  color : @math3d.Vec4
}

///|
fn new_physics_world() -> @physics3d.PhysicsWorld {
  @physics3d.PhysicsWorld::new(@math3d.Vec3::new(0.0, -9.81, 0.0), 2.0)
}

///|
fn GameState::reset_physics(self : GameState) -> Unit {
  self.physics = new_physics_world()
  self.props.clear()
  self.shot_frames = 0
  // Low perimeter walls contain dynamic props after repeated impulses.
  for
    (id, position, half_extents) in [
      (
        -1,
        @math3d.Vec3::new(0.0, 0.5, -9.25),
        @math3d.Vec3::new(9.5, 0.5, 0.25),
      ),
      (-2, @math3d.Vec3::new(0.0, 0.5, 9.25), @math3d.Vec3::new(9.5, 0.5, 0.25)),
      (
        -3,
        @math3d.Vec3::new(-9.25, 0.5, 0.0),
        @math3d.Vec3::new(0.25, 0.5, 9.0),
      ),
      (-4, @math3d.Vec3::new(9.25, 0.5, 0.0), @math3d.Vec3::new(0.25, 0.5, 9.0)),
    ] {
    if self.authored is None {
      self.physics.add_body(
        @physics3d.RigidBody::new_static(
          id,
          position,
          AABBShape(half_extents, @math3d.Vec3::zero()),
        ),
      )
    }
  }
  if self.authored is Some(session) {
    for i, entity in session.scene().entities {
      let position = scene_vec(entity.position)
      let scale = scene_vec(entity.scale)
      match entity.kind {
        "floor" | "wall" =>
          self.physics.add_body(
            @physics3d.RigidBody::new_static(
              i,
              position,
              AABBShape(scale.scale(0.5), @math3d.Vec3::zero()),
            ),
          )
        "crate" | "ball" =>
          self.add_physics_prop(
            i,
            entity.id,
            position,
            scale,
            entity.kind == "ball",
            scene_color(entity.color),
          )
        _ => ()
      }
    }
  } else {
    self.physics.add_body(
      @physics3d.RigidBody::new_static(
        0,
        @math3d.Vec3::new(0.0, -0.25, 0.0),
        AABBShape(@math3d.Vec3::new(9.0, 0.25, 9.0), @math3d.Vec3::zero()),
      ),
    )
    for row in 0..<3 {
      for col in 0..<(3 - row) {
        self.add_physics_prop(
          1 + row * 3 + col,
          "crate-\{row}-\{col}",
          @math3d.Vec3::new(
            -3.0 + col.to_double() * 1.05 + row.to_double() * 0.5,
            0.5 + row.to_double() * 1.05,
            -3.0,
          ),
          @math3d.Vec3::one(),
          false,
          scene_color(0xD89A57),
        )
      }
    }
    for i in 0..<3 {
      self.add_physics_prop(
        20 + i,
        "ball-\{i}",
        @math3d.Vec3::new(2.0 + i.to_double() * 1.3, 3.0 + i.to_double(), -3.0),
        @math3d.Vec3::one(),
        true,
        scene_color(0x53C7D8),
      )
    }
  }
}

///|
fn GameState::add_physics_prop(
  self : GameState,
  id : Int,
  key : String,
  position : @math3d.Vec3,
  scale : @math3d.Vec3,
  sphere : Bool,
  color : @math3d.Vec4,
) -> Unit {
  let shape = if sphere {
    @physics3d.SphereShape(@math3d.Vec3::zero(), scale.x * 0.5)
  } else {
    @physics3d.AABBShape(scale.scale(0.5), @math3d.Vec3::zero())
  }
  self.physics.add_body(
    @physics3d.RigidBody::new_dynamic(id, position, 1.0, shape)
    .with_restitution(if sphere { 0.78 } else { 0.08 })
    .with_friction(0.55)
    .with_damping(0.08),
  )
  self.props.push({ id, key, sphere, scale, color, })
}

///|
fn body_hit(
  body : @physics3d.RigidBody,
  ray : @collision3d.Ray,
) -> @collision3d.HitResult {
  match body.collider {
    SphereShape(center, radius) =>
      ray.intersects_sphere(
        @collision3d.Sphere::new(body.position.add(center), radius),
      )
    AABBShape(_, _) => ray.intersects_aabb(body.world_aabb())
  }
}

///|
/// A single nearest-hit query prevents shooting through walls or stacked props.
fn GameState::fire_ray(
  self : GameState,
  origin : @math3d.Vec3,
  direction : @math3d.Vec3,
) -> Unit {
  let ray = @collision3d.Ray::new(origin, direction.normalize())
  let mut distance = 40.0
  let mut body_id = -1
  let mut enemy_index = -1
  for body in self.physics.bodies {
    let hit = body_hit(body, ray)
    if hit.hit && hit.distance < distance {
      distance = hit.distance
      body_id = body.id
    }
  }
  for i, enemy in self.enemies {
    if !enemy.active {
      continue
    }
    let hit = ray.intersects_sphere(
      @collision3d.Sphere::new(enemy.position, 0.55),
    )
    if hit.hit && hit.distance < distance {
      distance = hit.distance
      enemy_index = i
    }
  }
  if enemy_index >= 0 {
    self.enemies[enemy_index].active = false
    self.score += 25
  } else if body_id >= 0 {
    self.physics.apply_impulse(body_id, direction.normalize().scale(12.0))
  }
  self.shot_start = origin
  self.shot_end = ray.point_at(distance)
  self.shot_frames = 6
}

///|
fn GameState::physics_nodes(self : GameState) -> Array[@scene3d.View] {
  let nodes = []
  for prop in self.props {
    if self.physics.get_body(prop.id) is Some(body) {
      nodes.push(
        @scene3d.mesh(
          key=prop.key,
          mesh=if prop.sphere { self.meshes.player } else { self.meshes.wall },
          position=body.position,
          scale=prop.scale,
          color=prop.color,
        ),
      )
    }
  }
  // Fixed-size tracer: shooting does not accumulate meshes or rigid bodies.
  if self.shot_frames > 0 {
    let delta = self.shot_end.sub(self.shot_start)
    for i in 0..<12 {
      nodes.push(
        @scene3d.mesh(
          key="shot-\{i}",
          mesh=self.meshes.item,
          position=self.shot_start.add(
            delta.scale((i.to_double() + 1.0) / 12.0),
          ),
          scale=@math3d.Vec3::new(0.16, 0.16, 0.16),
          color=scene_color(0xFFF1B5),
        ),
      )
    }
  }
  nodes
}
