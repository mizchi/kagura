///|
test "lifecycle hooks: on_start and on_stop fire correctly" {
  let events : Array[String] = []
  set_lifecycle_hooks({
    on_start: fn(canvas, title) {
      events.push("start:" + canvas + ":" + title)
    },
    on_stop: fn() { events.push("stop") },
  })
  invoke_on_start("#app", "test-game")
  invoke_on_stop()
  assert_eq(events, ["start:#app:test-game", "stop"])
  reset_lifecycle_hooks()
}

///|
test "lifecycle hooks: no-op when not set" {
  reset_lifecycle_hooks()
  // Should not panic
  invoke_on_start("#app", "test")
  invoke_on_stop()
}

///|
test "lifecycle hooks: reset clears hooks" {
  let called = Ref::new(false)
  set_lifecycle_hooks({
    on_start: fn(_canvas, _title) { called.val = true },
    on_stop: fn() {},
  })
  reset_lifecycle_hooks()
  invoke_on_start("#app", "test")
  assert_false(called.val)
}
