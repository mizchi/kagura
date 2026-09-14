///|
test "landscape benchmark fixtures retain geometry, bone animation and full uniform payloads" {
  let mesh = @mesh3d.Mesh3D::cube(1.0)
  assert_eq(mesh.indices.length(), 36)
  assert_eq(fixture_skin_vertices(mesh).length(), mesh.vertex_count() * 16)
  let clip = fixture_bake(fixture_skeleton())
  assert_eq(clip.frame_count, 48)
  assert_eq(clip.matrices(47).length(), 18)
  assert_true(clip.matrices(47)[17].elements[12] > 0.09)
  let uniforms = fixture_scenery_uniforms(
    fixture_models(128),
    @math3d.Mat4::identity(),
    @light3d.LightingEnvironment::default(),
    fixture_mask(),
  )
  assert_eq(uniforms.length(), 128)
  assert_true(uniforms.all(words => words.length() == 72))
  assert_true(uniforms[1][12] != uniforms[2][12])
  let cells = fixture_scatter(100, 80)
  assert_eq(cells.length(), 8000)
  let count = cells.filter(v => v).length()
  assert_true(count > 250 && count < 800)
  assert_eq(fixture_scatter(100, 80), cells)
}

///|
test "clear sweep benchmark traverses the full ray while the blocked one exits early" {
  let start = @math3d.Vec3::new(3.5, 2.0, 3.0)
  let end = @math3d.Vec3::new(4.0, 3.0, 8.0)
  let mut clear_calls = 0
  let clear = @camera3d.sweep_camera_boom(start, end, p => {
    clear_calls += 1
    p.y < 0.18
  })
  let mut blocked_calls = 0
  let blocked = @camera3d.sweep_camera_boom(start, end, p => {
    blocked_calls += 1
    p.z >= 6.0
  })
  assert_eq(clear, 1.0)
  assert_true(clear_calls > 40 && clear_calls < 50)
  assert_true(blocked < 0.6 && blocked > 0.55)
  assert_true(blocked_calls > 20 && blocked_calls < clear_calls)
}
