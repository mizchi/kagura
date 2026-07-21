///|
test "default_frame_profile starts empty" {
  let profile = default_frame_profile()
  assert_eq(profile.fps, 0.0)
  assert_eq(profile.draw_calls, 0)
  assert_eq(profile.vertex_count, 0)
}

///|
test "build_profiler_hud appends overlay draw commands" {
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  build_profiler_hud(
    cmds,
    @gfx.new_image_handle(1, 320, 240),
    @gfx.new_shader_handle(2, "profiler"),
    {
      fps: 60.0,
      frame_time_ms: 16.0,
      update_ms: 4.0,
      draw_ms: 8.0,
      gpu_frame_ms: 12.0,
      draw_calls: 3,
      vertex_count: 9,
      asset_inflight: 1,
    },
    320.0,
    240.0,
  )
  assert_true(cmds.length() > 8)
  assert_eq(cmds[0].dst.id, 1)
  assert_eq(cmds[0].shader.id, 2)
}
