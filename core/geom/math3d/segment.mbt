///|
/// A finite line segment in world coordinates. Endpoints are included.
pub(all) struct Segment3 {
  start : Vec3
  end : Vec3
}

///|
pub fn Segment3::new(start : Vec3, end : Vec3) -> Segment3 {
  { start, end, }
}

///|
pub fn Segment3::closest_point(self : Segment3, point : Vec3) -> Vec3 {
  let direction = self.end.sub(self.start)
  let length_squared = direction.length_squared()
  if length_squared == 0 {
    return self.start
  }
  let t = (point.sub(self.start).dot(direction) / length_squared).max(0).min(1)
  self.start.add(direction.scale(t))
}

///|
/// Squared distance avoids a square root for swept sphere/capsule tests.
/// Compare with radius² using < or <= according to the caller's contact policy.
pub fn Segment3::distance_squared(self : Segment3, point : Vec3) -> Double {
  point.distance_squared(self.closest_point(point))
}
