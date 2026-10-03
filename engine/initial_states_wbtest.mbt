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

///|
test "initial state registry supports 64 scenarios and rejects the 65th" {
  let named : Array[(String, (Int, Int) -> Int)] = []
  for i in 0..<64 {
    named.push(("state_\{i}", (w, h) => w + h))
  }
  let registry = InitialStates::new(default=(_w, _h) => 0, named~)
  assert_eq(registry.names().length(), 64)
  named.push(("state_64", (_w, _h) => 0))
  let rejected = try {
    InitialStates::new(default=(_w, _h) => 0, named~) |> ignore
    false
  } catch {
    _ => true
  }
  assert_true(rejected)
}
