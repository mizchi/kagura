///|
test "boom sweep stops before the first obstacle and handles a zero-length boom" {
  let start = @math3d.Vec3::new(2.0, 1.0, 0.0)
  let end = @math3d.Vec3::new(2.0, 1.0, 10.0)
  let fraction = sweep_camera_boom(start, end, p => p.z >= 4.0, step=0.12)
  let safe = start.lerp(end, fraction)
  assert_true(safe.z < 4.0 && safe.z >= 3.88)
  assert_eq(safe.x, 2.0)
  assert_eq(sweep_camera_boom(start, end, _ => false), 1.0)
  assert_eq(sweep_camera_boom(start, end, _ => true), 0.0)
  assert_eq(sweep_camera_boom(start, start, _ => true), 1.0)
}

///|
test "boom retracts immediately but releases monotonically without crossing its limit" {
  assert_eq(release_camera_boom(5.0, 2.0, release=0.18), 2.0)
  assert_eq(release_camera_boom(2.0, 5.0, release=1.0), 5.0)
  let mut distance = 2.0
  for _ in 0..<60 {
    let next = release_camera_boom(distance, 5.0, release=0.18)
    assert_true(next > distance && next <= 5.0)
    distance = next
  }
  assert_true((distance - 5.0).abs() < 0.001)
  assert_eq(release_camera_boom(2.0, 5.0, release=-1.0), 2.0)
  assert_eq(release_camera_boom(2.0, 5.0, release=2.0), 5.0)
}
