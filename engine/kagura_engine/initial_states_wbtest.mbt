///|
test "named initial states create fresh state at the requested viewport" {
  let defaults = Ref(0)
  let named = Ref(0)
  let states = InitialStates::new(
    default=(w, h) => {
      defaults.val += 1
      Ref(w + h)
    },
    named=[
      (
        "focused",
        (w, h) => {
          named.val += 1
          Ref(w * h)
        },
      ),
    ],
  )
  let a = states.create(Some("focused"), width=360, height=640)
  a.val = 0
  let b = states.create(Some("focused"), width=360, height=640)
  assert_eq(b.val, 230400)
  assert_eq(named.val, 2)
  assert_eq(defaults.val, 0)
  assert_eq(states.create(None, width=640, height=480).val, 1120)
  assert_eq(defaults.val, 1)
  assert_eq(states.names(), ["focused"])
}

///|
test "initial state names reject duplicates and unknown names before construction" {
  let calls = Ref(0)
  let make = (_w, _h) => {
    calls.val += 1
    0
  }
  for names in [["a", "a"], [""], ["../a"]] {
    let rejected = try {
      let _ = InitialStates::new(default=make, named=names.map(n => (n, make)))
      false
    } catch {
      _ => true
    }
    assert_true(rejected)
  }
  let states = InitialStates::new(default=make)
  let rejected = try {
    let _ = states.create(Some("missing"), width=640, height=480)
    false
  } catch {
    _ => true
  }
  assert_true(rejected)
  assert_eq(calls.val, 0)
}
