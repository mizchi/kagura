///|
/// The executable game and Studio share this declaration.
pub fn definition() -> @scene_flow.Definition {
  {
    entry: "title",
    scenes: ["title", "playing", "gameover"],
    terminal: [],
    transitions: [
      { from: "title", event: "flap", to: "playing" },
      { from: "playing", event: "collision", to: "gameover" },
      { from: "gameover", event: "retry", to: "title" },
      { from: "playing", event: "reset", to: "title" },
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
