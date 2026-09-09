///|
test "default runtime clock returns a non-negative value" {
  assert_true(default_runtime_clock_now_ms() >= 0.0)
}
