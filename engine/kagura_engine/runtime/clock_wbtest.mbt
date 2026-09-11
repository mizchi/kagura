///|
test "default runtime clock returns a non-negative value" {
  assert_true(default_runtime_clock_now_ms() >= 0.0)
}

///|
test "public clock follows the installed provider" {
  set_runtime_clock_provider(fn() { 42.0 })
  let now = clock_now_ms()
  reset_runtime_clock_provider()
  assert_eq(now, 42.0)
}
