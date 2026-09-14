///|
test "radial input is rotationally symmetric, bounded and monotonic outside its dead zone" {
  let mut previous = 0.0
  for i = 0; i <= 100; i = i + 1 {
    let distance = i.to_double() / 50
    let (x, y) = radial_stick(distance, 0, 1, 0.18)
    let (rx, ry) = radial_stick(0, distance, 1, 0.18)
    assert_eq(x, ry)
    assert_eq(y, rx)
    assert_true(x >= previous && x <= 1)
    if distance <= 0.18 {
      assert_eq(x, 0)
    }
    previous = x
  }
}
