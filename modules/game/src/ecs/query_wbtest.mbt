///|
test "query1 yields entities with the component" {
  let world = World::new()
  let transforms : ComponentStore[@transform3d.Transform3D] = ComponentStore::new()
  let e1 = world.spawn()
  let _e2 = world.spawn()
  let e3 = world.spawn()
  transforms.set(
    e1,
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(1.0, 0.0, 0.0)),
  )
  transforms.set(
    e3,
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(3.0, 0.0, 0.0)),
  )
  let count = query1(world, transforms).count()
  assert_eq(count, 2)
}

///|
test "query1 skips dead entities" {
  let world = World::new()
  let transforms : ComponentStore[@transform3d.Transform3D] = ComponentStore::new()
  let e1 = world.spawn()
  let e2 = world.spawn()
  transforms.set(
    e1,
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(1.0, 0.0, 0.0)),
  )
  transforms.set(
    e2,
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(2.0, 0.0, 0.0)),
  )
  world.despawn(e1)
  assert_eq(query1(world, transforms).count(), 1)
}

///|
test "query2 requires both components" {
  let world = World::new()
  let transforms : ComponentStore[@transform3d.Transform3D] = ComponentStore::new()
  let velocities : ComponentStore[Velocity] = ComponentStore::new()
  let e1 = world.spawn()
  let e2 = world.spawn()
  let e3 = world.spawn()
  // e1: both
  transforms.set(
    e1,
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(0.0, 0.0, 0.0)),
  )
  velocities.set(e1, { x: 1.0, y: 0.0, z: 0.0 })
  // e2: only transform
  transforms.set(
    e2,
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(0.0, 0.0, 0.0)),
  )
  // e3: only velocity
  velocities.set(e3, { x: 1.0, y: 0.0, z: 0.0 })
  let count = query2(world, transforms, velocities).count()
  assert_eq(count, 1)
}

///|
test "query2 passes correct data" {
  let world = World::new()
  let transforms : ComponentStore[@transform3d.Transform3D] = ComponentStore::new()
  let velocities : ComponentStore[Velocity] = ComponentStore::new()
  let eid = world.spawn()
  transforms.set(
    eid,
    @transform3d.Transform3D::from_position(@math3d.Vec3::new(10.0, 20.0, 0.0)),
  )
  velocities.set(eid, { x: 5.0, y: -3.0, z: 0.0 })
  let tx = @ref.new(0.0)
  let vx = @ref.new(0.0)
  let vy = @ref.new(0.0)
  query2(world, transforms, velocities).each(fn(entry) {
    let (_e, t, v) = entry
    tx.val = t.position.x
    vx.val = v.x
    vy.val = v.y
  })
  assert_true((tx.val - 10.0).abs() < 0.001)
  assert_true((vx.val - 5.0).abs() < 0.001)
  assert_true((vy.val - -3.0).abs() < 0.001)
}

///|
test "tags_add / tags_has / entities_with_tag" {
  let world = World::new()
  let tags : ComponentStore[Array[Tag]] = ComponentStore::new()
  let e1 = world.spawn()
  let e2 = world.spawn()
  let e3 = world.spawn()
  tags_add(tags, e1, Enemy)
  tags_add(tags, e2, Player)
  tags_add(tags, e3, Enemy)
  assert_true(tags_has(tags, e1, Enemy))
  assert_false(tags_has(tags, e1, Player))
  let enemies = entities_with_tag(world, tags, Enemy).collect()
  assert_eq(enemies.length(), 2)
}

///|
test "entities_with_tag excludes dead entities" {
  let world = World::new()
  let tags : ComponentStore[Array[Tag]] = ComponentStore::new()
  let e1 = world.spawn()
  let e2 = world.spawn()
  tags_add(tags, e1, Bullet)
  tags_add(tags, e2, Bullet)
  world.despawn(e1)
  assert_eq(entities_with_tag(world, tags, Bullet).count(), 1)
}

///|
test "entity carrying multiple tags" {
  let world = World::new()
  let tags : ComponentStore[Array[Tag]] = ComponentStore::new()
  let eid = world.spawn()
  tags_add(tags, eid, Player)
  tags_add(tags, eid, Item) // player carrying item
  assert_eq(entities_with_tag(world, tags, Player).count(), 1)
  assert_eq(entities_with_tag(world, tags, Item).count(), 1)
}
