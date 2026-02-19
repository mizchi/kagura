///|
test "planned frame draw count resets on begin" {
  runtime_begin_frame(0.0, 0.0, 0.0, 1.0)
  assert_eq(runtime_pending_draw_calls(), 0)
  assert_eq(runtime_pending_command_count(), 0)
  runtime_record_draw_region_count(2)
  assert_eq(runtime_pending_draw_calls(), 2)
  assert_eq(runtime_pending_command_count(), 1)
  assert_eq(runtime_last_pipeline_id(), 0)
  assert_eq(runtime_last_uniform_hash(), 0)
  assert_eq(runtime_last_blend_mode(), 1)
  assert_eq(runtime_last_dst_image_id(), 0)
  assert_eq(runtime_last_shader_id(), 0)
  assert_eq(runtime_last_index_offset(), 0)
  assert_eq(runtime_last_region_count(), 2)
  assert_eq(runtime_last_total_index_count(), 6)
  assert_eq(runtime_last_vertex_float_count(), 0)
  assert_eq(runtime_last_index_count(), 6)
  assert_eq(runtime_last_src_image_count(), 0)
  assert_eq(runtime_last_uniform_dword_count(), 0)

  runtime_begin_frame(1.0, 0.0, 0.0, 1.0)
  assert_eq(runtime_pending_draw_calls(), 0)
  assert_eq(runtime_pending_command_count(), 0)
  assert_eq(runtime_last_pipeline_id(), 0)
  assert_eq(runtime_last_uniform_hash(), 0)
  assert_eq(runtime_last_blend_mode(), 1)
  assert_eq(runtime_last_dst_image_id(), 0)
  assert_eq(runtime_last_shader_id(), 0)
  assert_eq(runtime_last_index_offset(), 0)
  assert_eq(runtime_last_region_count(), 0)
  assert_eq(runtime_last_total_index_count(), 0)
  assert_eq(runtime_last_vertex_float_count(), 0)
  assert_eq(runtime_last_index_count(), 0)
  assert_eq(runtime_last_src_image_count(), 0)
  assert_eq(runtime_last_uniform_dword_count(), 0)
}

///|
test "planned frame present returns false without context" {
  runtime_begin_frame(0.0, 0.0, 0.0, 1.0)
  runtime_record_draw_region_count(1)
  let rendered = runtime_present_planned_frame()
  assert_true(!rendered)
}

///|
test "runtime records draw command metadata for native backend bridge" {
  runtime_begin_frame(0.0, 0.0, 0.0, 1.0)
  runtime_record_draw_command(2, 7, 11, 3, 100, 200, 4, 2, 6, 16, 6, 2, 3)
  runtime_record_draw_command(1, 9, 13, 2, 101, 201, 8, 1, 3, 12, 3, 1, 4)

  assert_eq(runtime_pending_draw_calls(), 3)
  assert_eq(runtime_pending_command_count(), 2)
  assert_eq(runtime_last_pipeline_id(), 9)
  assert_eq(runtime_last_uniform_hash(), 13)
  assert_eq(runtime_last_blend_mode(), 2)
  assert_eq(runtime_last_dst_image_id(), 101)
  assert_eq(runtime_last_shader_id(), 201)
  assert_eq(runtime_last_index_offset(), 8)
  assert_eq(runtime_last_region_count(), 1)
  assert_eq(runtime_last_total_index_count(), 3)
  assert_eq(runtime_last_vertex_float_count(), 12)
  assert_eq(runtime_last_index_count(), 3)
  assert_eq(runtime_last_src_image_count(), 1)
  assert_eq(runtime_last_uniform_dword_count(), 4)
}

///|
test "runtime render size is clamped to positive values" {
  let size = clamp_runtime_render_size(0, -9)
  assert_eq(size.width, 1)
  assert_eq(size.height, 1)

  let size2 = clamp_runtime_render_size(640, 480)
  assert_eq(size2.width, 640)
  assert_eq(size2.height, 480)
}
