///|
/// Apply `velocities * dt` to `transforms`. Iterates the (transform,
/// velocity) intersection over live entities.
pub fn system_movement(
  world : World,
  transforms : ComponentStore[@transform3d.Transform3D],
  velocities : ComponentStore[Velocity],
  dt : Double,
) -> Unit {
  // Inlined loop rather than `query2_each` — saves one closure call per
  // iteration, which is the dominant cost when the body is small.
  let td = transforms.data
  let vd = velocities.data
  let alive = world.alive
  let tlen = td.length()
  let vlen = vd.length()
  let wlen = alive.length()
  let mut bound = if tlen < wlen { tlen } else { wlen }
  if vlen < bound {
    bound = vlen
  }
  for i in 0..<bound {
    if !alive.unsafe_get(i) {
      continue
    }
    match (td.unsafe_get(i), vd.unsafe_get(i)) {
      (Some(t), Some(v)) => {
        let pos = t.position
        let new_pos = @math3d.Vec3::new(
          pos.x + v.x * dt,
          pos.y + v.y * dt,
          pos.z + v.z * dt,
        )
        td.unsafe_set(i, Some(t.with_position(new_pos)))
      }
      _ => ()
    }
  }
}

///|
/// Despawn entities whose `Health.current <= 0`. Slots become inactive in
/// the world; their lingering component data is left in the stores until
/// overwritten or until `ComponentStore::cleanup` is called.
pub fn system_death(
  world : World,
  health : ComponentStore[Health],
) -> Unit {
  // Collect first: despawn mutates `world.alive` and we don't want the
  // walk to observe a partial state.
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
        transforms.overwrite(
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
