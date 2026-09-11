///|
struct Fixture {
  y : Double
  title : String
  enabled : Bool
} derive(FromJson, ToJson, Eq, Debug)

///|
fn fixture_inspector() -> Inspector[Fixture] raise {
  Inspector::new([
    bind_subject("bird", name="Bird", fields=[
      number_field(
        "y",
        get=s => s.y,
        set=(s, value) => { ..s, y: value, },
        unit="px",
      ),
      number_field("speed", get=s => s.y.abs()),
      text_field("title", get=s => s.title, set=(s, value) => {
        ..s,
        title: value,
      }),
      boolean_field("enabled", get=s => s.enabled, set=(s, value) => {
        ..s,
        enabled: value,
      }),
    ]),
  ])
}

///|
test "one field declaration drives both presentation and typed reduction" {
  let inspector = fixture_inspector()
  let before : Fixture = { y: 12.0, title: "Bird", enabled: true, }
  let subjects = inspector.describe(before)
  assert_eq(subjects[0].id, "bird")
  assert_eq(subjects[0].fields[0].to_json(), {
    "id": "y",
    "label": "y",
    "kind": "number",
    "value": 12,
    "unit": "px",
    "access": "runtime",
  })
  let edited = inspector.edit(before, subject="bird", field="y", value=80)
  assert_eq(edited.y, 80.0)
  assert_eq(before.y, 12.0)
  assert_eq(
    inspector.edit(before, subject="bird", field="title", value="Renamed").title,
    "Renamed",
  )
  assert_eq(
    inspector.edit(before, subject="bird", field="enabled", value=false).enabled,
    false,
  )
  assert_true(
    try {
      ignore(inspector.edit(before, subject="bird", field="speed", value=1))
      false
    } catch {
      _ => true
    },
  )
  assert_true(
    try {
      ignore(inspector.edit(before, subject="bird", field="y", value="bad"))
      false
    } catch {
      _ => true
    },
  )
  assert_true(
    try {
      ignore(inspector.edit(before, subject="gone", field="y", value=1))
      false
    } catch {
      _ => true
    },
  )
}

///|
test "ambiguous subject and property declarations fail before registration" {
  let field = number_field("y", get=(s : Fixture) => s.y)
  assert_true(
    try {
      ignore(Inspector::new([bind_subject("bird", fields=[field, field])]))
      false
    } catch {
      _ => true
    },
  )
  let subject = bind_subject("bird", fields=[field])
  assert_true(
    try {
      ignore(Inspector::new([subject, subject]))
      false
    } catch {
      _ => true
    },
  )
  assert_true(
    try {
      ignore(Inspector::new([bind_subject("bad/path", fields=[field])]))
      false
    } catch {
      _ => true
    },
  )
}
