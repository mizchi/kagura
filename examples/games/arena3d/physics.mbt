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
  self.stage_nodes.clear()
  self.emitters.clear()
  self.rain_slots.clear()
  self.rain_ticks = 0
  self.rain_count = 0
  self.shot_frames = 0
  self.shots.clear()
  // Four perimeter walls contain the falling props.
  for
    (id, position, half_extents) in [
      (
        -1,
        @math3d.Vec3::new(0.0, 1.5, -9.25),
        @math3d.Vec3::new(9.5, 1.5, 0.25),
      ),
      (-2, @math3d.Vec3::new(0.0, 1.5, 9.25), @math3d.Vec3::new(9.5, 1.5, 0.25)),
      (
        -3,
        @math3d.Vec3::new(-9.25, 1.5, 0.0),
        @math3d.Vec3::new(0.25, 1.5, 9.0),
      ),
      (-4, @math3d.Vec3::new(9.25, 1.5, 0.0), @math3d.Vec3::new(0.25, 1.5, 9.0)),
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
        "slide" => self.add_slide(-100 - i * 10, entity.id, position, scale)
        "ball_dropper" => self.add_dropper(entity.id, position)
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
    self.add_slide(
      -100,
      "slide",
      @math3d.Vec3::new(-4.8, 1.6, -4.0),
      @math3d.Vec3::new(2.2, 3.2, 6.0),
    )
    self.add_dropper("dropper", @math3d.Vec3::new(-4.8, 7.0, -6.3))
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
  self.player_spawn = self.player.position
  self.player_body_index = self.physics.bodies.length()
  self.physics.add_body(new_player_body(self.player.position))
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
    .with_restitution(if sphere { 0.42 } else { 0.08 })
    .with_friction(0.55)
    .with_damping(0.08),
  )
  self.props.push({ id, key, sphere, scale, color, })
}

///|
fn GameState::physics_nodes(self : GameState) -> Array[@scene3d.View] {
  let nodes = self.stage_nodes.copy()
  for prop in self.props {
    if self.physics.get_body(prop.id) is Some(body) {
      nodes.push(
        @scene3d.mesh(
          key=prop.key,
          mesh=if prop.sphere { self.meshes.player } else { self.meshes.wall },
          position=body.position,
          rotation=if prop.sphere {
            body.rotation
          } else {
            @math3d.Quaternion::identity()
          },
          scale=prop.scale,
          color=prop.color,
        ),
      )
    }
  }
  self.append_shot_nodes(nodes)
  nodes
}
