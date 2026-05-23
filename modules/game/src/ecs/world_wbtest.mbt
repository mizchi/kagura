///|
test "spawn returns sequential indices" {
  let world = World::new()
  let e1 = world.spawn()
  let e2 = world.spawn()
  assert_eq(e1.index, 0)
  assert_eq(e2.index, 1)
  assert_true(world.is_alive(e1))
  assert_true(world.is_alive(e2))
}

///|
test "despawn marks entity as dead" {
  let world = World::new()
  let e1 = world.spawn()
  world.despawn(e1)
  assert_false(world.is_alive(e1))
}

///|
test "is_alive false for sentinel and out-of-range" {
  let world = World::new()
  assert_false(world.is_alive(entity_id_none))
  assert_false(world.is_alive({ index: 999 }))
}

///|
test "despawn is idempotent" {
  let world = World::new()
  let e1 = world.spawn()
  world.despawn(e1)
  world.despawn(e1)
  assert_false(world.is_alive(e1))
  assert_eq(world.entity_count(), 0)
}

///|
test "spawn after despawn uses fresh monotonic index" {
  let world = World::new()
  let e1 = world.spawn()
  world.despawn(e1)
  let e2 = world.spawn()
  // Monotonic — no slot reuse, so a dead handle can't alias a new entity.
  assert_eq(e2.index, 1)
  assert_false(world.is_alive(e1))
  assert_true(world.is_alive(e2))
}

///|
test "entity_count tracks live entities" {
  let world = World::new()
  let e1 = world.spawn()
  let _e2 = world.spawn()
  let _e3 = world.spawn()
  assert_eq(world.entity_count(), 3)
  world.despawn(e1)
  assert_eq(world.entity_count(), 2)
}

///|
test "World::iter yields only live entities" {
  let world = World::new()
  let _e1 = world.spawn()
  let e2 = world.spawn()
  let _e3 = world.spawn()
  world.despawn(e2)
  let count = world.iter().count()
  assert_eq(count, 2)
}
