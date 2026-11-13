///|
/// The executable game and Studio share this declaration.
pub fn definition() -> @scene_flow.Definition {
  {
    entry: "title",
    scenes: ["title", "playing", "levelup", "gameover"],
    terminal: [],
    transitions: [
      { from: "title", event: "start", to: "playing" },
      { from: "playing", event: "levelup", to: "levelup" },
      { from: "levelup", event: "choose-upgrade", to: "playing" },
      { from: "playing", event: "defeated", to: "gameover" },
      { from: "gameover", event: "retry", to: "title" },
      { from: "playing", event: "reset", to: "title" },
      { from: "levelup", event: "reset", to: "title" },
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
