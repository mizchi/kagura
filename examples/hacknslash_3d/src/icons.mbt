// Procedural icon generation + atlas packing for UI icons

// 16x16 pixel icon patterns (1=filled, 0=empty)
// Each pattern is a 16-element array of 16-bit row masks

fn icon_sword() -> Array[Int] {
  [
    0b0000000000000010,
    0b0000000000000100,
    0b0000000000001000,
    0b0000000000010000,
    0b0000000000100000,
    0b0000000001000000,
    0b0000000010000000,
    0b0000000100000000,
    0b0000001000000000,
    0b0000010100000000,
    0b0000100010000000,
    0b0001000000000000,
    0b0010000000000000,
    0b0100000000000000,
    0b0010000000000000,
    0b0001000000000000,
  ]
}

fn icon_armor() -> Array[Int] {
  [
    0b0000011111000000,
    0b0000100000100000,
    0b0001000000010000,
    0b0011111111111000,
    0b0010000000001000,
    0b0010000000001000,
    0b0010000000001000,
    0b0010000000001000,
    0b0010000000001000,
    0b0010000000001000,
    0b0010000000001000,
    0b0001000000010000,
    0b0001000000010000,
    0b0000100000100000,
    0b0000011111000000,
    0b0000000000000000,
  ]
}

fn icon_ring() -> Array[Int] {
  [
    0b0000000000000000,
    0b0000000000000000,
    0b0000001111000000,
    0b0000010000100000,
    0b0000100000010000,
    0b0001000000001000,
    0b0001000000001000,
    0b0001000000001000,
    0b0001000000001000,
    0b0000100000010000,
    0b0000010000100000,
    0b0000001111000000,
    0b0000000110000000,
    0b0000001001000000,
    0b0000000110000000,
    0b0000000000000000,
  ]
}

fn icon_heart() -> Array[Int] {
  [
    0b0000000000000000,
    0b0000000000000000,
    0b0001100001100000,
    0b0010010010010000,
    0b0100001100001000,
    0b0100000000001000,
    0b0100000000001000,
    0b0010000000010000,
    0b0010000000010000,
    0b0001000000100000,
    0b0000100001000000,
    0b0000010010000000,
    0b0000001100000000,
    0b0000000000000000,
    0b0000000000000000,
    0b0000000000000000,
  ]
}

fn icon_star() -> Array[Int] {
  [
    0b0000000100000000,
    0b0000000100000000,
    0b0000001110000000,
    0b0000001110000000,
    0b0111111111111100,
    0b0011111111111000,
    0b0001111111110000,
    0b0000111111100000,
    0b0000111111100000,
    0b0001110011100000,
    0b0001100001100000,
    0b0011000000110000,
    0b0110000000011000,
    0b0100000000001000,
    0b0000000000000000,
    0b0000000000000000,
  ]
}

fn icon_skull() -> Array[Int] {
  [
    0b0000011111000000,
    0b0000100000100000,
    0b0001000000010000,
    0b0010000000001000,
    0b0010011001001000,
    0b0010011001001000,
    0b0010000000001000,
    0b0010000000001000,
    0b0001000100010000,
    0b0001001010010000,
    0b0000100000100000,
    0b0000011111000000,
    0b0000010101000000,
    0b0000010101000000,
    0b0000011111000000,
    0b0000000000000000,
  ]
}

fn all_icon_patterns() -> Array[Array[Int]] {
  [icon_sword(), icon_armor(), icon_ring(), icon_heart(), icon_star(), icon_skull()]
}

// Rasterize a 16x16 icon pattern into RGBA8 pixel array
fn rasterize_icon(pattern : Array[Int], color : Int) -> Array[Int] {
  let r = (color >> 16).land(0xFF)
  let g = (color >> 8).land(0xFF)
  let b = color.land(0xFF)
  let pixels : Array[Int] = []
  for row in 0..<16 {
    let bits = pattern[row]
    for col in 0..<16 {
      if bits.land(1 .lsl(15 - col)) != 0 {
        pixels.push(r)
        pixels.push(g)
        pixels.push(b)
        pixels.push(255)
      } else {
        pixels.push(0)
        pixels.push(0)
        pixels.push(0)
        pixels.push(0)
      }
    }
  }
  pixels
}

// Create sprite inputs for all icons with rarity color variants
fn build_icon_sprite_inputs() -> Array[@sprite_packer.SpriteInput] {
  let patterns = all_icon_patterns()
  let rarity_colors = [
    (@game.Common, 0xAAAAAA),
    (@game.Uncommon, 0x00CC00),
    (@game.Rare, 0x3366FF),
    (@game.Epic, 0xCC00FF),
  ]
  let skill_color = 0xFFCC00
  let inputs : Array[@sprite_packer.SpriteInput] = []
  // Item icons: pattern x rarity (6 patterns x 4 rarities = 24 icons)
  for p_idx, pattern in patterns {
    for r in rarity_colors {
      let (_, color) = r
      inputs.push({
        key: "item_" + p_idx.to_string() + "_" + color.to_string(),
        spec: @asset.image_spec_with_rgba8(16, 16, rasterize_icon(pattern, color)),
      })
    }
  }
  // Skill icons (6 skills in yellow)
  for p_idx, pattern in patterns {
    inputs.push({
      key: "skill_" + p_idx.to_string(),
      spec: @asset.image_spec_with_rgba8(16, 16, rasterize_icon(pattern, skill_color)),
    })
  }
  inputs
}

struct IconAtlas {
  repo : @asset.SimpleAtlasImageRepository
  atlas_image : @asset.ImageSpec
}

fn create_icon_atlas() -> IconAtlas {
  let inputs = build_icon_sprite_inputs()
  let config : @sprite_packer.PackerConfig = {
    max_width: 256,
    max_height: 256,
    padding: 1,
    power_of_two: true,
  }
  let result = @sprite_packer.pack_sprites(inputs, config~)
  match result {
    Some(pack_result) => {
      let atlas_image = @sprite_packer.compose_packed_image(inputs, pack_result)
      let repo = @sprite_packer.create_packed_atlas_repository(
        inputs, pack_result,
      )
      { repo, atlas_image }
    }
    None => {
      // Fallback: empty atlas
      {
        repo: @asset.new_simple_atlas_image_repository(256, 256, 0),
        atlas_image: @asset.image_spec_with_rgba8(256, 256, []),
      }
    }
  }
}
