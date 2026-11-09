///|
fn register_inspection(a : App) -> Unit {
  a.inspection.register_fields(
    game="emberwing",
    scope=() => a.inspection.scope("emberwing"),
    subjects=() => a.game.tuning_subjects(),
    state=() => a.game.tuning_state(),
    pause=value => {
      if value {
        @sim.command(a.game, "pause")
      } else if a.game.mode == "paused" {
        @sim.command(a.game, "resume")
      }
      a.inspection.set_paused(value)
      a.input = @sim.idle_input()
      a.accumulator = 0.0
      a.previous = now()
    },
    edit=(subject, field, value) => a.game.apply_tuning(subject, field, value),
  )
}
