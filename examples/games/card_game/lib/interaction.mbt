///|
let enemy_drag_id_base : Int = 1000

///|
let battlefield_drag_id : Int = 2000

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
  drag : @ui.UIDragController
  mut hint : String
  mut deck_open : Bool
  mut deck_page : Int
  mut presentation : Presentation?
  mut last_frame_ms : Double?
  mut reduced_motion : Bool
}

///|
pub impl @scene.SceneGame for Game with fn update_game(self, input) {
  if prefers_reduced_motion() is Some(reduced) {
    self.reduced_motion = reduced
  }
  self.update(self.surface_input(input), elapsed_ms=self.frame_delta())
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
    drag: @ui.UIDragController::new(),
    hint: "DRAG A CARD TO PLAY",
    deck_open: false,
    deck_page: 0,
    presentation: None,
    last_frame_ms: None,
    reduced_motion: false,
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
  if self.presentation_state() is Some(state) {
    return state
  }
  if self.deck_open {
    return "deck"
  }
  if self.drag.snapshot() is Some({ dragging: true, .. }) {
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
  let _ = self.drag.cancel()
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
  let before = CombatFeedback::capture(state)
  let flight = if index >= 0 && index < state.hand.length() {
    Some({
      card: state.hand[index],
      slot: index,
      hand_count: state.hand.length(),
    })
  } else {
    None
  }
  let result = play_card(state, index, target)
  self.hint = match result {
    Ok => "CARD PLAYED"
    NotEnoughEnergy => "NOT ENOUGH ENERGY"
    InvalidTarget => "CHOOSE A LIVING ENEMY"
    _ => "CANNOT PLAY THIS CARD"
  }
  self.cancel_card()
  if result == Ok && flight is Some(flight) {
    self.present(CardPlay(flight, before))
  }
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
pub fn Game::update(
  self : Game,
  input : @core.InputSnapshot,
  elapsed_ms? : Double = 1000.0 / 60.0,
) -> Unit {
  @inpututil.update_input_helper(self.input, input)
  let events = self.drag.update(
    input,
    source_at=fn(x, y) { self.drag_source_at(x, y) },
    target_at=fn(source, x, y) { self.drag_target_at(source, x, y) },
    enabled=self.presentation is None && !self.deck_open,
  )
  let pointer = self.drag.pointer()
  if pointer.x != -1.0 || pointer.y != -1.0 {
    self.cursor_x = pointer.x
    self.cursor_y = pointer.y
  }
  // Both input helpers consume edges while presentation locks gameplay.
  if self.advance_presentation(elapsed_ms) {
    return
  }
  let keys = self.input.key_state
  let mouse = self.input.mouse_state
  let pressed = pointer.pressed
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
        self.travel(Restart(run.rng_seed + 1))
      }
    RestSite =>
      if confirm || (pressed && self.layout.continue_rect().contains(cx, cy)) {
        self.travel(Rest)
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
        self.travel(ChooseReward(choice))
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
                self.travel(ContinueBattle)
              }
            EnemyTurn => self.cancel_card()
            PlayerTurn => {
              if @inputstate.is_key_just_pressed(keys, 69) ||
                (
                  pressed &&
                  self.layout.end_turn_rect().contains(cx, cy) &&
                  self.drag.snapshot() is None
                ) {
                self.cancel_card()
                begin_enemy_turn(state)
                self.present(EnemyNotice)
                self.run.set(run)
                self.hint = "ENEMY TURN"
                return
              }
              let mut keyboard_selected = false
              for i = 0; i < ui_min(state.hand.length(), 9); i = i + 1 {
                if @inputstate.is_key_just_pressed(keys, 49 + i) {
                  self.cancel_card()
                  self.select_card(state, i)
                  keyboard_selected = true
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
              if keyboard_selected {
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
                  self.select_card(state, index)
                  if can_play_card(state, index) {
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
              for event in events {
                match event {
                  @ui.UIEvent::Click(source) =>
                    if source.value == self.selected_card.get() &&
                      (!self.need_target || alive_enemy_count(state) == 1) {
                      self.commit_card(
                        state,
                        source.value,
                        first_alive_enemy(state),
                      )
                      return
                    }
                  @ui.UIEvent::Drag(drag) =>
                    match drag.phase {
                      @ui.UIDragPhase::Start | Move | Enter =>
                        self.target_enemy.set(
                          match drag.target {
                            Some(id) =>
                              if id.value >= enemy_drag_id_base &&
                                id.value < battlefield_drag_id {
                                id.value - enemy_drag_id_base
                              } else {
                                -1
                              }
                            None => -1
                          },
                        )
                      Leave => self.target_enemy.set(-1)
                      Drop =>
                        if drag.source.value == self.selected_card.get() &&
                          drag.target is Some(id) {
                          self.commit_card(
                            state,
                            drag.source.value,
                            if id.value == battlefield_drag_id {
                              0
                            } else {
                              id.value - enemy_drag_id_base
                            },
                          )
                          return
                        }
                      Cancel(_) => {
                        self.cancel_card()
                        self.hint = "CANCELLED - CARD RETURNED"
                      }
                      End(_) => ()
                    }
                  _ => ()
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

///|
fn Game::drag_source_at(self : Game, x : Double, y : Double) -> @ui.UINodeId? {
  let run = self.run.get()
  if run.phase != Battle {
    return None
  }
  guard run.battle is Some(state) else { return None }
  if state.phase != PlayerTurn {
    return None
  }
  let index = hit_card(self.layout, state.hand.length(), x, y)
  if can_play_card(state, index) {
    Some(@ui.UINodeId::new(index))
  } else {
    None
  }
}

///|
/// The shared UI handles gestures; acceptance and identities are game policy.
fn Game::drag_target_at(
  self : Game,
  source : @ui.UINodeId,
  x : Double,
  y : Double,
) -> @ui.UINodeId? {
  guard self.run.get().battle is Some(state) else { return None }
  if !can_play_card(state, source.value) {
    return None
  }
  if card_needs_target(state.hand[source.value]) {
    let enemy = hit_enemy(self.layout, state, x, y)
    if enemy >= 0 {
      Some(@ui.UINodeId::new(enemy_drag_id_base + enemy))
    } else {
      None
    }
  } else if self.layout.play_area().contains(x, y) {
    Some(@ui.UINodeId::new(battlefield_drag_id))
  } else {
    None
  }
}
