// Benchmark fixtures for physics3d.
//
// Mirrors `physics2d/bench_fixtures.mbt`; see that file's header for why the
// fixtures are built outside the bench closures, why every iteration resets, and
// why the fixtures are pre-warmed. Keeping the two engines' fixtures
// structurally identical is what makes their numbers comparable.

///|
/// Deterministic LCG, so fixture jitter is identical on every machine, target,
/// and run.
priv struct BenchRng3D {
  mut state : UInt
}

///|
fn BenchRng3D::new(seed : UInt) -> BenchRng3D {
  { state: seed, }
}

///|
/// Returns a value in [-1.0, 1.0).
fn BenchRng3D::next_signed(self : BenchRng3D) -> Double {
  self.state = self.state * 1664525 + 1013904223
  let bits = (self.state >> 8).land(0xFFFFFF).reinterpret_as_int()
  bits.to_double() / 8388608.0 - 1.0
}

///|
/// A pre-warmed world plus the body snapshot that `reset` restores.
priv struct BenchFixture3D {
  world : PhysicsWorld
  snapshot : Array[RigidBody]
}

///|
fn BenchFixture3D::capture(world : PhysicsWorld) -> BenchFixture3D {
  { world, snapshot: world.bodies.copy(), }
}

///|
/// Restore the snapshot. `RigidBody` is immutable, so this is one reference
/// write per body and no allocation.
fn BenchFixture3D::reset(self : BenchFixture3D) -> Unit {
  let bodies = self.world.bodies
  let snapshot = self.snapshot
  for i = 0; i < snapshot.length(); i = i + 1 {
    bodies[i] = snapshot[i]
  }
}

///|
/// Cube side length for `count` bodies, so a pile is roughly cubic.
fn bench_grid_side3d(count : Int) -> Int {
  let mut side = 1
  while side * side * side < count {
    side = side + 1
  }
  side
}

///|
/// Square side length for `count` bodies, for the single-layer resting fixture.
fn bench_grid_cols3d(count : Int) -> Int {
  let mut cols = 1
  while cols * cols < count {
    cols = cols + 1
  }
  cols
}

///|
/// Spheres packed shoulder to shoulder in a floored box: dense contacts, deep
/// islands, and the warm-start path all exercised at once.
///
/// `warm_frames` must stay below `sleep_time_threshold3d / dt` or the fixture
/// starts pricing the sleep fast-path instead of the solver.
fn bench_pile_fixture3d(count : Int, warm_frames : Int) -> BenchFixture3D {
  let world = PhysicsWorld::new(@math3d.Vec3::new(0.0, -9.8, 0.0), 1.0)
  let side = bench_grid_side3d(count)
  let span = side.to_double() * bench_pile_spacing3d
  // A floor wide enough to catch the whole pile, plus four walls. One large
  // static AABB against many small dynamic spheres is the shape a real scene
  // has, and it is what makes the broadphase cost visible.
  //
  // The walls are load-bearing for the benchmark, not decoration. Spheres start
  // 0.02 into each other so that frame 1 already has contacts; resolving that
  // overlap pushes the pile outward, and unconfined it thins out fast —
  // measured, a 256-sphere pile with only a floor falls from 1764 candidate
  // pairs to 354 over the 8 warm-up frames. Walls hold the contact count up so
  // the fixture keeps pricing a dense pile.
  world.add_body(
    RigidBody::new_static(
      bench_static_id_base3d,
      @math3d.Vec3::new(0.0, -0.5, 0.0),
      AABBShape(
        @math3d.Vec3::new(span * 0.5 + 2.0, 0.5, span * 0.5 + 2.0),
        @math3d.Vec3::zero(),
      ),
    ),
  )
  let wall_half_height = span * 0.5 + 1.0
  let wall_offset = span * 0.5 + 0.5
  let wall_extents_x = @math3d.Vec3::new(0.5, wall_half_height, wall_offset)
  let wall_extents_z = @math3d.Vec3::new(wall_offset, wall_half_height, 0.5)
  world.add_body(
    RigidBody::new_static(
      bench_static_id_base3d + 1,
      @math3d.Vec3::new(-wall_offset, wall_half_height, 0.0),
      AABBShape(wall_extents_x, @math3d.Vec3::zero()),
    ),
  )
  world.add_body(
    RigidBody::new_static(
      bench_static_id_base3d + 2,
      @math3d.Vec3::new(wall_offset, wall_half_height, 0.0),
      AABBShape(wall_extents_x, @math3d.Vec3::zero()),
    ),
  )
  world.add_body(
    RigidBody::new_static(
      bench_static_id_base3d + 3,
      @math3d.Vec3::new(0.0, wall_half_height, -wall_offset),
      AABBShape(wall_extents_z, @math3d.Vec3::zero()),
    ),
  )
  world.add_body(
    RigidBody::new_static(
      bench_static_id_base3d + 4,
      @math3d.Vec3::new(0.0, wall_half_height, wall_offset),
      AABBShape(wall_extents_z, @math3d.Vec3::zero()),
    ),
  )
  let rng = BenchRng3D::new(0x5EED_3D01)
  for i = 0; i < count; i = i + 1 {
    let col = i % side
    let row = i / side % side
    let layer = i / (side * side)
    let x = (col.to_double() - (side.to_double() - 1.0) * 0.5) *
      bench_pile_spacing3d +
      rng.next_signed() * bench_pile_jitter3d
    let y = bench_pile_radius3d +
      layer.to_double() * bench_pile_spacing3d +
      rng.next_signed() * bench_pile_jitter3d
    let z = (row.to_double() - (side.to_double() - 1.0) * 0.5) *
      bench_pile_spacing3d +
      rng.next_signed() * bench_pile_jitter3d
    world.add_body(
      RigidBody::new_dynamic(
        i,
        @math3d.Vec3::new(x, y, z),
        1.0,
        SphereShape(@math3d.Vec3::zero(), bench_pile_radius3d),
      ).with_friction(0.4),
    )
  }
  for _f = 0; _f < warm_frames; _f = _f + 1 {
    world.step(bench_dt3d)
  }
  BenchFixture3D::capture(world)
}

///|
/// Spheres spread far enough apart that the broadphase finds no pairs. Prices
/// the per-body floor of a frame with the narrowphase and solver empty.
fn bench_scatter_fixture3d(count : Int, warm_frames : Int) -> BenchFixture3D {
  let world = PhysicsWorld::new(@math3d.Vec3::new(0.0, -9.8, 0.0), 1.0)
  let side = bench_grid_side3d(count)
  let rng = BenchRng3D::new(0x5EED_3D02)
  for i = 0; i < count; i = i + 1 {
    let col = i % side
    let row = i / side % side
    let layer = i / (side * side)
    world.add_body(
      RigidBody::new_dynamic(
        i,
        @math3d.Vec3::new(
          col.to_double() * bench_scatter_spacing3d +
          rng.next_signed() * bench_pile_jitter3d,
          layer.to_double() * bench_scatter_spacing3d,
          row.to_double() * bench_scatter_spacing3d +
          rng.next_signed() * bench_pile_jitter3d,
        ),
        1.0,
        SphereShape(@math3d.Vec3::zero(), bench_pile_radius3d),
      ),
    )
  }
  for _f = 0; _f < warm_frames; _f = _f + 1 {
    world.step(bench_dt3d)
  }
  BenchFixture3D::capture(world)
}

///|
/// Spheres at rest on the floor, spaced so each one touches the floor and
/// nothing else, so every dynamic body is its own island and the island sleep
/// rule can fire. See the 2D counterpart for why this is not a pile.
fn bench_resting_fixture3d(count : Int, warm_frames : Int) -> BenchFixture3D {
  let world = PhysicsWorld::new(@math3d.Vec3::new(0.0, -9.8, 0.0), 1.0)
  let side = bench_grid_cols3d(count)
  let span = side.to_double() * bench_resting_spacing3d
  world.add_body(
    RigidBody::new_static(
      bench_static_id_base3d,
      @math3d.Vec3::new(0.0, -0.5, 0.0),
      AABBShape(
        @math3d.Vec3::new(span * 0.5 + 2.0, 0.5, span * 0.5 + 2.0),
        @math3d.Vec3::zero(),
      ),
    ),
  )
  for i = 0; i < count; i = i + 1 {
    let col = i % side
    let row = i / side
    world.add_body(
      RigidBody::new_dynamic(
        i,
        @math3d.Vec3::new(
          (col.to_double() - (side.to_double() - 1.0) * 0.5) *
          bench_resting_spacing3d,
          bench_pile_radius3d,
          (row.to_double() - (side.to_double() - 1.0) * 0.5) *
          bench_resting_spacing3d,
        ),
        1.0,
        SphereShape(@math3d.Vec3::zero(), bench_pile_radius3d),
      ).with_friction(0.4),
    )
  }
  for _f = 0; _f < warm_frames; _f = _f + 1 {
    world.step(bench_dt3d)
  }
  BenchFixture3D::capture(world)
}

///|
/// A hanging rope: one static anchor and `count` links chained by distance
/// joints. Prices `precompute_distance_joint3d` + `solve_distance_joint3d`,
/// which no benchmark covered before.
fn bench_rope_fixture3d(count : Int, warm_frames : Int) -> BenchFixture3D {
  let world = PhysicsWorld::new(@math3d.Vec3::new(0.0, -9.8, 0.0), 1.0)
  bench_build_chain_bodies3d(world, count)
  for i = 0; i + 1 < count; i = i + 1 {
    world.add_distance_joint({
      body_a_id: i,
      body_b_id: i + 1,
      local_anchor_a: @math3d.Vec3::zero(),
      local_anchor_b: @math3d.Vec3::zero(),
      rest_length: bench_chain_link3d,
      hertz: 60.0,
      damping_ratio: 1.0,
    })
  }
  for _f = 0; _f < warm_frames; _f = _f + 1 {
    world.step(bench_dt3d)
  }
  BenchFixture3D::capture(world)
}

///|
/// The same chain held by ball joints instead, so the two joint solvers are
/// tracked separately rather than averaged together.
fn bench_ball_chain_fixture3d(count : Int, warm_frames : Int) -> BenchFixture3D {
  let world = PhysicsWorld::new(@math3d.Vec3::new(0.0, -9.8, 0.0), 1.0)
  bench_build_chain_bodies3d(world, count)
  for i = 0; i + 1 < count; i = i + 1 {
    world.add_ball_joint({
      body_a_id: i,
      body_b_id: i + 1,
      local_anchor_a: @math3d.Vec3::new(bench_chain_link3d * 0.5, 0.0, 0.0),
      local_anchor_b: @math3d.Vec3::new(-bench_chain_link3d * 0.5, 0.0, 0.0),
      hertz: 60.0,
      damping_ratio: 1.0,
    })
  }
  for _f = 0; _f < warm_frames; _f = _f + 1 {
    world.step(bench_dt3d)
  }
  BenchFixture3D::capture(world)
}

///|
/// Chain links: body 0 is the static anchor, the rest hang below it far enough
/// apart that no contacts are generated, so a joint benchmark prices joints.
fn bench_build_chain_bodies3d(world : PhysicsWorld, count : Int) -> Unit {
  world.add_body(
    RigidBody::new_static(
      0,
      @math3d.Vec3::zero(),
      SphereShape(@math3d.Vec3::zero(), bench_pile_radius3d),
    ),
  )
  for i = 1; i < count; i = i + 1 {
    world.add_body(
      RigidBody::new_dynamic(
        i,
        @math3d.Vec3::new(i.to_double() * bench_chain_link3d, 0.0, 0.0),
        1.0,
        SphereShape(@math3d.Vec3::zero(), bench_pile_radius3d),
      ),
    )
  }
}

///|
/// Static bodies get ids well above the dynamic range so `contact_pair_key3d`
/// never collides between the floor and a body.
let bench_static_id_base3d : Int = 1_000_000

///|
let bench_pile_radius3d : Double = 0.5

///|
/// Slightly under one diameter, so every neighbour starts in contact instead of
/// merely nearby.
let bench_pile_spacing3d : Double = 0.98

///|
let bench_pile_jitter3d : Double = 0.02

///|
/// Eight diameters apart: far enough that no two bodies ever share a
/// broadphase cell.
let bench_scatter_spacing3d : Double = 8.0

///|
/// Two diameters, so a resting body touches the floor and nothing else.
let bench_resting_spacing3d : Double = 2.0

///|
/// Three diameters, so chain links never touch each other.
let bench_chain_link3d : Double = 3.0

///|
let bench_dt3d : Double = 1.0 / 60.0

///|
/// Below `sleep_time_threshold3d / bench_dt3d`, so a warmed pile is in contact
/// and warm-started but still awake.
let bench_warm_frames3d : Int = 8

///|
/// Past the sleep threshold with margin, so the resting fixture is fully asleep.
let bench_resting_frames3d : Int = 40
