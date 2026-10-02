///|
/// Fresh deterministic fixtures for visual review, excluded from release builds.
pub fn Game::preview(name : String, width : Int, height : Int) -> Game {
  let game = Game::new()
  game.set_viewport(width, height)
  let run = game.run.get()
  match name {
    "card_reward" | "complex_reward" => {
      run.phase = CardReward
      run.card_rewards.clear()
      let cards = if name == "complex_reward" {
        [Corruption, Feed, Reaper]
      } else {
        [Pommel_Strike, Inflame, Shrug_It_Off]
      }
      for card in cards {
        run.card_rewards.push(card)
      }
    }
    "rest" => {
      run.phase = RestSite
      run.floor = 5
      run.player_hp = 46
    }
    "victory" => {
      run.phase = RunVictory
      run.floor = 30
    }
    "defeat" => {
      run.phase = RunDefeat
      run.player_hp = 0
    }
    "battle_victory" => run.battle.unwrap().phase = Victory
    "deck" => game.deck_open = true
    "large_hand" | "inspect_card" => {
      let b = run.battle.unwrap()
      b.hand.clear()
      for
        card in [
          Strike,
          Defend,
          Bash,
          Offering,
          Inflame,
          Whirlwind,
          Shrug_It_Off,
          Metallicize,
          Battle_Trance,
          Heavy_Blade,
          Corruption,
          Feed,
        ] {
        b.hand.push(card)
      }
      if name == "inspect_card" {
        let r = game.layout.card_rect(10, b.hand.length())
        game.cursor_x = r.x + 2.0
        game.cursor_y = r.y + 30.0
      }
    }
    "low_energy" => {
      let b = run.battle.unwrap()
      b.player.energy = 0
      b.hand.clear()
      for card in [Offering, Demon_Form, Whirlwind, Corruption, Seeing_Red] {
        b.hand.push(card)
      }
    }
    "dragging" => {
      let b = run.battle.unwrap()
      b.hand[0] = Defend
      let card = game.layout.card_rect(0, b.hand.length())
      let target = game.layout.player_rect()
      game.selected_card.set(0)
      game.gesture = Some({
        index: 0,
        start_x: card.x + 12.0,
        start_y: card.y + 30.0,
        touch_id: None,
        dragged: true,
      })
      game.cursor_x = target.x + target.w / 2.0
      game.cursor_y = target.y + target.h / 2.0
      game.hint = "DROP ON THE BATTLEFIELD"
    }
    _ => ()
  }
  game
}
