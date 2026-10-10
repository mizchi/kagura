///|
/// Deterministic generator so failures reproduce.
priv struct Lcg {
  mut state : UInt
}

///|
fn Lcg::next(self : Lcg) -> Double {
  self.state = self.state * 1664525U + 1013904223U
  (self.state >> 8).to_double() / 16777216.0
}

///|
fn Lcg::range(self : Lcg, lo : Double, hi : Double) -> Double {
  lo + (hi - lo) * self.next()
}

///|
fn Lcg::vec(self : Lcg, lo : Double, hi : Double) -> @math3d.Vec3 {
  @math3d.Vec3::new(self.range(lo, hi), self.range(lo, hi), self.range(lo, hi))
}

///|
fn Lcg::rotation(self : Lcg) -> @math3d.Quaternion {
  @math3d.Quaternion::from_axis_angle(
    self.vec(-1.0, 1.0).add(@math3d.Vec3::new(0.01, 0.0, 0.0)),
    self.range(0.0, 6.28),
  )
}

///|
fn Lcg::shape(self : Lcg) -> Shape {
  let c = self.vec(-0.6, 0.6)
  match (self.next() * 8.0).to_int() {
    0 => Point(at=c)
    1 => Sphere(center=c, radius=self.range(0.2, 1.0))
    2 =>
      Box(center=c, half_extents=self.vec(0.1, 0.8), rotation=self.rotation())
    3 => Segment(start=c, end=c.add(self.vec(-1.0, 1.0)))
    4 =>
      Capsule(
        start=c,
        end=c.add(self.vec(-1.0, 1.0)),
        radius=self.range(0.1, 0.5),
      )
    5 =>
      Cylinder(
        start=c,
        end=c.add(self.vec(-1.0, 1.0)),
        radius=self.range(0.1, 0.6),
      )
    6 =>
      Cone(
        base_center=c,
        apex=c.add(self.vec(-1.0, 1.0)),
        radius=self.range(0.1, 0.6),
      )
    _ => Hull(vertices=Array::makei(4, _ => c.add(self.vec(-0.7, 0.7))))
  }
}

///|
fn fibonacci_directions(n : Int) -> Array[@math3d.Vec3] {
  let golden = 3.141592653589793 * (3.0 - 5.0.sqrt())
  Array::makei(n, i => {
    let y = 1.0 - 2.0 * (i.to_double() + 0.5) / n.to_double()
    let r = (1.0 - y * y).sqrt()
    let t = golden * i.to_double()
    @math3d.Vec3::new(@math.cos(t) * r, y, @math.sin(t) * r)
  })
}

///|
test "sphere to sphere matches the closed form" {
  let rng = Lcg::{ state: 1, }
  for _ in 0..<300 {
    let ca = rng.vec(-3.0, 3.0)
    let cb = rng.vec(-3.0, 3.0)
    let ra = rng.range(0.2, 2.0)
    let rb = rng.range(0.2, 2.0)
    let exact = @cmp.maximum(0.0, ca.distance(cb) - ra - rb)
    let d = distance(Sphere(center=ca, radius=ra), Sphere(center=cb, radius=rb))
    assert_true((d.distance - exact).abs() < 1.0e-7)
    assert_eq(d.intersecting, exact == 0.0)
  }
}

///|
test "axis-aligned boxes match the per-axis gap" {
  let rng = Lcg::{ state: 2, }
  for _ in 0..<300 {
    let min_a = rng.vec(-2.0, 2.0)
    let max_a = min_a.add(rng.vec(0.2, 1.5))
    let min_b = rng.vec(-2.0, 2.0)
    let max_b = min_b.add(rng.vec(0.2, 1.5))
    let gap = (lo_a : Double, hi_a : Double, lo_b : Double, hi_b : Double) => {
      @cmp.maximum(0.0, @cmp.maximum(lo_a - hi_b, lo_b - hi_a))
    }
    let g = @math3d.Vec3::new(
      gap(min_a.x, max_a.x, min_b.x, max_b.x),
      gap(min_a.y, max_a.y, min_b.y, max_b.y),
      gap(min_a.z, max_a.z, min_b.z, max_b.z),
    )
    let d = distance(
      Shape::aabb(min=min_a, max=max_a),
      Shape::aabb(min=min_b, max=max_b),
    )
    assert_true((d.distance - g.length()).abs() < 1.0e-7)
  }
}

///|
test "a point against a rotated box matches clamping in the box frame" {
  let rng = Lcg::{ state: 3, }
  for _ in 0..<300 {
    let center = rng.vec(-1.0, 1.0)
    let half = rng.vec(0.2, 1.0)
    let rotation = rng.rotation()
    let p = rng.vec(-3.0, 3.0)
    let in_box = rotation.conjugate().rotate_vec3(p.sub(center))
    let clamp = (v : Double, h : Double) => @cmp.maximum(-h, @cmp.minimum(h, v))
    let nearest = @math3d.Vec3::new(
      clamp(in_box.x, half.x),
      clamp(in_box.y, half.y),
      clamp(in_box.z, half.z),
    )
    let d = distance(Point(at=p), Box(center~, half_extents=half, rotation~))
    assert_true((d.distance - in_box.sub(nearest).length()).abs() < 1.0e-7)
  }
}

///|
/// Certificate: when apart, the plane normal to point_b - point_a must have
/// all of `a` on one side and all of `b` on the other, `distance` apart, so
/// the reported distance is both reachable and a lower bound. When they
/// overlap, no sampled direction may separate them.
test "every result carries a verifiable certificate" {
  let rng = Lcg::{ state: 4, }
  let directions = fibonacci_directions(64)
  let mut apart = 0
  let mut touching = 0
  for _ in 0..<2000 {
    let a = rng.shape()
    let b = rng.shape()
    let d = distance(a, b)
    assert_true(d.converged)
    let back = distance(b, a)
    assert_true((back.distance - d.distance).abs() < 1.0e-7)
    if d.intersecting {
      touching += 1
      assert_true(d.point_a.distance(d.point_b) < 1.0e-8)
      for dir in directions {
        // Separation along dir: lowest point of b minus highest point of a,
        // and the same with the roles swapped.
        let b_above = b.support(dir.scale(-1.0)).dot(dir) -
          a.support(dir).dot(dir)
        let a_above = a.support(dir.scale(-1.0)).dot(dir) -
          b.support(dir).dot(dir)
        assert_true(b_above <= 1.0e-8 && a_above <= 1.0e-8)
      }
    } else {
      apart += 1
      let n = d.point_b.sub(d.point_a)
      assert_true((n.length() - d.distance).abs() < 1.0e-8)
      let n = n.normalize()
      assert_true(a.support(n).dot(n) <= d.point_a.dot(n) + 1.0e-8)
      assert_true(b.support(n.scale(-1.0)).dot(n) >= d.point_b.dot(n) - 1.0e-8)
    }
  }
  assert_true(apart > 400 && touching > 400)
}

///|
test "doc example: a ball one unit from a box" {
  let d = distance(
    Sphere(center=@math3d.Vec3::zero(), radius=1.0),
    Shape::aabb(
      min=@math3d.Vec3::new(2.0, -1.0, -1.0),
      max=@math3d.Vec3::new(3.0, 1.0, 1.0),
    ),
  )
  assert_true((d.distance - 1.0).abs() < 1.0e-12)
  // A curved surface pins its closest point less tightly than the distance
  // (about the square root of the tolerance); see `Distance`.
  assert_true(d.point_a.distance(@math3d.Vec3::new(1.0, 0.0, 0.0)) < 1.0e-6)
  assert_true(d.point_b.distance(@math3d.Vec3::new(2.0, 0.0, 0.0)) < 1.0e-6)
}

///|
test "a rod through the hole of a frame does not touch it" {
  // Square frame in the z = 0 plane: outer half size 1.5, hole half size 1.
  let bar = (cx : Double, cy : Double, hx : Double, hy : Double) => {
    Shape::aabb(
      min=@math3d.Vec3::new(cx - hx, cy - hy, -0.2),
      max=@math3d.Vec3::new(cx + hx, cy + hy, 0.2),
    )
  }
  let frame = [
    bar(0.0, 1.25, 1.5, 0.25),
    bar(0.0, -1.25, 1.5, 0.25),
    bar(1.25, 0.0, 0.25, 1.0),
    bar(-1.25, 0.0, 0.25, 1.0),
  ]
  let rod = (radius : Double) => {
    [
      Capsule(
        start=@math3d.Vec3::new(0.0, 0.0, -2.0),
        end=@math3d.Vec3::new(0.0, 0.0, 2.0),
        radius~,
      ),
    ]
  }
  let thin = distance_between_unions(frame, rod(0.9))
  assert_true((thin.distance - 0.1).abs() < 1.0e-9)
  assert_true(distance_between_unions(frame, rod(1.1)).intersecting)
}
