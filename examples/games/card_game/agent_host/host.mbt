///|
pub fn create(seed : Int32) -> @lib.AgentSession {
  @lib.AgentSession::new(seed~)
}

///|
pub fn balance_trial(
  seed : Int32,
  policy : String,
  hp_scale : Double,
  player_hp : Int32,
) -> String {
  let strategy = match policy {
    "smart" => @lib.Smart
    "aggressive" => @lib.Aggressive
    "defensive" => @lib.Defensive
    _ => return "{}"
  }
  let result = @lib.simulate_tuned_battle(
    @lib.FungiPair,
    strategy,
    seed,
    hp_scale,
    player_hp,
  ) catch {
    _ => return "{}"
  }
  let data : Json = {
    "status": if result.won {
      "victory"
    } else if result.hp_remaining <= 0 {
      "defeat"
    } else {
      "limit"
    },
    "metrics": {
      "hpRemaining": result.hp_remaining.to_double() / result.max_hp.to_double(),
      "turns": result.turns_taken,
      "cardsPlayed": result.cards_played,
    },
  }
  data.stringify()
}

///|
pub fn create_run(
  seed : Int32,
  character : String,
  stage : String,
) -> @lib.AgentSession? {
  let character = match character {
    "ironclad" => @lib.Ironclad
    "warden" => @lib.Warden
    _ => return None
  }
  let stage = match stage {
    "ascent" => @lib.Ascent
    "act_two" => @lib.ActTwo
    "guardian_trial" => @lib.GuardianTrial
    _ => return None
  }
  Some(@lib.AgentSession::start(character, stage, seed~))
}

///|
pub fn observe(session : @lib.AgentSession) -> String {
  session.observe().stringify()
}

///|
pub fn step(
  session : @lib.AgentSession,
  revision : Int32,
  choice_id : String,
) -> String {
  match session.step(revision, choice_id) {
    @lib.Applied => "applied"
    @lib.StaleRevision => "stale_revision"
    @lib.IllegalChoice => "illegal_choice"
    @lib.Terminal => "terminal"
  }
}
