// === system_movement ===

///|
test "system_movement applies velocity to transform" {
  let world = World::new()
  let eid = world.spawn()
  world.set_transform(
    eid,
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(0.0, 0.0, 0.0)),
  )
  world.set_velocity(eid, { x: 10.0, y: 5.0, z: 0.0 })
  system_movement(world, 0.1)
  match world.get_transform(eid) {
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
  let eid = world.spawn()
  let pos = @math3d.Vec3::new(5.0, 5.0, 5.0)
  world.set_transform(eid, @transform3d.Transform3D::from_position(pos))
  system_movement(world, 1.0)
  match world.get_transform(eid) {
    Some(t) => assert_true((t.position.x - 5.0).abs() < 0.001)
    None => fail("expected transform")
  }
}

///|
test "system_movement skips entities without transform" {
  let world = World::new()
  let eid = world.spawn()
  world.set_velocity(eid, { x: 10.0, y: 0.0, z: 0.0 })
  system_movement(world, 1.0)
  assert_true(world.get_transform(eid) is None)
}

///|
test "system_movement skips dead entities" {
  let world = World::new()
  let eid = world.spawn()
  world.set_transform(
    eid,
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(0.0, 0.0, 0.0)),
  )
  world.set_velocity(eid, { x: 100.0, y: 0.0, z: 0.0 })
  world.destroy(eid)
  system_movement(world, 1.0)
  // transform unchanged because entity is dead
  match world.get_transform(eid) {
    Some(t) => assert_true((t.position.x - 0.0).abs() < 0.001)
    None => fail("expected transform")
  }
}

///|
test "system_movement applies to all 3 axes" {
  let world = World::new()
  let eid = world.spawn()
  world.set_transform(
    eid,
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(1.0, 2.0, 3.0)),
  )
  world.set_velocity(eid, { x: 10.0, y: 20.0, z: 30.0 })
  system_movement(world, 0.5)
  match world.get_transform(eid) {
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
  let eid = world.spawn()
  world.set_transform(
    eid,
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(0.0, 0.0, 0.0)),
  )
  world.set_velocity(eid, { x: 10.0, y: 0.0, z: 0.0 })
  system_movement(world, 0.1)
  system_movement(world, 0.1)
  system_movement(world, 0.1)
  match world.get_transform(eid) {
    Some(t) => assert_true((t.position.x - 3.0).abs() < 0.001)
    None => fail("expected transform")
  }
}

///|
test "system_movement handles negative velocity" {
  let world = World::new()
  let eid = world.spawn()
  world.set_transform(
    eid,
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(10.0, 0.0, 0.0)),
  )
  world.set_velocity(eid, { x: -5.0, y: 0.0, z: 0.0 })
  system_movement(world, 1.0)
  match world.get_transform(eid) {
    Some(t) => assert_true((t.position.x - 5.0).abs() < 0.001)
    None => fail("expected transform")
  }
}

///|
test "system_movement with multiple entities" {
  let world = World::new()
  let e1 = world.spawn()
  let e2 = world.spawn()
  world.set_transform(
    e1,
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(0.0, 0.0, 0.0)),
  )
  world.set_velocity(e1, { x: 1.0, y: 0.0, z: 0.0 })
  world.set_transform(
    e2,
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(0.0, 0.0, 0.0)),
  )
  world.set_velocity(e2, { x: 0.0, y: 2.0, z: 0.0 })
  system_movement(world, 1.0)
  match world.get_transform(e1) {
    Some(t) => assert_true((t.position.x - 1.0).abs() < 0.001)
    None => fail("expected transform e1")
  }
  match world.get_transform(e2) {
    Some(t) => assert_true((t.position.y - 2.0).abs() < 0.001)
    None => fail("expected transform e2")
  }
}

// === system_death ===

///|
test "system_death destroys entities with zero health" {
  let world = World::new()
  let e1 = world.spawn()
  let e2 = world.spawn()
  world.set_health(e1, { current: 0, max: 100 })
  world.set_health(e2, { current: 50, max: 100 })
  system_death(world)
  assert_false(world.is_alive(e1))
  assert_true(world.is_alive(e2))
}

///|
test "system_death destroys entities with negative health" {
  let world = World::new()
  let eid = world.spawn()
  world.set_health(eid, { current: -10, max: 100 })
  system_death(world)
  assert_false(world.is_alive(eid))
}

///|
test "system_death ignores entities without health" {
  let world = World::new()
  let eid = world.spawn()
  // no health component set
  system_death(world)
  assert_true(world.is_alive(eid))
}

///|
test "system_death skips already dead entities" {
  let world = World::new()
  let eid = world.spawn()
  world.set_health(eid, { current: 100, max: 100 })
  world.destroy(eid)
  system_death(world)
  assert_false(world.is_alive(eid))
}

///|
test "system_death with health exactly 1 survives" {
  let world = World::new()
  let eid = world.spawn()
  world.set_health(eid, { current: 1, max: 100 })
  system_death(world)
  assert_true(world.is_alive(eid))
}

// === system_cleanup ===

///|
test "system_cleanup compacts dead entities" {
  let world = World::new()
  let e1 = world.spawn()
  let e2 = world.spawn()
  world.set_health(e1, { current: 0, max: 10 })
  world.set_health(e2, { current: 10, max: 10 })
  system_death(world)
  system_cleanup(world)
  assert_eq(world.entity_count(), 1)
  assert_true(world.get_health(e1) is None)
}

// === integrated death + cleanup pipeline ===

///|
test "death and cleanup pipeline" {
  let world = World::new()
  let player = world.spawn()
  let enemy1 = world.spawn()
  let enemy2 = world.spawn()
  let bullet = world.spawn()
  world.add_tag(player, Player)
  world.add_tag(enemy1, Enemy)
  world.add_tag(enemy2, Enemy)
  world.add_tag(bullet, Bullet)
  world.set_health(player, { current: 100, max: 100 })
  world.set_health(enemy1, { current: 0, max: 50 })
  world.set_health(enemy2, { current: 30, max: 50 })
  // bullet has no health - should survive death system
  assert_eq(world.entity_count(), 4)
  system_death(world)
  assert_eq(world.entity_count(), 3)
  assert_false(world.is_alive(enemy1))
  system_cleanup(world)
  assert_eq(world.entity_count(), 3)
  let enemies = world.entities_with_tag(Enemy)
  assert_eq(enemies.length(), 1)
  assert_eq(enemies[0].value, enemy2.value)
}
