///|
test "typed word comparisons observe in-place changes without taking ownership" {
  let a = @core.any(([1, 2, 3] : FixedArray[Int32]))
  let b = @core.any(([1, 2, 3] : FixedArray[Int32]))
  assert_true(equal_dwords(a, b, @core.undefined()))
  b._set("1", @core.any(9))
  assert_false(equal_dwords(a, b, @core.undefined()))
  assert_true(equal_dwords(a, a, @core.undefined()))
}
