///|
/// A renderer-independent transition state. Only the latest live request can commit.
pub struct Flow {
  ids : Array[String]
  mut scene : String
  mut serial : Int32
  mut pending : (Int32, String)?
  transitions : Array[Transition]?
}

///|
pub fn Flow::new(ids : Array[String], entry : String) -> Flow raise {
  if ids.is_empty() || !ids.contains(entry) {
    fail("Unknown entry scene")
  }
  for i = 0; i < ids.length(); i = i + 1 {
    if ids[i].is_empty() {
      fail("Empty scene ID")
    }
    for j = 0; j < i; j = j + 1 {
      if ids[i] == ids[j] {
        fail("Duplicate scene ID")
      }
    }
  }
  { ids: ids.copy(), scene: entry, serial: 0, pending: None, transitions: None }
}

///|
/// Compile a checked definition. Structural warnings remain inspectable.
pub fn Flow::from_definition(definition : Definition) -> Flow raise {
  let report = definition.analyze()
  if !report.valid {
    fail("Invalid scene flow: " + report.issues.filter(i => i.severity == "error").map(i => i.code).join(", "))
  }
  let flow = Flow::new(definition.scenes, definition.entry)
  { ..flow, transitions: Some(definition.transitions.copy()) }
}

///|
/// Resolve a declared event in the current scene; activation still needs commit.
pub fn Flow::send(self : Flow, event : String) -> Int32 raise {
  if self.transitions is Some(edges) {
    for edge in edges {
      if edge.from == self.scene && edge.event == event {
        return self.request(edge.to)
      }
    }
  }
  fail("Illegal scene event: \{self.scene} / \{event}")
}

///|
pub fn Flow::current(self : Flow) -> String {
  self.scene
}

///|
/// Request a transition. Load and validate the destination before committing it.
pub fn Flow::request(self : Flow, target : String) -> Int32 raise {
  if !self.ids.contains(target) {
    fail("Unknown scene: \{target}")
  }
  if self.transitions is Some(edges) &&
    !edges.any(edge => edge.from == self.scene && edge.to == target) {
    fail("Illegal scene transition: \{self.scene} -> \{target}")
  }
  if self.pending is Some(_) {
    fail("A scene transition is already pending")
  }
  self.serial += 1
  self.pending = Some((self.serial, target))
  self.serial
}

///|
pub fn Flow::commit(self : Flow, ticket : Int32) -> Bool {
  match self.pending {
    Some((id, target)) if id == ticket => {
      self.scene = target
      self.pending = None
      true
    }
    _ => false
  }
}

///|
pub fn Flow::cancel(self : Flow, ticket : Int32) -> Bool {
  match self.pending {
    Some((id, _)) if id == ticket => {
      self.pending = None
      true
    }
    _ => false
  }
}

///|
/// A ground-plane trigger owned by gameplay, independent of the editor and GPU.
#derive(FromJson, ToJson)
pub(all) struct Portal {
  x : Double
  z : Double
  radius : Double
  target : String
}

///|
pub extend Portal with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend Portal with ToJson::{to_json}

///|
pub fn Portal::contains(self : Portal, x : Double, z : Double) -> Bool {
  let dx = x - self.x
  let dz = z - self.z
  self.radius > 0.0 && dx * dx + dz * dz <= self.radius * self.radius
}
