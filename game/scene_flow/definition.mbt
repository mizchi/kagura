///|
/// A deterministic event edge. Conditions belong in game code, before send().
#derive(FromJson, ToJson)
pub(all) struct Transition {
  from : String
  event : String
  to : String
}

///|
/// Renderer-independent state machine, shared by runtime and inspection tools.
#derive(FromJson, ToJson)
pub(all) struct Definition {
  entry : String
  scenes : Array[String]
  terminal : Array[String]
  transitions : Array[Transition]
}

///|
#derive(ToJson)
pub(all) struct Issue {
  code : String
  severity : String
  scene : String
  // Zero-based index in the declaration, or -1 for a scene-level issue.
  transition : Int
}

///|
#derive(ToJson)
pub(all) struct Report {
  valid : Bool
  reachable : Array[String]
  issues : Array[Issue]
}

///|
/// Check a state change owned by an enum, signal, or serialized game state.
/// This keeps the game as the sole owner of its current state.
pub fn Definition::require_transition(self : Definition, from : String, to : String) -> Unit raise {
  if !self.analyze().valid {
    fail("Invalid scene flow definition")
  }
  if !self.transitions.any(edge => edge.from == from && edge.to == to) {
    fail("Illegal scene transition: \{from} -> \{to}")
  }
}

///|
/// Analyze structure, not the satisfiability of arbitrary gameplay conditions.
pub fn Definition::analyze(self : Definition) -> Report {
  let issues : Array[Issue] = []
  fn issue(code : String, scene : String, transition : Int, severity : String) {
    issues.push({ code, severity, scene, transition })
  }
  let ids : Array[String] = []
  for id in self.scenes {
    if id.is_empty() {
      issue("invalid-scene", id, -1, "error")
    } else if ids.contains(id) {
      issue("duplicate-scene", id, -1, "error")
    } else {
      ids.push(id)
    }
  }
  if !ids.contains(self.entry) {
    issue("invalid-entry", self.entry, -1, "error")
  }
  let terminals : Array[String] = []
  for id in self.terminal {
    if !ids.contains(id) {
      issue("unknown-terminal", id, -1, "error")
    } else if terminals.contains(id) {
      issue("duplicate-terminal", id, -1, "error")
    } else {
      terminals.push(id)
    }
  }
  let usable : Array[Bool] = []
  for i, edge in self.transitions {
    let mut ok = true
    if !ids.contains(edge.from) {
      issue("unknown-source", edge.from, i, "error")
      ok = false
    }
    if !ids.contains(edge.to) {
      issue("unknown-target", edge.to, i, "error")
      ok = false
    }
    if edge.event.is_empty() {
      issue("invalid-event", edge.from, i, "error")
      ok = false
    }
    if terminals.contains(edge.from) {
      issue("terminal-transition", edge.from, i, "error")
      ok = false
    }
    for j = 0; j < i; j = j + 1 {
      let previous = self.transitions[j]
      if previous.from == edge.from && previous.event == edge.event {
        issue("ambiguous-event", edge.from, i, "error")
        ok = false
        break
      }
    }
    usable.push(ok)
  }
  let reached : Array[String] = []
  if ids.contains(self.entry) {
    reached.push(self.entry)
  }
  let mut cursor = 0
  while cursor < reached.length() {
    let source = reached[cursor]
    cursor += 1
    for i, edge in self.transitions {
      if usable[i] && edge.from == source && !reached.contains(edge.to) {
        reached.push(edge.to)
      }
    }
  }
  // Reverse reachability detects whole sink cycles, not only leaf scenes.
  let finishes = terminals.copy()
  cursor = 0
  while cursor < finishes.length() {
    let target = finishes[cursor]
    cursor += 1
    for i, edge in self.transitions {
      if usable[i] && edge.to == target && !finishes.contains(edge.from) {
        finishes.push(edge.from)
      }
    }
  }
  for id in ids {
    if !reached.contains(id) {
      issue("unreachable-scene", id, -1, "warning")
    } else if !terminals.contains(id) {
      let mut outgoing = false
      for i, edge in self.transitions {
        if usable[i] && edge.from == id {
          outgoing = true
        }
      }
      if !outgoing {
        issue("dead-end", id, -1, "warning")
      } else if !terminals.is_empty() && !finishes.contains(id) {
        issue("no-terminal-path", id, -1, "warning")
      }
    }
  }
  for i, edge in self.transitions {
    if !usable[i] || !reached.contains(edge.from) {
      issue("dead-transition", edge.from, i, "warning")
    }
  }
  {
    valid: !issues.any(i => i.severity == "error"),
    reachable: ids.filter(id => reached.contains(id)),
    issues,
  }
}

///|
fn mermaid_label(source : String) -> String {
  let out = StringBuilder::new()
  for char in source {
    match char {
      '&' => out.write_string("#38;")
      '"' => out.write_string("#34;")
      '<' => out.write_string("#60;")
      '>' => out.write_string("#62;")
      '|' => out.write_string("#124;")
      '\n' | '\r' => out.write_string(" ")
      '\\' => out.write_string("#92;")
      _ => {
        if (char >= 'a' && char <= 'z') ||
          (char >= 'A' && char <= 'Z') ||
          (char >= '0' && char <= '9') || char == ' ' || char == '_' {
          out.write_char(char)
        } else {
          out.write_string("#\{char.to_int()};")
        }
      }
    }
  }
  out.to_string()
}

///|
/// Export without executing user-provided Mermaid identifiers or directives.
pub fn Definition::to_mermaid(self : Definition) -> String {
  let lines = ["stateDiagram-v2"]
  for i, id in self.scenes {
    lines.push("  state \"\{mermaid_label(id)}\" as s\{i}")
    if id == self.entry {
      lines.push("  [*] --> s\{i}")
    }
    if self.terminal.contains(id) {
      lines.push("  s\{i} --> [*]")
    }
  }
  for edge in self.transitions {
    let from = self.scenes.search(edge.from)
    let to = self.scenes.search(edge.to)
    if from is Some(a) && to is Some(b) {
      lines.push("  s\{a} --> s\{b}: \{mermaid_label(edge.event)}")
    }
  }
  lines.join("\n") + "\n"
}

///|
pub extend Transition with @moonbitlang/core/json.FromJson::{from_json}
///|
pub extend Transition with ToJson::{to_json}
///|
pub extend Definition with @moonbitlang/core/json.FromJson::{from_json}
///|
pub extend Definition with ToJson::{to_json}
///|
pub extend Issue with ToJson::{to_json}
///|
pub extend Report with ToJson::{to_json}
