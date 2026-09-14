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

///|
test "placement preview retains holes and does not mutate source footprints" {
  let item = @core.json_parse(
    "{\"source\":0,\"width\":2,\"height\":3,\"rotated\":false,\"cells\":[[0,0],[1,0],[0,1],[0,2]]}",
  )
  assert_eq(footprint(item, true), [(2, 0), (2, 1), (1, 0), (0, 0)])
  assert_eq(footprint(item, false), [(0, 0), (1, 0), (0, 1), (0, 2)])
}

///|
test "typed word comparisons observe in-place changes without taking ownership" {
  let a = @core.any([1, 2, 3])
  let b = @core.any([1, 2, 3])
  assert_true(equal_dwords(a, b, @core.undefined()))
  b._call("splice", [@core.any(1), @core.any(1), @core.any(9)]) |> ignore
  assert_false(equal_dwords(a, b, @core.undefined()))
  assert_true(equal_dwords(a, a, @core.undefined()))
}
