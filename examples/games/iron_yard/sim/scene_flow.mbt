///|
/// All normal mode changes use the same declaration exported to Studio.
pub fn Game::transition_phase(self : Game, target : String) -> Unit raise {
  if self.phase == target { return }
  @flow.check(self.phase, target)
  self.phase = target
}
///|
pub fn Game::set_phase(self : Game, target : String) -> Unit {
  self.transition_phase(target) catch { error => abort(error.to_string()) }
}
