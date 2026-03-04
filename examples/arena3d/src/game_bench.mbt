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
test "bench arena3d build_scene_graph" (b : @bench.T) {
  let state = GameState::new()
  state.mode = mode_playing
  b.bench(name="arena3d/build_scene_graph", fn() {
    let graph = state.build_scene_graph()
    b.keep(graph.roots.length())
  })
}

///|
test "bench arena3d render_scene3d_graph_gpu" (b : @bench.T) {
  let state = GameState::new()
  state.mode = mode_playing
  let dst = @gfx.new_image_handle(1, screen_w, screen_h)
  b.bench(name="arena3d/render_scene3d_graph_gpu", fn() {
    let graph = state.build_scene_graph()
    let cmds = @scene3d.render_scene3d_graph_gpu(
      graph,
      state.camera.to_camera3d(),
      lighting=state.lighting,
      dst,
      state.shader3d,
      screen_w,
      screen_h,
    )
    b.keep(cmds.length())
  })
}
