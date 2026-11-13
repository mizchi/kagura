///|
/// The executable game and Studio share this declaration.
pub fn definition() -> @scene_flow.Definition {
  {
    entry: "title",
    scenes: ["title", "playing", "paused", "lost", "cleared"],
    terminal: [],
    transitions: [
      { from: "title", event: "start", to: "playing" },
      { from: "playing", event: "pause", to: "paused" },
      { from: "paused", event: "resume", to: "playing" },
      { from: "playing", event: "defeated", to: "lost" },
      { from: "playing", event: "stage-clear", to: "cleared" },
      { from: "lost", event: "retry", to: "playing" },
      { from: "cleared", event: "retry", to: "playing" },
      { from: "playing", event: "retry", to: "playing" },
    ],
  }
}

///|
pub fn check(from : String, to : String) -> Unit raise {
  definition().require_transition(from, to)
}

///|
pub fn definition_json() -> String {
  definition().to_json().stringify()
}
