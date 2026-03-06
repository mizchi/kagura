///|
fn make_test_sprite(key : String, w : Int, h : Int) -> SpriteInput {
  let pixels : Array[Int] = Array::make(w * h * 4, 255)
  let spec = @asset.image_spec_with_rgba8(w, h, pixels)
  { key, spec }
}

///|
test "pack_sprites empty input" {
  let result = pack_sprites([], config=PackerConfig::default())
  assert_true(not(result is None))
  let r = result.unwrap()
  inspect(r.sprites.length(), content="0")
  inspect(r.width, content="1")
  inspect(r.height, content="1")
}

///|
test "pack_sprites single sprite" {
  let inputs = [make_test_sprite("a", 16, 16)]
  let result = pack_sprites(inputs, config=PackerConfig::default())
  assert_true(not(result is None))
  let r = result.unwrap()
  inspect(r.sprites.length(), content="1")
  assert_true(r.width >= 16)
  assert_true(r.height >= 16)
  inspect(r.sprites[0].key, content="a")
  inspect(r.sprites[0].width, content="16")
  inspect(r.sprites[0].height, content="16")
}

///|
test "pack_sprites padding is applied" {
  let config : PackerConfig = {
    max_width: 256,
    max_height: 256,
    padding: 4,
    power_of_two: false,
  }
  let inputs = [make_test_sprite("a", 16, 16), make_test_sprite("b", 16, 16)]
  let result = pack_sprites(inputs, config~)
  assert_true(not(result is None))
  let r = result.unwrap()
  // With padding=4, each sprite takes 24x24, sprites should not overlap
  for s in r.sprites {
    assert_true(s.x >= 4) // padding offset
    assert_true(s.y >= 4)
  }
}

///|
test "pack_sprites power of two" {
  let config : PackerConfig = {
    max_width: 2048,
    max_height: 2048,
    padding: 0,
    power_of_two: true,
  }
  let inputs = [make_test_sprite("a", 17, 17)]
  let result = pack_sprites(inputs, config~)
  assert_true(not(result is None))
  let r = result.unwrap()
  // 17 -> next POT = 32
  inspect(r.width, content="32")
  inspect(r.height, content="32")
}

///|
test "pack_sprites too large returns None" {
  let config : PackerConfig = {
    max_width: 16,
    max_height: 16,
    padding: 0,
    power_of_two: false,
  }
  let inputs = [make_test_sprite("big", 32, 32)]
  let result = pack_sprites(inputs, config~)
  assert_true(result is None)
}

///|
test "compose_packed_image pixel placement" {
  // Create a 2x2 red sprite
  let red_pixels : Array[Int] = [
    255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255,
  ]
  let red_spec = @asset.image_spec_with_rgba8(2, 2, red_pixels)
  let inputs : Array[SpriteInput] = [{ key: "red", spec: red_spec }]
  let pack_result : PackResult = {
    width: 4,
    height: 4,
    sprites: [{ key: "red", x: 1, y: 1, width: 2, height: 2 }],
  }
  let atlas = compose_packed_image(inputs, pack_result)
  inspect(atlas.width, content="4")
  inspect(atlas.height, content="4")
  // Check pixel at (1,1) is red
  let idx = (1 * 4 + 1) * 4
  inspect(atlas.pixels_rgba8[idx], content="255")
  inspect(atlas.pixels_rgba8[idx + 1], content="0")
  inspect(atlas.pixels_rgba8[idx + 2], content="0")
  inspect(atlas.pixels_rgba8[idx + 3], content="255")
  // Check pixel at (0,0) is transparent/black
  inspect(atlas.pixels_rgba8[0], content="0")
}

///|
test "next_power_of_two" {
  inspect(next_power_of_two(0), content="1")
  inspect(next_power_of_two(1), content="1")
  inspect(next_power_of_two(2), content="2")
  inspect(next_power_of_two(3), content="4")
  inspect(next_power_of_two(5), content="8")
  inspect(next_power_of_two(16), content="16")
  inspect(next_power_of_two(17), content="32")
  inspect(next_power_of_two(255), content="256")
  inspect(next_power_of_two(256), content="256")
  inspect(next_power_of_two(257), content="512")
}

///|
test "pack_sprites multiple sprites" {
  let inputs : Array[SpriteInput] = []
  for i in 0..<10 {
    inputs.push(make_test_sprite("s" + i.to_string(), 16, 16))
  }
  let result = pack_sprites(inputs, config=PackerConfig::default())
  assert_true(not(result is None))
  let r = result.unwrap()
  inspect(r.sprites.length(), content="10")
  // All sprites within bounds
  for s in r.sprites {
    assert_true(s.x + s.width <= r.width)
    assert_true(s.y + s.height <= r.height)
  }
}

///|
test "split_sprite_sheet to pack_sprites pipeline" {
  // Create a 64x64 dummy sprite sheet (4x4 grid of 16x16 tiles)
  let sheet_w = 64
  let sheet_h = 64
  let pixels : Array[Int] = Array::make(sheet_w * sheet_h * 4, 0)
  // Fill each 16x16 tile with a distinct color based on tile index
  for row in 0..<4 {
    for col in 0..<4 {
      let tile_idx = row * 4 + col
      let r = tile_idx * 17 % 256
      let g = tile_idx * 37 % 256
      let b = tile_idx * 59 % 256
      for py in 0..<16 {
        for px in 0..<16 {
          let idx = ((row * 16 + py) * sheet_w + col * 16 + px) * 4
          pixels[idx] = r
          pixels[idx + 1] = g
          pixels[idx + 2] = b
          pixels[idx + 3] = 255
        }
      }
    }
  }
  let sheet = @asset.image_spec_with_rgba8(sheet_w, sheet_h, pixels)
  // Split into 16 individual sprites
  let frames = @animation2d.split_sprite_sheet(sheet, "tile", 4, 4, 16, 16)
  inspect(frames.length(), content="16")
  // Convert to SpriteInput array
  let inputs : Array[SpriteInput] = []
  for pair in frames {
    let (key, spec) = pair
    inputs.push({ key: key.value, spec })
  }
  // Pack them
  let result = pack_sprites(inputs, config=PackerConfig::default())
  assert_true(not(result is None))
  let r = result.unwrap()
  inspect(r.sprites.length(), content="16")
  // All within bounds
  for s in r.sprites {
    assert_true(s.x + s.width <= r.width)
    assert_true(s.y + s.height <= r.height)
  }
  // Compose the atlas image
  let atlas = compose_packed_image(inputs, r)
  assert_true(atlas.width > 0)
  assert_true(atlas.height > 0)
  // Verify a pixel from the first sprite is correctly placed
  let s0 = r.sprites[0]
  let atlas_idx = (s0.y * atlas.width + s0.x) * 4
  // Alpha should be 255
  inspect(atlas.pixels_rgba8[atlas_idx + 3], content="255")
}
