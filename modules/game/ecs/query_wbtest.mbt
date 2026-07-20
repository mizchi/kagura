///|
test "each_entity iterates alive entities" {
  let world = World::new()
  let _e1 = world.spawn()
  let e2 = world.spawn()
  let _e3 = world.spawn()
  world.destroy(e2)
  let count = @ref.new(0)
  world.each_entity(fn(_eid) { count.update(fn(n) { n + 1 }) })
  assert_eq(count.val, 2)
}

///|
test "each_entity on empty world" {
  let world = World::new()
  let count = @ref.new(0)
  world.each_entity(fn(_eid) { count.update(fn(n) { n + 1 }) })
  assert_eq(count.val, 0)
}

///|
test "each_with_transform only visits entities with transform" {
  let world = World::new()
  let e1 = world.spawn()
  let _e2 = world.spawn() // no transform
  let e3 = world.spawn()
  world.set_transform(
    e1,
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(1.0, 0.0, 0.0)),
  )
  world.set_transform(
    e3,
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(3.0, 0.0, 0.0)),
  )
  let count = @ref.new(0)
  world.each_with_transform(fn(_eid, _t) { count.update(fn(n) { n + 1 }) })
  assert_eq(count.val, 2)
}

///|
test "each_with_transform skips dead entities" {
  let world = World::new()
  let e1 = world.spawn()
  let e2 = world.spawn()
  world.set_transform(
    e1,
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(1.0, 0.0, 0.0)),
  )
  world.set_transform(
    e2,
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(2.0, 0.0, 0.0)),
  )
  world.destroy(e1)
  let count = @ref.new(0)
  world.each_with_transform(fn(_eid, _t) { count.update(fn(n) { n + 1 }) })
  assert_eq(count.val, 1)
}

///|
test "each_with_transform_velocity requires both components" {
  let world = World::new()
  let e1 = world.spawn()
  let e2 = world.spawn()
  let e3 = world.spawn()
  // e1: both
  world.set_transform(
    e1,
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(0.0, 0.0, 0.0)),
  )
  world.set_velocity(e1, { x: 1.0, y: 0.0, z: 0.0 })
  // e2: only transform
  world.set_transform(
    e2,
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(0.0, 0.0, 0.0)),
  )
  // e3: only velocity
  world.set_velocity(e3, { x: 1.0, y: 0.0, z: 0.0 })
  let count = @ref.new(0)
  world.each_with_transform_velocity(fn(_eid, _t, _v) {
    count.update(fn(n) { n + 1 })
  })
  assert_eq(count.val, 1)
}

///|
test "each_with_transform_velocity passes correct data" {
  let world = World::new()
  let eid = world.spawn()
  world.set_transform(
    eid,
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(10.0, 20.0, 0.0)),
  )
  world.set_velocity(eid, { x: 5.0, y: -3.0, z: 0.0 })
  let tx = @ref.new(0.0)
  let vx = @ref.new(0.0)
  let vy = @ref.new(0.0)
  world.each_with_transform_velocity(fn(_e, t, v) {
    tx.val = t.position.x
    vx.val = v.x
    vy.val = v.y
  })
  assert_true((tx.val - 10.0).abs() < 0.001)
  assert_true((vx.val - 5.0).abs() < 0.001)
  assert_true((vy.val - -3.0).abs() < 0.001)
}

///|
test "each_with_tag filters by tag" {
  let world = World::new()
  let e1 = world.spawn()
  let e2 = world.spawn()
  let e3 = world.spawn()
  world.add_tag(e1, Enemy)
  world.add_tag(e2, Player)
  world.add_tag(e3, Enemy)
  let enemies = world.entities_with_tag(Enemy)
  assert_eq(enemies.length(), 2)
}

///|
test "entities_with_tag excludes dead entities" {
  let world = World::new()
  let e1 = world.spawn()
  let e2 = world.spawn()
  world.add_tag(e1, Bullet)
  world.add_tag(e2, Bullet)
  world.destroy(e1)
  let bullets = world.entities_with_tag(Bullet)
  assert_eq(bullets.length(), 1)
}

///|
test "entities_with_tag returns empty for no matches" {
  let world = World::new()
  let e1 = world.spawn()
  world.add_tag(e1, Player)
  let items = world.entities_with_tag(Item)
  assert_eq(items.length(), 0)
}

///|
test "each_with_tag on entity with multiple tags" {
  let world = World::new()
  let eid = world.spawn()
  world.add_tag(eid, Player)
  world.add_tag(eid, Item) // player carrying item
  let players = world.entities_with_tag(Player)
  let items = world.entities_with_tag(Item)
  assert_eq(players.length(), 1)
  assert_eq(items.length(), 1)
  assert_eq(players[0].value, eid.value)
  assert_eq(items[0].value, eid.value)
}
