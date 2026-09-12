///|
impl @scene.SceneGame for ShowcaseState with fn update_game(self, input) {
  self.update(input)
}

///|
impl @scene.SceneGame for ShowcaseState with fn view_game(self) {
  self.view()
}

///|
fn main {
  let state = initial_states().create_for_capture(
    width=screen_w.to_int(),
    height=screen_h.to_int(),
  )
  @scene.run_game(
    state,
    on_frame=fn(cmds, dst, shader, sw, sh) {
      state.render_text_hud(cmds, dst, shader, sw, sh)
    },
    width=screen_w.to_int(),
    height=screen_h.to_int(),
    title="Action RPG",
    canvas="#app",
    snapshot_state=fn() { state.snapshot_state() },
    apply_viewport=fn(width, height) { state.set_viewport(width, height) },
  )
}
