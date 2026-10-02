///|
/// Presentation captures values, never references to mutable fighters.
priv struct FighterFrame {
  hp : Int
  block : Int
  strength : Int
}

///|
fn FighterFrame::capture(fighter : Fighter) -> FighterFrame {
  { hp: fighter.hp, block: fighter.block, strength: fighter.status.strength, }
}

///|
priv struct CombatFeedback {
  player : FighterFrame
  enemies : Array[FighterFrame]
  intents : Array[Intent]
}

///|
fn CombatFeedback::capture(state : BattleState) -> CombatFeedback {
  {
    player: FighterFrame::capture(state.player),
    enemies: state.enemies.map(e => FighterFrame::capture(e.fighter)),
    intents: state.enemies.map(e => e.intent),
  }
}

///|
priv struct CardFlight {
  card : CardId
  slot : Int
  hand_count : Int
}

///|
priv enum ScreenAction {
  ChooseReward(Int)
  Rest
  ContinueBattle
  Restart(Int)
}

///|
priv enum PresentationStep {
  CardPlay(CardFlight, CombatFeedback)
  EnemyNotice
  EnemyWindup(Int)
  EnemyImpact(Int, CombatFeedback)
  DrawHand
  BattleOutcome(Array[Int])
  Travel(ScreenAction)
}

///|
struct Presentation {
  step : PresentationStep
  mut elapsed_ms : Double
  mut switched : Bool
}

///|
fn Presentation::new(step : PresentationStep) -> Presentation {
  { step, elapsed_ms: 0.0, switched: false, }
}

///|
fn Presentation::duration(self : Presentation) -> Double {
  match self.step {
    CardPlay(_, _) => 360.0
    EnemyNotice => 320.0
    EnemyWindup(_) => 240.0
    EnemyImpact(_, _) => 360.0
    DrawHand => 380.0
    BattleOutcome(_) => 650.0
    Travel(_) => 400.0
  }
}

///|
fn Presentation::progress(self : Presentation) -> Double {
  ui_min(1.0, self.elapsed_ms / self.duration())
}

///|
fn Game::present(self : Game, step : PresentationStep) -> Unit {
  self.presentation = Some(Presentation::new(step))
  self.cancel_card()
}

///|
fn Game::travel(self : Game, action : ScreenAction) -> Unit {
  self.present(Travel(action))
}

///|
fn Game::apply_screen_action(self : Game, action : ScreenAction) -> Unit {
  let run = self.run.get()
  match action {
    ChooseReward(index) => pick_card_reward(run, index)
    Rest => rest_heal(run)
    ContinueBattle =>
      match run.battle {
        Some({ phase: Victory, .. }) => on_battle_victory(run)
        Some({ phase: Defeat, .. }) => on_battle_defeat(run)
        _ => ()
      }
    Restart(seed) => self.run.set(RunState::new(seed~))
  }
  self.run.set(self.run.get())
  self.hint = "DRAG A CARD TO PLAY"
}

///|
fn next_living_enemy(state : BattleState, from : Int) -> Int {
  for i = from; i < state.enemies.length(); i = i + 1 {
    if !state.enemies[i].fighter.is_dead() {
      return i
    }
  }
  -1
}

///|
fn Game::present_enemy(self : Game, state : BattleState, from : Int) -> Unit {
  if state.phase == Defeat {
    self.present(BattleOutcome([]))
    return
  }
  let index = next_living_enemy(state, from)
  if index >= 0 {
    self.present(EnemyWindup(index))
    self.hint = state.enemies[index].fighter.name.to_upper() + " ACTS"
  } else {
    finish_enemy_turn(state)
    self.present(DrawHand)
    self.hint = "YOUR TURN"
  }
}

///|
/// A non-blocking timeline. One stage completes per update so background-tab
/// delays cannot collapse a whole enemy turn into a single invisible frame.
fn Game::advance_presentation(self : Game, elapsed_ms : Double) -> Bool {
  guard self.presentation is Some(p) else { return false }
  p.elapsed_ms += ui_max(0.0, ui_min(50.0, elapsed_ms))
  if p.step is Travel(action) && !p.switched && p.progress() >= 0.5 {
    p.switched = true
    self.apply_screen_action(action)
  }
  if p.elapsed_ms < p.duration() {
    return true
  }
  self.presentation = None
  match p.step {
    Travel(_) => ()
    _ =>
      match self.run.get().battle {
        None => ()
        Some(state) =>
          match p.step {
            CardPlay(_, before) =>
              if state.phase == Victory || state.phase == Defeat {
                let defeated : Array[Int] = []
                for i in 0..<state.enemies.length() {
                  if before.enemies[i].hp > 0 &&
                    state.enemies[i].fighter.is_dead() {
                    defeated.push(i)
                  }
                }
                self.present(BattleOutcome(defeated))
              } else {
                self.hint = "DRAG A CARD TO PLAY"
              }
            EnemyNotice => self.present_enemy(state, 0)
            EnemyWindup(index) => {
              let before = CombatFeedback::capture(state)
              execute_enemy_action(state, index)
              self.present(EnemyImpact(index, before))
            }
            EnemyImpact(index, _) => self.present_enemy(state, index + 1)
            DrawHand => self.hint = "DRAG A CARD TO PLAY"
            BattleOutcome(_) | Travel(_) => ()
          }
      }
  }
  self.run.set(self.run.get())
  true
}

///|
fn Game::feedback(self : Game) -> CombatFeedback? {
  match self.presentation {
    Some({ step: CardPlay(_, feedback) | EnemyImpact(_, feedback), .. }) =>
      Some(feedback)
    _ => None
  }
}

///|
fn Game::keep_battlefield(self : Game) -> Bool {
  match self.presentation {
    Some({ step: CardPlay(_, _) | EnemyImpact(_, _) | BattleOutcome(_), .. }) =>
      true
    _ => false
  }
}

///|
fn Game::effect_progress(self : Game) -> Double {
  match self.presentation {
    Some(p) =>
      match p.step {
        CardPlay(_, _) => ui_max(0.0, (p.elapsed_ms - 100.0) / 260.0)
        EnemyImpact(_, _) => p.progress()
        _ => 1.0
      }
    None => 1.0
  }
}

///|
fn Game::shown_hp(self : Game, fighter : Fighter, index : Int) -> Int {
  if self.reduced_motion {
    return fighter.hp
  }
  guard self.feedback() is Some(before) else { return fighter.hp }
  let hp = if index < 0 { before.player.hp } else { before.enemies[index].hp }
  let t = ui_min(1.0, self.effect_progress() * 2.0)
  (hp.to_double() + (fighter.hp - hp).to_double() * t).round().to_int()
}

///|
fn Game::presentation_state(self : Game) -> String? {
  match self.presentation {
    None => None
    Some({ step, .. }) =>
      Some(
        match step {
          CardPlay(_, _) => "card_play"
          EnemyNotice | EnemyWindup(_) | EnemyImpact(_, _) => "enemy_turn"
          DrawHand => "draw_hand"
          BattleOutcome(_) => "battle_outcome"
          Travel(_) => "transition"
        },
      )
  }
}

///|
/// Optional host time: headless captures and direct update calls use 60 Hz.
fn Game::frame_delta(self : Game) -> Double {
  let now = presentation_clock_ms()
  let dt = match (self.last_frame_ms, now) {
    (Some(previous), Some(current)) => current - previous
    _ => 1000.0 / 60.0
  }
  self.last_frame_ms = now
  dt
}

///|
pub fn Game::set_reduced_motion(self : Game, reduced : Bool) -> Unit {
  self.reduced_motion = reduced
}
