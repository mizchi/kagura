///|
test "typed word comparisons observe in-place changes without taking ownership" {
  let a = @core.any([1, 2, 3])
  let b = @core.any([1, 2, 3])
  assert_true(equal_dwords(a, b, @core.undefined()))
  b._call("splice", [@core.any(1), @core.any(1), @core.any(9)]) |> ignore
  assert_false(equal_dwords(a, b, @core.undefined()))
  assert_true(equal_dwords(a, a, @core.undefined()))
}
