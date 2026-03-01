///|
pub(all) struct AABB2D {
  min : @vector.Vec2
  max : @vector.Vec2
} derive(Show)

///|
pub fn AABB2D::new(min : @vector.Vec2, max : @vector.Vec2) -> AABB2D {
  { min, max }
}

///|
pub fn AABB2D::from_center_extents(
  center : @vector.Vec2,
  extents : @vector.Vec2,
) -> AABB2D {
  { min: center.sub(extents), max: center.add(extents) }
}

///|
pub fn AABB2D::center(self : AABB2D) -> @vector.Vec2 {
  self.min.add(self.max).scale(0.5)
}

///|
pub fn AABB2D::extents(self : AABB2D) -> @vector.Vec2 {
  self.max.sub(self.min).scale(0.5)
}

///|
pub fn AABB2D::contains_point(self : AABB2D, point : @vector.Vec2) -> Bool {
  point.x >= self.min.x &&
  point.x <= self.max.x &&
  point.y >= self.min.y &&
  point.y <= self.max.y
}

///|
pub fn AABB2D::intersects(self : AABB2D, other : AABB2D) -> Bool {
  self.min.x <= other.max.x &&
  self.max.x >= other.min.x &&
  self.min.y <= other.max.y &&
  self.max.y >= other.min.y
}

///|
pub fn AABB2D::closest_point(
  self : AABB2D,
  point : @vector.Vec2,
) -> @vector.Vec2 {
  point.clamp(self.min, self.max)
}

///|
pub fn AABB2D::merge(self : AABB2D, other : AABB2D) -> AABB2D {
  { min: self.min.min(other.min), max: self.max.max(other.max) }
}
