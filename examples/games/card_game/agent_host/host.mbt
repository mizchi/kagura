///|
pub fn create(seed : Int) -> @lib.AgentSession {
  @lib.AgentSession::new(seed~)
}

///|
pub fn create_run(
  seed : Int,
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
  revision : Int,
  choice_id : String,
) -> String {
  match session.step(revision, choice_id) {
    @lib.Applied => "applied"
    @lib.StaleRevision => "stale_revision"
    @lib.IllegalChoice => "illegal_choice"
    @lib.Terminal => "terminal"
  }
}
