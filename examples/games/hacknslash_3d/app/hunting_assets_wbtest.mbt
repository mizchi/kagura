///|
test "woodland assets have bounded topology and grounded collision footprints" {
  assert_eq(hunting_assets.length(), 4)
  for asset in hunting_assets {
    let mut triangles = 0
    let mut foot_vertices = 0
    for part in asset.parts {
      let data = part.mesh.vertex_data
      triangles += part.mesh.indices.length() / 3
      for index in part.mesh.indices {
        assert_true(index >= 0 && index * 8 < data.length())
      }
      for i in 0..<(data.length() / 8) {
        let x = data[i * 8]
        let y = data[i * 8 + 1]
        let z = data[i * 8 + 2]
        assert_true(y >= 0.0 && y < 4.0)
        if y < 0.19 {
          foot_vertices += 1
          assert_true(x.abs() <= 0.5 && z.abs() <= 0.5)
        }
      }
    }
    assert_true(foot_vertices > 0)
    assert_true(triangles > 30 && triangles < 1000)
  }
}

///|
test "responsive camera preserves world aiming and the render target stays within the pixel budget" {
  let state = GameState::new(seed=42)
  for viewport in [(1600.0, 900.0), (390.0, 844.0), (844.0, 390.0)] {
    let camera = hunter_responsive_camera(state.camera, viewport.0, viewport.1)
    assert_true((camera.aspect - viewport.0 / viewport.1).abs() < 0.00001)
    let (width, height) = hunter_render_size(viewport.0, viewport.1)
    assert_true(width > 0 && height > 0 && width * height <= 921600)
    assert_true(
      (width.to_double() / height.to_double() - camera.aspect).abs() < 0.003,
    )
    let px = state.world.player.x
    let pz = state.world.player.y
    let clip = camera
      .to_camera3d()
      .view_projection_matrix()
      .mul_vec4(
        @math3d.Vec4::new(px / tile_size + 1.0, 0.0, pz / tile_size + 1.0, 1.0),
      )
    let aim = hunter_aim_angle(
      camera,
      (clip.x / clip.w + 1.0) * 320.0,
      (1.0 - clip.y / clip.w) * 240.0,
      px,
      pz,
      0.0,
      0.0,
    )
    assert_true((aim - @math.PI / 4.0).abs() < 0.001)
  }
}

///|
test "hunter HUD reads usable skills and their real cooldowns from simulation" {
  let state = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  state.world.mode = @game.Playing
  let initial = state.hunter_hud_view()
  assert_eq(initial.skills.length(), 4)
  for skill in initial.skills {
    assert_true(skill.level > 0)
    assert_eq(skill.remaining, 0)
  }
  @game.activate_skill(state.world, 4)
  let cooldown = state.hunter_hud_view().skills[2]
  assert_true(cooldown.remaining > 0)
  assert_eq(cooldown.remaining, state.world.splitting_fireball_cooldown_timer)
}
