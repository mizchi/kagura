///|
/// Getters and setters operate on detached logical snapshots, never live game state.
pub struct Property[S] {
  id : String
  read : (S) -> Field
  write : ((S, Json) -> S raise)?
}

///|
pub struct SubjectBinding[S] {
  id : String
  name : String
  fields : Array[Property[S]]
}

///|
pub struct Inspector[S] {
  subjects : Array[SubjectBinding[S]]
}

///|
pub fn[S] number_field(
  id : String,
  get~ : (S) -> Double,
  set? : (S, Double) -> S raise,
  label? : String = id,
  unit? : String = "",
) -> Property[S] {
  let write : ((S, Json) -> S raise)? = set.map(fn(set) {
    fn(state, json) raise {
      let value : Double = @json.from_json(json)
      if value - value != 0.0 {
        fail("Expected finite inspection number")
      }
      set(state, value)
    }
  })
  {
    id,
    read: state => Number(id, label, get(state), unit, set is Some(_)),
    write,
  }
}

///|
pub fn[S] text_field(
  id : String,
  get~ : (S) -> String,
  set? : (S, String) -> S raise,
  label? : String = id,
) -> Property[S] {
  {
    id,
    read: state => Text(id, label, get(state), set is Some(_)),
    write: set.map(fn(set) {
      fn(state, value) raise { set(state, @json.from_json(value)) }
    }),
  }
}

///|
pub fn[S] boolean_field(
  id : String,
  get~ : (S) -> Bool,
  set? : (S, Bool) -> S raise,
  label? : String = id,
) -> Property[S] {
  {
    id,
    read: state => Boolean(id, label, get(state), set is Some(_)),
    write: set.map(fn(set) {
      fn(state, value) raise { set(state, @json.from_json(value)) }
    }),
  }
}

///|
pub fn[S] bind_subject(
  id : String,
  fields~ : Array[Property[S]],
  name? : String = id,
) -> SubjectBinding[S] {
  { id, name, fields: fields.copy(), }
}

///|
pub fn[S] Inspector::new(
  subjects : Array[SubjectBinding[S]],
) -> Inspector[S] raise {
  let ids : Map[String, Bool] = Map([])
  let mut count = 0
  for subject in subjects {
    if !@hierarchy.valid_subject(subject.id) ||
      ids.contains(subject.id) ||
      subject.name.length() > 256 {
      fail("Invalid or duplicate inspection subject")
    }
    ids[subject.id] = true
    let fields : Map[String, Bool] = Map([])
    for field in subject.fields {
      count += 1
      if count > 10000 ||
        !@hierarchy.valid_subject(field.id) ||
        fields.contains(field.id) {
        fail("Invalid or duplicate inspection field")
      }
      fields[field.id] = true
    }
  }
  if subjects.length() > 10000 {
    fail("Too many inspection subjects")
  }
  { subjects: subjects.map(s => { ..s, fields: s.fields.copy(), }), }
}

///|
/// Projects fields from the supplied logical snapshot; getters must be pure.
pub fn[S] Inspector::describe(self : Inspector[S], state : S) -> Array[Subject] {
  self.subjects.map(s => {
    id: s.id,
    name: s.name,
    fields: s.fields.map(f => (f.read)(state)),
  })
}

///|
/// Returns a candidate snapshot; does not commit, persist, or copy `state`.
/// Pass detached state and pure setters. `subject` is a game-owned identity,
/// independent of render keys/paths; `field` is its declared property ID.
/// The host checks Pause/session/revision, then the game's replace callback
/// validates and commits the candidate. Direct callers must provide those guards.
pub fn[S] Inspector::edit(
  self : Inspector[S],
  state : S,
  subject~ : String,
  field~ : String,
  value~ : Json,
) -> S raise {
  for s in self.subjects {
    if s.id == subject {
      for f in s.fields {
        if f.id == field {
          guard f.write is Some(write) else {
            fail("Inspection field is not writable")
          }
          return write(state, value)
        }
      }
      fail("Unknown inspection field")
    }
  }
  fail("Unknown inspection subject")
}
