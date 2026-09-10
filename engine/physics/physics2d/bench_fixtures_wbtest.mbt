// Correctness gate for the physics2d benchmark fixtures.
//
// `just bench-gate` can only see a benchmark getting slower. A benchmark whose
// workload silently collapses — no pairs found, no constraints built, the whole
// pile asleep — only ever gets faster, so the gate stays green forever while
// measuring nothing. That is the same failure as a baseline of 18 all-black
// frames passing the frame VRT.
//
// These tests are that missing half: they assert each fixture produces the work
// its benchmark name claims. If a refactor stops generating contacts, this file
// fails instead of the benchmark quietly improving.

///|
/// How much work the pile fixture hands to each phase.
fn bench_pile_work2d(count : Int) -> (Int, Int, Int) {
  let fixture = bench_pile_fixture2d(count, bench_warm_frames2d)
  let world = fixture.world
  let sub_dt = bench_dt2d / world.solver_config.substeps.to_double()
  let pairs = world.phase_broadphase_pairs()
  let raw_contacts = world.phase_narrowphase(pairs)
  let constraints = world.phase_contact_constraints(raw_contacts, sub_dt)
  (pairs.length(), raw_contacts.length(), constraints.length())
}

///|
test "bench fixture pile 2d produces contacts for every phase" {
  let (pairs, contacts, constraints) = bench_pile_work2d(256)
  // A packed pile must find at least one pair per body: four neighbours each,
  // halved for double counting, minus the boundary. Anything near zero means
  // the fixture stopped colliding and every `phase_` number below it is noise.
  assert_true(pairs >= 256)
  assert_true(contacts >= 256)
  // Every contact must survive into a constraint, or the solver benchmark is
  // solving an empty array.
  assert_eq(constraints, contacts)
}

///|
test "bench fixture pile 2d work scales with body count" {
  let (pairs_64, contacts_64, _) = bench_pile_work2d(64)
  let (pairs_256, contacts_256, _) = bench_pile_work2d(256)
  // The size sweep only says something about scaling if the work actually
  // grows with the sweep. Equal work at 4x the bodies would mean the pile
  // geometry, not the solver, is what changed between the two numbers.
  assert_true(pairs_256 > pairs_64 * 2)
  assert_true(contacts_256 > contacts_64 * 2)
}

///|
test "bench fixture pile 2d is awake" {
  let fixture = bench_pile_fixture2d(256, bench_warm_frames2d)
  let mut sleeping = 0
  for i = 0; i < fixture.snapshot.length(); i = i + 1 {
    if fixture.snapshot[i].is_sleeping {
      sleeping = sleeping + 1
    }
  }
  // `bench_warm_frames2d` is deliberately under the sleep threshold. If the
  // pile were asleep, `step_pile_*` would price the sleep fast-path while
  // claiming to price the solver.
  assert_eq(sleeping, 0)
}

///|
test "bench fixture resting 2d is asleep and still touching the ground" {
  let fixture = bench_resting_fixture2d(256, bench_resting_frames2d)
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
  // `step_resting_256` only means anything if the scene really is asleep.
  assert_eq(sleeping, 256)
  // ...and only prices the sleeping path of a *loaded* world if the contacts
  // are still there to be found. An asleep scene that also drifted out of
  // contact would be measuring an empty narrowphase instead.
  let world = fixture.world
  assert_eq(
    world.phase_narrowphase(world.phase_broadphase_pairs()).length(),
    256,
  )
}

///|
test "bench fixture scatter 2d has no contacts" {
  let fixture = bench_scatter_fixture2d(1024, bench_warm_frames2d)
  let world = fixture.world
  let pairs = world.phase_broadphase_pairs()
  // The point of `step_scatter_1024` is that it is the same body count as
  // `step_pile_1024` with the narrowphase and solver empty. If bodies started
  // touching, the comparison between the two would stop isolating contact cost.
  assert_eq(world.phase_narrowphase(pairs).length(), 0)
  assert_eq(world.body_count(), 1024)
}

///|
test "bench fixture rope 2d builds distance joints only" {
  let fixture = bench_rope_fixture2d(256, bench_warm_frames2d)
  let world = fixture.world
  let sub_dt = bench_dt2d / world.solver_config.substeps.to_double()
  let (dist_constraints, rev_constraints) = world.phase_joint_constraints(
    sub_dt,
  )
  assert_eq(world.joints_distance.length(), 255)
  assert_eq(dist_constraints.length(), 255)
  assert_eq(rev_constraints.length(), 0)
  // A rope benchmark must price joints, not incidental contacts between links.
  assert_eq(world.phase_narrowphase(world.phase_broadphase_pairs()).length(), 0)
}

///|
test "bench fixture hinge 2d builds revolute joints only" {
  let fixture = bench_hinge_fixture2d(256, bench_warm_frames2d)
  let world = fixture.world
  let sub_dt = bench_dt2d / world.solver_config.substeps.to_double()
  let (dist_constraints, rev_constraints) = world.phase_joint_constraints(
    sub_dt,
  )
  assert_eq(world.joints_revolute.length(), 255)
  assert_eq(rev_constraints.length(), 255)
  assert_eq(dist_constraints.length(), 0)
  assert_eq(world.phase_narrowphase(world.phase_broadphase_pairs()).length(), 0)
}

///|
test "bench fixture 2d reset restores the measured frame exactly" {
  let fixture = bench_pile_fixture2d(64, bench_warm_frames2d)
  let world = fixture.world
  world.step(bench_dt2d)
  world.step(bench_dt2d)
  fixture.reset()
  // Every benchmark iteration must start from the identical frame, or the
  // reported mean is an average over a drifting simulation.
  for i = 0; i < fixture.snapshot.length(); i = i + 1 {
    let expected = fixture.snapshot[i]
    let actual = world.bodies[i]
    assert_eq(actual.position.x, expected.position.x)
    assert_eq(actual.position.y, expected.position.y)
    assert_eq(actual.velocity.x, expected.velocity.x)
    assert_eq(actual.velocity.y, expected.velocity.y)
    assert_eq(actual.is_sleeping, expected.is_sleeping)
    assert_eq(actual.sleep_timer, expected.sleep_timer)
  }
}

///|
test "bench fixture 2d is deterministic across builds" {
  let first = bench_pile_fixture2d(64, bench_warm_frames2d)
  let second = bench_pile_fixture2d(64, bench_warm_frames2d)
  assert_eq(first.snapshot.length(), second.snapshot.length())
  // Fixture jitter comes from a fixed-seed LCG rather than `@random`, so two
  // runs on two machines compare against the same baseline.
  for i = 0; i < first.snapshot.length(); i = i + 1 {
    assert_eq(first.snapshot[i].position.x, second.snapshot[i].position.x)
    assert_eq(first.snapshot[i].position.y, second.snapshot[i].position.y)
  }
}

///|
test "bench fixture 2d reset keeps the solver doing work" {
  let fixture = bench_pile_fixture2d(64, bench_warm_frames2d)
  let world = fixture.world
  let config = world.solver_config
  let sub_dt = bench_dt2d / config.substeps.to_double()
  let template = world.phase_contact_constraints(
    world.phase_narrowphase(world.phase_broadphase_pairs()),
    sub_dt,
  )
  assert_true(template.length() > 0)
  let constraints = template.copy()
  // Run the solve benchmark's body twice over. Without the constraint restore
  // the accumulators would converge and the second pass would take the
  // skip-the-impulse branch, so the benchmark would price a no-op.
  let mut moved_first = 0
  let mut moved_second = 0
  for pass = 0; pass < 2; pass = pass + 1 {
    fixture.reset()
    bench_restore_constraints2d(constraints, template)
    world.phase_solve_velocities(
      constraints,
      [],
      [],
      config.velocity_iterations,
    )
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
