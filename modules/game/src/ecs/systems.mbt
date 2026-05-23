///|
/// Apply `velocities * dt` to `transforms`. Iterates the (transform,
/// velocity) intersection over live entities.
pub fn system_movement(
  world : World,
  transforms : ComponentStore[@transform3d.Transform3D],
  velocities : ComponentStore[Velocity],
  dt : Double,
) -> Unit {
  query2_each(world, transforms, velocities, fn(eid, t, v) {
    let pos = t.position
    let new_pos = @math3d.Vec3::new(
      pos.x + v.x * dt,
      pos.y + v.y * dt,
      pos.z + v.z * dt,
    )
    transforms.set(eid, t.with_position(new_pos))
  })
}

///|
/// Despawn entities whose `Health.current <= 0`. The world bumps the
/// slot's generation so component stores naturally treat the slot as empty
/// on subsequent lookups.
pub fn system_death(
  world : World,
  health : ComponentStore[Health],
) -> Unit {
  // Collect to a small array first: despawn mutates `world.alive` and we
  // don't want to see partially-mutated state from inside the callback.
  let doomed : Array[EntityId] = []
  query1_each(world, health, fn(eid, h) {
    if h.current <= 0 {
      doomed.push(eid)
    }
  })
  for eid in doomed {
    world.despawn(eid)
  }
}

///|
/// Copy positions/rotations from the physics world into ECS transforms.
pub fn system_sync_from_physics(
  world : World,
  transforms : ComponentStore[@transform3d.Transform3D],
  physics_body_ids : ComponentStore[Int],
  physics : @physics3d.PhysicsWorld,
) -> Unit {
  query2_each(world, physics_body_ids, transforms, fn(eid, body_id, t) {
    match physics.get_body(body_id) {
      Some(body) =>
        transforms.set(
          eid,
          t.with_position(body.position).with_rotation(body.rotation),
        )
      None => ()
    }
  })
}

///|
/// Push ECS transforms back into the physics world. Linear scan over
/// `physics.bodies` per entity matches the previous implementation.
pub fn system_sync_to_physics(
  world : World,
  transforms : ComponentStore[@transform3d.Transform3D],
  physics_body_ids : ComponentStore[Int],
  physics : @physics3d.PhysicsWorld,
) -> Unit {
  query2_each(world, physics_body_ids, transforms, fn(_eid, body_id, t) {
    for i = 0; i < physics.bodies.length(); i = i + 1 {
      if physics.bodies[i].id == body_id {
        let body = physics.bodies[i]
        physics.bodies[i] = { ..body, position: t.position, rotation: t.rotation }
        break
      }
    }
  })
}
