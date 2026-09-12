///|
test "opening woodland enemies fit the desktop and portrait camera with readable silhouettes" {
  let state = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  let region : VisibleRegion = {
    min_col: 0,
    max_col: 99,
    min_row: 0,
    max_row: 79,
  }
  state.rebuild_enemy_render_buckets(region)
  let mesh = state.enemy_models.get_skinned_mesh(@game.Basic)
  for viewport in [(1280.0, 900.0), (390.0, 844.0)] {
    let camera = hunter_responsive_camera(state.camera, viewport.0, viewport.1)
    let vp = camera.to_camera3d().view_projection_matrix()
    let mut visible = 0
    for model in state.enemy_render_buckets.basic_matrices {
      let foot = model.mul_vec4(@math3d.Vec4::new(0.0, 0.0, 0.0, 1.0))
      let mut top = foot.y
      for i in 0..<mesh.vertex_count() {
        let data = mesh.vertex_data
        let point = model.mul_vec4(
          @math3d.Vec4::new(data[i * 8], data[i * 8 + 1], data[i * 8 + 2], 1.0),
        )
        top = @cmp.maximum(top, point.y)
      }
      // The old half-tile enemy looked like ground debris beside the hunter.
      assert_true(top - foot.y >= 1.0)
      let clip = vp.mul_vec4(@math3d.Vec4::new(foot.x, top, foot.z, 1.0))
      if clip.w > 0.0 &&
        (clip.x / clip.w).abs() < 0.85 &&
        (clip.y / clip.w).abs() < 0.75 {
        visible += 1
      }
    }
    assert_true(visible >= 3)
  }
}
