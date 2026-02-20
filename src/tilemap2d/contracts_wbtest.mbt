///|
fn tilemap_test_repository() -> @asset.SimpleAtlasImageRepository {
  let repo = @asset.new_simple_atlas_image_repository(8, 8, 600)
  let _ = @asset.create_atlas_image(
    repo,
    @asset.new_asset_key("tile/a"),
    @asset.default_image_spec(2, 2),
  )
  let _ = @asset.create_atlas_image(
    repo,
    @asset.new_asset_key("tile/b"),
    @asset.default_image_spec(2, 2),
  )
  repo
}

///|
test "append_atlas_tilemap_draw_commands appends resolvable specs" {
  let repo = tilemap_test_repository()
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  let specs = [
    new_atlas_tile_draw_spec(
      @asset.new_asset_key("tile/a"),
      @gfx.new_dst_region(0, 0, 64, 64, 6),
      -0.5,
      -0.5,
      0.0,
      0.0,
      [1, 2, 3, 4],
    ),
    new_atlas_tile_draw_spec(
      @asset.new_asset_key("tile/missing"),
      @gfx.new_dst_region(0, 0, 64, 64, 6),
      0.0,
      -0.5,
      0.5,
      0.0,
      [1, 2, 3, 4],
    ),
    new_atlas_tile_draw_spec(
      @asset.new_asset_key("tile/b"),
      @gfx.new_dst_region(0, 0, 64, 64, 6),
      0.0,
      0.0,
      0.5,
      0.5,
      [5, 6, 7, 8],
    ),
  ]
  let appended = append_atlas_tilemap_draw_commands(
    commands,
    repo,
    @gfx.new_image_handle(10, 64, 64),
    @gfx.new_shader_handle(20, "shader"),
    7,
    11,
    @gfx.blend_mode_from_int(1),
    specs,
  )
  assert_eq(appended, 2)
  assert_eq(commands.length(), 2)
  assert_eq(commands[0].src_image_ids[0], 600)
  assert_eq(commands[0].vertex_data[2], 0.0)
  assert_eq(commands[0].vertex_data[3], 0.0)
  assert_eq(commands[1].src_image_ids[0], 600)
  assert_eq(commands[1].vertex_data[2], 0.25)
  assert_eq(commands[1].vertex_data[3], 0.0)
  assert_eq(commands[1].uniform_dwords[0], 5)
}

///|
test "atlas_tilemap_draw_commands allocates and returns appended commands" {
  let repo = tilemap_test_repository()
  let commands = atlas_tilemap_draw_commands(
    repo,
    @gfx.new_image_handle(10, 64, 64),
    @gfx.new_shader_handle(20, "shader"),
    7,
    11,
    @gfx.blend_mode_from_int(1),
    [
      new_atlas_tile_draw_spec(
        @asset.new_asset_key("tile/a"),
        @gfx.new_dst_region(0, 0, 64, 64, 6),
        -0.5,
        -0.5,
        0.5,
        0.5,
        [1, 2, 3, 4],
      ),
    ],
  )
  assert_eq(commands.length(), 1)
  assert_eq(commands[0].src_image_ids[0], 600)
}

///|
test "tile atlas table resolves tile index to atlas key" {
  let table = new_tile_atlas_table([
    new_tile_atlas_entry(1, @asset.new_asset_key("tile/a")),
    new_tile_atlas_entry(2, @asset.new_asset_key("tile/b")),
  ])
  match resolve_tile_atlas_key(table, 2) {
    Some(key) => assert_eq(key.value, "tile/b")
    None => panic()
  }
  match resolve_tile_atlas_key(table, 999) {
    Some(_) => panic()
    None => ()
  }
}

///|
test "append_tile_indexed_draw_commands resolves indexes and skips unknown tiles" {
  let repo = tilemap_test_repository()
  let table = new_tile_atlas_table([
    new_tile_atlas_entry(1, @asset.new_asset_key("tile/a")),
    new_tile_atlas_entry(2, @asset.new_asset_key("tile/b")),
  ])
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  let appended = append_tile_indexed_draw_commands(
    commands,
    table,
    repo,
    @gfx.new_image_handle(10, 64, 64),
    @gfx.new_shader_handle(20, "shader"),
    7,
    11,
    @gfx.blend_mode_from_int(1),
    @gfx.new_dst_region(0, 0, 64, 64, 6),
    [1, -1, 999, 2],
    2,
    -0.5,
    -0.5,
    0.5,
    0.5,
    [1, 2, 3, 4],
  )
  assert_eq(appended, 2)
  assert_eq(commands.length(), 2)
  assert_eq(commands[0].src_image_ids[0], 600)
  assert_eq(commands[0].vertex_data[0], -0.5)
  assert_eq(commands[0].vertex_data[1], -0.5)
  assert_eq(commands[1].vertex_data[0], 0.0)
  assert_eq(commands[1].vertex_data[1], 0.0)
}

///|
test "append_tile_indexed_chunk_draw_commands limits updates to chunk" {
  let repo = tilemap_test_repository()
  let table = new_tile_atlas_table([
    new_tile_atlas_entry(1, @asset.new_asset_key("tile/a")),
    new_tile_atlas_entry(2, @asset.new_asset_key("tile/b")),
  ])
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  let appended = append_tile_indexed_chunk_draw_commands(
    commands,
    table,
    repo,
    @gfx.new_image_handle(10, 64, 64),
    @gfx.new_shader_handle(20, "shader"),
    7,
    11,
    @gfx.blend_mode_from_int(1),
    @gfx.new_dst_region(0, 0, 64, 64, 6),
    [1, 1, 1, 1, 2, 1, 1, 1, 1],
    3,
    1,
    1,
    2,
    1,
    -0.5,
    -0.5,
    0.5,
    0.5,
    [1, 2, 3, 4],
  )
  assert_eq(appended, 2)
  assert_eq(commands.length(), 2)
  assert_eq(commands[0].vertex_data[0], 0.0)
  assert_eq(commands[0].vertex_data[1], 0.0)
  assert_eq(commands[1].vertex_data[0], 0.5)
  assert_eq(commands[1].vertex_data[1], 0.0)
}

///|
test "append_tile_indexed_chunk_batched_draw_commands merges per page" {
  let repo = tilemap_test_repository()
  let table = new_tile_atlas_table([
    new_tile_atlas_entry(1, @asset.new_asset_key("tile/a")),
    new_tile_atlas_entry(2, @asset.new_asset_key("tile/b")),
  ])
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  let appended = append_tile_indexed_chunk_batched_draw_commands(
    commands,
    table,
    repo,
    @gfx.new_image_handle(10, 64, 64),
    @gfx.new_shader_handle(20, "shader"),
    7,
    11,
    @gfx.blend_mode_from_int(1),
    @gfx.new_dst_region(0, 0, 64, 64, 6),
    [1, 2, -1, 1],
    2,
    0,
    0,
    2,
    2,
    -0.5,
    -0.5,
    0.5,
    0.5,
    [1, 2, 3, 4],
  )
  assert_eq(appended, 1)
  assert_eq(commands.length(), 1)
  assert_eq(commands[0].src_image_ids.length(), 1)
  assert_eq(commands[0].src_image_ids[0], 600)
  assert_eq(commands[0].vertex_data.length(), 48)
  assert_eq(commands[0].indices.length(), 18)
}

///|
test "estimate_visible_tile_chunk clamps to map bounds" {
  let chunk = estimate_visible_tile_chunk(
    10, 8, 0.0, 0.0, 16.0, 16.0, -8.0, -8.0, 40.0, 24.0, 1,
  )
  assert_eq(chunk.tile_x, 0)
  assert_eq(chunk.tile_y, 0)
  assert_eq(chunk.tile_width, 4)
  assert_eq(chunk.tile_height, 3)
}

///|
test "diff_tile_index_chunks returns changed chunk rectangles" {
  let previous = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
  let next = [1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3]
  let chunks = diff_tile_index_chunks(previous, next, 4, 2)
  assert_eq(chunks.length(), 2)
  assert_eq(chunks[0].tile_width, 2)
  assert_eq(chunks[0].tile_height, 2)
  assert_eq(chunks[1].tile_width, 2)
  assert_eq(chunks[1].tile_height, 2)
}

///|
test "append_tile_indexed_dirty_chunk_batched_draw_commands appends from chunk diff" {
  let repo = tilemap_test_repository()
  let table = new_tile_atlas_table([
    new_tile_atlas_entry(1, @asset.new_asset_key("tile/a")),
    new_tile_atlas_entry(2, @asset.new_asset_key("tile/b")),
  ])
  let previous = [1, 1, 1, 1]
  let next = [1, 2, 1, 1]
  let chunks = diff_tile_index_chunks(previous, next, 2, 2)
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  let appended = append_tile_indexed_dirty_chunk_batched_draw_commands(
    commands,
    chunks,
    table,
    repo,
    @gfx.new_image_handle(10, 64, 64),
    @gfx.new_shader_handle(20, "shader"),
    7,
    11,
    @gfx.blend_mode_from_int(1),
    @gfx.new_dst_region(0, 0, 64, 64, 6),
    next,
    2,
    -0.5,
    -0.5,
    0.5,
    0.5,
    [1, 2, 3, 4],
  )
  assert_eq(chunks.length(), 1)
  assert_eq(appended, 1)
  assert_eq(commands.length(), 1)
  assert_eq(commands[0].src_image_ids[0], 600)
}

///|
test "clip_tile_chunks_to_visible intersects chunks with view" {
  let chunks = [
    new_tile_chunk_rect(0, 0, 2, 2),
    new_tile_chunk_rect(3, 0, 2, 2),
    new_tile_chunk_rect(1, 2, 2, 2),
  ]
  let visible = new_tile_chunk_rect(1, 1, 2, 2)
  let clipped = clip_tile_chunks_to_visible(chunks, visible)
  assert_eq(clipped.length(), 2)
  assert_eq(clipped[0].tile_x, 1)
  assert_eq(clipped[0].tile_y, 1)
  assert_eq(clipped[0].tile_width, 1)
  assert_eq(clipped[0].tile_height, 1)
  assert_eq(clipped[1].tile_x, 1)
  assert_eq(clipped[1].tile_y, 2)
  assert_eq(clipped[1].tile_width, 2)
  assert_eq(clipped[1].tile_height, 1)
}

///|
test "tile_atlas_table empty has no entries" {
  let table = new_tile_atlas_table([])
  match resolve_tile_atlas_key(table, 0) {
    Some(_) => panic()
    None => ()
  }
}

///|
test "estimate_visible_tile_chunk full map when view covers all" {
  // 4 cols x 3 rows, tile size 1.0x1.0, view covers 0..4 x 0..3
  let chunk = estimate_visible_tile_chunk(
    4, 3, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0, 4.0, 3.0, 0,
  )
  assert_eq(chunk.tile_x, 0)
  assert_eq(chunk.tile_y, 0)
  assert_eq(chunk.tile_width, 4)
  assert_eq(chunk.tile_height, 3)
}

///|
test "diff_tile_index_chunks no changes returns empty" {
  let tiles = [1, 2, 3, 4]
  let chunks = diff_tile_index_chunks(tiles, tiles, 2, 2)
  assert_eq(chunks.length(), 0)
}

///|
test "diff_visible_tile_index_chunks filters changed chunks by visibility" {
  let previous = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
  let next = [1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3]
  let visible = new_tile_chunk_rect(0, 0, 2, 2)
  let chunks = diff_visible_tile_index_chunks(previous, next, 4, 2, visible)
  assert_eq(chunks.length(), 1)
  assert_eq(chunks[0].tile_x, 0)
  assert_eq(chunks[0].tile_y, 0)
  assert_eq(chunks[0].tile_width, 2)
  assert_eq(chunks[0].tile_height, 2)
}
