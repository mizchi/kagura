///|
/// The solver's velocity working set, in flat arrays.
///
/// ## Why this exists
///
/// `RigidBody` and `@math3d.Vec3` are both immutable structs, which on the JS
/// target means both are heap objects. So the natural way to write a
/// Gauss-Seidel contact solver — read two bodies, do vector math, write two new
/// bodies — allocates on every constraint: two `RigidBody` rebuilds plus roughly
/// fourteen intermediate `Vec3`. A 256-sphere pile has ~690 contacts and the
/// solve pass runs once per substep, four times a frame, so that shape allocated
/// on the order of 44,000 objects per frame in the solve pass alone.
///
/// Measured, the solve pass was **53% of the whole frame**: holding substeps at 4
/// and stepping `velocity_iterations` 1 -> 2 -> 4 cost 449us per extra pass over
/// the constraints, against a 3.4ms frame with four passes in it. The isolated
/// `phase_solve_velocities` benchmark reported 77us for the same pass, 5.9x less,
/// because benched alone it runs on a body state that never occurs mid-step (see
/// `world_bench.mbt`).
///
/// Box2D v3 reaches for the same shape (`b2BodyState` in flat SoA arrays, solved
/// with SIMD) and the data-oriented-design literature is unanimous about it. On a
/// GC target the cache-locality argument is the smaller half of the win: what
/// matters here is that scalar math on `Array[Double]` allocates nothing.
///
/// ## What it does not do
///
/// It carries velocity only. Positions and rotations stay in the bodies, because
/// `phase_integrate_positions` needs the whole body for the CCD sweep, and they do
/// not change during a solve pass anyway. The buffer is loaded from the bodies at
/// the start of each solve pass and stored back at the end, so nothing outside
/// `phase_solve_velocities` can observe it.
///
/// It is pooled on the world: `load` reuses the arrays, so a steady body count
/// allocates nothing per frame.
pub struct VelocityState3D {
  vx : Array[Double]
  vy : Array[Double]
  vz : Array[Double]
  wx : Array[Double]
  wy : Array[Double]
  wz : Array[Double]
  mut count : Int
}

///|
pub fn VelocityState3D::new() -> VelocityState3D {
  { vx: [], vy: [], vz: [], wx: [], wy: [], wz: [], count: 0, }
}

///|
/// Copy the bodies' velocities in, growing the arrays if the world did.
pub fn VelocityState3D::load(
  self : VelocityState3D,
  bodies : Array[RigidBody],
) -> Unit {
  let count = bodies.length()
  while self.vx.length() < count {
    self.vx.push(0.0)
    self.vy.push(0.0)
    self.vz.push(0.0)
    self.wx.push(0.0)
    self.wy.push(0.0)
    self.wz.push(0.0)
  }
  self.count = count
  for i = 0; i < count; i = i + 1 {
    let body = bodies[i]
    let v = body.velocity
    let w = body.angular_velocity
    self.vx[i] = v.x
    self.vy[i] = v.y
    self.vz[i] = v.z
    self.wx[i] = w.x
    self.wy[i] = w.y
    self.wz[i] = w.z
  }
}

///|
/// Write the velocities back, skipping bodies the solver left alone.
///
/// The AoS solver rewrote both bodies of every constraint that produced an
/// impulse, including the static one and including a body whose own components
/// came out unchanged. Rebuilding a struct with identical field values is not
/// observable, so comparing first and skipping is equivalent — and on a resting
/// scene it skips nearly everything.
pub fn VelocityState3D::store(
  self : VelocityState3D,
  bodies : Array[RigidBody],
) -> Unit {
  for i = 0; i < self.count; i = i + 1 {
    let body = bodies[i]
    let v = body.velocity
    let w = body.angular_velocity
    let vx = self.vx[i]
    let vy = self.vy[i]
    let vz = self.vz[i]
    let wx = self.wx[i]
    let wy = self.wy[i]
    let wz = self.wz[i]
    if v.x != vx ||
      v.y != vy ||
      v.z != vz ||
      w.x != wx ||
      w.y != wy ||
      w.z != wz {
      bodies[i] = {
        ..body,
        velocity: @math3d.Vec3::new(vx, vy, vz),
        angular_velocity: @math3d.Vec3::new(wx, wy, wz),
      }
    }
  }
}
