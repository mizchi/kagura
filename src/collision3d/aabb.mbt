///|
pub(all) struct AABB {
  min : @math3d.Vec3
  max : @math3d.Vec3
} derive(Show)

///|
pub fn AABB::new(min : @math3d.Vec3, max : @math3d.Vec3) -> AABB {
  { min, max }
}

///|
pub fn AABB::from_center_extents(
  center : @math3d.Vec3,
  extents : @math3d.Vec3,
) -> AABB {
  { min: center.sub(extents), max: center.add(extents) }
}

///|
pub fn AABB::center(self : AABB) -> @math3d.Vec3 {
  self.min.add(self.max).scale(0.5)
}

///|
pub fn AABB::extents(self : AABB) -> @math3d.Vec3 {
  self.max.sub(self.min).scale(0.5)
}

///|
pub fn AABB::contains_point(self : AABB, point : @math3d.Vec3) -> Bool {
  point.x >= self.min.x &&
  point.x <= self.max.x &&
  point.y >= self.min.y &&
  point.y <= self.max.y &&
  point.z >= self.min.z &&
  point.z <= self.max.z
}

///|
pub fn AABB::intersects_aabb(self : AABB, other : AABB) -> Bool {
  self.min.x <= other.max.x &&
  self.max.x >= other.min.x &&
  self.min.y <= other.max.y &&
  self.max.y >= other.min.y &&
  self.min.z <= other.max.z &&
  self.max.z >= other.min.z
}

///|
pub fn AABB::intersects_sphere(self : AABB, sphere : Sphere) -> Bool {
  let closest = self.closest_point(sphere.center)
  closest.distance_squared(sphere.center) <= sphere.radius * sphere.radius
}

///|
pub fn AABB::merge(self : AABB, other : AABB) -> AABB {
  { min: self.min.min(other.min), max: self.max.max(other.max) }
}

///|
pub fn AABB::closest_point(self : AABB, point : @math3d.Vec3) -> @math3d.Vec3 {
  point.clamp(self.min, self.max)
}
