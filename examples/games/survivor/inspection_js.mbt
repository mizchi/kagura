///|
fn SurvivorState::register_inspection(self : SurvivorState) -> Unit {
  self.inspection.register_fields(
    game="survivor",
    scope=() => self.inspection.scope("survivor"),
    subjects=() => self.tuning_subjects(),
    state=() => self.tuning_state(),
    pause=value => self.set_inspection_paused(value),
    edit=(subject, field, value) => self.apply_tuning(subject, field, value),
  )
}
