///|
test "split_sprite_sheet produces correct number of frames" {
  let pixels : Array[Int] = Array::make(4 * 2 * 4, 255)
  let sheet = @asset.image_spec_with_rgba8(4, 2, pixels)
  let frames = split_sprite_sheet(sheet, "test", 2, 2, 2, 1)
  assert_eq(frames.length(), 4)
}

///|
test "split_sprite_sheet frame dimensions" {
  let pixels : Array[Int] = Array::make(8 * 4 * 4, 128)
  let sheet = @asset.image_spec_with_rgba8(8, 4, pixels)
  let frames = split_sprite_sheet(sheet, "spr", 4, 2, 2, 2)
  assert_eq(frames.length(), 8)
  let (_, spec) = frames[0]
  assert_eq(spec.width, 2)
  assert_eq(spec.height, 2)
}

///|
test "split_sprite_sheet key naming" {
  let pixels : Array[Int] = Array::make(6 * 2 * 4, 0)
  let sheet = @asset.image_spec_with_rgba8(6, 2, pixels)
  let frames = split_sprite_sheet(sheet, "walk", 3, 1, 2, 2)
  assert_eq(frames.length(), 3)
  let (key0, _) = frames[0]
  let (key1, _) = frames[1]
  let (key2, _) = frames[2]
  assert_eq(key0.value, "walk_0")
  assert_eq(key1.value, "walk_1")
  assert_eq(key2.value, "walk_2")
}

///|
test "register_sprite_sheet registers all frames in atlas" {
  let atlas = @asset.new_simple_atlas_image_repository(256, 256, 1)
  let pixels : Array[Int] = Array::make(8 * 2 * 4, 200)
  let sheet = @asset.image_spec_with_rgba8(8, 2, pixels)
  let keys = register_sprite_sheet(atlas, sheet, "anim", 4, 1, 2, 2)
  assert_eq(keys.length(), 4)
  // Verify each key can be found in the atlas
  for key in keys {
    let source = @asset.get_atlas_draw_source(atlas, key)
    assert_true(source is Some(_))
  }
}
