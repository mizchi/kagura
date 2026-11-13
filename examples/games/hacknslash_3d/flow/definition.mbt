///|
/// The executable game and Studio share this declaration.
pub fn definition() -> @scene_flow.Definition {
  { entry: "title", scenes: ["title", "character_select", "playing", "gameover"], terminal: [],
    transitions: [
      { from: "title", event: "new-save", to: "character_select" },
      { from: "title", event: "load-save", to: "playing" },
      { from: "character_select", event: "confirm-build", to: "playing" },
      { from: "character_select", event: "back", to: "title" },
      { from: "playing", event: "defeated", to: "gameover" },
      { from: "gameover", event: "respawn", to: "playing" },
      { from: "playing", event: "save-select", to: "title" },
      { from: "gameover", event: "save-select", to: "title" },
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
