///|
fn scene_mode_id(mode : GameMode) -> String {
  match mode {
    Title => "title"
    CharacterSelect => "character_select"
    Playing => "playing"
    GameOver => "gameover"
  }
}
///|
pub fn GameWorld::transition_mode(self : GameWorld, target : GameMode) -> Unit raise {
  if self.mode == target { return }
  @flow.check(scene_mode_id(self.mode), scene_mode_id(target))
  self.mode = target
}
///|
pub fn GameWorld::set_mode(self : GameWorld, target : GameMode) -> Unit {
  self.transition_mode(target) catch { error => abort(error.to_string()) }
}
