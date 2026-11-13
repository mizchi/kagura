///|
/// All normal mode changes use the same declaration exported to Studio.
pub fn Game::transition_mode(self : Game, target : String) -> Unit raise {
  if self.mode == target { return }
  @flow.check(self.mode, target)
  self.mode = target
}
///|
pub fn Game::set_mode(self : Game, target : String) -> Unit {
  self.transition_mode(target) catch { error => abort(error.to_string()) }
}
