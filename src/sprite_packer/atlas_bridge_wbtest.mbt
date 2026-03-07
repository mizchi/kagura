///|
test "packed_sprite_to_atlas_region" {
  let sprite : PackedSprite = {
    key: "test",
    x: 10,
    y: 20,
    width: 32,
    height: 48,
  }
  let region = packed_sprite_to_atlas_region(sprite, 5)
  assert_eq(region.x, 10)
  assert_eq(region.y, 20)
  assert_eq(region.width, 32)
  assert_eq(region.height, 48)
  assert_eq(region.atlas_id, 5)
}

///|
test "create_packed_atlas_repository basic" {
  // Create two 4x4 sprites
  let pixels_a : Array[Int] = Array::make(4 * 4 * 4, 255)
  let pixels_b : Array[Int] = Array::make(4 * 4 * 4, 128)
  let spec_a = @asset.image_spec_with_rgba8(4, 4, pixels_a)
  let spec_b = @asset.image_spec_with_rgba8(4, 4, pixels_b)
  let inputs : Array[SpriteInput] = [
    { key: "sprite_a", spec: spec_a },
    { key: "sprite_b", spec: spec_b },
  ]
  let result : PackResult = {
    width: 16,
    height: 16,
    sprites: [
      { key: "sprite_a", x: 0, y: 0, width: 4, height: 4 },
      { key: "sprite_b", x: 5, y: 0, width: 4, height: 4 },
    ],
  }
  let repo = create_packed_atlas_repository(inputs, result)
  // Both sprites should be retrievable
  let src_a = @asset.get_atlas_draw_source(
    repo,
    @asset.new_asset_key("sprite_a"),
  )
  assert_true(not(src_a is None))
  let src_b = @asset.get_atlas_draw_source(
    repo,
    @asset.new_asset_key("sprite_b"),
  )
  assert_true(not(src_b is None))
  // Nonexistent key returns None
  let src_c = @asset.get_atlas_draw_source(repo, @asset.new_asset_key("nope"))
  assert_true(src_c is None)
}

///|
test "create_packed_atlas_repository UV coordinates" {
  let pixels : Array[Int] = Array::make(8 * 8 * 4, 200)
  let spec = @asset.image_spec_with_rgba8(8, 8, pixels)
  let inputs : Array[SpriteInput] = [{ key: "img", spec }]
  let result : PackResult = {
    width: 32,
    height: 32,
    sprites: [{ key: "img", x: 8, y: 16, width: 8, height: 8 }],
  }
  let repo = create_packed_atlas_repository(inputs, result)
  let src = @asset.get_atlas_draw_source(repo, @asset.new_asset_key("img"))
  assert_true(not(src is None))
  let s = src.unwrap()
  // u0 = 8/32 = 0.25, v0 = 16/32 = 0.5, u1 = 16/32 = 0.5, v1 = 24/32 = 0.75
  assert_eq(s.u0, 0.25)
  assert_eq(s.v0, 0.5)
  assert_eq(s.u1, 0.5)
  assert_eq(s.v1, 0.75)
}

///|
test "pack_result_to_tile_atlas_table with tile_ keys" {
  let result : PackResult = {
    width: 64,
    height: 64,
    sprites: [
      { key: "tile_0", x: 0, y: 0, width: 16, height: 16 },
      { key: "tile_3", x: 16, y: 0, width: 16, height: 16 },
      { key: "tile_7", x: 32, y: 0, width: 16, height: 16 },
    ],
  }
  let table = pack_result_to_tile_atlas_table(result)
  // Should have 3 entries
  inspect(table.entries.length(), content="3")
  // Verify tile indices
  let r0 = @tilemap2d.resolve_tile_atlas_key(table, 0)
  assert_true(not(r0 is None))
  let r3 = @tilemap2d.resolve_tile_atlas_key(table, 3)
  assert_true(not(r3 is None))
  let r7 = @tilemap2d.resolve_tile_atlas_key(table, 7)
  assert_true(not(r7 is None))
  // Non-existent tile index
  let r1 = @tilemap2d.resolve_tile_atlas_key(table, 1)
  assert_true(r1 is None)
}

///|
test "pack_result_to_tile_atlas_table with non-tile keys" {
  let result : PackResult = {
    width: 32,
    height: 32,
    sprites: [
      { key: "grass", x: 0, y: 0, width: 16, height: 16 },
      { key: "stone", x: 16, y: 0, width: 16, height: 16 },
    ],
  }
  let table = pack_result_to_tile_atlas_table(result)
  inspect(table.entries.length(), content="2")
  // Sequential indices: 0 and 1
  let r0 = @tilemap2d.resolve_tile_atlas_key(table, 0)
  assert_true(not(r0 is None))
  let r1 = @tilemap2d.resolve_tile_atlas_key(table, 1)
  assert_true(not(r1 is None))
}

///|
test "end-to-end: split_sprite_sheet → pack → repository → draw_source" {
  // Create a 32x32 sprite sheet (2x2 grid of 16x16 tiles)
  let sheet_w = 32
  let sheet_h = 32
  let pixels : Array[Int] = Array::make(sheet_w * sheet_h * 4, 0)
  for row in 0..<2 {
    for col in 0..<2 {
      let tile_idx = row * 2 + col
      let r = tile_idx * 60
      let g = tile_idx * 40
      let b = tile_idx * 20
      for py in 0..<16 {
        for px in 0..<16 {
          let x = col * 16 + px
          let y = row * 16 + py
          let idx = (y * sheet_w + x) * 4
          pixels[idx] = r
          pixels[idx + 1] = g
          pixels[idx + 2] = b
          pixels[idx + 3] = 255
        }
      }
    }
  }
  let sheet = @asset.image_spec_with_rgba8(sheet_w, sheet_h, pixels)
  // Split into 4 tiles
  let frames = @animation2d.split_sprite_sheet(sheet, "tile", 2, 2, 16, 16)
  inspect(frames.length(), content="4")
  // Convert to SpriteInput
  let inputs : Array[SpriteInput] = []
  for pair in frames {
    let (key, spec) = pair
    inputs.push({ key: key.value, spec })
  }
  // Pack
  let result = pack_sprites(inputs, config=PackerConfig::default())
  assert_true(not(result is None))
  let pack_result = result.unwrap()
  inspect(pack_result.sprites.length(), content="4")
  // Build repository
  let repo = create_packed_atlas_repository(inputs, pack_result)
  // All 4 tiles should be accessible
  for i in 0..<4 {
    let key = @asset.new_asset_key("tile_" + i.to_string())
    let src = @asset.get_atlas_draw_source(repo, key)
    assert_true(not(src is None))
  }
  // Build tile atlas table
  let table = pack_result_to_tile_atlas_table(pack_result)
  inspect(table.entries.length(), content="4")
}

///|
test "parse_tile_index" {
  assert_eq(parse_tile_index("tile_0"), Some(0))
  assert_eq(parse_tile_index("tile_42"), Some(42))
  assert_eq(parse_tile_index("sprite_7"), Some(7))
  assert_eq(parse_tile_index("notile"), None)
  assert_eq(parse_tile_index("tile_"), None)
  assert_eq(parse_tile_index("tile_abc"), None)
}
