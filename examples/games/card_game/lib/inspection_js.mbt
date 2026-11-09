///|
pub fn Game::register_inspection(self : Game) -> Unit {
  self.inspection.register_fields(
    game="card_game",
    scope=() => self.tuning_scope(),
    subjects=() => self.tuning_subjects(),
    state=() => self.tuning_state(),
    pause=value => self.set_inspection_paused(value),
    edit=(subject, field, value) => self.apply_tuning(subject, field, value),
  )
}
