///|
/// Solid convex shape in world coordinates, described by its support
/// function. Constructors take labelled arguments; see
/// `docs/architecture/coordinates.md` for the axis and rotation conventions.
///
/// Non-convex solids are a union of these: pass an `Array[Shape]` to
/// `distance_between_unions`.
pub(all) enum Shape {
  /// A single point.
  Point(at~ : @math3d.Vec3)
  /// Ball of `radius` around `center`.
  Sphere(center~ : @math3d.Vec3, radius~ : Double)
  /// Box of `half_extents` (half the edge lengths) around `center`, turned by
  /// `rotation`. Use `Shape::aabb` for an axis-aligned box given by corners.
  Box(
    center~ : @math3d.Vec3,
    half_extents~ : @math3d.Vec3,
    rotation~ : @math3d.Quaternion
  )
  /// Line segment from `start` to `end`.
  Segment(start~ : @math3d.Vec3, end~ : @math3d.Vec3)
  /// Points within `radius` of the segment from `start` to `end`.
  Capsule(start~ : @math3d.Vec3, end~ : @math3d.Vec3, radius~ : Double)
  /// Solid cylinder whose axis runs from `start` to `end` (flat caps).
  Cylinder(start~ : @math3d.Vec3, end~ : @math3d.Vec3, radius~ : Double)
  /// Solid cone with a disc of `radius` at `base_center`, tapering to `apex`.
  Cone(base_center~ : @math3d.Vec3, apex~ : @math3d.Vec3, radius~ : Double)
  /// Convex hull of `vertices` (a triangle, a tetrahedron, any polytope).
  Hull(vertices~ : Array[@math3d.Vec3])
} derive(Debug)

///|
pub impl Show for Shape with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
/// Axis-aligned box from its minimum and maximum corners.
pub fn Shape::aabb(min~ : @math3d.Vec3, max~ : @math3d.Vec3) -> Shape {
  Box(
    center=min.add(max).scale(0.5),
    half_extents=max.sub(min).scale(0.5),
    rotation=@math3d.Quaternion::identity(),
  )
}

///|
fn farthest(vertices : Array[@math3d.Vec3], dir : @math3d.Vec3) -> @math3d.Vec3 {
  let mut best = vertices[0]
  let mut best_dot = best.dot(dir)
  for i in 1..<vertices.length() {
    let d = vertices[i].dot(dir)
    if d > best_dot {
      best = vertices[i]
      best_dot = d
    }
  }
  best
}

///|
/// Unit component of `dir` perpendicular to the unit vector `axis`, or zero
/// when `dir` is (nearly) parallel to it. Projecting twice removes the
/// rounding error that otherwise dominates near-parallel directions.
fn perpendicular(dir : @math3d.Vec3, axis : @math3d.Vec3) -> @math3d.Vec3 {
  let once = dir.sub(axis.scale(dir.dot(axis)))
  let twice = once.sub(axis.scale(once.dot(axis)))
  if twice.length() <= 1.0e-9 * dir.length() {
    @math3d.Vec3::zero()
  } else {
    twice.normalize()
  }
}

///|
/// The point of the shape farthest along `dir` (any such point on ties).
/// `dir` need not be normalised.
pub fn Shape::support(self : Shape, dir : @math3d.Vec3) -> @math3d.Vec3 {
  match self {
    Point(at~) => at
    Sphere(center~, radius~) => center.add(dir.normalize().scale(radius))
    Box(center~, half_extents~, rotation~) => {
      let axes = [
        (rotation.rotate_vec3(@math3d.Vec3::unit_x()), half_extents.x),
        (rotation.rotate_vec3(@math3d.Vec3::unit_y()), half_extents.y),
        (rotation.rotate_vec3(@math3d.Vec3::unit_z()), half_extents.z),
      ]
      let mut p = center
      for item in axes {
        let (axis, half) = item
        p = p.add(axis.scale(if dir.dot(axis) >= 0.0 { half } else { -half }))
      }
      p
    }
    Segment(start~, end~) => farthest([start, end], dir)
    Capsule(start~, end~, radius~) =>
      farthest([start, end], dir).add(dir.normalize().scale(radius))
    Cylinder(start~, end~, radius~) => {
      let axis = end.sub(start).normalize()
      let cap = if dir.dot(axis) >= 0.0 { end } else { start }
      cap.add(perpendicular(dir, axis).scale(radius))
    }
    Cone(base_center~, apex~, radius~) => {
      let axis = apex.sub(base_center).normalize()
      let rim = base_center.add(perpendicular(dir, axis).scale(radius))
      if apex.dot(dir) >= rim.dot(dir) {
        apex
      } else {
        rim
      }
    }
    Hull(vertices~) => farthest(vertices, dir)
  }
}

///|
/// A point inside the shape, used to start the search.
pub fn Shape::interior_point(self : Shape) -> @math3d.Vec3 {
  match self {
    Point(at~) => at
    Sphere(center~, ..) | Box(center~, ..) => center
    Segment(start~, end~)
    | Capsule(start~, end~, ..)
    | Cylinder(start~, end~, ..) => start.add(end).scale(0.5)
    Cone(base_center~, apex~, ..) =>
      base_center.scale(0.75).add(apex.scale(0.25))
    Hull(vertices~) => {
      let mut sum = @math3d.Vec3::zero()
      for v in vertices {
        sum = sum.add(v)
      }
      sum.scale(1.0 / vertices.length().to_double())
    }
  }
}

///|
pub extend Shape with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Shape with Show::{to_string, output}
