///|
struct CardGesture {
  index : Int
  start_x : Double
  start_y : Double
  touch_id : Int?
  mut dragged : Bool
}

///|
/// Transient input state is separate from persistent combat/run rules.
pub struct Game {
  run : @signals.Signal[RunState]
  selected_card : @signals.Signal[Int]
  target_enemy : @signals.Signal[Int]
  input : @inpututil.InputHelper
  mut layout : GameLayout
  mut cursor_x : Double
  mut cursor_y : Double
  mut need_target : Bool
  mut gesture : CardGesture?
  mut hint : String
  mut deck_open : Bool
  mut deck_page : Int
}

///|
pub impl @scene.SceneGame for Game with fn update_game(self, input) {
  self.update(self.surface_input(input))
}

///|
pub impl @scene.SceneGame for Game with fn view_game(self) {
  self.view()
}

///|
pub extend Game with @scene.SceneGame::{update_game, view_game}

///|
pub fn Game::new() -> Game {
  {
    run: @signals.signal(RunState::new()),
    selected_card: @signals.signal(-1),
    target_enemy: @signals.signal(-1),
    input: @inpututil.new_input_helper(),
    layout: GameLayout::new(screen_w, screen_h),
    cursor_x: -1.0,
    cursor_y: -1.0,
    need_target: false,
    gesture: None,
    hint: "DRAG A CARD TO PLAY",
    deck_open: false,
    deck_page: 0,
  }
}

///|
pub fn Game::set_viewport(self : Game, width : Int, height : Int) -> Unit {
  if self.layout.w != width.to_double() || self.layout.h != height.to_double() {
    self.cancel_card()
  }
  self.layout = GameLayout::new(width, height)
}

///|
pub fn Game::snapshot_state(self : Game) -> String {
  if self.deck_open {
    return "deck"
  }
  if self.gesture is Some({ dragged: true, .. }) {
    return "dragging"
  }
  match self.run.get().phase {
    Battle =>
      match self.run.get().battle {
        Some({ phase: Victory, .. }) => "battle_victory"
        Some({ phase: Defeat, .. }) => "battle_defeat"
        _ => "battle"
      }
    CardReward => "card_reward"
    RestSite => "rest"
    RunVictory => "victory"
    RunDefeat => "defeat"
  }
}

///|
fn Game::cancel_card(self : Game) -> Unit {
  self.gesture = None
  self.selected_card.set(-1)
  self.target_enemy.set(-1)
  self.need_target = false
}

///|
fn Game::commit_card(
  self : Game,
  state : BattleState,
  index : Int,
  target : Int,
) -> Unit {
  let result = play_card(state, index, target)
  self.hint = match result {
    Ok => "CARD PLAYED"
    NotEnoughEnergy => "NOT ENOUGH ENERGY"
    InvalidTarget => "CHOOSE A LIVING ENEMY"
    _ => "CANNOT PLAY THIS CARD"
  }
  self.cancel_card()
  self.run.set(self.run.get())
}

///|
fn Game::select_card(self : Game, state : BattleState, index : Int) -> Unit {
  if !can_play_card(state, index) {
    self.hint = "NOT ENOUGH ENERGY"
    self.cancel_card()
    return
  }
  self.selected_card.set(index)
  self.need_target = card_needs_target(state.hand[index])
  self.target_enemy.set(first_alive_enemy(state))
  self.hint = if self.need_target {
    "CHOOSE AN ENEMY OR PRESS ENTER"
  } else {
    "PRESS ENTER TO PLAY"
  }
}

///|
fn deck_button_rect(layout : GameLayout) -> UiRect {
  { x: layout.w - 96.0, y: 8.0, w: 80.0, h: 36.0, }
}

///|
pub fn Game::update(self : Game, input : @core.InputSnapshot) -> Unit {
  @inpututil.update_input_helper(self.input, input)
  let keys = self.input.key_state
  let mouse = self.input.mouse_state
  let previous_x = self.cursor_x
  let previous_y = self.cursor_y
  if input.cursor_x != -1.0 || input.cursor_y != -1.0 {
    self.cursor_x = input.cursor_x
    self.cursor_y = input.cursor_y
  }
  let mut pressed = @inputstate.is_mouse_button_just_pressed(mouse, 0)
  let mut released = @inputstate.is_mouse_button_just_released(mouse, 0)
  let mut down = @inputstate.is_mouse_button_pressed(mouse, 0)
  let mut touch_id : Int? = None
  // A gesture owns its touch; a second finger must not retarget it.
  let active_touch = match self.gesture {
    Some(g) => g.touch_id
    None => None
  }
  if active_touch is Some(id) {
    let mut found = false
    for touch in input.touches {
      if touch.id == id {
        self.cursor_x = touch.x
        self.cursor_y = touch.y
        down = true
        found = true
      }
    }
    released = !found
    if !found {
      self.cursor_x = previous_x
      self.cursor_y = previous_y
    }
  } else if input.touches.length() > 0 {
    let touch = input.touches[0]
    self.cursor_x = touch.x
    self.cursor_y = touch.y
    touch_id = Some(touch.id)
    pressed = @inputstate.is_touch_just_pressed(
      self.input.touch_state,
      touch.id,
    )
    down = true
  }
  let cx = self.cursor_x
  let cy = self.cursor_y
  let escape = @inputstate.is_key_just_pressed(keys, 27) ||
    @inputstate.is_key_just_pressed(keys, 256) ||
    @inputstate.is_mouse_button_just_pressed(mouse, 1) ||
    @inputstate.is_mouse_button_just_pressed(mouse, 2)
  if escape {
    self.cancel_card()
    self.deck_open = false
    self.hint = "CANCELLED"
    return
  }
  if @inputstate.is_key_just_pressed(keys, 68) ||
    (pressed && deck_button_rect(self.layout).contains(cx, cy)) {
    self.deck_open = !self.deck_open
    self.deck_page = 0
    self.cancel_card()
    return
  }
  if self.deck_open {
    if pressed && self.layout.continue_rect().contains(cx, cy) {
      self.deck_open = false
    }
    if @inputstate.is_key_just_pressed(keys, 39) ||
      @inputstate.is_key_just_pressed(keys, 262) {
      self.deck_page = (self.deck_page + 1) % deck_page_count(self.run.get())
    }
    if pressed && deck_next_rect(self.layout).contains(cx, cy) {
      self.deck_page = (self.deck_page + 1) % deck_page_count(self.run.get())
    }
    return
  }
  let confirm = @inpututil.is_confirm_just_pressed(self.input)
  let run = self.run.get()
  match run.phase {
    RunVictory | RunDefeat =>
      if confirm || (pressed && self.layout.continue_rect().contains(cx, cy)) {
        self.run.set(RunState::new(seed=run.rng_seed + 1))
        self.cancel_card()
        self.hint = "DRAG A CARD TO PLAY"
      }
    RestSite =>
      if confirm || (pressed && self.layout.continue_rect().contains(cx, cy)) {
        rest_heal(run)
        self.run.set(run)
        self.cancel_card()
        self.hint = "RESTORED AND READY"
      }
    CardReward => {
      let mut choice = -2
      for i = 0; i < run.card_rewards.length(); i = i + 1 {
        if (
            pressed &&
            self.layout
            .reward_rect(i, run.card_rewards.length())
            .contains(cx, cy)
          ) ||
          @inputstate.is_key_just_pressed(keys, 49 + i) {
          choice = i
        }
      }
      if (pressed && self.layout.continue_rect().contains(cx, cy)) ||
        @inputstate.is_key_just_pressed(keys, 83) {
        choice = -1
      }
      if choice >= -1 {
        pick_card_reward(run, choice)
        self.run.set(run)
        self.cancel_card()
        self.hint = "DRAG A CARD TO PLAY"
      }
    }
    Battle =>
      match run.battle {
        None => ()
        Some(state) =>
          match state.phase {
            Victory | Defeat =>
              if confirm ||
                (pressed && self.layout.continue_rect().contains(cx, cy)) {
                if state.phase == Victory {
                  on_battle_victory(run)
                } else {
                  on_battle_defeat(run)
                }
                self.run.set(run)
                self.cancel_card()
              }
            EnemyTurn => self.cancel_card()
            PlayerTurn => {
              if @inputstate.is_key_just_pressed(keys, 69) ||
                (
                  pressed &&
                  self.layout.end_turn_rect().contains(cx, cy) &&
                  self.gesture is None
                ) {
                self.cancel_card()
                end_player_turn(state)
                self.run.set(run)
                self.hint = "NEW TURN"
                return
              }
              for i = 0; i < ui_min(state.hand.length(), 9); i = i + 1 {
                if @inputstate.is_key_just_pressed(keys, 49 + i) {
                  self.cancel_card()
                  self.select_card(state, i)
                }
              }
              if self.need_target &&
                (
                  @inputstate.is_key_just_pressed(keys, 39) ||
                  @inputstate.is_key_just_pressed(keys, 37) ||
                  @inputstate.is_key_just_pressed(keys, 262) ||
                  @inputstate.is_key_just_pressed(keys, 263)
                ) {
                let direction = if @inputstate.is_key_just_pressed(keys, 37) ||
                  @inputstate.is_key_just_pressed(keys, 263) {
                  -1
                } else {
                  1
                }
                for step = 1; step <= state.enemies.length(); step = step + 1 {
                  let idx = (
                      self.target_enemy.get() +
                      direction * step +
                      state.enemies.length()
                    ) %
                    state.enemies.length()
                  if !state.enemies[idx].fighter.is_dead() {
                    self.target_enemy.set(idx)
                    break
                  }
                }
              }
              if confirm && can_play_card(state, self.selected_card.get()) {
                self.commit_card(
                  state,
                  self.selected_card.get(),
                  self.target_enemy.get(),
                )
                return
              }
              if pressed {
                if self.need_target {
                  let target = hit_enemy(self.layout, state, cx, cy)
                  if target >= 0 {
                    self.commit_card(state, self.selected_card.get(), target)
                    return
                  }
                }
                let index = hit_card(self.layout, state.hand.length(), cx, cy)
                if index >= 0 {
                  self.cancel_card()
                  self.select_card(state, index)
                  if can_play_card(state, index) {
                    self.gesture = Some({
                      index,
                      start_x: cx,
                      start_y: cy,
                      touch_id,
                      dragged: false,
                    })
                    self.hint = if self.need_target {
                      "DROP ON AN ENEMY"
                    } else {
                      "DROP ON THE BATTLEFIELD"
                    }
                  }
                } else {
                  self.cancel_card()
                }
              }
              if self.gesture is Some(g) {
                let dx = cx - g.start_x
                let dy = cy - g.start_y
                if dx * dx + dy * dy >= 64.0 {
                  g.dragged = true
                }
                if g.dragged && down {
                  self.target_enemy.set(hit_enemy(self.layout, state, cx, cy))
                }
                if released {
                  if g.dragged {
                    let target = if card_needs_target(state.hand[g.index]) {
                      hit_enemy(self.layout, state, cx, cy)
                    } else if self.layout.play_area().contains(cx, cy) {
                      0
                    } else {
                      -1
                    }
                    if target >= 0 {
                      self.commit_card(state, g.index, target)
                    } else {
                      self.cancel_card()
                      self.hint = "CANCELLED - CARD RETURNED"
                    }
                  } else {
                    self.gesture = None
                    if !self.need_target || alive_enemy_count(state) == 1 {
                      self.commit_card(state, g.index, first_alive_enemy(state))
                    }
                  }
                }
              }
            }
          }
      }
  }
}

///|
fn deck_next_rect(layout : GameLayout) -> UiRect {
  { x: layout.w / 2.0 - 70.0, y: layout.h - 130.0, w: 140.0, h: 40.0, }
}
