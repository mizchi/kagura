// Benchmark fixtures for physics2d.
//
// Three rules keep these numbers honest, and they are the reason the fixtures
// live here instead of inside the bench closures:
//
//   1. **The measured boundary is named.** `moon bench` times the whole
//      closure and offers no per-iteration setup hook, so anything a closure
//      does is part of its number. These fixtures are built once, and each
//      closure only calls `reset`, whose cost is published as its own
//      `phase_reset_` benchmark so it can be subtracted. Construction is cheap
//      enough to hide in a step (measured: ~150us for 1024 bodies against a
//      ~25ms step) which is exactly why it needs its own `build_` benchmark
//      rather than a share of someone else's.
//   2. **Every iteration simulates the same frame.** `step` mutates the world,
//      and the batch runner calls a closure thousands of times. Without a reset
//      a pile settles and falls asleep after ~30 iterations, so the benchmark
//      would silently stop pricing the solver and start pricing the sleep
//      fast-path. `reset` restores the captured snapshot instead.
//   3. **The frame is a steady-state frame.** Fixtures are pre-stepped so the
//      contact cache is warm and penetration has been resolved. Frame 1 of a
//      cold world is the least representative frame in the simulation, and it
//      leaves warm starting — a branch that runs on every other frame — with no
//      coverage at all, because the cache it reads is still empty.
//
// `bench_fixtures_wbtest.mbt` asserts that each fixture actually produces the
// work it claims. A benchmark whose workload collapses to nothing only ever
// gets faster, and the regression gate cannot see that.

///|
/// Deterministic LCG, so fixture jitter is identical on every machine, target,
/// and run. Perfectly symmetric lattices settle into degenerate solver paths,
/// but `@random` would make the numbers unreproducible.
priv struct BenchRng2D {
  mut state : UInt
}

///|
fn BenchRng2D::new(seed : UInt) -> BenchRng2D {
  { state: seed, }
}

///|
/// Returns a value in [-1.0, 1.0).
fn BenchRng2D::next_signed(self : BenchRng2D) -> Double {
  self.state = self.state * 1664525 + 1013904223
  let bits = (self.state >> 8).land(0xFFFFFF).reinterpret_as_int()
  bits.to_double() / 8388608.0 - 1.0
}

///|
/// A pre-warmed world plus the body snapshot that `reset` restores.
priv struct BenchFixture2D {
  world : PhysicsWorld2D
  snapshot : Array[RigidBody2D]
}

///|
/// Capture the current bodies as the per-iteration starting state.
fn BenchFixture2D::capture(world : PhysicsWorld2D) -> BenchFixture2D {
  { world, snapshot: world.bodies.copy(), }
}

///|
/// Restore the snapshot. `RigidBody2D` is immutable, so this is one reference
/// write per body and no allocation.
///
/// The contact cache is deliberately left alone: because every iteration steps
/// from the identical body state, the cache converges after the first iteration
/// and then stays fixed, which is both deterministic and warm.
fn BenchFixture2D::reset(self : BenchFixture2D) -> Unit {
  let bodies = self.world.bodies
  let snapshot = self.snapshot
  for i = 0; i < snapshot.length(); i = i + 1 {
    bodies[i] = snapshot[i]
  }
}

///|
/// Grid column count for `count` bodies, so a pile is roughly as wide as it is
/// tall.
fn bench_grid_cols(count : Int) -> Int {
  let mut cols = 1
  while cols * cols < count {
    cols = cols + 1
  }
  cols
}

///|
/// Circles packed shoulder to shoulder in a box: dense contacts, deep islands,
/// and the warm-start path all exercised at once.
///
/// `warm_frames` must stay below `sleep_time_threshold / dt` (30 frames at
/// 60Hz) or the pile falls asleep and the fixture stops pricing the solver.
fn bench_pile_fixture2d(count : Int, warm_frames : Int) -> BenchFixture2D {
  let world = PhysicsWorld2D::new(@vector.Vec2::new(0.0, -9.8), 1.0)
  let cols = bench_grid_cols(count)
  let span = cols.to_double() * bench_pile_spacing2d
  // Floor plus two walls, so the pile is confined and the broadphase sees a
  // realistic mix of one huge static AABB and many small dynamic circles.
  world.add_body(
    RigidBody2D::new_static(
      bench_static_id_base2d,
      @vector.Vec2::new(0.0, -0.5),
      AABBShape2D(
        @vector.Vec2::new(span * 0.5 + 2.0, 0.5),
        @vector.Vec2::zero(),
      ),
    ),
  )
  world.add_body(
    RigidBody2D::new_static(
      bench_static_id_base2d + 1,
      @vector.Vec2::new(-span * 0.5 - 0.5, span * 0.5),
      AABBShape2D(@vector.Vec2::new(0.5, span * 0.5), @vector.Vec2::zero()),
    ),
  )
  world.add_body(
    RigidBody2D::new_static(
      bench_static_id_base2d + 2,
      @vector.Vec2::new(span * 0.5 + 0.5, span * 0.5),
      AABBShape2D(@vector.Vec2::new(0.5, span * 0.5), @vector.Vec2::zero()),
    ),
  )
  let rng = BenchRng2D::new(0x5EED_2D01)
  for i = 0; i < count; i = i + 1 {
    let col = i % cols
    let row = i / cols
    let x = (col.to_double() - (cols.to_double() - 1.0) * 0.5) *
      bench_pile_spacing2d +
      rng.next_signed() * bench_pile_jitter2d
    let y = bench_pile_radius2d +
      row.to_double() * bench_pile_spacing2d +
      rng.next_signed() * bench_pile_jitter2d
    world.add_body(
      RigidBody2D::new_dynamic(
        i,
        @vector.Vec2::new(x, y),
        1.0,
        CircleShape(@vector.Vec2::zero(), bench_pile_radius2d),
      ).with_friction(0.4),
    )
  }
  for _f = 0; _f < warm_frames; _f = _f + 1 {
    world.step(bench_dt2d)
  }
  BenchFixture2D::capture(world)
}

///|
/// Circles spread far enough apart that the broadphase finds no pairs. Prices
/// the per-body floor of a frame — AABB refresh, hash insert, integration,
/// force clear, sleep bookkeeping — with the narrowphase and solver empty.
fn bench_scatter_fixture2d(count : Int, warm_frames : Int) -> BenchFixture2D {
  let world = PhysicsWorld2D::new(@vector.Vec2::new(0.0, -9.8), 1.0)
  let cols = bench_grid_cols(count)
  let rng = BenchRng2D::new(0x5EED_2D02)
  for i = 0; i < count; i = i + 1 {
    let col = i % cols
    let row = i / cols
    let x = col.to_double() * bench_scatter_spacing2d +
      rng.next_signed() * bench_pile_jitter2d
    let y = row.to_double() * bench_scatter_spacing2d +
      rng.next_signed() * bench_pile_jitter2d
    world.add_body(
      RigidBody2D::new_dynamic(
        i,
        @vector.Vec2::new(x, y),
        1.0,
        CircleShape(@vector.Vec2::zero(), bench_pile_radius2d),
      ),
    )
  }
  for _f = 0; _f < warm_frames; _f = _f + 1 {
    world.step(bench_dt2d)
  }
  BenchFixture2D::capture(world)
}

///|
/// A hanging rope: one static anchor and `count` links chained by distance
/// joints. Prices `precompute_distance_joint` + `solve_distance_joint`, which
/// no benchmark covered before.
fn bench_rope_fixture2d(count : Int, warm_frames : Int) -> BenchFixture2D {
  let world = PhysicsWorld2D::new(@vector.Vec2::new(0.0, -9.8), 1.0)
  bench_build_chain_bodies2d(world, count)
  for i = 0; i + 1 < count; i = i + 1 {
    world.add_distance_joint({
      body_a_id: i,
      body_b_id: i + 1,
      local_anchor_a: @vector.Vec2::zero(),
      local_anchor_b: @vector.Vec2::zero(),
      rest_length: bench_chain_link2d,
      hertz: 60.0,
      damping_ratio: 1.0,
    })
  }
  for _f = 0; _f < warm_frames; _f = _f + 1 {
    world.step(bench_dt2d)
  }
  BenchFixture2D::capture(world)
}

///|
/// The same chain held by revolute joints instead, so the two joint solvers are
/// tracked separately rather than averaged together.
fn bench_hinge_fixture2d(count : Int, warm_frames : Int) -> BenchFixture2D {
  let world = PhysicsWorld2D::new(@vector.Vec2::new(0.0, -9.8), 1.0)
  bench_build_chain_bodies2d(world, count)
  for i = 0; i + 1 < count; i = i + 1 {
    world.add_revolute_joint({
      body_a_id: i,
      body_b_id: i + 1,
      local_anchor_a: @vector.Vec2::new(bench_chain_link2d * 0.5, 0.0),
      local_anchor_b: @vector.Vec2::new(-bench_chain_link2d * 0.5, 0.0),
      hertz: 60.0,
      damping_ratio: 1.0,
    })
  }
  for _f = 0; _f < warm_frames; _f = _f + 1 {
    world.step(bench_dt2d)
  }
  BenchFixture2D::capture(world)
}

///|
/// Chain links: body 0 is the static anchor, the rest hang below it far enough
/// apart that no contacts are generated, so a joint benchmark prices joints.
fn bench_build_chain_bodies2d(world : PhysicsWorld2D, count : Int) -> Unit {
  world.add_body(
    RigidBody2D::new_static(
      0,
      @vector.Vec2::new(0.0, 0.0),
      CircleShape(@vector.Vec2::zero(), bench_pile_radius2d),
    ),
  )
  for i = 1; i < count; i = i + 1 {
    world.add_body(
      RigidBody2D::new_dynamic(
        i,
        @vector.Vec2::new(i.to_double() * bench_chain_link2d, 0.0),
        1.0,
        CircleShape(@vector.Vec2::zero(), bench_pile_radius2d),
      ),
    )
  }
}

///|
/// Bodies at rest on the ground, spaced so each one touches the floor and
/// nothing else. Every dynamic body is its own contact island, so the island
/// sleep rule can actually fire and the fixture prices the sleeping path.
///
/// This is deliberately *not* a pile. A dense pile in this solver never sleeps:
/// measured over 400 frames (6.7s of simulated time) at spacings from 0.98 to
/// 1.1 and damping from 0.05 to 0.3, peak speed in a 256-body pile stays
/// between 1.0 and 3.2 units/s, always above the 0.5 sleep threshold, and one
/// body above the threshold keeps its whole island awake. A pile therefore
/// cannot be warmed into a sleeping scene, and trying would have produced a
/// benchmark named `settled` that measured a fully awake solver.
fn bench_resting_fixture2d(count : Int, warm_frames : Int) -> BenchFixture2D {
  let world = PhysicsWorld2D::new(@vector.Vec2::new(0.0, -9.8), 1.0)
  let span = count.to_double() * bench_resting_spacing2d
  world.add_body(
    RigidBody2D::new_static(
      bench_static_id_base2d,
      @vector.Vec2::new(0.0, -0.5),
      AABBShape2D(
        @vector.Vec2::new(span * 0.5 + 2.0, 0.5),
        @vector.Vec2::zero(),
      ),
    ),
  )
  for i = 0; i < count; i = i + 1 {
    let x = (i.to_double() - (count.to_double() - 1.0) * 0.5) *
      bench_resting_spacing2d
    world.add_body(
      RigidBody2D::new_dynamic(
        i,
        @vector.Vec2::new(x, bench_pile_radius2d),
        1.0,
        CircleShape(@vector.Vec2::zero(), bench_pile_radius2d),
      ).with_friction(0.4),
    )
  }
  for _f = 0; _f < warm_frames; _f = _f + 1 {
    world.step(bench_dt2d)
  }
  BenchFixture2D::capture(world)
}

///|
/// Static bodies get ids well above the dynamic range so `contact_pair_key`
/// never collides between a wall and a body.
let bench_static_id_base2d : Int = 1_000_000

///|
let bench_pile_radius2d : Double = 0.5

///|
/// Slightly under one diameter, so every neighbour starts in contact instead of
/// merely nearby.
let bench_pile_spacing2d : Double = 0.98

///|
let bench_pile_jitter2d : Double = 0.02

///|
/// Eight diameters apart: far enough that no two bodies ever share a
/// broadphase cell.
let bench_scatter_spacing2d : Double = 8.0

///|
/// Three diameters, so chain links never touch each other.
let bench_chain_link2d : Double = 3.0

///|
let bench_dt2d : Double = 1.0 / 60.0

///|
/// Below `sleep_time_threshold / bench_dt2d` (30), so a warmed pile is in
/// contact and warm-started but still awake.
let bench_warm_frames2d : Int = 8

///|
/// Two diameters, so a resting body touches the ground and nothing else.
let bench_resting_spacing2d : Double = 2.0

///|
/// Past `sleep_time_threshold / bench_dt2d` (30) with margin, so the resting
/// fixture is fully asleep.
let bench_resting_frames2d : Int = 40
