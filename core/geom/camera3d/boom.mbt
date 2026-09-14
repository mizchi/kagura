///|
/// Sample an anchor-to-eye segment and return the last clear fraction, in 0..1.
/// The caller supplies collision policy (including the camera radius). The
/// anchor is assumed clear; a segment shorter than 0.001 returns 1 without a
/// query. This is a bounded-step sweep, not continuous collision detection:
/// choose step smaller than the thinnest obstacle. Coordinates must be finite.
pub fn sweep_camera_boom(
  start : @math3d.Vec3,
  end : @math3d.Vec3,
  blocked : (@math3d.Vec3) -> Bool,
  step? : Double = 0.12,
) -> Double {
  let delta = end.sub(start)
  let length = delta.length()
  if length < 0.001 {
    return 1.0
  }
  let spacing = if step.is_nan() || step <= 0.0 { 0.12 } else { step }
  let steps = (length / spacing).to_int() + 1
  for i in 1..<=steps {
    let t = i.to_double() / steps.to_double()
    if blocked(start.add(delta.scale(t))) {
      return (i - 1).to_double() / steps.to_double()
    }
  }
  1.0
}

///|
/// Shorten immediately for collision; extend by a clamped per-update fraction.
/// Call once per camera update with finite, nonnegative distances. Keep the
/// desired distance separately so collision never changes the user's setting.
pub fn release_camera_boom(
  previous : Double,
  available : Double,
  release~ : Double,
) -> Double {
  if available <= previous {
    available
  } else {
    previous + (available - previous) * release.clamp(min=0.0, max=1.0)
  }
}
