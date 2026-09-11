///|
/// The solver's velocity working set, in flat arrays.
///
/// The 2D mirror of `physics3d/velocity_state.mbt`; see that file for why this
/// shape exists. 2D carries three columns rather than six, because angular
/// velocity is a scalar here.
///
/// 2D needed it more than 3D did. `solve_constraint2d` read two `RigidBody2D`
/// structs, wrote four of them (two in the normal pass, two in the friction
/// pass), rebuilt the whole constraint struct to store two accumulators, and put
/// roughly eighteen `@vector.Vec2` through the heap on the way -- about
/// twenty-three allocations per constraint per iteration. On a 256-body pile
/// that is ~1900 contacts times four substeps, so on the order of 170,000
/// allocations per frame in this one loop, which is why the pass was 48% of the
/// 2D step against 12% of the 3D one.
pub struct VelocityState2D {
  vx : Array[Double]
  vy : Array[Double]
  w : Array[Double]
  mut count : Int
}

///|
pub fn VelocityState2D::new() -> VelocityState2D {
  { vx: [], vy: [], w: [], count: 0, }
}

///|
/// Copy the bodies' velocities in, growing the arrays if the world did.
pub fn VelocityState2D::load(
  self : VelocityState2D,
  bodies : Array[RigidBody2D],
) -> Unit {
  let count = bodies.length()
  while self.vx.length() < count {
    self.vx.push(0.0)
    self.vy.push(0.0)
    self.w.push(0.0)
  }
  self.count = count
  for i = 0; i < count; i = i + 1 {
    let body = bodies[i]
    self.vx[i] = body.velocity.x
    self.vy[i] = body.velocity.y
    self.w[i] = body.angular_velocity
  }
}

///|
/// Write the velocities back, skipping bodies the solver left alone.
///
/// The AoS solver rewrote both bodies of every constraint that produced an
/// impulse, static side included, and rebuilding a struct with identical field
/// values is not observable -- so comparing first and skipping is equivalent.
pub fn VelocityState2D::store(
  self : VelocityState2D,
  bodies : Array[RigidBody2D],
) -> Unit {
  for i = 0; i < self.count; i = i + 1 {
    let body = bodies[i]
    let vx = self.vx[i]
    let vy = self.vy[i]
    let w = self.w[i]
    if body.velocity.x != vx ||
      body.velocity.y != vy ||
      body.angular_velocity != w {
      bodies[i] = {
        ..body,
        velocity: @vector.Vec2::new(vx, vy),
        angular_velocity: w,
      }
    }
  }
}
