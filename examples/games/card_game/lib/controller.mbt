///|
/// Focus navigation never spends a card. Confirm first enters the target scope,
/// then confirms the chosen target; cancel returns to the original hand slot.
fn Game::update_combat_navigation(
  self : Game,
  state : BattleState,
  navigation : Array[@ui.UINavigationEvent],
) -> Bool {
  if self.drag.snapshot() is Some(_) ||
    (self.combat_focus is None && self.selected_card.get() >= 0) {
    return false
  }
  let mut handled = false
  for event in navigation {
    match event {
      Move(direction) => {
        handled = true
        let forward = direction is (Right | Down)
        let step = if forward { 1 } else { -1 }
        match self.combat_focus {
          Some(Target(index)) =>
            if self.need_target {
              let alive : Array[Int] = []
              for i in 0..<state.enemies.length() {
                if !state.enemies[i].fighter.is_dead() {
                  alive.push(i)
                }
              }
              let mut current = 0
              for i, target in alive {
                if target == index {
                  current = i
                }
              }
              if !alive.is_empty() {
                let next = alive[(current + alive.length() + step) %
                  alive.length()]
                self.target_enemy.set(next)
                self.combat_focus = Some(Target(next))
              }
            }
          Some(Hand(index)) =>
            if direction is Up {
              self.combat_focus = Some(DrawPile)
            } else if !state.hand.is_empty() {
              self.combat_focus = Some(
                Hand((index + state.hand.length() + step) % state.hand.length()),
              )
            }
          Some(DrawPile | DiscardPile | EndTurn) =>
            if direction is Down {
              self.combat_focus = if state.hand.is_empty() {
                Some(EndTurn)
              } else {
                Some(Hand(0))
              }
            } else if direction is Up {
              self.combat_focus = Some(DeckButton)
            } else {
              let index = match self.combat_focus {
                Some(DrawPile) => 0
                Some(DiscardPile) => 1
                _ => 2
              }
              self.combat_focus = Some(
                match (index + 3 + step) % 3 {
                  0 => DrawPile
                  1 => DiscardPile
                  _ => EndTurn
                },
              )
            }
          Some(DeckButton) => self.combat_focus = Some(DrawPile)
          None =>
            if state.hand.is_empty() ||
              (self.end_turn_focused() && direction is (Up | Down)) {
              self.combat_focus = Some(EndTurn)
            } else {
              self.combat_focus = Some(
                Hand(if forward { 0 } else { state.hand.length() - 1 }),
              )
            }
        }
        self.hint = match self.combat_focus {
          Some(Target(_)) =>
            "ARROWS: TARGET / A OR ENTER: PLAY / B OR ESC: BACK"
          Some(Hand(_)) => "LEFT RIGHT: CARD / A OR ENTER: SELECT"
          _ => "ARROWS: CONTROL / A OR ENTER: CONFIRM"
        }
      }
      Confirm =>
        match self.combat_focus {
          Some(Hand(index)) => {
            handled = true
            if can_play_card(state, index) {
              self.select_card(state, index)
              let target = if self.need_target {
                first_alive_enemy(state)
              } else {
                -1
              }
              self.combat_focus = Some(Target(target))
              self.target_enemy.set(target)
              self.hint = "ARROWS: TARGET / A OR ENTER: PLAY / B OR ESC: BACK"
            } else {
              self.hint = "NOT ENOUGH ENERGY"
            }
          }
          Some(Target(index)) => {
            self.commit_card(state, self.selected_card.get(), ui_max(0, index))
            return true
          }
          Some(EndTurn) => {
            self.start_enemy_turn(state)
            return true
          }
          Some(DrawPile) => {
            self.open_pile(Draw)
            return true
          }
          Some(DiscardPile) => {
            self.open_pile(Discard)
            return true
          }
          Some(DeckButton) => {
            self.open_pile(Deck)
            return true
          }
          None => ()
        }
      _ => ()
    }
  }
  handled
}
