///|
pub(all) struct Ray {
  origin : @math3d.Vec3
  direction : @math3d.Vec3
} derive(Show)

///|
pub(all) struct HitResult {
  hit : Bool
  distance : Double
  point : @math3d.Vec3
} derive(Show)

///|
pub fn Ray::new(origin : @math3d.Vec3, direction : @math3d.Vec3) -> Ray {
  { origin, direction: direction.normalize() }
}

///|
pub fn Ray::point_at(self : Ray, t : Double) -> @math3d.Vec3 {
  self.origin.add(self.direction.scale(t))
}

///|
/// Ray-AABB intersection using the slab method.
pub fn Ray::intersects_aabb(self : Ray, aabb : AABB) -> HitResult {
  let no_hit : HitResult = {
    hit: false,
    distance: 0.0,
    point: @math3d.Vec3::zero(),
  }
  let mut tmin = -1.0e308
  let mut tmax = 1.0e308
  // X axis
  if self.direction.x.abs() < 1.0e-12 {
    if self.origin.x < aabb.min.x || self.origin.x > aabb.max.x {
      return no_hit
    }
  } else {
    let inv_d = 1.0 / self.direction.x
    let mut t1 = (aabb.min.x - self.origin.x) * inv_d
    let mut t2 = (aabb.max.x - self.origin.x) * inv_d
    if t1 > t2 {
      let tmp = t1
      t1 = t2
      t2 = tmp
    }
    if t1 > tmin {
      tmin = t1
    }
    if t2 < tmax {
      tmax = t2
    }
    if tmin > tmax {
      return no_hit
    }
  }
  // Y axis
  if self.direction.y.abs() < 1.0e-12 {
    if self.origin.y < aabb.min.y || self.origin.y > aabb.max.y {
      return no_hit
    }
  } else {
    let inv_d = 1.0 / self.direction.y
    let mut t1 = (aabb.min.y - self.origin.y) * inv_d
    let mut t2 = (aabb.max.y - self.origin.y) * inv_d
    if t1 > t2 {
      let tmp = t1
      t1 = t2
      t2 = tmp
    }
    if t1 > tmin {
      tmin = t1
    }
    if t2 < tmax {
      tmax = t2
    }
    if tmin > tmax {
      return no_hit
    }
  }
  // Z axis
  if self.direction.z.abs() < 1.0e-12 {
    if self.origin.z < aabb.min.z || self.origin.z > aabb.max.z {
      return no_hit
    }
  } else {
    let inv_d = 1.0 / self.direction.z
    let mut t1 = (aabb.min.z - self.origin.z) * inv_d
    let mut t2 = (aabb.max.z - self.origin.z) * inv_d
    if t1 > t2 {
      let tmp = t1
      t1 = t2
      t2 = tmp
    }
    if t1 > tmin {
      tmin = t1
    }
    if t2 < tmax {
      tmax = t2
    }
    if tmin > tmax {
      return no_hit
    }
  }
  if tmax < 0.0 {
    return no_hit
  }
  let t = if tmin >= 0.0 { tmin } else { tmax }
  { hit: true, distance: t, point: self.point_at(t) }
}

///|
/// Ray-Sphere intersection using geometric method.
pub fn Ray::intersects_sphere(self : Ray, sphere : Sphere) -> HitResult {
  let no_hit : HitResult = {
    hit: false,
    distance: 0.0,
    point: @math3d.Vec3::zero(),
  }
  let oc = self.origin.sub(sphere.center)
  let b = oc.dot(self.direction)
  let c = oc.dot(oc) - sphere.radius * sphere.radius
  let discriminant = b * b - c
  if discriminant < 0.0 {
    return no_hit
  }
  let sqrt_d = discriminant.sqrt()
  let t1 = -b - sqrt_d
  let t2 = -b + sqrt_d
  if t2 < 0.0 {
    return no_hit
  }
  let t = if t1 >= 0.0 { t1 } else { t2 }
  { hit: true, distance: t, point: self.point_at(t) }
}
