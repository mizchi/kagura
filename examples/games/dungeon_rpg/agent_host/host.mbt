///|
pub fn create(seed : Int32) -> @sim.AgentSession {
  @sim.AgentSession::new(seed~)
}

///|
pub fn create_configured(seed : Int32, balance : String) -> @sim.AgentSession {
  let session = @sim.AgentSession::new(seed~)
  session.game.configure_balance(balance) catch {
    _ => abort("invalid_balance")
  }
  session
}

///|
pub fn create_full(
  seed : Int32,
  balance : String,
  master : String,
) -> @sim.AgentSession {
  let session = @sim.AgentSession::new(seed~)
  session.game.configure_master_data(master) catch {
    _ => abort("invalid_master_data")
  }
  session.game.configure_balance(balance) catch {
    _ => abort("invalid_balance")
  }
  session
}

///|
pub fn master(session : @sim.AgentSession) -> String {
  session.game.master_data_source()
}

///|
pub fn observe(session : @sim.AgentSession) -> String {
  session.observe().stringify()
}

///|
/// Evaluation-only display receipts, kept out of the agent's decision input.
pub fn feedback(session : @sim.AgentSession) -> String {
  session.game.snapshot()
}

///|
pub fn experience(session : @sim.AgentSession, after : Int32) -> String {
  session.game.experience_events(after).stringify()
}

///|
pub fn step(
  session : @sim.AgentSession,
  revision : Int32,
  choice_id : String,
) -> String {
  try {
    session.step(revision, choice_id)
    "applied"
  } catch {
    e => e.to_string()
  }
}
