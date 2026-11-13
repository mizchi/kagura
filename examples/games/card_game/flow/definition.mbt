///|
/// The executable game and Studio share this declaration.
pub fn definition() -> @scene_flow.Definition {
  { entry: "title", scenes: ["title", "settings", "character_select", "playing"], terminal: [],
    transitions: [
      { from: "title", event: "settings", to: "settings" },
      { from: "settings", event: "back", to: "title" },
      { from: "title", event: "begin", to: "character_select" },
      { from: "character_select", event: "back", to: "title" },
      { from: "character_select", event: "choose-character", to: "playing" },
      { from: "playing", event: "restart", to: "character_select" },
      { from: "playing", event: "settings", to: "settings" },
      { from: "settings", event: "resume", to: "playing" },
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
