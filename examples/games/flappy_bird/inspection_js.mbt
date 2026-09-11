///|
/// Included only in debug builds by moon.pkg.
/// Runtime::register is not automatically stripped: its caller in scene_js.mbt
/// and the bindings/debug state are also excluded from release by moon.pkg.
fn Game::setup_inspection(self : Game) -> Unit {
  @inspection.Runtime::new(
    game="flappy_bird",
    schema="flappy_bird.runtime",
    inspector=debug_inspector(),
    read=() => {
      revision: self._inspection.revision,
      paused: self._inspection.paused,
      state: self.debug_state(),
    },
    pause=paused => self.debug_pause(paused),
    step=() => self.debug_step(),
    replace=state => self.debug_replace(state),
  ).register(scene=() => self.scene_snapshot(), hierarchy=() => {
    self.scene_hierarchy()
  }) catch {
    error => abort(error.to_string())
  }
}

///|
fn Game::scene_snapshot(self : Game) -> String {
  let result : Json = {
    "layout": self.layout.to_json(),
    "birdY": self.bird_y.get().to_json(),
    "mode": self.game_mode.get().to_json(),
  }
  result.stringify()
}
