// Species are decorations over a shared, colorless 12-joint biped.
// Palette batches stay instanced; faces, weapons and clothing are real geometry.

///|
struct EnemyMaterialPart {
  name : String
  geometry : @scene3d.SkinnedMeshAsset
  color : @math3d.Vec4
}

///|
fn monster_material(
  name : String,
  geometry : @procedural3d.RigidGeometry,
  color : Int,
) -> EnemyMaterialPart {
  let mesh = geometry.build_mesh()
  let skin = geometry.build_skin()
  {
    name,
    geometry: @scene3d.SkinnedMeshAsset::new(mesh, skin),
    color: hex_to_vec4(color),
  }
}

///|
fn monster_ear(
  g : @procedural3d.RigidGeometry,
  root : @math3d.Vec3,
  tip : @math3d.Vec3,
  half_height : Double,
) -> Unit {
  let a = root.add(@math3d.Vec3::new(0.0, half_height, -0.015))
  let b = root.add(@math3d.Vec3::new(0.0, -half_height, 0.025))
  let c = root.add(@math3d.Vec3::new(0.0, 0.0, -0.11))
  g.triangle(a, tip, b, 2)
  g.triangle(b, tip, c, 2)
  g.triangle(c, tip, a, 2)
  g.triangle(a, b, c, 2)
}

///|
fn monster_eyes(
  dark : @procedural3d.RigidGeometry,
  glow : @procedural3d.RigidGeometry,
  y : Double,
  z : Double,
  skull : Bool,
) -> Unit {
  for side in [-1.0, 1.0] {
    dark.box(
      side * 0.09,
      y,
      z,
      0.105,
      if skull {
        0.105
      } else {
        0.065
      },
      0.035,
      2,
    )
    glow.box(side * 0.09, y, z + 0.023, 0.033, 0.028, 0.014, 2)
  }
}

///|
fn build_monster_mesh_data(
  species : @game.EnemySpecies,
  armor? : Int = 0,
) -> EnemyMeshData {
  let goblin = species == @game.Goblin
  let kobold = species == @game.Kobold
  let defaults = @procedural3d.default_biped_proportions()
  let proportions = if goblin {
    { ..defaults, head_width: 0.255, head_height: 0.43, torso_width: 0.19, }
  } else if kobold {
    {
      ..defaults,
      head_width: 0.205,
      head_depth: 0.205,
      torso_width: 0.145,
      limb_radius: 0.055,
    }
  } else {
    { ..defaults, head_width: 0.205, torso_width: 0.15, limb_radius: 0.033, }
  }
  let base = @procedural3d.build_biped_base(proportions)
  let flesh = @procedural3d.RigidGeometry::new()
  let cloth = @procedural3d.RigidGeometry::new()
  let dark = @procedural3d.RigidGeometry::new()
  let iron = @procedural3d.RigidGeometry::new()
  let glow = @procedural3d.RigidGeometry::new()
  flesh.append(base.arms)
  if goblin || kobold {
    flesh.append(base.head)
    flesh.append(base.torso)
    dark.append(base.legs)
    // Loincloth and a broad scarf break up the silhouette and remain visible above grass.
    cloth.loft(
      0.0,
      0.0,
      [(0.29, 0.19, 0.15), (0.43, 0.17, 0.14), (0.48, 0.18, 0.15)],
      6,
      1,
    )
    cloth.loft(
      0.0,
      0.0,
      [(0.66, 0.17, 0.13), (0.72, 0.20, 0.15), (0.77, 0.16, 0.12)],
      8,
      1,
    )
    dark.box(0.0, 0.47, 0.0, 0.39, 0.047, 0.32, 1)
    iron.box(0.0, 0.47, 0.17, 0.073, 0.068, 0.025, 1)
    if goblin {
      for side in [-1.0, 1.0] {
        monster_ear(
          flesh,
          @math3d.Vec3::new(side * 0.20, 1.02, 0.0),
          @math3d.Vec3::new(side * 0.51, 1.16, -0.03),
          0.105,
        )
        monster_ear(
          cloth,
          @math3d.Vec3::new(side * 0.24, 1.04, 0.035),
          @math3d.Vec3::new(side * 0.44, 1.13, 0.005),
          0.048,
        )
        flesh.box(side * 0.09, 1.045, 0.19, 0.14, 0.04, 0.06, 2)
      }
      monster_eyes(dark, glow, 0.999, 0.192, false)
      let nose = @math3d.Vec3::new(0.0, 0.915, 0.335)
      flesh.triangle(
        @math3d.Vec3::new(-0.06, 0.99, 0.18),
        nose,
        @math3d.Vec3::new(0.06, 0.99, 0.18),
        2,
      )
      flesh.triangle(
        @math3d.Vec3::new(0.06, 0.99, 0.18),
        nose,
        @math3d.Vec3::new(0.0, 0.90, 0.16),
        2,
      )
      flesh.triangle(
        @math3d.Vec3::new(0.0, 0.90, 0.16),
        nose,
        @math3d.Vec3::new(-0.06, 0.99, 0.18),
        2,
      )
      dark.box(0.0, 0.86, 0.19, 0.14, 0.026, 0.026, 2)
      for side in [-1.0, 1.0] {
        iron.box(side * 0.055, 0.872, 0.211, 0.027, 0.047, 0.025, 2)
      }
      // Cleaver and wooden buckler follow the forearms.
      dark.box(0.31, 0.37, 0.12, 0.045, 0.19, 0.045, 6)
      iron.box(0.355, 0.60, 0.12, 0.16, 0.31, 0.046, 6)
      iron.triangle(
        @math3d.Vec3::new(0.275, 0.755, 0.143),
        @math3d.Vec3::new(0.435, 0.755, 0.143),
        @math3d.Vec3::new(0.405, 0.83, 0.143),
        6,
      )
      cloth.segment(
        @math3d.Vec3::new(-0.31, 0.40, 0.075),
        @math3d.Vec3::new(-0.31, 0.40, 0.135),
        0.16,
        0.16,
        8,
        4,
      )
      iron.box(-0.31, 0.40, 0.145, 0.12, 0.032, 0.024, 4)
    } else {
      // Canine muzzle, black nose, tall ears and a bent, animated tail.
      flesh.loft(
        0.0,
        0.23,
        [(0.855, 0.11, 0.13), (0.94, 0.13, 0.17), (1.00, 0.085, 0.11)],
        6,
        2,
      )
      dark.box(0.0, 0.956, 0.392, 0.105, 0.069, 0.04, 2)
      dark.box(0.0, 0.866, 0.318, 0.16, 0.018, 0.04, 2)
      monster_eyes(dark, glow, 1.045, 0.16, false)
      for side in [-1.0, 1.0] {
        monster_ear(
          flesh,
          @math3d.Vec3::new(side * 0.15, 1.12, -0.02),
          @math3d.Vec3::new(side * 0.29, 1.40, -0.08),
          0.08,
        )
        monster_ear(
          dark,
          @math3d.Vec3::new(side * 0.17, 1.16, 0.008),
          @math3d.Vec3::new(side * 0.26, 1.35, -0.04),
          0.035,
        )
      }
      flesh.segment(
        @math3d.Vec3::new(0.0, 0.42, -0.10),
        @math3d.Vec3::new(0.02, 0.29, -0.38),
        0.085,
        0.07,
        6,
        11,
      )
      flesh.segment(
        @math3d.Vec3::new(0.02, 0.29, -0.38),
        @math3d.Vec3::new(0.18, 0.41, -0.63),
        0.07,
        0.048,
        6,
        11,
      )
      dark.segment(
        @math3d.Vec3::new(0.18, 0.41, -0.63),
        @math3d.Vec3::new(0.23, 0.62, -0.69),
        0.05,
        0.009,
        6,
        11,
      )
      dark.segment(
        @math3d.Vec3::new(0.34, 0.16, 0.14),
        @math3d.Vec3::new(0.34, 1.18, 0.14),
        0.022,
        0.022,
        6,
        6,
      )
      iron.loft(
        0.34,
        0.14,
        [(1.12, 0.015, 0.012), (1.20, 0.066, 0.021), (1.39, 0.003, 0.003)],
        4,
        6,
      )
      cloth.box(0.34, 1.08, 0.14, 0.09, 0.10, 0.06, 6)
    }
  } else {
    flesh.append(base.legs)
    // Open ribcage: discrete ribs and spine leave real gaps, not a painted torso.
    flesh.segment(
      @math3d.Vec3::new(0.0, 0.39, -0.035),
      @math3d.Vec3::new(0.0, 0.75, -0.035),
      0.036,
      0.026,
      6,
      1,
    )
    for y in [0.51, 0.575, 0.64] {
      for side in [-1.0, 1.0] {
        flesh.segment(
          @math3d.Vec3::new(side * 0.015, y, 0.115),
          @math3d.Vec3::new(side * 0.155, y + 0.015, 0.045),
          0.023,
          0.020,
          5,
          1,
        )
        flesh.segment(
          @math3d.Vec3::new(side * 0.155, y + 0.015, 0.045),
          @math3d.Vec3::new(side * 0.09, y + 0.025, -0.09),
          0.020,
          0.021,
          5,
          1,
        )
      }
    }
    flesh.box(0.0, 0.58, 0.123, 0.038, 0.22, 0.037, 1)
    flesh.box(0.0, 0.675, 0.02, 0.38, 0.033, 0.07, 1)
    flesh.box(0.0, 0.397, 0.0, 0.27, 0.04, 0.17, 0)
    for side in [-1.0, 1.0] {
      flesh.box(side * 0.115, 0.365, 0.0, 0.042, 0.09, 0.14, 0)
      flesh.box(
        side * 0.105,
        0.22,
        0.045,
        0.075,
        0.07,
        0.05,
        if side < 0.0 {
          8
        } else {
          10
        },
      )
    }
    // Cranium, detached jaw, eye sockets, nasal cavity and individual teeth.
    flesh.loft(
      0.0,
      0.0,
      [
        (0.87, 0.16, 0.13),
        (0.98, 0.23, 0.19),
        (1.16, 0.205, 0.19),
        (1.235, 0.13, 0.12),
      ],
      8,
      2,
    )
    flesh.box(0.0, 0.81, 0.06, 0.27, 0.055, 0.21, 2)
    for side in [-1.0, 1.0] {
      flesh.box(side * 0.137, 0.86, -0.012, 0.036, 0.115, 0.11, 2)
    }
    monster_eyes(dark, glow, 1.032, 0.174, true)
    dark.triangle(
      @math3d.Vec3::new(-0.04, 0.944, 0.185),
      @math3d.Vec3::new(0.04, 0.944, 0.185),
      @math3d.Vec3::new(0.0, 0.985, 0.207),
      2,
    )
    for x in [-0.087, -0.043, 0.0, 0.043, 0.087] {
      flesh.box(x, 0.877, 0.136, 0.032, 0.064, 0.057, 2)
      flesh.box(x, 0.846, 0.151, 0.027, 0.036, 0.031, 2)
    }
    cloth.box(0.0, 0.40, -0.08, 0.28, 0.12, 0.095, 0)
    cloth.box(0.07, 0.325, -0.10, 0.15, 0.18, 0.045, 0)
    cloth.segment(
      @math3d.Vec3::new(0.105, 0.43, -0.16),
      @math3d.Vec3::new(0.105, 0.75, -0.16),
      0.068,
      0.068,
      6,
      1,
    )
    for x in [0.08, 0.13] {
      iron.segment(
        @math3d.Vec3::new(x, 0.68, -0.16),
        @math3d.Vec3::new(x, 0.88, -0.16),
        0.009,
        0.009,
        4,
        1,
      )
    }
    let bow = [
      @math3d.Vec3::new(-0.31, 0.16, 0.12),
      @math3d.Vec3::new(-0.40, 0.31, 0.22),
      @math3d.Vec3::new(-0.40, 0.57, 0.22),
      @math3d.Vec3::new(-0.31, 0.74, 0.12),
    ]
    for i in 1..<bow.length() {
      dark.segment(bow[i - 1], bow[i], 0.024, 0.020, 5, 4)
    }
    iron.segment(bow[0], bow[3], 0.005, 0.005, 4, 4)
  }
  // Heavy variants reuse the species silhouette and add readable armor.
  if armor > 0 {
    iron.loft(
      0.0,
      0.0,
      [(1.08, 0.27, 0.22), (1.20, 0.23, 0.19), (1.31, 0.10, 0.09)],
      8,
      2,
    )
    for side in [-1.0, 1.0] {
      iron.box(
        side * 0.25,
        0.70,
        0.0,
        0.22,
        0.14,
        0.24,
        if side < 0.0 {
          3
        } else {
          5
        },
      )
      if armor == 2 {
        iron.segment(
          @math3d.Vec3::new(side * 0.20, 1.2, 0.0),
          @math3d.Vec3::new(side * 0.32, 1.52, -0.05),
          0.065,
          0.006,
          5,
          2,
        )
      }
    }
  }
  let parts = [
    monster_material(
      if goblin || kobold {
        "skin"
      } else {
        "bone"
      },
      flesh,
      if goblin {
        0x94AB65
      } else if kobold {
        0xAC7045
      } else {
        0xD2CFB2
      },
    ),
    monster_material("cloth", cloth, if kobold { 0x3F6B73 } else { 0x8B4B43 }),
    monster_material("shadow", dark, if kobold { 0x372B27 } else { 0x293131 }),
    monster_material("iron", iron, 0xA3AAA3),
    monster_material(
      "eyes",
      glow,
      if goblin || kobold {
        0xFFD080
      } else {
        0x8DDCD5
      },
    ),
  ]
  let combined = @procedural3d.RigidGeometry::new()
  for g in [flesh, cloth, dark, iron, glow] {
    combined.append(g)
  }
  let mesh = combined.build_mesh()
  let skin = combined.build_skin()
  { geometry: @scene3d.SkinnedMeshAsset::new(mesh, skin), parts, }
}
