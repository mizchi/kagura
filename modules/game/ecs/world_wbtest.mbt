// === spawn / destroy / is_alive ===

///|
test "spawn and is_alive" {
  let world = World::new()
  let e1 = world.spawn()
  let e2 = world.spawn()
  assert_true(world.is_alive(e1))
  assert_true(world.is_alive(e2))
  assert_eq(e1.value, 0)
  assert_eq(e2.value, 1)
}

///|
test "destroy marks entity as dead" {
  let world = World::new()
  let e1 = world.spawn()
  world.destroy(e1)
  assert_false(world.is_alive(e1))
}

///|
test "is_alive returns false for non-existent entity" {
  let world = World::new()
  assert_false(world.is_alive({ value: 999 }))
}

///|
test "destroy is idempotent" {
  let world = World::new()
  let e1 = world.spawn()
  world.destroy(e1)
  world.destroy(e1)
  assert_false(world.is_alive(e1))
  assert_eq(world.entity_count(), 0)
}

///|
test "spawn_at creates entity with transform" {
  let world = World::new()
  let t = @transform3d.Transform3D::from_position(
    @math3d.Vec3::new(1.0, 2.0, 3.0),
  )
  let eid = world.spawn_at(t)
  assert_true(world.is_alive(eid))
  match world.get_transform(eid) {
    Some(tr) => {
      assert_true((tr.position.x - 1.0).abs() < 0.001)
      assert_true((tr.position.y - 2.0).abs() < 0.001)
      assert_true((tr.position.z - 3.0).abs() < 0.001)
    }
    None => fail("expected transform")
  }
}

// === entity_count ===

///|
test "entity_count tracks alive entities" {
  let world = World::new()
  let e1 = world.spawn()
  let _e2 = world.spawn()
  let _e3 = world.spawn()
  assert_eq(world.entity_count(), 3)
  world.destroy(e1)
  assert_eq(world.entity_count(), 2)
}

///|
test "entity_count is zero on empty world" {
  let world = World::new()
  assert_eq(world.entity_count(), 0)
}

// === component set/get ===

///|
test "component set/get transform" {
  let world = World::new()
  let eid = world.spawn()
  let t = @transform3d.Transform3D::from_position(
    @math3d.Vec3::new(5.0, 0.0, 0.0),
  )
  world.set_transform(eid, t)
  match world.get_transform(eid) {
    Some(tr) => assert_true((tr.position.x - 5.0).abs() < 0.001)
    None => fail("expected transform")
  }
}

///|
test "component set/get health" {
  let world = World::new()
  let eid = world.spawn()
  world.set_health(eid, { current: 100, max: 100 })
  match world.get_health(eid) {
    Some(h) => {
      assert_eq(h.current, 100)
      assert_eq(h.max, 100)
    }
    None => fail("expected health")
  }
}

///|
test "component set/get velocity" {
  let world = World::new()
  let eid = world.spawn()
  world.set_velocity(eid, { x: 1.0, y: 2.0, z: 3.0 })
  match world.get_velocity(eid) {
    Some(v) => {
      assert_true((v.x - 1.0).abs() < 0.001)
      assert_true((v.y - 2.0).abs() < 0.001)
      assert_true((v.z - 3.0).abs() < 0.001)
    }
    None => fail("expected velocity")
  }
}

///|
test "component set/get sprite" {
  let world = World::new()
  let eid = world.spawn()
  world.set_sprite(eid, {
    image_id: 42,
    width: 32.0,
    height: 32.0,
    color: 0xFFFFFF,
    alpha: 1.0,
  })
  match world.get_sprite(eid) {
    Some(s) => {
      assert_eq(s.image_id, 42)
      assert_true((s.width - 32.0).abs() < 0.001)
    }
    None => fail("expected sprite")
  }
}

///|
test "component set/get material" {
  let world = World::new()
  let eid = world.spawn()
  let mat = @scene3d.Material::new(metallic=0.8)
  world.set_material(eid, mat)
  match world.get_material(eid) {
    Some(m) => assert_true((m.metallic - 0.8).abs() < 0.001)
    None => fail("expected material")
  }
}

///|
test "get component returns None for entity without component" {
  let world = World::new()
  let eid = world.spawn()
  assert_true(world.get_transform(eid) is None)
  assert_true(world.get_velocity(eid) is None)
  assert_true(world.get_health(eid) is None)
  assert_true(world.get_sprite(eid) is None)
  assert_true(world.get_material(eid) is None)
}

///|
test "component overwrite replaces previous value" {
  let world = World::new()
  let eid = world.spawn()
  world.set_health(eid, { current: 100, max: 100 })
  world.set_health(eid, { current: 50, max: 100 })
  match world.get_health(eid) {
    Some(h) => assert_eq(h.current, 50)
    None => fail("expected health")
  }
}

// === physics_body_id / scene_node_id ===

///|
test "set/get physics_body_id" {
  let world = World::new()
  let eid = world.spawn()
  world.set_physics_body_id(eid, 42)
  assert_eq(world.get_physics_body_id(eid), Some(42))
}

///|
test "set/get scene_node_id" {
  let world = World::new()
  let eid = world.spawn()
  world.set_scene_node_id(eid, 7)
  assert_eq(world.get_scene_node_id(eid), Some(7))
}

// === tags ===

///|
test "tag add/has" {
  let world = World::new()
  let eid = world.spawn()
  world.add_tag(eid, Player)
  world.add_tag(eid, Enemy)
  assert_true(world.has_tag(eid, Player))
  assert_true(world.has_tag(eid, Enemy))
  assert_false(world.has_tag(eid, Bullet))
}

///|
test "has_tag returns false for entity without tags" {
  let world = World::new()
  let eid = world.spawn()
  assert_false(world.has_tag(eid, Player))
}

///|
test "multiple entities can share same tag" {
  let world = World::new()
  let e1 = world.spawn()
  let e2 = world.spawn()
  world.add_tag(e1, Enemy)
  world.add_tag(e2, Enemy)
  assert_true(world.has_tag(e1, Enemy))
  assert_true(world.has_tag(e2, Enemy))
}

///|
test "custom tag works" {
  let world = World::new()
  let eid = world.spawn()
  world.add_tag(eid, Custom("boss"))
  assert_true(world.has_tag(eid, Custom("boss")))
  assert_false(world.has_tag(eid, Custom("minion")))
}

// === compact ===

///|
test "compact removes dead entity components" {
  let world = World::new()
  let e1 = world.spawn()
  let e2 = world.spawn()
  world.set_health(e1, { current: 10, max: 10 })
  world.set_health(e2, { current: 20, max: 20 })
  world.add_tag(e1, Player)
  world.destroy(e1)
  world.compact()
  assert_eq(world.entity_count(), 1)
  assert_true(world.get_health(e1) is None)
  assert_true(world.get_health(e2) is Some(_))
}

///|
test "compact removes all component types of dead entity" {
  let world = World::new()
  let eid = world.spawn()
  world.set_transform(
    eid,
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(1.0, 0.0, 0.0)),
  )
  world.set_velocity(eid, { x: 1.0, y: 0.0, z: 0.0 })
  world.set_health(eid, { current: 10, max: 10 })
  world.set_sprite(eid, {
    image_id: 1,
    width: 16.0,
    height: 16.0,
    color: 0,
    alpha: 1.0,
  })
  world.add_tag(eid, Enemy)
  world.set_physics_body_id(eid, 5)
  world.set_scene_node_id(eid, 3)
  world.destroy(eid)
  world.compact()
  assert_true(world.get_transform(eid) is None)
  assert_true(world.get_velocity(eid) is None)
  assert_true(world.get_health(eid) is None)
  assert_true(world.get_sprite(eid) is None)
  assert_false(world.has_tag(eid, Enemy))
  assert_true(world.get_physics_body_id(eid) is None)
  assert_true(world.get_scene_node_id(eid) is None)
}

///|
test "compact on empty world is safe" {
  let world = World::new()
  world.compact()
  assert_eq(world.entity_count(), 0)
}

///|
test "compact preserves alive entities" {
  let world = World::new()
  let e1 = world.spawn()
  let e2 = world.spawn()
  let e3 = world.spawn()
  world.set_health(e1, { current: 10, max: 10 })
  world.set_health(e2, { current: 20, max: 20 })
  world.set_health(e3, { current: 30, max: 30 })
  world.destroy(e2)
  world.compact()
  assert_eq(world.entity_count(), 2)
  assert_true(world.is_alive(e1))
  assert_false(world.is_alive(e2))
  assert_true(world.is_alive(e3))
  match world.get_health(e1) {
    Some(h) => assert_eq(h.current, 10)
    None => fail("e1 health lost")
  }
  match world.get_health(e3) {
    Some(h) => assert_eq(h.current, 30)
    None => fail("e3 health lost")
  }
}

// === spawn after compact reuses no IDs (monotonic) ===

///|
test "spawn after compact uses new IDs" {
  let world = World::new()
  let e1 = world.spawn()
  world.destroy(e1)
  world.compact()
  let e2 = world.spawn()
  assert_eq(e2.value, 1) // monotonically increasing, no reuse
  assert_true(world.is_alive(e2))
}
