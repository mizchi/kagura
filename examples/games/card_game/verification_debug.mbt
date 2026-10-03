///|
fn initial_states() -> @engine.InitialStates[@lib.Game] {
  let named : Array[(String, (Int, Int) -> @lib.Game)] = []
  for
    name in [
      "map", "map_unique", "event", "shop", "shop_sold", "card_removal", "treasure",
      "unique_battle", "unique_reward", "battle", "title", "settings", "character_select",
      "event_complete", "boss", "draw_pile", "discard_pile", "controller_target",
      "card_reward", "complex_reward", "inspect_card", "rest", "victory", "defeat",
      "battle_victory", "deck", "large_hand", "low_energy", "energy_empty", "energy_selected",
      "dragging", "drag_attack", "drop_enemy", "drop_outside", "card_impact", "block_effect",
      "enemy_windup", "enemy_impact", "draw_hand", "battle_outcome",
    ] {
    named.push(
      (name, (width, height) => @lib.Game::preview(name, width, height)),
    )
  }
  @engine.InitialStates::new(
    default=(width, height) => {
      let name = preview_request_name()
      if name != "" {
        return @lib.Game::preview(name, width, height)
      }
      let game = @lib.Game::new_app()
      game.set_viewport(width, height)
      game
    },
    named~,
  ) catch {
    @engine.InitialStateError(message) => abort(message)
  }
}
