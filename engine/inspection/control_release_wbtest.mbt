///|
test "release debugger control is Unit" {
  let control : Unit = new_control()
  assert_eq(control, ())
}
