///|
/// The executable game and Studio share this declaration.
pub fn definition() -> @scene_flow.Definition {
  {
    entry: "town",
    scenes: ["town", "explore", "battle", "chest", "warning", "cleared"],
    terminal: [],
    transitions: [
      { from: "town", event: "enter", to: "explore", },
      { from: "cleared", event: "enter", to: "explore", },
      { from: "explore", event: "encounter", to: "battle", },
      { from: "explore", event: "guardian-room", to: "warning", },
      { from: "warning", event: "challenge", to: "battle", },
      { from: "explore", event: "chest", to: "chest", },
      { from: "chest", event: "loot-or-back", to: "explore", },
      { from: "warning", event: "back", to: "explore", },
      { from: "battle", event: "victory-or-flee", to: "explore", },
      { from: "battle", event: "defeat", to: "town", },
      { from: "explore", event: "return", to: "town", },
      { from: "explore", event: "return-with-relic", to: "cleared", },
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
