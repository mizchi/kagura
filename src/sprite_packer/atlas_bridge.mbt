///|
/// Convert a PackedSprite to an AtlasRegion.
pub fn packed_sprite_to_atlas_region(
  sprite : PackedSprite,
  atlas_id : Int,
) -> @asset.AtlasRegion {
  @asset.new_atlas_region(sprite.x, sprite.y, sprite.width, sprite.height, atlas_id)
}

///|
/// Build a SimpleAtlasImageRepository from PackResult and original inputs.
/// The composed atlas image pixels are baked, and each sprite is registered
/// with its MaxRects-computed region (bypassing the row-based allocator).
pub fn create_packed_atlas_repository(
  inputs : Array[SpriteInput],
  result : PackResult,
  atlas_id~ : Int = 0,
) -> @asset.SimpleAtlasImageRepository {
  let repo = @asset.new_simple_atlas_image_repository(
    result.width,
    result.height,
    atlas_id,
  )
  // Build lookup from key to spec
  let specs : Map[String, @asset.ImageSpec] = {}
  for inp in inputs {
    specs[inp.key] = inp.spec
  }
  for sprite in result.sprites {
    let spec = match specs.get(sprite.key) {
      Some(s) => s
      None => continue
    }
    let region = packed_sprite_to_atlas_region(sprite, atlas_id)
    let key = @asset.new_asset_key(sprite.key)
    let _ = @asset.register_precomputed_image(repo, key, region, spec)

  }
  repo
}

///|
/// Generate a TileAtlasTable from PackResult.
/// Keys matching "tile_N" or "<prefix>_N" pattern use N as tile_index.
/// Other keys are assigned sequential indices starting from 0.
pub fn pack_result_to_tile_atlas_table(
  result : PackResult,
) -> @tilemap2d.TileAtlasTable {
  let entries : Array[@tilemap2d.TileAtlasEntry] = []
  let mut next_index = 0
  for sprite in result.sprites {
    let tile_index = parse_tile_index(sprite.key)
    match tile_index {
      Some(idx) => {
        entries.push(
          @tilemap2d.new_tile_atlas_entry(idx, @asset.new_asset_key(sprite.key)),
        )
        if idx >= next_index {
          next_index = idx + 1
        }
      }
      None => {
        entries.push(
          @tilemap2d.new_tile_atlas_entry(
            next_index,
            @asset.new_asset_key(sprite.key),
          ),
        )
        next_index = next_index + 1
      }
    }
  }
  @tilemap2d.new_tile_atlas_table(entries)
}

///|
/// Parse tile index from key like "tile_3" or "sprite_12" -> Some(3) / Some(12).
/// Returns None if the key doesn't end with _N pattern.
fn parse_tile_index(key : String) -> Int? {
  // Find last underscore
  let bytes = key.to_array()
  let mut last_underscore = -1
  for i in 0..<bytes.length() {
    if bytes[i] == '_' {
      last_underscore = i
    }
  }
  if last_underscore < 0 || last_underscore >= bytes.length() - 1 {
    return None
  }
  // Parse digits after underscore
  let mut result = 0
  let mut has_digits = false
  for i in (last_underscore + 1)..<bytes.length() {
    let c = bytes[i]
    if c >= '0' && c <= '9' {
      result = result * 10 + (c.to_int() - '0'.to_int())
      has_digits = true
    } else {
      return None
    }
  }
  if has_digits {
    Some(result)
  } else {
    None
  }
}
