///|
/// Opt-in field editing is available in all profiles; it never implies a full snapshot restore.
pub(all) struct FieldControl {
  mut paused : Bool
  mut revision : Int32
  mut generation : Int32
}

///|
pub fn new_field_control() -> FieldControl {
  { paused: false, revision: 0, generation: 0, }
}

///|
pub fn FieldControl::begin_update(self : FieldControl) -> Bool {
  if self.paused {
    return false
  }
  self.revision += 1
  true
}

///|
pub fn FieldControl::set_paused(self : FieldControl, value : Bool) -> Unit {
  if self.paused != value {
    self.paused = value
    self.revision += 1
  }
}

///|
/// Keep the counter across game resets so old tokens can never alias a new run.
pub fn FieldControl::restart(self : FieldControl) -> Unit {
  self.generation += 1
  self.revision += 1
}

///|
pub fn FieldControl::scope(self : FieldControl, game : String) -> String {
  "\{game}:\{self.generation}"
}

///|
/// The callback must validate before mutation. A rejection never advances revision.
pub fn FieldControl::commit(
  self : FieldControl,
  revision : Int32,
  scope : String,
  current_scope : String,
  apply : () -> Unit raise,
) -> Unit raise {
  if !self.paused {
    fail("Runtime must be paused")
  }
  if revision != self.revision {
    fail("Runtime field revision conflict")
  }
  if scope != current_scope {
    fail("Runtime field scope conflict")
  }
  apply()
  self.revision += 1
}

///|
pub fn bounded_number(
  value : Double,
  low : Double,
  high : Double,
) -> Double raise {
  if !(value - value == 0.0 && value >= low && value <= high) {
    fail("Expected finite value within \{low}..\{high}")
  }
  value
}

///|
pub fn bounded_integer(
  value : Double,
  low : Int32,
  high : Int32,
) -> Int32 raise {
  ignore(bounded_number(value, low.to_double(), high.to_double()))
  let number = value.to_int()
  if number.to_double() != value {
    fail("Expected integer value")
  }
  number
}

///|
pub fn FieldControl::fields_json(
  self : FieldControl,
  scope : String,
  subjects : Array[Subject],
) -> String {
  let result : Json = {
    "revision": self.revision,
    "paused": self.paused,
    "scope": scope,
    "subjects": subjects,
  }
  result.stringify()
}

///|
pub fn FieldControl::observation_json(
  _self : FieldControl,
  state : Json,
  scope : String,
  subjects : Array[Subject],
) -> String {
  let observed = subjects.map(subject => {
    ..subject,
    fields: subject.fields.map(field => {
      match field {
        Number(id, label, value, unit, _) =>
          Number(id, label, value, unit, false)
        Text(id, label, value, _) => Text(id, label, value, false)
        Boolean(id, label, value, _) => Boolean(id, label, value, false)
      }
    }),
  })
  let result : Json = {
    "state": state,
    "inspection": { "scope": scope, "subjects": observed },
  }
  result.stringify()
}
