///|
/// Release bypasses inspection. @inspection.Control is Unit in this profile;
/// pkg.generated.mbti shows its debug struct, not this release representation.
/// @scene.subject is identity and rect/group do not add inspection key/name attrs.
/// Registration/bindings must also be excluded in moon.pkg. The Flappy artifact
/// gate verifies JS/C removal; it is not a guarantee for other games or Wasm output.
fn Game::resolved_view(self : Game) -> @scene.SceneNode {
  self.view()
}

///|
fn Game::update(self : Game, input : @core.InputSnapshot) -> Unit {
  self.update_tick(input)
}
