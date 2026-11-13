///|
pub let simulation_hz : Int32 = 60

///|
pub let simulation_step_ms : Double = 1000.0 / simulation_hz.to_double()

///|
// Design references for a prepared simple visual response, not population bounds.
// See README for sources; choice and device allowances below are tuning values.
pub let visual_reaction_fast_ms : Int32 = 180

///|
pub let visual_reaction_ms : Int32 = 250

///|
pub(all) struct ReactionBudget {
  visual_ms : Int32
  decision_ms : Int32
  device_ms : Int32
  comfort_ms : Int32
}

///|
pub let default_reaction_budget : ReactionBudget = {
  visual_ms: visual_reaction_ms,
  decision_ms: 150,
  device_ms: 50,
  comfort_ms: 50,
}

///|
// Execution and pacing reserves are independent of the human visual reference.
pub let escape_execution_ms : Int32 = 300

///|
pub let telegraph_margin_ms : Int32 = 200

///|
pub let reposition_allowance_ms : Int32 = 500

///|
pub let counter_execution_ms : Int32 = 500

///|
pub let shield_extra_windup_ms : Int32 = 200

///|
pub let boss_extra_windup_ms : Int32 = 400

///|
pub let boss_extra_recovery_ms : Int32 = 300

///|
/// Round up to complete simulation ticks. Splitting whole seconds avoids
/// overflowing Int32 even at the largest millisecond input; nonpositive is zero.
pub fn frames_from_ms(milliseconds : Int32) -> Int32 {
  let ms = milliseconds.max(0)
  ms / 1000 * simulation_hz + (ms % 1000 * simulation_hz + 999) / 1000
}

///|
pub fn ReactionBudget::response_ms(self : ReactionBudget) -> Int32 {
  self.visual_ms + self.decision_ms + self.device_ms + self.comfort_ms
}

///|
pub fn ReactionBudget::response_frames(self : ReactionBudget) -> Int32 {
  frames_from_ms(self.response_ms())
}

///|
pub fn ReactionBudget::windup_frames(self : ReactionBudget) -> Int32 {
  frames_from_ms(self.response_ms() + escape_execution_ms + telegraph_margin_ms)
}

///|
pub fn ReactionBudget::counter_frames(self : ReactionBudget) -> Int32 {
  frames_from_ms(
    self.response_ms() + reposition_allowance_ms + counter_execution_ms,
  )
}

///|
pub fn ReactionBudget::spacing_frames(self : ReactionBudget) -> Int32 {
  frames_from_ms(self.visual_ms + self.decision_ms)
}

///|
pub fn ReactionBudget::guard_reset_frames(self : ReactionBudget) -> Int32 {
  frames_from_ms(self.response_ms() + escape_execution_ms)
}
