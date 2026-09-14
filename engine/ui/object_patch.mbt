///|
/// Incremental JSON object transport. Fields are compared structurally; only
/// changed top-level fields are encoded. Owns a deep copy of retained values,
/// so callers may reuse mutable input maps/arrays. Receivers apply `full`, `set`
/// and `remove` atomically; null is a value, not a deletion.
pub struct JsonObjectPublisher {
  previous : Map[String, Json]
  mut initialized : Bool
}

///|
pub fn JsonObjectPublisher::new() -> JsonObjectPublisher {
  { previous: Map([]), initialized: false, }
}

///|
pub fn JsonObjectPublisher::reset(self : JsonObjectPublisher) -> Unit {
  self.previous.clear()
  self.initialized = false
}

///|
fn copy_json_value(value : Json) -> Json {
  match value {
    Array(items) => Json::array(items.map(copy_json_value))
    Object(fields) => {
      let copy : Map[String, Json] = Map([])
      for key, item in fields {
        copy[key] = copy_json_value(item)
      }
      Json::object(copy)
    }
    _ => value
  }
}

///|
/// First call (including an empty object) sends a full replacement; unchanged
/// subsequent objects return None. `reset` starts a new receiver session.
pub fn JsonObjectPublisher::encode(
  self : JsonObjectPublisher,
  fields : Map[String, Json],
) -> String? {
  let changed : Map[String, Json] = Map([])
  let removed : Array[Json] = []
  for key, value in fields {
    if self.previous.get(key) != Some(value) {
      let copy = copy_json_value(value)
      self.previous[key] = copy
      changed[key] = copy
    }
  }
  for key in self.previous.keys().to_array() {
    if !fields.contains(key) {
      self.previous.remove(key)
      removed.push(Json::string(key))
    }
  }
  if self.initialized && changed.is_empty() && removed.is_empty() {
    return None
  }
  let patch : Json = {
    "full": (!self.initialized).to_json(),
    "set": Json::object(changed),
    "remove": Json::array(removed),
  }
  self.initialized = true
  Some(patch.stringify())
}
