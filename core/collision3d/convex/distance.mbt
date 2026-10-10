///|
/// Result of `distance`.
///
/// `point_a` lies in `a` and `point_b` in `b`. When the shapes are apart they
/// are a closest pair and `distance == point_a.distance(point_b)`; when they
/// overlap both are a common point and `distance` is 0. This is not a
/// penetration depth.
///
/// `distance` is accurate to a relative 1e-12. On a curved surface (sphere,
/// capsule, cylinder, cone) the closest points are blends of support points
/// and sit within about 1e-6 of the true ones, so compare points loosely.
pub(all) struct Distance {
  distance : Double
  intersecting : Bool
  point_a : @math3d.Vec3
  point_b : @math3d.Vec3
  /// False when the iteration limit was hit; `distance` is then an upper bound.
  converged : Bool
} derive(Debug)

///|
pub impl Show for Distance with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
/// One vertex of the Minkowski difference `a - b` and the support points that
/// made it.
priv struct MinkowskiVertex {
  w : @math3d.Vec3
  on_a : @math3d.Vec3
  on_b : @math3d.Vec3
}

///|
/// Closest point to the origin on the hull of up to four points, as an index
/// subset with barycentric weights.
priv struct SimplexHit {
  point : @math3d.Vec3
  length_squared : Double
  indices : Array[Int]
  weights : Array[Double]
}

///|
/// Solves the small dense system `m x = rhs` by Gauss-Jordan elimination with
/// partial pivoting; None when it is (nearly) singular.
fn solve(m : Array[Array[Double]], rhs : Array[Double]) -> Array[Double]? {
  let n = rhs.length()
  let a = Array::makei(n, i => {
    let row = m[i].copy()
    row.push(rhs[i])
    row
  })
  for c in 0..<n {
    let mut pivot = c
    for r in (c + 1)..<n {
      if a[r][c].abs() > a[pivot][c].abs() {
        pivot = r
      }
    }
    if a[pivot][c].abs() < 1.0e-14 {
      return None
    }
    let tmp = a[c]
    a[c] = a[pivot]
    a[pivot] = tmp
    for r in 0..<n {
      if r != c {
        let f = a[r][c] / a[c][c]
        for k in c..<(n + 1) {
          a[r][k] = a[r][k] - f * a[c][k]
        }
      }
    }
  }
  Some(Array::makei(n, i => a[i][n] / a[i][i]))
}

///|
/// Brute-force Johnson sub-algorithm: tries every face of the simplex and
/// keeps the closest point whose weights are all non-negative.
fn closest_on_simplex(points : Array[@math3d.Vec3]) -> SimplexHit? {
  let n = points.length()
  let mut best : SimplexHit? = None
  for mask in 1..<(1 << n) {
    let indices = []
    for i in 0..<n {
      if (mask & (1 << i)) != 0 {
        indices.push(i)
      }
    }
    let p0 = points[indices[0]]
    let edges = Array::makei(indices.length() - 1, k => {
      points[indices[k + 1]].sub(p0)
    })
    let mut point = p0
    let weights = []
    if edges.is_empty() {
      weights.push(1.0)
    } else {
      let gram = edges.map(e => edges.map(f => e.dot(f)))
      match solve(gram, edges.map(e => -e.dot(p0))) {
        None => continue
        Some(mu) => {
          let mut sum = 0.0
          for x in mu {
            sum = sum + x
          }
          weights.push(1.0 - sum)
          for k, x in mu {
            weights.push(x)
            point = point.add(edges[k].scale(x))
          }
        }
      }
    }
    if weights.iter().any(w => w < -1.0e-12) {
      continue
    }
    let length_squared = point.length_squared()
    let closer = match best {
      None => true
      Some(b) => length_squared < b.length_squared - 1.0e-18
    }
    if closer {
      best = Some({ point, length_squared, indices, weights, })
    }
  }
  best
}

///|
fn blend(
  simplex : Array[MinkowskiVertex],
  weights : Array[Double],
  pick : (MinkowskiVertex) -> @math3d.Vec3,
) -> @math3d.Vec3 {
  let mut p = @math3d.Vec3::zero()
  for i, v in simplex {
    p = p.add(pick(v).scale(weights[i]))
  }
  p
}

///|
/// Minimum distance between two convex solids (GJK, distance variant), with a
/// closest pair of points. 0 when they touch or overlap.
///
/// ```mbt nocheck
/// let d = @convex.distance(
///   Sphere(center=Vec3::zero(), radius=1.0),
///   Shape::aabb(min=Vec3::new(2.0, -1.0, -1.0), max=Vec3::new(3.0, 1.0, 1.0)),
/// )
/// // d.distance == 1.0, d.point_a == (1, 0, 0), d.point_b == (2, 0, 0)
/// ```
pub fn distance(a : Shape, b : Shape, max_iterations? : Int = 128) -> Distance {
  let vertex = (dir : @math3d.Vec3) => {
    let on_a = a.support(dir)
    let on_b = b.support(dir.scale(-1.0))
    { w: on_a.sub(on_b), on_a, on_b, }
  }
  let start_a = a.interior_point()
  let start_b = b.interior_point()
  let mut v = start_a.sub(start_b)
  if v.length() < 1.0e-12 {
    return {
      distance: 0.0,
      intersecting: true,
      point_a: start_a,
      point_b: start_b,
      converged: true,
    }
  }
  let mut simplex : Array[MinkowskiVertex] = []
  let mut weights : Array[Double] = []
  let mut last = @double.infinity
  let finish = (
    simplex : Array[MinkowskiVertex],
    weights,
    intersecting,
    d,
    converged,
  ) => {
    distance: d,
    intersecting,
    point_a: blend(simplex, weights, m => m.on_a),
    point_b: blend(simplex, weights, m => m.on_b),
    converged,
  }
  for _ in 0..<max_iterations {
    let next = vertex(v.scale(-1.0))
    let vv = v.dot(v)
    // v.dot(next.w) / |v| is a lower bound on the distance and |v| an upper
    // bound. Stop when they agree to a relative 1e-12, so tiny gaps keep
    // their precision; the no-progress check below ends the loop when
    // rounding stops it from getting there.
    if !simplex.is_empty() && vv - v.dot(next.w) <= 1.0e-12 * vv {
      return finish(simplex, weights, false, vv.sqrt(), true)
    }
    let candidate = simplex.copy()
    candidate.push(next)
    guard closest_on_simplex(candidate.map(m => m.w)) is Some(hit) else {
      return finish(simplex, weights, false, vv.sqrt(), false)
    }
    let d = hit.length_squared.sqrt()
    if !simplex.is_empty() && d >= last - 1.0e-15 {
      // No progress: the previous simplex already holds the closest point.
      return finish(simplex, weights, false, last, true)
    }
    simplex = hit.indices.map(i => candidate[i])
    weights = hit.weights
    v = hit.point
    if d < 1.0e-10 || hit.indices.length() == 4 {
      return finish(simplex, weights, true, 0.0, true)
    }
    last = d
  }
  finish(simplex, weights, false, last, false)
}

///|
/// Minimum distance between two unions of convex pieces (an L-shape, a frame
/// with a hole, ...): the closest result over every pair of pieces.
/// Both arrays must be non-empty.
pub fn distance_between_unions(
  a : Array[Shape],
  b : Array[Shape],
  max_iterations? : Int = 128,
) -> Distance {
  let mut best : Distance? = None
  for pa in a {
    for pb in b {
      let d = distance(pa, pb, max_iterations~)
      match best {
        Some(current) if current.distance <= d.distance => ()
        _ => best = Some(d)
      }
    }
  }
  best.unwrap()
}

///|
pub extend Distance with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Distance with Show::{to_string, output}
