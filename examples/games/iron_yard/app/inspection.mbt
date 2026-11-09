///|
pub fn register_inspection() -> Unit {
  guard app.val is Some(a) else { return }
  a.inspection.register_fields(
    game="iron_yard",
    scope=() => a.inspection.scope("iron_yard"),
    subjects=() => a.game.tuning_subjects(),
    state=() => {
      @json.parse(@sim.snapshot(a.game)) catch {
        error => abort(error.to_string())
      }
    },
    pause=value => {
      if value {
        a.inspection_resume = a.game.phase == "playing" ||
          a.game.phase == "paused"
        @sim.pause(a.game)
        pause_audio()
      } else if a.inspection_resume {
        @sim.start_playing(a.game)
      }
      a.inspection.set_paused(value)
      a.input = @sim.input(yaw=a.game.pilot.yaw, pitch=a.game.pilot.pitch)
      a.previous = now()
    },
    edit=(subject, field, value) => a.game.apply_tuning(subject, field, value),
  )
}
