///|
/// Rotate a finite 2D velocity toward an aim vector by at most max_turn_radians.
/// The caller owns time units, targeting and collision; speed is preserved.
/// Zero velocity, zero aim and nonpositive turn limits leave velocity unchanged.
pub fn turn_velocity_towards(
  vx : Double,
  vy : Double,
  aim_x : Double,
  aim_y : Double,
  max_turn_radians : Double,
) -> (Double, Double) {
  if max_turn_radians <= 0.0 ||
    vx * vx + vy * vy < 0.000000001 ||
    aim_x * aim_x + aim_y * aim_y < 0.000000001 {
    return (vx, vy)
  }
  let angle = @math.atan2(vx * aim_y - vy * aim_x, vx * aim_x + vy * aim_y)
  let step = angle.max(-max_turn_radians).min(max_turn_radians)
  let c = @math.cos(step)
  let s = @math.sin(step)
  (vx * c - vy * s, vx * s + vy * c)
}
