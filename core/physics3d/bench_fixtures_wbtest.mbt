// Correctness gate for the physics3d benchmark fixtures.
//
// `just bench-gate` can only see a benchmark getting slower. A benchmark whose
// workload silently collapses — no pairs found, no constraints built, the whole
// pile asleep — only ever gets faster, so the gate stays green forever while
// measuring nothing.
//
// These tests are that missing half: they assert each fixture produces the work
// its benchmark name claims.

///|
/// How much work the pile fixture hands to each phase.
fn bench_pile_work3d(count : Int) -> (Int, Int) {
  let fixture = bench_pile_fixture3d(count, bench_warm_frames3d)
  let world = fixture.world
  let sub_dt = bench_dt3d / world.solver_config.substeps.to_double()
  let pairs = world.phase_broadphase_pairs()
  let constraints = world.phase_contact_constraints(pairs, sub_dt)
  (pairs, constraints.length())
}

///|
test "bench fixture pile 3d produces contacts for every phase" {
  let (pairs, constraints) = bench_pile_work3d(256)
  // A packed 3D pile has six neighbours per interior sphere, so at least one
  // pair per body is a conservative floor. Anything near zero means the fixture
  // stopped colliding and every `phase_` number below it is noise.
  assert_true(pairs >= 256)
  assert_true(constraints >= 256)
}

///|
test "bench fixture pile 3d work scales with body count" {
  let (pairs_64, constraints_64) = bench_pile_work3d(64)
  let (pairs_256, constraints_256) = bench_pile_work3d(256)
  // The size sweep only says something about scaling if the work actually grows
  // with the sweep.
  assert_true(pairs_256 > pairs_64 * 2)
  assert_true(constraints_256 > constraints_64 * 2)
}

///|
test "bench fixture pile 3d is awake" {
  let fixture = bench_pile_fixture3d(256, bench_warm_frames3d)
  let mut sleeping = 0
  for i = 0; i < fixture.snapshot.length(); i = i + 1 {
    if fixture.snapshot[i].is_sleeping {
      sleeping = sleeping + 1
    }
  }
  // `bench_warm_frames3d` is deliberately under the sleep threshold. An asleep
  // pile would make `step_pile_*` price the sleep fast-path while claiming to
  // price the solver — and in 3D it would also skip the union-find pass that
  // `phase_sleep_islands_pile_256` exists to measure.
  assert_eq(sleeping, 0)
}

///|
test "bench fixture resting 3d is asleep and still touching the floor" {
  let fixture = bench_resting_fixture3d(256, bench_resting_frames3d)
  let mut sleeping = 0
  let mut dynamic = 0
  for i = 0; i < fixture.snapshot.length(); i = i + 1 {
    let body = fixture.snapshot[i]
    if body.is_dynamic() {
      dynamic = dynamic + 1
      if body.is_sleeping {
        sleeping = sleeping + 1
      }
    }
  }
  assert_eq(dynamic, 256)
  // `step_resting_256` and `phase_sleep_islands_resting_256` only mean anything
  // if the scene really is asleep — the latter exists precisely to run the
  // union-find pass that an awake-but-settled scene would skip.
  assert_eq(sleeping, 256)
  let world = fixture.world
  let sub_dt = bench_dt3d / world.solver_config.substeps.to_double()
  // The broadphase still finds every body/floor pair -- the scene is loaded, not
  // empty -- but none of them becomes a constraint, because both sides of each
  // are immovable: one static floor, one sleeping sphere. That skip is the whole
  // reason a settled scene is cheap, and it is also what stops a settled island
  // being kicked awake by its own cached impulses.
  //
  // So this asserts the pairing survives and the solving does not. If a later
  // change makes `step_resting_256` build constraints again, this fails and the
  // benchmark's meaning has changed with it.
  assert_eq(world.phase_broadphase_pairs(), 256)
  assert_eq(
    world
    .phase_contact_constraints(world.phase_broadphase_pairs(), sub_dt)
    .length(),
    0,
  )
}

///|
test "bench fixture scatter 3d has no contacts" {
  let fixture = bench_scatter_fixture3d(1024, bench_warm_frames3d)
  let world = fixture.world
  let sub_dt = bench_dt3d / world.solver_config.substeps.to_double()
  // The point of `step_scatter_1024` is that it is the same body count as
  // `step_pile_1024` with the narrowphase and solver empty.
  assert_eq(
    world
    .phase_contact_constraints(world.phase_broadphase_pairs(), sub_dt)
    .length(),
    0,
  )
  assert_eq(world.body_count(), 1024)
}

///|
test "bench fixture rope 3d builds distance joints only" {
  let fixture = bench_rope_fixture3d(256, bench_warm_frames3d)
  let world = fixture.world
  let sub_dt = bench_dt3d / world.solver_config.substeps.to_double()
  let (dist_constraints, ball_constraints) = world.phase_joint_constraints(
    sub_dt,
  )
  assert_eq(world.joints_distance.length(), 255)
  assert_eq(dist_constraints.length(), 255)
  assert_eq(ball_constraints.length(), 0)
  // A rope benchmark must price joints, not incidental contacts between links.
  assert_eq(
    world
    .phase_contact_constraints(world.phase_broadphase_pairs(), sub_dt)
    .length(),
    0,
  )
}

///|
test "bench fixture ball chain 3d builds ball joints only" {
  let fixture = bench_ball_chain_fixture3d(256, bench_warm_frames3d)
  let world = fixture.world
  let sub_dt = bench_dt3d / world.solver_config.substeps.to_double()
  let (dist_constraints, ball_constraints) = world.phase_joint_constraints(
    sub_dt,
  )
  assert_eq(world.joints_ball.length(), 255)
  assert_eq(ball_constraints.length(), 255)
  assert_eq(dist_constraints.length(), 0)
  assert_eq(
    world
    .phase_contact_constraints(world.phase_broadphase_pairs(), sub_dt)
    .length(),
    0,
  )
}

///|
test "bench fixture 3d reset restores the measured frame exactly" {
  let fixture = bench_pile_fixture3d(64, bench_warm_frames3d)
  let world = fixture.world
  world.step(bench_dt3d)
  world.step(bench_dt3d)
  fixture.reset()
  // Every benchmark iteration must start from the identical frame, or the
  // reported mean is an average over a drifting simulation.
  for i = 0; i < fixture.snapshot.length(); i = i + 1 {
    let expected = fixture.snapshot[i]
    let actual = world.bodies[i]
    assert_eq(actual.position.x, expected.position.x)
    assert_eq(actual.position.y, expected.position.y)
    assert_eq(actual.position.z, expected.position.z)
    assert_eq(actual.velocity.x, expected.velocity.x)
    assert_eq(actual.velocity.y, expected.velocity.y)
    assert_eq(actual.velocity.z, expected.velocity.z)
    assert_eq(actual.rotation.w, expected.rotation.w)
    assert_eq(actual.is_sleeping, expected.is_sleeping)
    assert_eq(actual.sleep_timer, expected.sleep_timer)
  }
}

///|
test "bench fixture 3d is deterministic across builds" {
  let first = bench_pile_fixture3d(64, bench_warm_frames3d)
  let second = bench_pile_fixture3d(64, bench_warm_frames3d)
  assert_eq(first.snapshot.length(), second.snapshot.length())
  // Fixture jitter comes from a fixed-seed LCG rather than `@random`, so two
  // runs on two machines compare against the same baseline.
  for i = 0; i < first.snapshot.length(); i = i + 1 {
    assert_eq(first.snapshot[i].position.x, second.snapshot[i].position.x)
    assert_eq(first.snapshot[i].position.y, second.snapshot[i].position.y)
    assert_eq(first.snapshot[i].position.z, second.snapshot[i].position.z)
  }
}

///|
test "bench fixture 3d reset keeps the solver doing work" {
  let fixture = bench_pile_fixture3d(64, bench_warm_frames3d)
  let world = fixture.world
  let config = world.solver_config
  let sub_dt = bench_dt3d / config.substeps.to_double()
  let template = world.phase_contact_constraints(
    world.phase_broadphase_pairs(),
    sub_dt,
  )
  assert_true(template.length() > 0)
  let constraints = template.copy()
  // Run the solve benchmark's body twice over. Without the constraint restore
  // the accumulators would converge and the second pass would fall behind the
  // near-zero impulse guards, so the benchmark would price a no-op.
  let mut moved_first = 0
  let mut moved_second = 0
  for pass = 0; pass < 2; pass = pass + 1 {
    fixture.reset()
    bench_restore_constraints3d(constraints, template)
    let vel = world.velocity_state
    vel.load(world.bodies)
    world.phase_solve_velocities(
      constraints,
      [],
      [],
      vel,
      config.velocity_iterations,
    )
    vel.store(world.bodies)
    let mut moved = 0
    for i = 0; i < fixture.snapshot.length(); i = i + 1 {
      if world.bodies[i].velocity.y != fixture.snapshot[i].velocity.y {
        moved = moved + 1
      }
    }
    if pass == 0 {
      moved_first = moved
    } else {
      moved_second = moved
    }
  }
  assert_true(moved_first > 0)
  assert_eq(moved_first, moved_second)
}
