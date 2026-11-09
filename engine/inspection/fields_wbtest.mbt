///|
test "field control freezes ticks and guards scope and revision before committing" {
  let c = new_field_control()
  let mut hp = 10
  assert_true(c.begin_update())
  c.set_paused(true)
  let revision = c.revision
  c.commit(revision, "run", "run", fn() { hp = 7 })
  assert_eq(hp, 7)
  assert_eq(c.revision, revision + 1)
  assert_false(c.begin_update())
  for token in [(revision, "run"), (c.revision, "old")] {
    assert_true(
      try {
        c.commit(token.0, token.1, "run", fn() { hp = 1 })
        false
      } catch {
        _ => true
      },
    )
    assert_eq(hp, 7)
  }
  let current = c.revision
  assert_true(
    try {
      c.commit(current, "run", "run", () => fail("Invalid game value"))
      false
    } catch {
      _ => true
    },
  )
  assert_eq(c.revision, current)
  let scope = c.scope("game")
  c.restart()
  assert_true(c.scope("game") != scope)
  c.set_paused(false)
  assert_true(
    try {
      c.commit(c.revision, "run", "run", fn() { hp = 1 })
      false
    } catch {
      _ => true
    },
  )
  assert_eq(hp, 7)
}

///|
test "field observations are detached read-only descriptors and edits retain declared permissions" {
  let c = new_field_control()
  let subjects = [
    Subject::{
      id: "player",
      name: "Player",
      fields: [number("hp", 8.0, editable=true)],
    },
  ]
  let read = @json.parse(c.fields_json("run", subjects))
  guard read
    is { "subjects": [{ "fields": [{ "access": "runtime", .. }], .. }], .. } else {
    fail("Missing edit rights")
  }
  let observed = @json.parse(
    c.observation_json(Json({ "hp": 8 }), "run", subjects),
  )
  guard observed
    is {
      "state": { "hp": 8, .. },
      "inspection": {
        "subjects": [{ "fields": [{ "access": "readonly", .. }], .. }],
        ..
      },
      ..
    } else {
    fail("Observation granted writes")
  }
}

///|
test "bounded tuning values reject non-finite fractional and out-of-range input" {
  assert_eq(bounded_integer(3.0, 1, 6), 3)
  assert_eq(bounded_number(0.5, 0.0, 1.0), 0.5)
  for value in [0.0, 7.0, 2.5, 0.0 / 0.0, 1.0 / 0.0] {
    assert_true(
      try {
        ignore(bounded_integer(value, 1, 6))
        false
      } catch {
        _ => true
      },
    )
  }
}
