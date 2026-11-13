///|
test "all declared scenes and edges are structurally live" {
  let report = definition().analyze()
  assert_true(report.valid)
  assert_eq(report.issues.length(), 0)
}
