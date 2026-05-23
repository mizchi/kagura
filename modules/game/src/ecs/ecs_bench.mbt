///|
priv struct BenchSetup {
  world : World
  transforms : ComponentStore[@transform3d.Transform3D]
  velocities : ComponentStore[Velocity]
  health : ComponentStore[Health]
}

///|
fn setup_world(n : Int) -> BenchSetup {
  let world = World::new()
  let transforms : ComponentStore[@transform3d.Transform3D] = ComponentStore::new()
  let velocities : ComponentStore[Velocity] = ComponentStore::new()
  let health : ComponentStore[Health] = ComponentStore::new()
  for i in 0..<n {
    let eid = world.spawn()
    transforms.set(
      eid,
      @transform3d.Transform3D::from_position(
        @math3d.Vec3::new(i.to_double(), 0.0, 0.0),
      ),
    )
    velocities.set(eid, { x: 1.0, y: 2.0, z: 0.0 })
    health.set(eid, { current: 100, max: 100 })
  }
  { world, transforms, velocities, health }
}

///|
fn checksum(setup : BenchSetup) -> Int {
  let mut sum = 0
  query1(setup.world, setup.transforms).each(fn(entry) {
    let (_eid, t) = entry
    sum += (t.position.x * 100.0).to_int()
  })
  sum
}

///|
test "bench spawn 10000 entities" (b : @bench.T) {
  b.bench(name="ecs/spawn_10000", fn() {
    let world = World::new()
    for _i in 0..<10000 {
      let _ = world.spawn()
    }
    b.keep(world.entity_count())
  })
}

///|
test "bench spawn + transform set 10000" (b : @bench.T) {
  b.bench(name="ecs/spawn_with_transform_10000", fn() {
    let world = World::new()
    let transforms : ComponentStore[@transform3d.Transform3D] = ComponentStore::new()
    for i in 0..<10000 {
      let eid = world.spawn()
      transforms.set(
        eid,
        @transform3d.Transform3D::from_position(
          @math3d.Vec3::new(i.to_double(), 0.0, 0.0),
        ),
      )
    }
    b.keep(world.entity_count())
  })
}

///|
test "bench system_movement 10000" (b : @bench.T) {
  let setup = setup_world(10000)
  b.bench(name="ecs/system_movement_10000", fn() {
    system_movement(setup.world, setup.transforms, setup.velocities, 0.016)
    b.keep(checksum(setup))
  })
}

///|
test "bench system_death 10000" (b : @bench.T) {
  b.bench(name="ecs/system_death_10000", fn() {
    let setup = setup_world(10000)
    // kill half (every even index)
    for i in 0..<5000 {
      let eid : EntityId = { index: i * 2, generation: 0 }
      setup.health.set(eid, { current: 0, max: 100 })
    }
    system_death(setup.world, setup.health)
    b.keep(setup.world.entity_count())
  })
}

///|
test "bench World::iter 10000" (b : @bench.T) {
  let setup = setup_world(10000)
  b.bench(name="ecs/world_iter_10000", fn() {
    b.keep(setup.world.iter().count())
  })
}

///|
test "bench query1 transform 10000" (b : @bench.T) {
  let setup = setup_world(10000)
  b.bench(name="ecs/query1_transform_10000", fn() {
    let mut sum = 0
    query1(setup.world, setup.transforms).each(fn(entry) {
      let (_e, t) = entry
      sum += (t.position.x * 100.0).to_int()
    })
    b.keep(sum)
  })
}

///|
test "bench query1_each transform 10000" (b : @bench.T) {
  let setup = setup_world(10000)
  b.bench(name="ecs/query1_each_transform_10000", fn() {
    let mut sum = 0
    query1_each(setup.world, setup.transforms, fn(_e, t) {
      sum += (t.position.x * 100.0).to_int()
    })
    b.keep(sum)
  })
}

///|
test "bench query2 transform+velocity 10000" (b : @bench.T) {
  let setup = setup_world(10000)
  b.bench(name="ecs/query2_transform_velocity_10000", fn() {
    let mut sum = 0
    query2(setup.world, setup.transforms, setup.velocities).each(fn(entry) {
      let (_e, t, v) = entry
      sum += (t.position.x * 100.0 + v.x * 10.0).to_int()
    })
    b.keep(sum)
  })
}

///|
test "bench query2_each transform+velocity 10000" (b : @bench.T) {
  let setup = setup_world(10000)
  b.bench(name="ecs/query2_each_transform_velocity_10000", fn() {
    let mut sum = 0
    query2_each(setup.world, setup.transforms, setup.velocities, fn(_e, t, v) {
      sum += (t.position.x * 100.0 + v.x * 10.0).to_int()
    })
    b.keep(sum)
  })
}

///|
test "bench entities_with_tag 10000" (b : @bench.T) {
  let setup = setup_world(10000)
  let tags : ComponentStore[Array[Tag]] = ComponentStore::new()
  for i in 0..<10000 {
    let eid : EntityId = { index: i, generation: 0 }
    if i % 3 == 0 {
      tags_add(tags, eid, Enemy)
    } else {
      tags_add(tags, eid, Bullet)
    }
  }
  b.bench(name="ecs/entities_with_tag_10000", fn() {
    b.keep(entities_with_tag(setup.world, tags, Enemy).count())
  })
}

///|
test "bench component set/get 10000" (b : @bench.T) {
  let setup = setup_world(10000)
  b.bench(name="ecs/component_set_get_10000", fn() {
    let mut sum = 0
    for i in 0..<10000 {
      let eid : EntityId = { index: i, generation: 0 }
      setup.health.set(eid, { current: i, max: 100 })
      match setup.health.get(eid) {
        Some(h) => sum += h.current
        None => ()
      }
    }
    b.keep(sum)
  })
}

///|
test "bench full frame tick 1000" (b : @bench.T) {
  let setup = setup_world(1000)
  for i in 0..<1000 {
    if i % 10 == 0 {
      let eid : EntityId = { index: i, generation: 0 }
      setup.health.set(eid, { current: 0, max: 100 })
    }
  }
  b.bench(name="ecs/full_frame_tick_1000", fn() {
    system_movement(setup.world, setup.transforms, setup.velocities, 0.016)
    system_death(setup.world, setup.health)
    b.keep(setup.world.entity_count())
  })
}
