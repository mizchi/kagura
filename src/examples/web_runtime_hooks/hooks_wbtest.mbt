///|
test "web runtime hooks install and uninstall" {
  uninstall()
  assert_true(!is_ready())

  install("#app")
  assert_true(is_ready())

  shutdown()
  assert_true(!is_ready())
}
