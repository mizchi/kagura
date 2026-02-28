///|
test "bench arena3d update" (b : @bench.T) {
  let state = GameState::new()
  state.mode = mode_playing
  let input = @core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [])
  b.bench(name="arena3d/update", fn() {
    state.update(input)
    b.keep(state.frame_count)
  })
}

///|
test "bench arena3d build_scene3d" (b : @bench.T) {
  let state = GameState::new()
  state.mode = mode_playing
  b.bench(name="arena3d/build_scene3d", fn() {
    let scene = state.build_scene3d()
    b.keep(scene.objects.length())
  })
}

///|
test "bench arena3d render_scene3d" (b : @bench.T) {
  let state = GameState::new()
  state.mode = mode_playing
  let dst = @gfx.new_image_handle(1, screen_w, screen_h)
  let shader = @gfx.new_shader_handle(1, "test")
  b.bench(name="arena3d/render_scene3d", fn() {
    let scene = state.build_scene3d()
    let cmds = @scene3d.render_scene3d(scene, dst, shader, screen_w, screen_h)
    b.keep(cmds.length())
  })
}
