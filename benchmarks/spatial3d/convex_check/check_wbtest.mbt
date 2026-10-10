// Checks `@convex.distance` against the spatial3d benchmark's ground truth.
// The data is generated into fixture_wbtest.mbt; see ../export-convex-fixture.mjs.

///|
fn v(x : Double, y : Double, z : Double) -> @math3d.Vec3 {
  @math3d.Vec3::new(x, y, z)
}

///|
/// The benchmark writes quaternions as [w, x, y, z] and rounds them to four
/// decimals; kagura's `Quaternion` is (x, y, z, w) and must be unit length.
fn wxyz(w : Double, x : Double, y : Double, z : Double) -> @math3d.Quaternion {
  @math3d.Quaternion::new(x, y, z, w).normalize()
}

///|
test "distances match the spatial3d v3 ground truth" {
  let mut worst = 0.0
  for item in v3_distances {
    let (id, a, b, expected) = item
    let got = @convex.distance_between_unions(a, b)
    let error = (got.distance - expected).abs()
    if error > worst {
      worst = error
    }
    // The answers are rounded to 6 decimals.
    if error > 1.0e-6 || got.intersecting != (expected == 0.0) || !got.converged {
      fail("\{id}: got \{got.distance}, expected \{expected}")
    }
  }
  assert_eq(v3_distances.length(), 232)
  // Rounding alone allows 5e-7; GJK adds about 1e-12.
  assert_true(worst <= 5.0e-7 + 1.0e-9)
}

///|
test "intersections match the spatial3d v2 ground truth" {
  for item in v2_intersections {
    let (id, a, b, expected) = item
    let got = @convex.distance_between_unions(a, b)
    if got.intersecting != expected || !got.converged {
      fail("\{id}: got intersecting=\{got.intersecting}, expected \{expected}")
    }
  }
  assert_eq(v2_intersections.length(), 276)
}
