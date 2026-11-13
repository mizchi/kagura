///|
fn scene_mode_id(mode : Int) -> String {
  match mode {
    0 => "title"
    1 => "playing"
    2 => "levelup"
    3 => "gameover"
    _ => "invalid"
  }
}
///|
fn SurvivorState::transition_mode(self : SurvivorState, target : Int) -> Unit raise {
  if self.game_mode == target { return }
  @flow.check(scene_mode_id(self.game_mode), scene_mode_id(target))
  self.game_mode = target
}
///|
fn SurvivorState::set_mode(self : SurvivorState, target : Int) -> Unit {
  self.transition_mode(target) catch { error => abort(error.to_string()) }
}
