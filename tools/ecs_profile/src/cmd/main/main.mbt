// CPU profiling target for the ECS hot loops.
// Runs each workload long enough that the sampler attributes meaningful
// time per function, then prints a checksum to keep the optimizer honest.

fn setup_world(n : Int) -> @ecs.World {
  let world = @ecs.World::new()
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

fn run_movement(iters : Int, n : Int) -> Int {
  let world = setup_world(n)
  for _ in 0..<iters {
    @ecs.system_movement(world, 0.016)
  }
  let mut sum = 0
  world.each_with_transform(fn(_e, t) { sum += (t.position.x * 100.0).to_int() })
  sum
}

fn run_each_transform(iters : Int, n : Int) -> Int {
  let world = setup_world(n)
  let mut sum = 0
  for _ in 0..<iters {
    world.each_with_transform(fn(_e, t) {
      sum += (t.position.x * 100.0).to_int()
    })
  }
  sum
}

fn run_each_t_v(iters : Int, n : Int) -> Int {
  let world = setup_world(n)
  let mut sum = 0
  for _ in 0..<iters {
    world.each_with_transform_velocity(fn(_e, t, v) {
      sum += (t.position.x * 100.0 + v.x * 10.0).to_int()
    })
  }
  sum
}

fn run_full_frame(iters : Int, n : Int) -> Int {
  let world = setup_world(n)
  for i in 0..<n {
    if i % 10 == 0 {
      world.set_health({ value: i }, { current: 0, max: 100 })
    }
  }
  for _ in 0..<iters {
    @ecs.system_movement(world, 0.016)
    @ecs.system_death(world)
    @ecs.system_cleanup(world)
  }
  world.entity_count()
}

fn run_spawn(iters : Int, n : Int) -> Int {
  let mut sum = 0
  for _ in 0..<iters {
    let world = @ecs.World::new()
    for _i in 0..<n {
      let _ = world.spawn()
    }
    sum += world.entity_count()
  }
  sum
}

fn run_set_get(iters : Int, n : Int) -> Int {
  let world = setup_world(n)
  let mut sum = 0
  for _ in 0..<iters {
    for i in 0..<n {
      let eid : @ecs.EntityId = { value: i }
      world.set_health(eid, { current: i, max: 100 })
      match world.get_health(eid) {
        Some(h) => sum += h.current
        None => ()
      }
    }
  }
  sum
}

fn main {
  // Sizing: each workload aims for ~50-200ms wall time on V8 so the
  // CPU profiler (default 1ms sampling) collects enough samples.
  let mv = run_movement(2000, 10000) // system_movement
  let et = run_each_transform(2000, 10000) // each_with_transform
  let etv = run_each_t_v(2000, 10000) // each_with_transform_velocity
  let ff = run_full_frame(2000, 1000) // full_frame_tick
  let sp = run_spawn(500, 10000) // spawn loop
  let sg = run_set_get(200, 10000) // component set+get
  println(
    "ecs_profile: mv=\{mv} et=\{et} etv=\{etv} ff=\{ff} sp=\{sp} sg=\{sg}",
  )
}
