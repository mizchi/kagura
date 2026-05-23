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
test "ComponentStore::get returns None after slot recycled and re-set" {
  let world = World::new()
  let store : ComponentStore[Health] = ComponentStore::new()
  let e1 = world.spawn()
  store.set(e1, { current: 50, max: 100 })
  world.despawn(e1)
  // Slot is recycled with generation 1; new owner sets a value, bumping
  // the store's per-slot generation to 1 too.
  let e2 = world.spawn()
  assert_eq(e2.index, e1.index)
  store.set(e2, { current: 7, max: 50 })
  // The old handle (generation 0) no longer matches the store generation
  // (now 1), so reads return None even though the slot is populated.
  assert_true(store.get(e1) is None)
  match store.get(e2) {
    Some(h) => assert_eq(h.current, 7)
    None => fail("new handle should read the new value")
  }
}

///|
test "ComponentStore::iter_in skips slot reused without re-set" {
  // After respawn at the same index, before the new owner sets a value,
  // iter_in must NOT yield the stale data — even though the slot is alive.
  let world = World::new()
  let store : ComponentStore[Health] = ComponentStore::new()
  let e1 = world.spawn()
  store.set(e1, { current: 50, max: 100 })
  world.despawn(e1)
  let _e2 = world.spawn() // same index, world gen 1, store gen still 0
  assert_eq(store.iter_in(world).count(), 0)
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
