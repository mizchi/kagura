///|
fn scene_mode_id(mode : Int) -> String {
  match mode {
    0 => "title"
    1 => "playing"
    2 => "gameover"
    _ => "invalid"
  }
}
///|
fn Game::transition_mode(self : Game, target : Int) -> Unit raise {
  if self.game_mode.get() == target { return }
  @flow.check(scene_mode_id(self.game_mode.get()), scene_mode_id(target))
  self.game_mode.set(target)
}
///|
fn Game::set_mode(self : Game, target : Int) -> Unit {
  self.transition_mode(target) catch { error => abort(error.to_string()) }
}
