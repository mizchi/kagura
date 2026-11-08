///|
/// Semantic actions are independent of pixels, input devices and presentation.
#derive(Eq)
pub(all) enum AgentAction {
  Begin
  ChooseCharacter(CharacterId)
  PlayCard(Int32, Int32)
  UsePotion(Int32, Int32)
  EndTurn
  ContinueBattle
  ChooseReward(Int32)
  SkipReward
  Rest
  Explore(RunChoiceAction)
}

///|
pub struct AgentChoice {
  id : String
  label : String
  action : AgentAction
}

///|
#derive(Debug, Eq)
pub(all) enum AgentStepResult {
  Applied
  StaleRevision
  IllegalChoice
  Terminal
}

///|
/// Only this owner can mutate a run. Observations and choices are detached values.
pub struct AgentSession {
  priv mut scene : AppScene
  priv seed : Int32
  priv mut run : RunState?
  priv mut revision : Int32
}

///|
pub extend AgentAction with Eq::{equal, not_equal}

///|
pub extend AgentStepResult with Eq::{equal, not_equal}

///|
pub extend AgentStepResult with @moonbitlang/core/debug.Debug::{to_repr}
