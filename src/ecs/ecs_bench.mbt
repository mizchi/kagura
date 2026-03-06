///|
fn setup_world(n : Int) -> World {
  let world = World::new()
  for i in 0..<n {
    let eid = world.spawn()
    world.set_transform(
      eid,
      @transform3d.Transform3D::from_position(
        @math3d.Vec3::new(i.to_double(), 0.0, 0.0),
      ),
    )
    world.set_velocity(eid, { x: 1.0, y: 2.0, z: 0.0 })
    world.set_health(eid, { current: 100, max: 100 })
  }
  world
}

///|
fn world_checksum(world : World) -> Int {
  let mut sum = 0
  world.each_with_transform(fn(_eid, t) {
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
test "bench spawn_at 10000 entities" (b : @bench.T) {
  b.bench(name="ecs/spawn_at_10000", fn() {
    let world = World::new()
    for i in 0..<10000 {
      let _ = world.spawn_at(
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
  let world = setup_world(10000)
  b.bench(name="ecs/system_movement_10000", fn() {
    system_movement(world, 0.016)
    b.keep(world_checksum(world))
  })
}

///|
test "bench system_death 10000" (b : @bench.T) {
  b.bench(name="ecs/system_death_10000", fn() {
    let world = setup_world(10000)
    // kill half
    for i in 0..<5000 {
      world.set_health({ value: i * 2 }, { current: 0, max: 100 })
    }
    system_death(world)
    b.keep(world.entity_count())
  })
}

///|
test "bench compact 10000 half dead" (b : @bench.T) {
  b.bench(name="ecs/compact_10000_half_dead", fn() {
    let world = setup_world(10000)
    for i in 0..<5000 {
      world.destroy({ value: i * 2 })
    }
    world.compact()
    b.keep(world.entity_count())
  })
}

///|
test "bench each_entity 10000" (b : @bench.T) {
  let world = setup_world(10000)
  b.bench(name="ecs/each_entity_10000", fn() {
    let mut count = 0
    world.each_entity(fn(_eid) { count += 1 })
    b.keep(count)
  })
}

///|
test "bench each_with_transform 10000" (b : @bench.T) {
  let world = setup_world(10000)
  b.bench(name="ecs/each_with_transform_10000", fn() {
    let mut sum = 0
    world.each_with_transform(fn(_eid, t) {
      sum += (t.position.x * 100.0).to_int()
    })
    b.keep(sum)
  })
}

///|
test "bench each_with_transform_velocity 10000" (b : @bench.T) {
  let world = setup_world(10000)
  b.bench(name="ecs/each_with_transform_velocity_10000", fn() {
    let mut sum = 0
    world.each_with_transform_velocity(fn(_eid, t, v) {
      sum += (t.position.x * 100.0 + v.x * 10.0).to_int()
    })
    b.keep(sum)
  })
}

///|
test "bench entities_with_tag 10000" (b : @bench.T) {
  let world = setup_world(10000)
  for i in 0..<10000 {
    if i % 3 == 0 {
      world.add_tag({ value: i }, Enemy)
    } else {
      world.add_tag({ value: i }, Bullet)
    }
  }
  b.bench(name="ecs/entities_with_tag_10000", fn() {
    let enemies = world.entities_with_tag(Enemy)
    b.keep(enemies.length())
  })
}

///|
test "bench component set/get 10000" (b : @bench.T) {
  let world = setup_world(10000)
  b.bench(name="ecs/component_set_get_10000", fn() {
    let mut sum = 0
    for i in 0..<10000 {
      let eid : EntityId = { value: i }
      world.set_health(eid, { current: i, max: 100 })
      match world.get_health(eid) {
        Some(h) => sum += h.current
        None => ()
      }
    }
    b.keep(sum)
  })
}

///|
test "bench full frame tick 1000" (b : @bench.T) {
  let world = setup_world(1000)
  for i in 0..<1000 {
    if i % 10 == 0 {
      world.set_health({ value: i }, { current: 0, max: 100 })
    }
  }
  b.bench(name="ecs/full_frame_tick_1000", fn() {
    system_movement(world, 0.016)
    system_death(world)
    system_cleanup(world)
    b.keep(world.entity_count())
  })
}
