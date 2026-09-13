// Shared immutable modular assets. Heads reuse the same species sculpt as enemies.

///|
let character_source_parts : Array[CharacterPart] = build_hunter_parts()

///|
let character_slot_assets : Map[Int, Array[CharacterPart]] = Map::new()

///|
let character_heads : Array[Array[CharacterPart]] = [
  Human,
  Goblin,
  Kobold,
  Skeleton,
].map(build_character_head)

///|
fn character_head_parts(species : CharacterSpecies) -> Array[CharacterPart] {
  character_heads[species.index()]
}

///|
fn build_character_head(species : CharacterSpecies) -> Array[CharacterPart] {
  let parts : Array[CharacterPart] = []
  if species == Human {
    for part in character_source_parts {
      if part.name != "cloth" && part.name != "shadow" {
        continue
      }
      let data = @procedural3d.RigidGeometry::new()
      data.append_joint(part.mesh, part.skin, 5, 5)
      let mesh = data.build_mesh()
      let skin = data.build_skin()
      parts.push({
        name: "head_" + part.name,
        mesh,
        skin,
        packed: @skeleton3d.build_skinned_vertex_data(mesh, skin),
        color: part.color,
      })
    }
  } else {
    let monster = build_monster_mesh_data(
      match species {
        Goblin => @game.Goblin
        Kobold => @game.Kobold
        _ => @game.Skeleton
      },
    )
    for part in monster.parts {
      let data = @procedural3d.RigidGeometry::new()
      data.append_joint(part.geometry.bind_mesh, part.geometry.skin_data, 2, 5)
      if data.indices.is_empty() {
        continue
      }
      let mesh = data.build_mesh()
      let skin = data.build_skin()
      parts.push({
        name: "head_" + part.name,
        mesh,
        skin,
        packed: @skeleton3d.build_skinned_vertex_data(mesh, skin),
        color: part.color,
      })
    }
  }
  parts
}

///|
let character_base_parts : Array[CharacterPart] = {
  let body = @procedural3d.RigidGeometry::new()
  body.loft(
    0.0,
    0.0,
    [(0.34, 0.16, 0.10), (0.59, 0.20, 0.12), (0.68, 0.14, 0.10)],
    8,
    1,
  )
  for side in [-1.0, 1.0] {
    let left = side < 0.0
    body.loft(
      side * 0.25,
      0.0,
      [(0.45, 0.053, 0.055), (0.63, 0.072, 0.066)],
      6,
      if left {
        6
      } else {
        2
      },
    )
    body.loft(
      side * 0.30,
      0.025,
      [(0.30, 0.046, 0.046), (0.47, 0.056, 0.051)],
      6,
      if left {
        7
      } else {
        3
      },
    )
    body.loft(
      side * 0.115,
      0.0,
      [(0.18, 0.062, 0.057), (0.38, 0.080, 0.075)],
      6,
      if left {
        8
      } else {
        10
      },
    )
    body.loft(
      side * 0.115,
      0.0,
      [(0.03, 0.066, 0.060), (0.22, 0.062, 0.057)],
      6,
      if left {
        9
      } else {
        11
      },
    )
    body.box(
      side * 0.115,
      0.03,
      0.035,
      0.14,
      0.06,
      0.22,
      if left {
        9
      } else {
        11
      },
    )
  }
  [finish_hunter_part(body, "body_underclothes", 0x30343D)]
}

///|
fn character_outfit_parts(
  species : CharacterSpecies,
  outfit : CharacterOutfit,
) -> Array[CharacterPart] {
  let parts = character_base_parts.copy()
  parts.append(character_head_parts(species))
  for slot in @game.equipment_slots() {
    if slot == @game.Weapon {
      continue
    }
    if outfit.style(slot) is Some(style) {
      parts.append(character_gear_parts(slot, style))
    }
  }
  parts
}

///|
fn gear_palette(style : GearStyle) -> (Int, Int, Int) {
  match style {
    Worn => (0x35414A, 0xB29462, 0x91BDC5)
    Leather => (0x674437, 0xC19C65, 0xD19B58)
    Plate => (0x718894, 0xD0DADD, 0x73BDDC)
    Occult => (0x413750, 0xB7A1CE, 0xB887F2)
  }
}

///|
fn character_gear_parts(
  slot : @game.EquipSlot,
  style : GearStyle,
) -> Array[CharacterPart] {
  let key = slot.index() * 4 + style.index()
  match character_slot_assets.get(key) {
    Some(parts) => parts
    None => {
      let parts = build_character_gear(slot, style)
      character_slot_assets[key] = parts
      parts
    }
  }
}

///|
fn build_character_gear(
  slot : @game.EquipSlot,
  style : GearStyle,
) -> Array[CharacterPart] {
  let parts : Array[CharacterPart] = []
  let prefix = "slot" + slot.index().to_string() + "_"
  let (main_color, trim_color, gem_color) = gear_palette(style)
  let joints = match slot {
    @game.Armor => [1, 2, 6, 12, 13]
    @game.Helmet => if style == Worn { [5] } else { [] }
    @game.Gloves => [3, 7]
    @game.Boots => [9, 11]
    _ => []
  }
  for part in character_source_parts {
    if part.name == "shadow" || (slot == @game.Helmet && part.name == "cloth") {
      continue
    }
    let data = @procedural3d.RigidGeometry::new()
    for joint in joints {
      data.append_joint(part.mesh, part.skin, joint, joint)
    }
    if data.indices.is_empty() {
      continue
    }
    let mesh = data.build_mesh()
    let skin = data.build_skin()
    let color = if style == Worn {
      part.color
    } else {
      hex_to_vec4(
        if part.name == "brass" || part.name == "cloth" {
          trim_color
        } else {
          main_color
        },
      )
    }
    parts.push({
      name: prefix + part.name,
      mesh,
      skin,
      color,
      packed: @skeleton3d.build_skinned_vertex_data(mesh, skin),
    })
  }
  let shell = @procedural3d.RigidGeometry::new()
  let trim = @procedural3d.RigidGeometry::new()
  let gem = @procedural3d.RigidGeometry::new()
  match slot {
    @game.Helmet =>
      if style != Worn {
        // Open crown: faces, long ears, muzzle and jaw remain species-owned.
        shell.loft(
          0.0,
          -0.025,
          [
            (1.20, 0.31, 0.27),
            (1.36, 0.28, 0.23),
            (if style == Occult { 1.61 } else { 1.43 }, 0.06, 0.05),
          ],
          8,
          5,
        )
        trim.loft(0.0, -0.025, [(1.20, 0.32, 0.28), (1.245, 0.32, 0.28)], 8, 5)
        if style == Leather {
          shell.box(0.0, 1.21, 0.22, 0.65, 0.03, 0.20, 5)
        }
        if style == Plate {
          trim.box(0.0, 1.37, -0.015, 0.055, 0.23, 0.42, 5)
        }
        gem.box(0.0, 1.28, 0.25, 0.08, 0.08, 0.035, 5)
      }
    @game.Armor =>
      if style != Worn {
        for side in [-1.0, 1.0] {
          let joint = if side < 0.0 { 6 } else { 2 }
          shell.loft(
            side * 0.255,
            0.0,
            [(0.59, 0.12, 0.13), (0.68, 0.15, 0.15), (0.73, 0.09, 0.09)],
            6,
            joint,
          )
          if style == Occult {
            gem.loft(
              side * 0.29,
              0.0,
              [(0.70, 0.055, 0.055), (0.85, 0.0, 0.0)],
              4,
              joint,
            )
          }
        }
        if style == Plate {
          shell.box(0.0, 0.565, 0.145, 0.32, 0.19, 0.055, 1)
        }
        trim.box(0.0, 0.49, 0.18, 0.28, 0.04, 0.025, 1)
      }
    @game.Gloves =>
      if style != Worn {
        for side in [-1.0, 1.0] {
          let joint = if side < 0.0 { 7 } else { 3 }
          shell.box(side * 0.30, 0.365, 0.105, 0.14, 0.11, 0.045, joint)
          gem.box(side * 0.30, 0.40, 0.135, 0.055, 0.035, 0.025, joint)
        }
      }
    @game.Boots =>
      if style != Worn {
        for side in [-1.0, 1.0] {
          let joint = if side < 0.0 { 9 } else { 11 }
          shell.box(side * 0.115, 0.20, 0.085, 0.14, 0.15, 0.045, joint)
          trim.box(side * 0.115, 0.08, 0.17, 0.19, 0.06, 0.045, joint)
        }
      }
    @game.Offhand => {
      // Stowed on the back, leaving both hands free for bow, focus and flintlock.
      let radius = if style == Plate { 0.31 } else { 0.25 }
      for i in 0..<8 {
        let a = i.to_double() / 8.0 * @math.PI * 2.0
        let b = (i + 1).to_double() / 8.0 * @math.PI * 2.0
        let p = @math3d.Vec3::new(
          @math.sin(a) * radius,
          0.53 + @math.cos(a) * radius,
          -0.28,
        )
        let q = @math3d.Vec3::new(
          @math.sin(b) * radius,
          0.53 + @math.cos(b) * radius,
          -0.28,
        )
        shell.triangle(@math3d.Vec3::new(0.0, 0.53, -0.34), p, q, 1)
        trim.segment(p, q, 0.018, 0.018, 6, 1)
      }
      trim.box(0.0, 0.53, -0.35, 0.045, 0.34, 0.025, 1)
      trim.box(0.0, 0.53, -0.35, 0.26, 0.045, 0.025, 1)
      gem.box(0.0, 0.53, -0.375, 0.08, 0.08, 0.025, 1)
    }
    @game.Accessory => {
      trim.loft(0.30, 0.025, [(0.32, 0.073, 0.073), (0.35, 0.073, 0.073)], 8, 3)
      gem.box(0.30, 0.338, 0.11, 0.065, 0.045, 0.035, 3)
    }
    @game.Amulet => {
      for side in [-1.0, 1.0] {
        trim.segment(
          @math3d.Vec3::new(side * 0.135, 0.70, 0.18),
          @math3d.Vec3::new(0.0, 0.53, 0.20),
          0.012,
          0.012,
          5,
          1,
        )
      }
      gem.loft(
        0.0,
        0.21,
        [(0.49, 0.0, 0.0), (0.55, 0.065, 0.033), (0.60, 0.0, 0.0)],
        4,
        1,
      )
    }
    _ => ()
  }
  for
    (geometry, name, color) in [
      (shell, "shell", main_color),
      (trim, "trim", trim_color),
      (gem, "gem", gem_color),
    ] {
    if !geometry.indices.is_empty() {
      parts.push(finish_hunter_part(geometry, prefix + name, color))
    }
  }
  parts
}

///|
fn character_weapon_parts(
  weapon : HunterWeaponSet,
  style : GearStyle?,
) -> Array[CharacterPart] {
  match style {
    Some(Leather) | Some(Plate) | Some(Occult) => {
      let (_, color, _) = gear_palette(style.or(Worn))
      weapon.parts.map(part => {
        if part.name == "leather" {
          part
        } else {
          { ..part, color: hex_to_vec4(color), }
        }
      })
    }
    _ => weapon.parts
  }
}
