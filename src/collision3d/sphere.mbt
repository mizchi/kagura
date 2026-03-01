///|
pub(all) struct Sphere {
  center : @math3d.Vec3
  radius : Double
} derive(Show)

///|
pub fn Sphere::new(center : @math3d.Vec3, radius : Double) -> Sphere {
  { center, radius }
}

///|
pub fn Sphere::contains_point(self : Sphere, point : @math3d.Vec3) -> Bool {
  self.center.distance_squared(point) <= self.radius * self.radius
}

///|
pub fn Sphere::intersects_sphere(self : Sphere, other : Sphere) -> Bool {
  let dist_sq = self.center.distance_squared(other.center)
  let r_sum = self.radius + other.radius
  dist_sq <= r_sum * r_sum
}

///|
pub fn Sphere::intersects_aabb(self : Sphere, aabb : AABB) -> Bool {
  aabb.intersects_sphere(self)
}
