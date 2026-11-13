///|
fn scene_mode_id(mode : Mode) -> String {
  match mode {
    Town => "town"
    Exploring => "explore"
    Fighting => "battle"
    Looting => "chest"
    Warning => "warning"
    Cleared => "cleared"
  }
}
///|
pub fn Game::transition_mode(self : Game, target : Mode) -> Unit raise {
  if self.mode == target { return }
  @flow.check(scene_mode_id(self.mode), scene_mode_id(target))
  self.mode = target
}
///|
fn Game::set_mode(self : Game, target : Mode) -> Unit {
  self.transition_mode(target) catch { error => abort(error.to_string()) }
}
