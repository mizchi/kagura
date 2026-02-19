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
