///|
fn sprite_test_atlas_repository() -> @asset.SimpleAtlasImageRepository {
  let repo = @asset.new_simple_atlas_image_repository(8, 8, 333)
  let _ = @asset.create_atlas_image(
    repo,
    @asset.new_asset_key("sprite/a"),
    @asset.default_image_spec(2, 2),
  )
  let _ = @asset.create_atlas_image(
    repo,
    @asset.new_asset_key("sprite/b"),
    @asset.default_image_spec(2, 2),
  )
  repo
}

///|
test "new_atlas_sprite_draw_command builds command for existing key" {
  let repo = sprite_test_atlas_repository()
  let command = match
    new_atlas_sprite_draw_command(
      repo,
      @asset.new_asset_key("sprite/b"),
      @gfx.new_image_handle(10, 64, 64),
      @gfx.new_shader_handle(20, "shader"),
      @gfx.new_dst_region(0, 0, 64, 64, 6),
      0,
      7,
      11,
      @gfx.blend_mode_from_int(1),
      -0.5,
      -0.5,
      0.5,
      0.5,
      [1, 2, 3, 4],
    ) {
    Some(value) => value
    None => panic()
  }
  assert_eq(command.src_image_ids.length(), 1)
  assert_eq(command.src_image_ids[0], 333)
  assert_eq(command.vertex_data.length(), 16)
  assert_eq(command.vertex_data[2], 0.25)
  assert_eq(command.vertex_data[3], 0.0)
  assert_eq(command.vertex_data[10], 0.5)
  assert_eq(command.vertex_data[11], 0.25)
}

///|
test "new_atlas_sprite_draw_command returns none for missing key" {
  let repo = sprite_test_atlas_repository()
  match
    new_atlas_sprite_draw_command(
      repo,
      @asset.new_asset_key("sprite/missing"),
      @gfx.new_image_handle(10, 64, 64),
      @gfx.new_shader_handle(20, "shader"),
      @gfx.new_dst_region(0, 0, 64, 64, 6),
      0,
      7,
      11,
      @gfx.blend_mode_from_int(1),
      -0.5,
      -0.5,
      0.5,
      0.5,
      [1, 2, 3, 4],
    ) {
    Some(_) => panic()
    None => ()
  }
}

///|
test "new_atlas_sprite_draw_command propagates uniform_dwords" {
  let repo = sprite_test_atlas_repository()
  let command = match
    new_atlas_sprite_draw_command(
      repo,
      @asset.new_asset_key("sprite/a"),
      @gfx.new_image_handle(10, 64, 64),
      @gfx.new_shader_handle(20, "shader"),
      @gfx.new_dst_region(0, 0, 64, 64, 6),
      0,
      7,
      11,
      @gfx.blend_mode_from_int(1),
      -1.0,
      -1.0,
      1.0,
      1.0,
      [10, 20, 30],
    ) {
    Some(value) => value
    None => panic()
  }
  assert_eq(command.uniform_dwords.length(), 3)
  assert_eq(command.uniform_dwords[0], 10)
  assert_eq(command.uniform_dwords[1], 20)
  assert_eq(command.uniform_dwords[2], 30)
}

///|
test "new_atlas_sprite_draw_command indices has 6 elements" {
  let repo = sprite_test_atlas_repository()
  let command = match
    new_atlas_sprite_draw_command(
      repo,
      @asset.new_asset_key("sprite/a"),
      @gfx.new_image_handle(1, 32, 32),
      @gfx.new_shader_handle(2, "s"),
      @gfx.new_dst_region(0, 0, 32, 32, 6),
      0,
      1,
      1,
      @gfx.blend_mode_from_int(0),
      0.0,
      0.0,
      0.5,
      0.5,
      [],
    ) {
    Some(value) => value
    None => panic()
  }
  assert_eq(command.indices.length(), 6)
  assert_eq(command.indices[0], 0)
  assert_eq(command.indices[1], 1)
  assert_eq(command.indices[2], 2)
  assert_eq(command.indices[3], 2)
  assert_eq(command.indices[4], 3)
  assert_eq(command.indices[5], 0)
}

///|
test "append_atlas_sprite_draw_command multiple sprites accumulate" {
  let repo = sprite_test_atlas_repository()
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  let _ = append_atlas_sprite_draw_command(
    commands,
    repo,
    @asset.new_asset_key("sprite/a"),
    @gfx.new_image_handle(10, 64, 64),
    @gfx.new_shader_handle(20, "shader"),
    @gfx.new_dst_region(0, 0, 64, 64, 6),
    0,
    7,
    11,
    @gfx.blend_mode_from_int(1),
    -0.5,
    -0.5,
    0.5,
    0.5,
    [],
  )
  let _ = append_atlas_sprite_draw_command(
    commands,
    repo,
    @asset.new_asset_key("sprite/b"),
    @gfx.new_image_handle(10, 64, 64),
    @gfx.new_shader_handle(20, "shader"),
    @gfx.new_dst_region(0, 0, 64, 64, 6),
    0,
    7,
    11,
    @gfx.blend_mode_from_int(1),
    0.0,
    0.0,
    1.0,
    1.0,
    [],
  )
  assert_eq(commands.length(), 2)
  // Both commands should use same atlas page
  assert_eq(commands[0].src_image_ids[0], 333)
  assert_eq(commands[1].src_image_ids[0], 333)
}

///|
test "new_atlas_sprite_draw_command empty uniform_dwords" {
  let repo = sprite_test_atlas_repository()
  let command = match
    new_atlas_sprite_draw_command(
      repo,
      @asset.new_asset_key("sprite/a"),
      @gfx.new_image_handle(1, 32, 32),
      @gfx.new_shader_handle(2, "s"),
      @gfx.new_dst_region(0, 0, 32, 32, 6),
      0,
      5,
      9,
      @gfx.blend_mode_from_int(0),
      0.0,
      0.0,
      1.0,
      1.0,
      [],
    ) {
    Some(value) => value
    None => panic()
  }
  assert_eq(command.uniform_dwords.length(), 0)
  assert_eq(command.pipeline_id, 5)
  assert_eq(command.uniform_hash, 9)
}

///|
test "append_atlas_sprite_draw_command returns false for all missing" {
  let repo = sprite_test_atlas_repository()
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  let r1 = append_atlas_sprite_draw_command(
    commands, repo, @asset.new_asset_key("missing/1"),
    @gfx.new_image_handle(1, 32, 32), @gfx.new_shader_handle(2, "s"),
    @gfx.new_dst_region(0, 0, 32, 32, 6), 0, 1, 1,
    @gfx.blend_mode_from_int(0), 0.0, 0.0, 1.0, 1.0, [],
  )
  let r2 = append_atlas_sprite_draw_command(
    commands, repo, @asset.new_asset_key("missing/2"),
    @gfx.new_image_handle(1, 32, 32), @gfx.new_shader_handle(2, "s"),
    @gfx.new_dst_region(0, 0, 32, 32, 6), 0, 1, 1,
    @gfx.blend_mode_from_int(0), 0.0, 0.0, 1.0, 1.0, [],
  )
  assert_true(!r1)
  assert_true(!r2)
  assert_eq(commands.length(), 0)
}

///|
test "new_atlas_sprite_draw_command preserves index_offset" {
  let repo = sprite_test_atlas_repository()
  let command = match
    new_atlas_sprite_draw_command(
      repo,
      @asset.new_asset_key("sprite/b"),
      @gfx.new_image_handle(10, 64, 64),
      @gfx.new_shader_handle(20, "shader"),
      @gfx.new_dst_region(0, 0, 64, 64, 6),
      100,
      7,
      11,
      @gfx.blend_mode_from_int(1),
      0.0,
      0.0,
      0.5,
      0.5,
      [],
    ) {
    Some(value) => value
    None => panic()
  }
  assert_eq(command.index_offset, 100)
}

///|
test "append_atlas_sprite_draw_command appends only resolvable sprites" {
  let repo = sprite_test_atlas_repository()
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  let appended = append_atlas_sprite_draw_command(
    commands,
    repo,
    @asset.new_asset_key("sprite/a"),
    @gfx.new_image_handle(10, 64, 64),
    @gfx.new_shader_handle(20, "shader"),
    @gfx.new_dst_region(0, 0, 64, 64, 6),
    0,
    7,
    11,
    @gfx.blend_mode_from_int(1),
    -0.5,
    -0.5,
    0.5,
    0.5,
    [1, 2, 3, 4],
  )
  let missing = append_atlas_sprite_draw_command(
    commands,
    repo,
    @asset.new_asset_key("sprite/missing"),
    @gfx.new_image_handle(10, 64, 64),
    @gfx.new_shader_handle(20, "shader"),
    @gfx.new_dst_region(0, 0, 64, 64, 6),
    0,
    7,
    11,
    @gfx.blend_mode_from_int(1),
    -0.5,
    -0.5,
    0.5,
    0.5,
    [1, 2, 3, 4],
  )
  assert_true(appended)
  assert_true(!missing)
  assert_eq(commands.length(), 1)
}
