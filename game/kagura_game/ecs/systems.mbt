///|
/// Advance every moving entity by its velocity.
///
/// The transform is updated **in place**. It used to be rebuilt --
/// `t.with_position(...)` then stored back -- and that one allocation per entity
/// per frame was 90% of this system: 2.84 ms against 203 us for 10,000 entities,
/// a 14x difference measured on the JS target. The loop, both `Option` reads and
/// the `Vec3` are all free by comparison (the `Option` compiles to a nullable
/// reference, the tuple match compiles away, and V8 drops the `Vec3` when it does
/// not escape). See `docs/performance/ecs-write-path.md`.
///
/// The `World` owns the transforms it stores, so mutating them here is sound; see
/// `Transform3D` for that contract.
pub fn system_movement(world : World, dt : Double) -> Unit {
  for id in 0..<world.alive.length() {
    if world.alive[id] {
      match world.transforms[id] {
        Some(t) =>
          match world.velocities[id] {
            Some(v) => {
              let pos = t.position
              t.set_position(
                @math3d.Vec3::new(
                  pos.x + v.x * dt,
                  pos.y + v.y * dt,
                  pos.z + v.z * dt,
                ),
              )
            }
            None => ()
          }
        None => ()
      }
    }
  }
}

///|
pub fn system_death(world : World) -> Unit {
  for id in 0..<world.alive.length() {
    if world.alive[id] {
      match world.health[id] {
        Some(h) => if h.current <= 0 { world.alive[id] = false }
        None => ()
      }
    }
  }
}

///|
pub fn system_cleanup(world : World) -> Unit {
  world.compact()
}

///|
pub fn system_sync_from_physics(
  world : World,
  physics : @physics3d.PhysicsWorld,
) -> Unit {
  for id in 0..<world.alive.length() {
    if world.alive[id] {
      match world.physics_body_ids[id] {
        Some(body_id) =>
          match physics.get_body(body_id) {
            Some(body) =>
              match world.transforms[id] {
                Some(t) => {
                  // In place: this used to build two transforms per entity per
                  // frame (`with_position` then `with_rotation`).
                  t.set_position(body.position)
                  t.set_rotation(body.rotation)
                }
                None => ()
              }
            None => ()
          }
        None => ()
      }
    }
  }
}

///|
pub fn system_sync_to_physics(
  world : World,
  physics : @physics3d.PhysicsWorld,
) -> Unit {
  for id in 0..<world.alive.length() {
    if world.alive[id] {
      match (world.physics_body_ids[id], world.transforms[id]) {
        (Some(body_id), Some(t)) =>
          for i = 0; i < physics.bodies.length(); i = i + 1 {
            if physics.bodies[i].id == body_id {
              let body = physics.bodies[i]
              physics.bodies[i] = {
                ..body,
                position: t.position,
                rotation: t.rotation,
              }
              break
            }
          }
        _ => ()
      }
    }
  }
}
