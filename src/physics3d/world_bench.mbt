///|
fn bench_make_dense_world(count : Int) -> PhysicsWorld {
  let world = PhysicsWorld::new(@math3d.Vec3::new(0.0, -9.8, 0.0), 1.0)
  for i in 0..<count {
    let x = (i % 4).to_double() * 0.9
    let y = (i / 4 % 4).to_double() * 0.9 + 4.0
    let z = (i / 16).to_double() * 0.9
    world.add_body(
      RigidBody::new_dynamic(
        i,
        @math3d.Vec3::new(x, y, z),
        1.0,
        SphereShape(@math3d.Vec3::zero(), 0.5),
      ),
    )
  }
  world
}

///|
fn bench_world_pairs(world : PhysicsWorld) -> Array[(Int, Int)] {
  world.broadphase.clear()
  for i = 0; i < world.bodies.length(); i = i + 1 {
    world.broadphase.insert(i, world.bodies[i].world_aabb())
  }
  world.broadphase.get_pairs()
}

///|
fn bench_world_constraints(
  world : PhysicsWorld,
  dt : Double,
) -> Array[ContactConstraintRuntime3D] {
  let pairs = bench_world_pairs(world)
  let sub_dt = dt / world.solver_config.substeps.to_double()
  let (contact_gamma, contact_bias_coefficient) = soft_constraint_params3d(
    world.solver_config.contact_hertz,
    world.solver_config.contact_damping_ratio,
    sub_dt,
  )
  let constraints : Array[ContactConstraintRuntime3D] = Array::new(
    capacity=pairs.length(),
  )
  for i = 0; i < pairs.length(); i = i + 1 {
    let (idx_a, idx_b) = pairs[i]
    let body_a = world.bodies[idx_a]
    let body_b = world.bodies[idx_b]
    if body_a.inv_mass >= 1.0e-12 || body_b.inv_mass >= 1.0e-12 {
      match generate_contact(body_a, body_b) {
        Some(contact) =>
          constraints.push(
            precompute_constraint3d(
              body_a, body_b, idx_a, idx_b, contact, contact_gamma, contact_bias_coefficient,
            ),
          )
        None => ()
      }
    }
  }
  constraints
}

///|
fn bench_world_through_substeps(world : PhysicsWorld, dt : Double) -> Int {
  let constraints = bench_world_constraints(world, dt)
  let config = world.solver_config
  let substeps = config.substeps
  let sub_dt = dt / substeps.to_double()
  let body_count = world.bodies.length()
  for _s = 0; _s < substeps; _s = _s + 1 {
    bench_world_integrate_velocities(world, sub_dt, body_count)
    bench_world_solve_constraints(
      world,
      constraints,
      config.velocity_iterations,
    )
    bench_world_integrate_positions(world, sub_dt, body_count)
  }
  constraints.length()
}

///|
fn bench_world_integrate_velocities(
  world : PhysicsWorld,
  sub_dt : Double,
  body_count : Int,
) -> Unit {
  for i = 0; i < body_count; i = i + 1 {
    let body = world.bodies[i]
    if body.is_dynamic() && not(body.is_sleeping) {
      let accel = world.gravity.add(body.force.scale(body.inv_mass))
      let new_vel = body.velocity
        .add(accel.scale(sub_dt))
        .scale(1.0 - body.linear_damping * sub_dt)
      let new_angular_vel = if body.angular_velocity.length_squared() <= 1.0e-24 &&
        body.torque.length_squared() <= 1.0e-24 {
        @math3d.Vec3::zero()
      } else {
        let angular_accel = body.torque.scale(body.inv_inertia)
        body.angular_velocity
        .add(angular_accel.scale(sub_dt))
        .scale(1.0 - body.angular_damping * sub_dt)
      }
      world.bodies[i] = {
        ..body,
        velocity: new_vel,
        angular_velocity: new_angular_vel,
      }
    }
  }
}

///|
fn bench_world_solve_constraints(
  world : PhysicsWorld,
  constraints : Array[ContactConstraintRuntime3D],
  velocity_iterations : Int,
) -> Unit {
  for _iter = 0; _iter < velocity_iterations; _iter = _iter + 1 {
    for ci = 0; ci < constraints.length(); ci = ci + 1 {
      solve_constraint3d(constraints, ci, world.bodies)
    }
  }
}

///|
fn bench_world_integrate_positions(
  world : PhysicsWorld,
  sub_dt : Double,
  body_count : Int,
) -> Unit {
  for i = 0; i < body_count; i = i + 1 {
    let body = world.bodies[i]
    if body.is_dynamic() && not(body.is_sleeping) {
      let omega = body.angular_velocity
      let omega_len_sq = omega.length_squared()
      let new_rotation = if omega_len_sq > 1.0e-24 {
        let omega_len = omega_len_sq.sqrt()
        let axis = omega.scale(1.0 / omega_len)
        let angle = omega_len * sub_dt
        body.rotation
        .multiply(@math3d.Quaternion::from_axis_angle(axis, angle))
        .normalize()
      } else {
        body.rotation
      }
      world.bodies[i] = {
        ..body,
        position: body.position.add(body.velocity.scale(sub_dt)),
        rotation: new_rotation,
      }
    }
  }
}

///|
test "bench physics3d step pairs dense 64" (b : @bench.T) {
  b.bench(name="physics3d/world_step_pairs_dense_64", fn() {
    let world = bench_make_dense_world(64)
    let pairs = bench_world_pairs(world)
    b.keep(pairs.length())
  })
}

///|
test "bench physics3d step constraints dense 64" (b : @bench.T) {
  b.bench(name="physics3d/world_step_constraints_dense_64", fn() {
    let world = bench_make_dense_world(64)
    let constraints = bench_world_constraints(world, 1.0 / 60.0)
    b.keep(constraints.length())
  })
}

///|
test "bench physics3d step through substeps dense 64" (b : @bench.T) {
  b.bench(name="physics3d/world_step_substeps_dense_64", fn() {
    let world = bench_make_dense_world(64)
    b.keep(bench_world_through_substeps(world, 1.0 / 60.0))
  })
}

///|
test "bench physics3d step velocity integration dense 64" (b : @bench.T) {
  b.bench(name="physics3d/world_step_velocity_dense_64", fn() {
    let world = bench_make_dense_world(64)
    let config = world.solver_config
    let sub_dt = 1.0 / 60.0 / config.substeps.to_double()
    bench_world_integrate_velocities(world, sub_dt, world.bodies.length())
    b.keep(world.body_count())
  })
}

///|
test "bench physics3d step solve dense 64" (b : @bench.T) {
  b.bench(name="physics3d/world_step_solve_dense_64", fn() {
    let world = bench_make_dense_world(64)
    let constraints = bench_world_constraints(world, 1.0 / 60.0)
    bench_world_solve_constraints(
      world,
      constraints,
      world.solver_config.velocity_iterations,
    )
    b.keep(constraints.length())
  })
}

///|
test "bench physics3d step solve only dense 64" (b : @bench.T) {
  let base_world = bench_make_dense_world(64)
  let base_constraints = bench_world_constraints(base_world, 1.0 / 60.0)
  let velocity_iterations = base_world.solver_config.velocity_iterations
  b.bench(name="physics3d/world_step_solve_only_dense_64", fn() {
    let world = bench_make_dense_world(64)
    let constraints = base_constraints.copy()
    bench_world_solve_constraints(world, constraints, velocity_iterations)
    b.keep(constraints.length())
  })
}

///|
test "bench physics3d step position integration dense 64" (b : @bench.T) {
  b.bench(name="physics3d/world_step_position_dense_64", fn() {
    let world = bench_make_dense_world(64)
    let config = world.solver_config
    let sub_dt = 1.0 / 60.0 / config.substeps.to_double()
    bench_world_integrate_positions(world, sub_dt, world.bodies.length())
    b.keep(world.body_count())
  })
}

///|
test "bench physics3d full step dense 64" (b : @bench.T) {
  b.bench(name="physics3d/world_step_full_dense_64", fn() {
    let world = bench_make_dense_world(64)
    world.step(1.0 / 60.0)
    b.keep(world.body_count())
  })
}
