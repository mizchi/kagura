///|
test "shared wire adapter decodes, rejects unknown fields and delegates atomic commit" {
  let mut state : Fixture = { y: 12.0, title: "Bird", enabled: true, }
  let mut revision = 0
  let mut paused = false
  let runtime = Runtime::new(
    game="fixture",
    schema="fixture.state",
    inspector=fixture_inspector(),
    read=() => { state, revision, paused, },
    pause=value => {
      paused = value
      revision += 1
    },
    step=() => {
      if !paused {
        fail("Pause first")
      }
      state = { ..state, y: state.y + 1.0, }
      revision += 1
    },
    replace=next => {
      if !paused || next.y > 100.0 {
        fail("Invalid state")
      }
      state = next
      revision += 1
    },
  )
  assert_eq(@json.parse(runtime.invoke("pause", "true")), {
    "ok": true,
    "value": Json::null(),
  })
  let snapshot = runtime.invoke("read", "null")
  let candidate : Json = [
    state.to_json(),
    { "subject": "bird", "field": "y", "value": 80 },
  ]
  let reduced = @json.parse(runtime.invoke("reduce", candidate.stringify()))
  guard reduced is { "ok": true, "value": value, .. } else {
    fail("Expected candidate state")
  }
  assert_eq(runtime.invoke("read", "null"), snapshot)
  assert_eq(@json.parse(runtime.invoke("replace", value.stringify())), {
    "ok": true,
    "value": Json::null(),
  })
  assert_eq(state.y, 80.0)
  let before = runtime.invoke("read", "null")
  let invalid = "{\"y\":1000,\"title\":\"Bird\",\"enabled\":true}"
  assert_true(
    @json.parse(runtime.invoke("replace", invalid)) is { "ok": false, .. },
  )
  assert_true(
    @json.parse(
      runtime.invoke(
        "replace", "{\"y\":1,\"title\":\"Bird\",\"enabled\":true,\"typo\":1}",
      ),
    )
    is { "ok": false, .. },
  )
  assert_eq(runtime.invoke("read", "null"), before)
}
