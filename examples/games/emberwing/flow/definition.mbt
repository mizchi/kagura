///|
/// The executable game and Studio share this declaration.
pub fn definition() -> @scene_flow.Definition {
  {
    entry: "title",
    scenes: ["title", "playing", "paused", "lost", "won"],
    terminal: [],
    transitions: [
      { from: "title", event: "start", to: "playing" },
      { from: "playing", event: "pause", to: "paused" },
      { from: "paused", event: "resume", to: "playing" },
      { from: "playing", event: "defeated", to: "lost" },
      { from: "playing", event: "boss-clear", to: "won" },
      { from: "lost", event: "restart", to: "playing" },
      { from: "won", event: "restart", to: "playing" },
      { from: "playing", event: "restart", to: "playing" },
      { from: "playing", event: "title", to: "title" },
      { from: "paused", event: "title", to: "title" },
      { from: "lost", event: "title", to: "title" },
      { from: "won", event: "title", to: "title" },
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
