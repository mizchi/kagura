// physics3d benchmarks.
//
// Naming: `physics3d/<what>_<fixture>_<bodies>`.
//
// | prefix          | what the number includes                                    |
// |-----------------|-------------------------------------------------------------|
// | `step_`         | one `PhysicsWorld::step` on a pre-warmed world, plus reset   |
// | `phase_`        | one phase of that step, plus the reset it needs              |
// | `phase_reset_`  | the reset alone — the floor to subtract from `phase_` numbers |
// | `build_`        | world construction alone — no warm-up, nothing simulated     |
//
// Deliberately kept name-for-name parallel with `physics2d/world_bench.mbt` so
// the two engines can be compared phase by phase. 3D fuses narrowphase into the
// constraint precompute, so it has one fewer phase than 2D.
//
// Every phase here is the function `step` itself calls. The previous version of
// this file re-implemented the broadphase, integration, and solve loops, so it
// measured a private copy of the pipeline that could drift from the shipped one.
//
// It also rebuilt a fresh 64-body world inside every timed closure. Measured,
// that construction was only 6.6us of a 981us iteration — 0.7%, so it was not
// the cost problem it looks like. The problem was what a fresh world *is*: its
// contact cache is empty, so the warm-start branch in
// `phase_contact_constraints` was never once taken (verified: cache length 0
// going into the measured step, 144 coming out). A whole code path had no
// benchmark coverage. The fixture was also 64 spheres at 0.9 spacing with
// radius 0.5 — 0.1 of mutual penetration, free-floating with no ground — so the
// number tracked a solver resolving an initial-overlap explosion, not a frame of
// any game.

///|
/// Restore constraint accumulators between iterations.
///
/// `solve_constraint3d` replaces whole array elements rather than mutating the
/// structs in place, so the pristine template is never damaged and restoring is
/// one reference write per constraint.
///
/// Without this the solver converges, the impulse writes fall behind their
/// near-zero guards, and the benchmark reports a solve that no longer solves.
fn bench_restore_constraints3d(
  constraints : Array[ContactConstraintRuntime3D],
  template : Array[ContactConstraintRuntime3D],
) -> Unit {
  for i = 0; i < template.length(); i = i + 1 {
    constraints[i] = template[i]
  }
}

// ---------------------------------------------------------------------------
// Full step, swept over body count
// ---------------------------------------------------------------------------

///|
test "bench physics3d step pile 64" (b : @bench.T) {
  let fixture = bench_pile_fixture3d(64, bench_warm_frames3d)
  b.bench(name="physics3d/step_pile_64", fn() {
    fixture.reset()
    fixture.world.step(bench_dt3d)
    b.keep(fixture.world.body_count())
  })
}

///|
test "bench physics3d step pile 256" (b : @bench.T) {
  let fixture = bench_pile_fixture3d(256, bench_warm_frames3d)
  b.bench(name="physics3d/step_pile_256", fn() {
    fixture.reset()
    fixture.world.step(bench_dt3d)
    b.keep(fixture.world.body_count())
  })
}

///|
test "bench physics3d step pile 1024" (b : @bench.T) {
  let fixture = bench_pile_fixture3d(1024, bench_warm_frames3d)
  b.bench(name="physics3d/step_pile_1024", fn() {
    fixture.reset()
    fixture.world.step(bench_dt3d)
    b.keep(fixture.world.body_count())
  })
}

///|
/// Same body count as `step_pile_1024` with the narrowphase and solver empty.
/// The gap between the two is what contacts cost; this one is the per-body
/// floor of a frame.
test "bench physics3d step scatter 1024" (b : @bench.T) {
  let fixture = bench_scatter_fixture3d(1024, bench_warm_frames3d)
  b.bench(name="physics3d/step_scatter_1024", fn() {
    fixture.reset()
    fixture.world.step(bench_dt3d)
    b.keep(fixture.world.body_count())
  })
}

///|
/// A fully asleep scene. Prices the path a settled level actually takes, which
/// is the common case in a shipped game and was previously unmeasured.
test "bench physics3d step resting 256" (b : @bench.T) {
  let fixture = bench_resting_fixture3d(256, bench_resting_frames3d)
  b.bench(name="physics3d/step_resting_256", fn() {
    fixture.reset()
    fixture.world.step(bench_dt3d)
    b.keep(fixture.world.body_count())
  })
}

///|
test "bench physics3d step rope 256" (b : @bench.T) {
  let fixture = bench_rope_fixture3d(256, bench_warm_frames3d)
  b.bench(name="physics3d/step_rope_256", fn() {
    fixture.reset()
    fixture.world.step(bench_dt3d)
    b.keep(fixture.world.body_count())
  })
}

///|
test "bench physics3d step ball chain 256" (b : @bench.T) {
  let fixture = bench_ball_chain_fixture3d(256, bench_warm_frames3d)
  b.bench(name="physics3d/step_ball_chain_256", fn() {
    fixture.reset()
    fixture.world.step(bench_dt3d)
    b.keep(fixture.world.body_count())
  })
}

// ---------------------------------------------------------------------------
// Construction, measured on purpose and separately
// ---------------------------------------------------------------------------

///|
/// World construction alone: 1024 bodies allocated and inserted, nothing
/// simulated. Warm-up is deliberately excluded, since 8 warm frames of a
/// 1024-body pile cost ~275ms against ~155us of construction and would leave
/// this benchmark tracking `step` a ninth time over.
test "bench physics3d build pile 1024" (b : @bench.T) {
  b.bench(name="physics3d/build_pile_1024", fn() {
    let fixture = bench_pile_fixture3d(1024, 0)
    b.keep(fixture.world.body_count())
  })
}

// ---------------------------------------------------------------------------
// Phase breakdown at a fixed size, and the reset floors to subtract
// ---------------------------------------------------------------------------

///|
test "bench physics3d phase reset floors pile 256" (b : @bench.T) {
  let fixture = bench_pile_fixture3d(256, bench_warm_frames3d)
  let world = fixture.world
  let sub_dt = bench_dt3d / world.solver_config.substeps.to_double()
  let template = world.phase_contact_constraints(
    world.phase_broadphase_pairs(),
    sub_dt,
  )
  let constraints = template.copy()
  b.bench(name="physics3d/phase_reset_bodies_pile_256", fn() {
    fixture.reset()
    b.keep(world.body_count())
  })
  b.bench(name="physics3d/phase_reset_bodies_constraints_pile_256", fn() {
    fixture.reset()
    bench_restore_constraints3d(constraints, template)
    b.keep(constraints.length())
  })
}

///|
/// Reads the world without mutating it, so this needs no reset and carries no
/// floor.
test "bench physics3d phase broadphase pile 256" (b : @bench.T) {
  let fixture = bench_pile_fixture3d(256, bench_warm_frames3d)
  b.bench(name="physics3d/phase_broadphase_pile_256", fn() {
    b.keep(fixture.world.phase_broadphase_pairs().length())
  })
}

///|
/// Narrowphase, constraint precompute, and warm starting. 3D fuses these into
/// one pass, so unlike 2D they cannot be priced apart. Warm starting applies
/// impulses to bodies, so this one resets.
test "bench physics3d phase contact constraints pile 256" (b : @bench.T) {
  let fixture = bench_pile_fixture3d(256, bench_warm_frames3d)
  let world = fixture.world
  let sub_dt = bench_dt3d / world.solver_config.substeps.to_double()
  let pairs = world.phase_broadphase_pairs()
  b.bench(name="physics3d/phase_contact_constraints_pile_256", fn() {
    fixture.reset()
    b.keep(world.phase_contact_constraints(pairs, sub_dt).length())
  })
}

///|
test "bench physics3d phase integrate velocities pile 256" (b : @bench.T) {
  let fixture = bench_pile_fixture3d(256, bench_warm_frames3d)
  let world = fixture.world
  let sub_dt = bench_dt3d / world.solver_config.substeps.to_double()
  b.bench(name="physics3d/phase_integrate_velocities_pile_256", fn() {
    fixture.reset()
    world.phase_integrate_velocities(sub_dt)
    b.keep(world.body_count())
  })
}

///|
test "bench physics3d phase solve velocities pile 256" (b : @bench.T) {
  let fixture = bench_pile_fixture3d(256, bench_warm_frames3d)
  let world = fixture.world
  let config = world.solver_config
  let sub_dt = bench_dt3d / config.substeps.to_double()
  let template = world.phase_contact_constraints(
    world.phase_broadphase_pairs(),
    sub_dt,
  )
  let (dist_constraints, ball_constraints) = world.phase_joint_constraints(
    sub_dt,
  )
  let constraints = template.copy()
  b.bench(name="physics3d/phase_solve_velocities_pile_256", fn() {
    fixture.reset()
    bench_restore_constraints3d(constraints, template)
    world.phase_solve_velocities(
      constraints,
      dist_constraints,
      ball_constraints,
      config.velocity_iterations,
    )
    b.keep(constraints.length())
  })
}

///|
/// Position and rotation integration. Unlike 2D this renormalises a quaternion
/// per moving body, so the 2D/3D gap on this phase is expected to be wide.
test "bench physics3d phase integrate positions pile 256" (b : @bench.T) {
  let fixture = bench_pile_fixture3d(256, bench_warm_frames3d)
  let world = fixture.world
  let sub_dt = bench_dt3d / world.solver_config.substeps.to_double()
  b.bench(name="physics3d/phase_integrate_positions_pile_256", fn() {
    fixture.reset()
    world.phase_integrate_positions(sub_dt)
    b.keep(world.body_count())
  })
}

///|
/// Rebuilding the warm-start cache. Allocates one manifold per contact every
/// frame, so it is not the free bookkeeping step its position at the end of
/// `step` suggests.
test "bench physics3d phase save contact cache pile 256" (b : @bench.T) {
  let fixture = bench_pile_fixture3d(256, bench_warm_frames3d)
  let world = fixture.world
  let sub_dt = bench_dt3d / world.solver_config.substeps.to_double()
  let constraints = world.phase_contact_constraints(
    world.phase_broadphase_pairs(),
    sub_dt,
  )
  // Reads bodies, writes only the cache, and rebuilds it from scratch each
  // call, so repeated calls are identical work and no reset is needed.
  b.bench(name="physics3d/phase_save_contact_cache_pile_256", fn() {
    world.phase_save_contact_cache(constraints)
    b.keep(world.contact_cache.length())
  })
}

///|
/// Writes a fresh struct per dynamic body unconditionally, so repeated calls
/// cost the same and need no reset.
test "bench physics3d phase clear forces pile 256" (b : @bench.T) {
  let fixture = bench_pile_fixture3d(256, bench_warm_frames3d)
  let world = fixture.world
  b.bench(name="physics3d/phase_clear_forces_pile_256", fn() {
    world.phase_clear_forces()
    b.keep(world.body_count())
  })
}

///|
/// Island detection plus sleep bookkeeping. 3D skips the union-find entirely
/// when nothing is asleep and nothing is ready to sleep, so this phase is
/// benchmarked on both an awake pile and a fully asleep scene.
test "bench physics3d phase sleep islands pile 256" (b : @bench.T) {
  let fixture = bench_pile_fixture3d(256, bench_warm_frames3d)
  let world = fixture.world
  let sub_dt = bench_dt3d / world.solver_config.substeps.to_double()
  let constraints = world.phase_contact_constraints(
    world.phase_broadphase_pairs(),
    sub_dt,
  )
  b.bench(name="physics3d/phase_sleep_islands_pile_256", fn() {
    fixture.reset()
    world.phase_update_sleep(constraints, bench_dt3d)
    b.keep(world.body_count())
  })
}

///|
/// The other side of the 3D sleep fast path: a scene that *is* asleep, so the
/// union-find pass runs. Prices what the awake-pile number above skips.
test "bench physics3d phase sleep islands resting 256" (b : @bench.T) {
  let fixture = bench_resting_fixture3d(256, bench_resting_frames3d)
  let world = fixture.world
  let sub_dt = bench_dt3d / world.solver_config.substeps.to_double()
  let constraints = world.phase_contact_constraints(
    world.phase_broadphase_pairs(),
    sub_dt,
  )
  b.bench(name="physics3d/phase_sleep_islands_resting_256", fn() {
    fixture.reset()
    world.phase_update_sleep(constraints, bench_dt3d)
    b.keep(world.body_count())
  })
}
