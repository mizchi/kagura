///|
test "build_runtime_smoke_tile_draw_plan returns tile and sprite commands" {
  let plan = build_runtime_smoke_tile_draw_plan(
    @gfx.new_image_handle(1, 64, 64),
    @gfx.new_shader_handle(2, "shader"),
  )
  assert_eq(plan.commands.length(), 2)
  let tile_command = plan.commands[0]
  assert_eq(tile_command.src_image_ids.length(), 1)
  assert_eq(tile_command.src_image_ids[0], runtime_smoke_atlas_page_id)
  assert_eq(tile_command.vertex_data[0], -0.5)
  assert_eq(tile_command.vertex_data[1], -0.5)
  assert_eq(tile_command.vertex_data[4], 0.5)
  assert_eq(tile_command.vertex_data[5], -0.5)
  assert_eq(tile_command.vertex_data[8], 0.5)
  assert_eq(tile_command.vertex_data[9], 0.5)
  assert_eq(tile_command.indices.length(), 6)
  assert_eq(plan.sprite_command_index, 1)
  let sprite_command = plan.commands[1]
  assert_eq(sprite_command.src_image_ids.length(), 1)
  assert_eq(sprite_command.src_image_ids[0], runtime_smoke_atlas_page_id)
  assert_eq(sprite_command.vertex_data.length(), 16)
  assert_eq(sprite_command.indices.length(), 6)
}
