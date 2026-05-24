///|
pub fn system_movement(world : World, dt : Double) -> Unit {
  // Hot path: mutate the Transform3D's position in place rather than
  // allocating a fresh Transform3D + Option wrapper per entity per tick.
  // Transform3D.position is `mut` for exactly this case — see profiler
  // notes in scripts/ecs-pprof.mjs.
  // Component arrays grow lazily, so iterate by the shorter of the two.
  // `unsafe_get` avoids the per-access bounds-check function call — we
  // already bounded by min-length above.
  let alive = world.alive
  let transforms = world.transforms
  let velocities = world.velocities
  let n = if transforms.length() < velocities.length() {
    transforms.length()
  } else {
    velocities.length()
  }
  for id in 0..<n {
    if alive.unsafe_get(id) {
      match transforms.unsafe_get(id) {
        Some(t) =>
          match velocities.unsafe_get(id) {
            Some(v) => {
              // Mutate the existing Vec3 in place — both Transform3D's
              // position field and Vec3's x/y/z are `mut` for this
              // exact case. Avoids the Vec3 allocation that `Vec3::new`
              // would force per tick per entity.
              let p = t.position
              p.set_xyz(p.x + v.x * dt, p.y + v.y * dt, p.z + v.z * dt)
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
  let alive = world.alive
  let health = world.health
  for id in 0..<health.length() {
    if alive[id] {
      match health[id] {
        Some(h) => if h.current <= 0 { alive[id] = false }
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
  let alive = world.alive
  let bodies = world.physics_body_ids
  let transforms = world.transforms
  let n = if bodies.length() < transforms.length() {
    bodies.length()
  } else {
    transforms.length()
  }
  for id in 0..<n {
    if alive[id] {
      match bodies[id] {
        Some(body_id) =>
          match physics.get_body(body_id) {
            Some(body) =>
              match transforms[id] {
                Some(t) =>
                  transforms[id] = Some(
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
  let alive = world.alive
  let bodies = world.physics_body_ids
  let transforms = world.transforms
  let n = if bodies.length() < transforms.length() {
    bodies.length()
  } else {
    transforms.length()
  }
  for id in 0..<n {
    if alive[id] {
      match (bodies[id], transforms[id]) {
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
