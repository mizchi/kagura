// physics2d benchmarks.
//
// Naming: `physics2d/<what>_<fixture>_<bodies>`.
//
// | prefix          | what the number includes                                    |
// |-----------------|-------------------------------------------------------------|
// | `step_`         | one `PhysicsWorld2D::step` on a pre-warmed world, plus reset |
// | `phase_`        | one phase of that step, plus the reset it needs              |
// | `phase_reset_`  | the reset alone — the floor to subtract from `phase_` numbers |
// | `build_`        | world construction alone — no warm-up, nothing simulated     |
//
// `phase_` numbers are only meaningful minus their floor. `moon bench` has no
// per-iteration setup hook, so the reset is inside every closure that needs one
// (see `bench_fixtures.mbt` for why a reset is needed at all). For `step_`
// benchmarks the floor is three orders of magnitude below the measurement and
// can be ignored.
//
// Every phase here is the function `step` itself calls, so a benchmark can never
// drift away from the shipped pipeline the way a hand-copied loop can.
//
// physics2d had no benchmarks at all before this file, despite being the engine
// this project leads with.

///|
/// Restore constraint accumulators between iterations.
///
/// `solve_constraint2d` replaces whole array elements rather than mutating the
/// structs in place, so the pristine template is never damaged and restoring is
/// one reference write per constraint.
///
/// Without this the solver converges: `delta_jn` falls under the 1e-15 branch,
/// the impulse writes are skipped, and the benchmark reports a solve that no
/// longer solves anything.
fn bench_restore_constraints2d(
  constraints : Array[ContactConstraint2D],
  template : Array[ContactConstraint2D],
) -> Unit {
  for i = 0; i < template.length(); i = i + 1 {
    constraints[i] = template[i]
  }
}

// ---------------------------------------------------------------------------
// Full step, swept over body count
// ---------------------------------------------------------------------------

///|
test "bench physics2d step pile 64" (b : @bench.T) {
  let fixture = bench_pile_fixture2d(64, bench_warm_frames2d)
  b.bench(name="physics2d/step_pile_64", fn() {
    fixture.reset()
    fixture.world.step(bench_dt2d)
    b.keep(fixture.world.body_count())
  })
}

///|
test "bench physics2d step pile 256" (b : @bench.T) {
  let fixture = bench_pile_fixture2d(256, bench_warm_frames2d)
  b.bench(name="physics2d/step_pile_256", fn() {
    fixture.reset()
    fixture.world.step(bench_dt2d)
    b.keep(fixture.world.body_count())
  })
}

///|
test "bench physics2d step pile 1024" (b : @bench.T) {
  let fixture = bench_pile_fixture2d(1024, bench_warm_frames2d)
  b.bench(name="physics2d/step_pile_1024", fn() {
    fixture.reset()
    fixture.world.step(bench_dt2d)
    b.keep(fixture.world.body_count())
  })
}

///|
/// Same body count as `step_pile_1024` with the narrowphase and solver empty.
/// The gap between the two is what contacts cost; this one is the per-body
/// floor of a frame.
test "bench physics2d step scatter 1024" (b : @bench.T) {
  let fixture = bench_scatter_fixture2d(1024, bench_warm_frames2d)
  b.bench(name="physics2d/step_scatter_1024", fn() {
    fixture.reset()
    fixture.world.step(bench_dt2d)
    b.keep(fixture.world.body_count())
  })
}

///|
/// A fully asleep scene. Prices the path a settled level actually takes, which
/// is the common case in a shipped game and was previously unmeasured.
test "bench physics2d step resting 256" (b : @bench.T) {
  let fixture = bench_resting_fixture2d(256, bench_resting_frames2d)
  b.bench(name="physics2d/step_resting_256", fn() {
    fixture.reset()
    fixture.world.step(bench_dt2d)
    b.keep(fixture.world.body_count())
  })
}

///|
test "bench physics2d step rope 256" (b : @bench.T) {
  let fixture = bench_rope_fixture2d(256, bench_warm_frames2d)
  b.bench(name="physics2d/step_rope_256", fn() {
    fixture.reset()
    fixture.world.step(bench_dt2d)
    b.keep(fixture.world.body_count())
  })
}

///|
test "bench physics2d step hinge 256" (b : @bench.T) {
  let fixture = bench_hinge_fixture2d(256, bench_warm_frames2d)
  b.bench(name="physics2d/step_hinge_256", fn() {
    fixture.reset()
    fixture.world.step(bench_dt2d)
    b.keep(fixture.world.body_count())
  })
}

// ---------------------------------------------------------------------------
// Construction, measured on purpose and separately
// ---------------------------------------------------------------------------

///|
/// World construction alone: 1024 bodies allocated and inserted, nothing
/// simulated. Warm-up is deliberately excluded, since 8 warm frames of a
/// 1024-body pile cost ~200ms against ~150us of construction and would leave
/// this benchmark tracking `step` a ninth time over.
test "bench physics2d build pile 1024" (b : @bench.T) {
  b.bench(name="physics2d/build_pile_1024", fn() {
    let fixture = bench_pile_fixture2d(1024, 0)
    b.keep(fixture.world.body_count())
  })
}

// ---------------------------------------------------------------------------
// Phase breakdown at a fixed size, and the reset floors to subtract
// ---------------------------------------------------------------------------

///|
test "bench physics2d phase reset floors pile 256" (b : @bench.T) {
  let fixture = bench_pile_fixture2d(256, bench_warm_frames2d)
  let world = fixture.world
  let sub_dt = bench_dt2d / world.solver_config.substeps.to_double()
  let pairs = world.phase_broadphase_pairs()
  let template = world.phase_contact_constraints(
    world.phase_narrowphase(pairs),
    sub_dt,
  )
  let constraints = template.copy()
  b.bench(name="physics2d/phase_reset_bodies_pile_256", fn() {
    fixture.reset()
    b.keep(world.body_count())
  })
  b.bench(name="physics2d/phase_reset_bodies_constraints_pile_256", fn() {
    fixture.reset()
    bench_restore_constraints2d(constraints, template)
    b.keep(constraints.length())
  })
  // The floor for the phases that now need a loaded velocity buffer: `step`
  // loads it once per frame, but an isolated phase has to load it itself, and
  // `moon bench` has no per-iteration setup hook to put that in.
  let vel = world.velocity_state
  b.bench(name="physics2d/phase_reset_bodies_constraints_velocity_pile_256", fn() {
    fixture.reset()
    bench_restore_constraints2d(constraints, template)
    vel.load(world.bodies)
    b.keep(constraints.length())
  })
}

///|
/// Broadphase and narrowphase read the world without mutating it, so these two
/// need no reset and carry no floor.
test "bench physics2d phase broadphase pile 256" (b : @bench.T) {
  let fixture = bench_pile_fixture2d(256, bench_warm_frames2d)
  b.bench(name="physics2d/phase_broadphase_pile_256", fn() {
    b.keep(fixture.world.phase_broadphase_pairs())
  })
}

///|
/// Grid fill only: `clear` plus one `insert` per body, no pair enumeration.
/// Subtract from `phase_broadphase_pile_256` for the cost of `get_pairs`, which
/// is the half that grows with the square of the bucket occupancy.
test "bench physics2d phase broadphase insert pile 256" (b : @bench.T) {
  let fixture = bench_pile_fixture2d(256, bench_warm_frames2d)
  let world = fixture.world
  b.bench(name="physics2d/phase_broadphase_insert_pile_256", fn() {
    world.broadphase.clear()
    for i = 0; i < world.bodies.length(); i = i + 1 {
      world.broadphase.insert(i, world.bodies[i].world_aabb())
    }
    b.keep(world.broadphase.count())
  })
}

///|
test "bench physics2d phase narrowphase pile 256" (b : @bench.T) {
  let fixture = bench_pile_fixture2d(256, bench_warm_frames2d)
  let world = fixture.world
  let pairs = world.phase_broadphase_pairs()
  b.bench(name="physics2d/phase_narrowphase_pile_256", fn() {
    b.keep(world.phase_narrowphase(pairs).length())
  })
}

///|
/// Warm starting applies impulses to bodies, so this one resets.
test "bench physics2d phase contact constraints pile 256" (b : @bench.T) {
  let fixture = bench_pile_fixture2d(256, bench_warm_frames2d)
  let world = fixture.world
  let sub_dt = bench_dt2d / world.solver_config.substeps.to_double()
  let raw_contacts = world.phase_narrowphase(world.phase_broadphase_pairs())
  b.bench(name="physics2d/phase_contact_constraints_pile_256", fn() {
    fixture.reset()
    b.keep(world.phase_contact_constraints(raw_contacts, sub_dt).length())
  })
}

///|
test "bench physics2d phase integrate velocities pile 256" (b : @bench.T) {
  let fixture = bench_pile_fixture2d(256, bench_warm_frames2d)
  let world = fixture.world
  let vel = world.velocity_state
  let sub_dt = bench_dt2d / world.solver_config.substeps.to_double()
  b.bench(name="physics2d/phase_integrate_velocities_pile_256", fn() {
    fixture.reset()
    vel.load(world.bodies)
    world.phase_integrate_velocities(vel, sub_dt)
    b.keep(world.body_count())
  })
}

///|
test "bench physics2d phase solve velocities pile 256" (b : @bench.T) {
  let fixture = bench_pile_fixture2d(256, bench_warm_frames2d)
  let world = fixture.world
  let config = world.solver_config
  let sub_dt = bench_dt2d / config.substeps.to_double()
  let template = world.phase_contact_constraints(
    world.phase_narrowphase(world.phase_broadphase_pairs()),
    sub_dt,
  )
  let (dist_constraints, rev_constraints) = world.phase_joint_constraints(
    sub_dt,
  )
  let constraints = template.copy()
  let vel = world.velocity_state
  // The load and store stay inside the closure: they used to be inside
  // `phase_solve_velocities` itself, and keeping them here is what makes this
  // entry comparable with its recorded baseline and with the 3D entry.
  b.bench(name="physics2d/phase_solve_velocities_pile_256", fn() {
    fixture.reset()
    bench_restore_constraints2d(constraints, template)
    vel.load(world.bodies)
    world.phase_solve_velocities(
      constraints,
      dist_constraints,
      rev_constraints,
      vel,
      config.velocity_iterations,
    )
    vel.store(world.bodies)
    b.keep(constraints.length())
  })
}

///|
test "bench physics2d phase integrate positions pile 256" (b : @bench.T) {
  let fixture = bench_pile_fixture2d(256, bench_warm_frames2d)
  let world = fixture.world
  let vel = world.velocity_state
  let sub_dt = bench_dt2d / world.solver_config.substeps.to_double()
  b.bench(name="physics2d/phase_integrate_positions_pile_256", fn() {
    fixture.reset()
    vel.load(world.bodies)
    world.phase_integrate_positions(vel, sub_dt)
    b.keep(world.body_count())
  })
}

///|
/// Rebuilding the warm-start cache. Allocates a fresh `Map[Int64, _]` and one
/// manifold per contact every frame, so it is not the free bookkeeping step its
/// position at the end of `step` suggests.
test "bench physics2d phase save contact cache pile 256" (b : @bench.T) {
  let fixture = bench_pile_fixture2d(256, bench_warm_frames2d)
  let world = fixture.world
  let sub_dt = bench_dt2d / world.solver_config.substeps.to_double()
  let constraints = world.phase_contact_constraints(
    world.phase_narrowphase(world.phase_broadphase_pairs()),
    sub_dt,
  )
  // Reads bodies, writes only the cache, and rebuilds it from scratch each
  // call, so repeated calls are identical work and no reset is needed.
  b.bench(name="physics2d/phase_save_contact_cache_pile_256", fn() {
    world.phase_save_contact_cache(constraints)
    b.keep(world.contact_cache.length())
  })
}

///|
/// Writes a fresh struct per dynamic body unconditionally, so repeated calls
/// cost the same and need no reset.
test "bench physics2d phase clear forces pile 256" (b : @bench.T) {
  let fixture = bench_pile_fixture2d(256, bench_warm_frames2d)
  let world = fixture.world
  b.bench(name="physics2d/phase_clear_forces_pile_256", fn() {
    world.phase_clear_forces()
    b.keep(world.body_count())
  })
}

///|
/// Island detection plus sleep bookkeeping. Union-find over the contact graph
/// is superlinear in island depth, which a pile maximises.
test "bench physics2d phase sleep islands pile 256" (b : @bench.T) {
  let fixture = bench_pile_fixture2d(256, bench_warm_frames2d)
  let world = fixture.world
  let sub_dt = bench_dt2d / world.solver_config.substeps.to_double()
  let constraints = world.phase_contact_constraints(
    world.phase_narrowphase(world.phase_broadphase_pairs()),
    sub_dt,
  )
  b.bench(name="physics2d/phase_sleep_islands_pile_256", fn() {
    fixture.reset()
    world.phase_update_sleep(constraints, bench_dt2d)
    b.keep(world.body_count())
  })
}
