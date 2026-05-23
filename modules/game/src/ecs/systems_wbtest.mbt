// === system_movement ===

///|
test "system_movement applies velocity to transform" {
  let world = World::new()
  let transforms : ComponentStore[@transform3d.Transform3D] = ComponentStore::new()
  let velocities : ComponentStore[Velocity] = ComponentStore::new()
  let eid = world.spawn()
  transforms.set(
    eid,
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(0.0, 0.0, 0.0)),
  )
  velocities.set(eid, { x: 10.0, y: 5.0, z: 0.0 })
  system_movement(world, transforms, velocities, 0.1)
  match transforms.get(eid) {
    Some(t) => {
      assert_true((t.position.x - 1.0).abs() < 0.001)
      assert_true((t.position.y - 0.5).abs() < 0.001)
    }
    None => fail("expected transform")
  }
}

///|
test "system_movement skips entities without velocity" {
  let world = World::new()
  let transforms : ComponentStore[@transform3d.Transform3D] = ComponentStore::new()
  let velocities : ComponentStore[Velocity] = ComponentStore::new()
  let eid = world.spawn()
  let pos = @math3d.Vec3::new(5.0, 5.0, 5.0)
  transforms.set(eid, @transform3d.Transform3D::from_position(pos))
  system_movement(world, transforms, velocities, 1.0)
  match transforms.get(eid) {
    Some(t) => assert_true((t.position.x - 5.0).abs() < 0.001)
    None => fail("expected transform")
  }
}

///|
test "system_movement skips dead entities" {
  let world = World::new()
  let transforms : ComponentStore[@transform3d.Transform3D] = ComponentStore::new()
  let velocities : ComponentStore[Velocity] = ComponentStore::new()
  let eid = world.spawn()
  transforms.set(
    eid,
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(0.0, 0.0, 0.0)),
  )
  velocities.set(eid, { x: 100.0, y: 0.0, z: 0.0 })
  world.despawn(eid)
  system_movement(world, transforms, velocities, 1.0)
  // Slot data lingers in the store, but the system skipped it because
  // iter_in filters by world.alive. So the position is unchanged.
  match transforms.get(eid) {
    Some(t) => assert_true((t.position.x - 0.0).abs() < 0.001)
    None => fail("store should still hold the value")
  }
}

///|
test "system_movement applies to all 3 axes" {
  let world = World::new()
  let transforms : ComponentStore[@transform3d.Transform3D] = ComponentStore::new()
  let velocities : ComponentStore[Velocity] = ComponentStore::new()
  let eid = world.spawn()
  transforms.set(
    eid,
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(1.0, 2.0, 3.0)),
  )
  velocities.set(eid, { x: 10.0, y: 20.0, z: 30.0 })
  system_movement(world, transforms, velocities, 0.5)
  match transforms.get(eid) {
    Some(t) => {
      assert_true((t.position.x - 6.0).abs() < 0.001)
      assert_true((t.position.y - 12.0).abs() < 0.001)
      assert_true((t.position.z - 18.0).abs() < 0.001)
    }
    None => fail("expected transform")
  }
}

///|
test "system_movement accumulates over multiple steps" {
  let world = World::new()
  let transforms : ComponentStore[@transform3d.Transform3D] = ComponentStore::new()
  let velocities : ComponentStore[Velocity] = ComponentStore::new()
  let eid = world.spawn()
  transforms.set(
    eid,
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(0.0, 0.0, 0.0)),
  )
  velocities.set(eid, { x: 10.0, y: 0.0, z: 0.0 })
  system_movement(world, transforms, velocities, 0.1)
  system_movement(world, transforms, velocities, 0.1)
  system_movement(world, transforms, velocities, 0.1)
  match transforms.get(eid) {
    Some(t) => assert_true((t.position.x - 3.0).abs() < 0.001)
    None => fail("expected transform")
  }
}

// === system_death ===

///|
test "system_death despawns entities with zero health" {
  let world = World::new()
  let health : ComponentStore[Health] = ComponentStore::new()
  let e1 = world.spawn()
  let e2 = world.spawn()
  health.set(e1, { current: 0, max: 100 })
  health.set(e2, { current: 50, max: 100 })
  system_death(world, health)
  assert_false(world.is_alive(e1))
  assert_true(world.is_alive(e2))
}

///|
test "system_death despawns entities with negative health" {
  let world = World::new()
  let health : ComponentStore[Health] = ComponentStore::new()
  let eid = world.spawn()
  health.set(eid, { current: -10, max: 100 })
  system_death(world, health)
  assert_false(world.is_alive(eid))
}

///|
test "system_death ignores entities without health" {
  let world = World::new()
  let health : ComponentStore[Health] = ComponentStore::new()
  let eid = world.spawn()
  system_death(world, health)
  assert_true(world.is_alive(eid))
}

///|
test "system_death with health exactly 1 survives" {
  let world = World::new()
  let health : ComponentStore[Health] = ComponentStore::new()
  let eid = world.spawn()
  health.set(eid, { current: 1, max: 100 })
  system_death(world, health)
  assert_true(world.is_alive(eid))
}
