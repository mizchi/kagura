///|
test "draw_sprite_animation appends command when atlas key exists" {
  let atlas = @atlas.new_simple_atlas_image_repository(256, 256, 1)
  let pixels : Array[Int] = Array::make(2 * 2 * 4, 255)
  let spec = @atlas.image_spec_with_rgba8(2, 2, pixels)
  let key = @atlas.new_asset_key("frame_0")
  let _ = @atlas.create_atlas_image(atlas, key, spec)
  let clip = SpriteAnimationClip::uniform("test", [key], 0.5)
  let player = SpriteAnimationPlayer::new(clip)
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  let dst = @gfx.new_image_handle(1, 320, 240)
  let shader = @gfx.new_shader_handle(1, "test_shader")
  let region = @gfx.new_dst_region(0, 0, 320, 240, 6)
  let ok = draw_sprite_animation(
    commands,
    atlas,
    player,
    dst,
    shader,
    region,
    @gfx.BlendMode::from_int(1),
    -1.0,
    -1.0,
    1.0,
    1.0,
  )
  assert_true(ok)
  assert_eq(commands.length(), 1)
}

///|
test "draw_sprite_animation returns false when atlas key missing" {
  let atlas = @atlas.new_simple_atlas_image_repository(256, 256, 1)
  let key = @atlas.new_asset_key("missing_0")
  let clip = SpriteAnimationClip::uniform("test", [key], 0.5)
  let player = SpriteAnimationPlayer::new(clip)
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  let dst = @gfx.new_image_handle(1, 320, 240)
  let shader = @gfx.new_shader_handle(1, "test_shader")
  let region = @gfx.new_dst_region(0, 0, 320, 240, 6)
  let ok = draw_sprite_animation(
    commands,
    atlas,
    player,
    dst,
    shader,
    region,
    @gfx.BlendMode::from_int(1),
    -1.0,
    -1.0,
    1.0,
    1.0,
  )
  assert_false(ok)
  assert_eq(commands.length(), 0)
}
