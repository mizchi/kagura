///|
fn test_atlas_draw_source(page_image_id : Int) -> @asset.AtlasDrawSource {
  let repo = @asset.new_simple_atlas_image_repository(8, 8, page_image_id)
  let key_a = @asset.new_asset_key("draw2d/source/a")
  let key_b = @asset.new_asset_key("draw2d/source/b")
  let _ = @asset.create_atlas_image(
    repo,
    key_a,
    @asset.default_image_spec(2, 2),
  )
  let _ = @asset.create_atlas_image(
    repo,
    key_b,
    @asset.default_image_spec(2, 2),
  )
  match @asset.get_atlas_draw_source(repo, key_b) {
    Some(value) => value
    None => panic()
  }
}

///|
test "atlas_quad_vertex_data encodes xyuv with atlas uv bounds" {
  let source = test_atlas_draw_source(777)
  let vertex = atlas_quad_vertex_data(source, -0.5, -0.25, 0.75, 0.5)
  assert_eq(vertex.length(), 16)
  assert_eq(vertex[0], -0.5)
  assert_eq(vertex[1], -0.25)
  assert_eq(vertex[2], 0.25)
  assert_eq(vertex[3], 0.0)
  assert_eq(vertex[6], 0.5)
  assert_eq(vertex[7], 0.0)
  assert_eq(vertex[10], 0.5)
  assert_eq(vertex[11], 0.25)
  assert_eq(vertex[14], 0.25)
  assert_eq(vertex[15], 0.25)
}

///|
test "new_atlas_quad_draw_command uses atlas page id as src image" {
  let source = test_atlas_draw_source(901)
  let command = new_atlas_quad_draw_command(
    @gfx.new_image_handle(10, 64, 64),
    @gfx.new_shader_handle(20, "shader"),
    @gfx.new_dst_region(0, 0, 64, 64, 6),
    0,
    7,
    11,
    @gfx.blend_mode_from_int(1),
    source,
    -0.5,
    -0.5,
    0.5,
    0.5,
    [1, 2, 3, 4],
  )
  assert_eq(command.src_image_ids.length(), 1)
  assert_eq(command.src_image_ids[0], 901)
  assert_eq(command.indices.length(), 6)
  assert_eq(command.indices[0], 0)
  assert_eq(command.indices[5], 0)
  assert_eq(command.vertex_data.length(), 16)
  assert_eq(command.vertex_data[2], 0.25)
  assert_eq(command.vertex_data[3], 0.0)
  assert_eq(command.vertex_data[10], 0.5)
  assert_eq(command.vertex_data[11], 0.25)
  assert_eq(command.uniform_dwords.length(), 4)
}
