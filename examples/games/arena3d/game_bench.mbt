///|
test "bench arena3d update" (b : @bench.T) {
  let state = GameState::new()
  state.load_default_scene()
  for enemy in state.enemies {
    enemy.active = false
  }
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
  state.load_default_scene()
  for enemy in state.enemies {
    enemy.active = false
  }
  state.mode = mode_playing
  b.bench(name="arena3d/build_scene_graph", fn() {
    let graph = state.build_scene_graph()
    b.keep(graph.roots.length())
  })
}

///|
test "bench arena3d renderer3d graph facade" (b : @bench.T) {
  let state = GameState::new()
  state.load_default_scene()
  for enemy in state.enemies {
    enemy.active = false
  }
  state.mode = mode_playing
  let dst = @gfx.new_image_handle(1, screen_w, screen_h)
  b.bench(name="arena3d/renderer3d_graph", fn() {
    let graph = state.build_scene_graph()
    let cmds = @renderer3d.render_scene3d_graph_to_dst(
      graph,
      state.view_camera(),
      lighting=state.lighting,
      dst,
      state.shader3d,
      screen_w,
      screen_h,
    )
    b.keep(cmds.length())
  })
}

///|
test "bench arena3d active physics yard" (b : @bench.T) {
  let state = GameState::new()
  state.load_default_scene()
  b.bench(name="arena3d/physics-awake", fn() {
    for prop in state.props {
      state.physics.apply_impulse(prop.id, @math3d.Vec3::new(0.01, 0.02, 0.0))
    }
    state.physics.step(1.0 / 60.0)
    b.keep(state.physics.body_count())
  })
}
