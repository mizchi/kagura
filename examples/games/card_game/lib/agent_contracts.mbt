///|
/// Semantic actions are independent of pixels, input devices and presentation.
pub(all) enum AgentAction {
  Begin
  ChooseCharacter(CharacterId)
  PlayCard(Int, Int)
  UsePotion(Int, Int)
  EndTurn
  ContinueBattle
  ChooseReward(Int)
  SkipReward
  Rest
  Explore(RunChoiceAction)
} derive(Eq)

///|
pub struct AgentChoice {
  id : String
  label : String
  action : AgentAction
}

///|
pub(all) enum AgentStepResult {
  Applied
  StaleRevision
  IllegalChoice
  Terminal
} derive(Debug, Eq)

///|
/// Only this owner can mutate a run. Observations and choices are detached values.
pub struct AgentSession {
  priv mut scene : AppScene
  priv seed : Int
  priv mut run : RunState?
  priv mut revision : Int
}

///|
pub extend AgentAction with Eq::{equal, not_equal}

///|
pub extend AgentStepResult with Eq::{equal, not_equal}

///|
pub extend AgentStepResult with @moonbitlang/core/debug.Debug::{to_repr}
