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
test "atlas_quad_indices returns standard quad pattern" {
  let idx = atlas_quad_indices()
  assert_eq(idx.length(), 6)
  assert_eq(idx[0], 0)
  assert_eq(idx[1], 1)
  assert_eq(idx[2], 2)
  assert_eq(idx[3], 2)
  assert_eq(idx[4], 3)
  assert_eq(idx[5], 0)
}

///|
test "atlas_quad_vertex_data zero-size quad" {
  let source = test_atlas_draw_source(100)
  let vertex = atlas_quad_vertex_data(source, 0.0, 0.0, 0.0, 0.0)
  assert_eq(vertex.length(), 16)
  // All position coords should be 0
  assert_eq(vertex[0], 0.0)
  assert_eq(vertex[1], 0.0)
  assert_eq(vertex[4], 0.0)
  assert_eq(vertex[5], 0.0)
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

///|
test "new_atlas_quad_draw_command empty uniform_dwords" {
  let source = test_atlas_draw_source(500)
  let command = new_atlas_quad_draw_command(
    @gfx.new_image_handle(1, 32, 32),
    @gfx.new_shader_handle(2, "s"),
    @gfx.new_dst_region(0, 0, 32, 32, 6),
    0,
    1,
    1,
    @gfx.blend_mode_from_int(0),
    source,
    0.0,
    0.0,
    1.0,
    1.0,
    [],
  )
  assert_eq(command.uniform_dwords.length(), 0)
  assert_eq(command.src_image_ids[0], 500)
}

///|
test "new_atlas_quad_draw_command preserves pipeline and blend" {
  let source = test_atlas_draw_source(600)
  let command = new_atlas_quad_draw_command(
    @gfx.new_image_handle(5, 128, 128),
    @gfx.new_shader_handle(10, "blend_test"),
    @gfx.new_dst_region(0, 0, 128, 128, 6),
    42,
    99,
    77,
    @gfx.blend_mode_from_int(2),
    source,
    -1.0,
    -1.0,
    1.0,
    1.0,
    [100, 200],
  )
  assert_eq(command.pipeline_id, 99)
  assert_eq(command.uniform_hash, 77)
  assert_eq(command.index_offset, 42)
  assert_eq(command.uniform_dwords.length(), 2)
  assert_eq(command.uniform_dwords[0], 100)
  assert_eq(command.uniform_dwords[1], 200)
}

///|
test "atlas_quad_vertex_data large coordinates" {
  let source = test_atlas_draw_source(300)
  let vertex = atlas_quad_vertex_data(source, -1000.0, -2000.0, 3000.0, 4000.0)
  assert_eq(vertex.length(), 16)
  assert_eq(vertex[0], -1000.0)
  assert_eq(vertex[1], -2000.0)
  assert_eq(vertex[4], 3000.0)
  assert_eq(vertex[5], -2000.0)
  assert_eq(vertex[8], 3000.0)
  assert_eq(vertex[9], 4000.0)
  assert_eq(vertex[12], -1000.0)
  assert_eq(vertex[13], 4000.0)
}

///|
test "atlas_quad_vertex_data inverted bounds" {
  // right < left, bottom < top (inverted quad)
  let source = test_atlas_draw_source(400)
  let vertex = atlas_quad_vertex_data(source, 1.0, 1.0, -1.0, -1.0)
  assert_eq(vertex.length(), 16)
  // TL: (1, 1)
  assert_eq(vertex[0], 1.0)
  assert_eq(vertex[1], 1.0)
  // TR: (-1, 1)
  assert_eq(vertex[4], -1.0)
  assert_eq(vertex[5], 1.0)
  // BR: (-1, -1)
  assert_eq(vertex[8], -1.0)
  assert_eq(vertex[9], -1.0)
}

///|
test "atlas_quad_vertex_data negative coords" {
  let source = test_atlas_draw_source(200)
  let vertex = atlas_quad_vertex_data(source, -1.0, -1.0, -0.5, -0.5)
  // TL
  assert_eq(vertex[0], -1.0)
  assert_eq(vertex[1], -1.0)
  // TR
  assert_eq(vertex[4], -0.5)
  assert_eq(vertex[5], -1.0)
  // BR
  assert_eq(vertex[8], -0.5)
  assert_eq(vertex[9], -0.5)
  // BL
  assert_eq(vertex[12], -1.0)
  assert_eq(vertex[13], -0.5)
}
