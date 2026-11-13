///|
test "actual portal graph has no unreachable scenes or dead transitions" {
  assert_eq(definition().analyze().issues.length(), 0)
}
