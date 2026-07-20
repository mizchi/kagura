///|
pub fn system_movement(world : World, dt : Double) -> Unit {
  for id in 0..<world.alive.length() {
    if world.alive[id] {
      match (world.transforms[id], world.velocities[id]) {
        (Some(t), Some(v)) => {
          let pos = t.position
          let new_pos = @math3d.Vec3::new(
            pos.x + v.x * dt,
            pos.y + v.y * dt,
            pos.z + v.z * dt,
          )
          world.transforms[id] = Some(t.with_position(new_pos))
        }
        _ => ()
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
                Some(t) =>
                  world.transforms[id] = Some(
                    t.with_position(body.position).with_rotation(body.rotation),
                  )
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
