///|
test "ComponentStore::set/get round-trips" {
  let world = World::new()
  let store : ComponentStore[Velocity] = ComponentStore::new()
  let eid = world.spawn()
  store.set(eid, { x: 1.0, y: 2.0, z: 3.0 })
  match store.get(eid) {
    Some(v) => {
      assert_true((v.x - 1.0).abs() < 0.001)
      assert_true((v.y - 2.0).abs() < 0.001)
      assert_true((v.z - 3.0).abs() < 0.001)
    }
    None => fail("expected value")
  }
}

///|
test "ComponentStore::get returns None for missing slot" {
  let world = World::new()
  let store : ComponentStore[Velocity] = ComponentStore::new()
  let eid = world.spawn()
  assert_true(store.get(eid) is None)
}

///|
test "ComponentStore::set overwrites previous value" {
  let world = World::new()
  let store : ComponentStore[Health] = ComponentStore::new()
  let eid = world.spawn()
  store.set(eid, { current: 100, max: 100 })
  store.set(eid, { current: 25, max: 100 })
  match store.get(eid) {
    Some(h) => assert_eq(h.current, 25)
    None => fail("expected value")
  }
}

///|
test "ComponentStore::remove clears slot" {
  let world = World::new()
  let store : ComponentStore[Health] = ComponentStore::new()
  let eid = world.spawn()
  store.set(eid, { current: 10, max: 10 })
  store.remove(eid)
  assert_true(store.get(eid) is None)
}

///|
test "ComponentStore::has reflects presence" {
  let world = World::new()
  let store : ComponentStore[Velocity] = ComponentStore::new()
  let eid = world.spawn()
  assert_false(store.has(eid))
  store.set(eid, { x: 0.0, y: 0.0, z: 0.0 })
  assert_true(store.has(eid))
}

///|
test "ComponentStore::iter visits every set value once" {
  let world = World::new()
  let store : ComponentStore[Velocity] = ComponentStore::new()
  let e1 = world.spawn()
  let _e2 = world.spawn() // no value
  let e3 = world.spawn()
  store.set(e1, { x: 1.0, y: 0.0, z: 0.0 })
  store.set(e3, { x: 3.0, y: 0.0, z: 0.0 })
  let entries = store.iter().collect()
  assert_eq(entries.length(), 2)
}

///|
test "ComponentStore::iter_in skips despawned entities" {
  let world = World::new()
  let store : ComponentStore[Velocity] = ComponentStore::new()
  let e1 = world.spawn()
  let e2 = world.spawn()
  store.set(e1, { x: 1.0, y: 0.0, z: 0.0 })
  store.set(e2, { x: 2.0, y: 0.0, z: 0.0 })
  world.despawn(e1)
  let entries = store.iter_in(world).collect()
  assert_eq(entries.length(), 1)
  let (eid, _v) = entries[0]
  assert_eq(eid.index, e2.index)
}

///|
test "ComponentStore::cleanup nulls dead slots" {
  let world = World::new()
  let store : ComponentStore[Health] = ComponentStore::new()
  let e1 = world.spawn()
  let e2 = world.spawn()
  store.set(e1, { current: 10, max: 10 })
  store.set(e2, { current: 20, max: 20 })
  world.despawn(e1)
  store.cleanup(world)
  assert_true(store.get(e1) is None)
  match store.get(e2) {
    Some(h) => assert_eq(h.current, 20)
    None => fail("live slot should survive cleanup")
  }
}
