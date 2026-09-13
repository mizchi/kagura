///|
let character_shields : Map[Int, Array[CharacterPart]] = Map::new()

///|
fn is_stowed_shield(part : CharacterPart) -> Bool {
  part.name == "slot6_shell" ||
  part.name == "slot6_trim" ||
  part.name == "slot6_gem"
}

///|
fn character_guard_parts(style : GearStyle) -> Array[CharacterPart] {
  if style == Worn {
    return hunter_guard_parts
  }
  match character_shields.get(style.index()) {
    Some(parts) => parts
    None => {
      let (main_color, trim_color, gem_color) = gear_palette(style)
      let size = if style == Plate { 1.15 } else { 1.0 }
      let rim = @procedural3d.RigidGeometry::new()
      let face = @procedural3d.RigidGeometry::new()
      let gem = @procedural3d.RigidGeometry::new()
      rim.loft(
        -0.30,
        0.02,
        [(0.38, 0.32 * size, 0.40 * size), (0.46, 0.32 * size, 0.40 * size)],
        8,
        7,
      )
      face.loft(
        -0.30,
        0.02,
        [(0.365, 0.265 * size, 0.34 * size), (0.375, 0.265 * size, 0.34 * size)],
        8,
        7,
      )
      rim.box(-0.30, 0.35, 0.02, 0.055, 0.045, 0.43, 7)
      rim.box(-0.30, 0.35, 0.04, 0.3, 0.045, 0.055, 7)
      gem.box(-0.30, 0.32, 0.04, 0.085, 0.045, 0.085, 7)
      let parts = [
        finish_hunter_part(rim, "shield_rim", trim_color),
        finish_hunter_part(face, "shield_face", main_color),
        finish_hunter_part(gem, "shield_gem", gem_color),
      ]
      character_shields[style.index()] = parts
      parts
    }
  }
}
