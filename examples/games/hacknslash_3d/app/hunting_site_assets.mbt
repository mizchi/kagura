///|
fn make_ruin_wall(variant : Int) -> HuntingAsset {
  let stone = @procedural3d.RigidGeometry::new()
  let pale = @procedural3d.RigidGeometry::new()
  let moss = @procedural3d.RigidGeometry::new()
  stone.box(0.0, 0.12, 0.0, 0.98, 0.24, 0.98, 0)
  for row in 0..<(2 + variant) {
    for side in [-1.0, 1.0] {
      let x = side * 0.24
      let y = 0.24 + row.to_double() * 0.32 + 0.15
      let g = if (row + variant) % 3 == 0 { pale } else { stone }
      g.box(x, y, 0.0, 0.455, 0.30, 0.90, 0)
    }
  }
  let top = 0.24 + (2 + variant).to_double() * 0.32
  stone.loft(
    -0.14,
    0.0,
    [(top, 0.31, 0.43), (top + 0.22, 0.16, 0.25), (top + 0.29, 0.015, 0.12)],
    5,
    0,
  )
  moss.box(0.22, 0.255, 0.25, 0.40, 0.035, 0.43, 0)
  {
    name: "broken-masonry",
    parts: [
      hunting_part(stone, 6),
      hunting_part(pale, 9),
      hunting_part(moss, 7),
    ],
  }
}

///|
fn make_ruin_column() -> HuntingAsset {
  let stone = @procedural3d.RigidGeometry::new()
  stone.box(0.0, 0.10, 0.0, 0.98, 0.20, 0.98, 0)
  stone.loft(
    0.0,
    0.0,
    [
      (0.2, 0.37, 0.37),
      (0.35, 0.29, 0.29),
      (1.75, 0.26, 0.26),
      (1.90, 0.37, 0.37),
      (2.07, 0.36, 0.36),
      (2.26, 0.08, 0.16),
    ],
    6,
    0,
  )
  let seams = @procedural3d.RigidGeometry::new()
  for y in [0.70, 1.30] {
    seams.loft(0.0, 0.0, [(y, 0.29, 0.29), (y + 0.055, 0.29, 0.29)], 6, 0)
  }
  {
    name: "shattered-chapel-column",
    parts: [hunting_part(stone, 6), hunting_part(seams, 9)],
  }
}

///|
fn make_camp_tent(canvas? : Int = 15) -> HuntingAsset {
  let cloth = @procedural3d.RigidGeometry::new()
  let trim = @procedural3d.RigidGeometry::new()
  let poles = @procedural3d.RigidGeometry::new()
  for side in [-1.0, 1.0] {
    let a = @math3d.Vec3::new(side * 1.44, 0.10, -0.93)
    let b = @math3d.Vec3::new(side * 1.44, 0.10, 0.93)
    let c = @math3d.Vec3::new(0.0, 1.85, 0.93)
    let d = @math3d.Vec3::new(0.0, 1.85, -0.93)
    if side > 0.0 {
      cloth.quad(a, d, c, b, 0)
    } else {
      cloth.quad(a, b, c, d, 0)
    }
    trim.triangle(b, @math3d.Vec3::new(side * 0.48, 0.05, 0.94), c, 0)
    poles.segment(
      @math3d.Vec3::new(side * 1.43, 0.05, 0.90),
      @math3d.Vec3::new(0.0, 1.88, 0.90),
      0.055,
      0.055,
      4,
      0,
    )
  }
  cloth.triangle(
    @math3d.Vec3::new(-1.44, 0.1, -0.93),
    @math3d.Vec3::new(0.0, 1.85, -0.93),
    @math3d.Vec3::new(1.44, 0.1, -0.93),
    0,
  )
  poles.segment(
    @math3d.Vec3::new(0.0, 0.0, -0.90),
    @math3d.Vec3::new(0.0, 2.03, -0.90),
    0.065,
    0.04,
    5,
    0,
  )
  {
    name: "raider-canvas-tent",
    parts: [
      hunting_part(cloth, canvas),
      hunting_part(trim, if canvas == 15 { 16 } else { 15 }),
      hunting_part(poles, 3),
    ],
  }
}

///|
fn make_camp_palisade() -> HuntingAsset {
  let wood = @procedural3d.RigidGeometry::new()
  let tips = @procedural3d.RigidGeometry::new()
  for i in 0..<3 {
    let x = (i - 1).to_double() * 0.30
    let h = 1.05 + (i % 2).to_double() * 0.20
    wood.loft(x, 0.0, [(0.0, 0.14, 0.32), (h, 0.12, 0.26)], 5, 0)
    tips.loft(x, 0.0, [(h, 0.12, 0.26), (h + 0.27, 0.005, 0.005)], 5, 0)
  }
  wood.box(0.0, 0.45, 0.34, 0.94, 0.13, 0.13, 0)
  {
    name: "sharpened-stockade",
    parts: [hunting_part(wood, 3), hunting_part(tips, 18)],
  }
}

///|
fn make_camp_fire() -> HuntingAsset {
  let stone = @procedural3d.RigidGeometry::new()
  let logs = @procedural3d.RigidGeometry::new()
  let flame = @procedural3d.RigidGeometry::new()
  for i in 0..<8 {
    let angle = i.to_double() * @math.PI / 4.0
    stone.loft(
      @math.cos(angle) * 0.36,
      @math.sin(angle) * 0.36,
      [(0.0, 0.12, 0.12), (0.18, 0.10, 0.10), (0.22, 0.03, 0.03)],
      5,
      0,
    )
  }
  logs.box(0.0, 0.15, 0.0, 0.67, 0.18, 0.19, 0)
  logs.box(0.0, 0.26, 0.0, 0.19, 0.15, 0.67, 0)
  for x in [-0.16, 0.10] {
    flame.loft(
      x,
      0.0,
      [(0.30, 0.14, 0.20), (0.56, 0.18, 0.15), (0.95 + x, 0.01, 0.01)],
      5,
      0,
    )
  }
  {
    name: "watchfire",
    parts: [
      hunting_part(stone, 6),
      hunting_part(logs, 3),
      hunting_part(flame, 8),
    ],
  }
}

///|
fn make_supply_crate() -> HuntingAsset {
  let wood = @procedural3d.RigidGeometry::new()
  let bands = @procedural3d.RigidGeometry::new()
  wood.box(0.0, 0.40, 0.0, 0.90, 0.80, 0.90, 0)
  for x in [-0.34, 0.34] {
    bands.box(x, 0.43, 0.0, 0.11, 0.85, 0.94, 0)
  }
  for y in [0.12, 0.69] {
    bands.box(0.0, y, 0.0, 0.94, 0.10, 0.94, 0)
  }
  {
    name: "raider-supplies",
    parts: [hunting_part(wood, 3), hunting_part(bands, 18)],
  }
}

///|
fn make_road_sign() -> HuntingAsset {
  let wood = @procedural3d.RigidGeometry::new()
  let paint = @procedural3d.RigidGeometry::new()
  wood.box(0.0, 0.85, 0.0, 0.12, 1.7, 0.16, 0)
  for y in [1.20, 1.57] {
    wood.box(0.0, y, 0.0, 0.90, 0.23, 0.17, 0)
    paint.box(0.0, y, 0.092, 0.53, 0.044, 0.018, 0)
  }
  {
    name: "pilgrim-road-sign",
    parts: [hunting_part(wood, 3), hunting_part(paint, 9)],
  }
}

///|
fn make_broken_cart() -> HuntingAsset {
  let wood = @procedural3d.RigidGeometry::new()
  let iron = @procedural3d.RigidGeometry::new()
  for x in [-0.54, -0.27, 0.0, 0.27, 0.54] {
    wood.box(x, 0.44, 0.0, 0.24, 0.13, 1.47, 0)
  }
  for x in [-0.71, 0.71] {
    wood.box(x, 0.73, 0.0, 0.12, 0.52, 1.52, 0)
    iron.segment(
      @math3d.Vec3::new(x - 0.06, 0.30, 0.10),
      @math3d.Vec3::new(x + 0.06, 0.30, 0.10),
      0.30,
      0.30,
      8,
      0,
    )
  }
  wood.box(0.0, 0.72, -0.73, 1.40, 0.49, 0.13, 0)
  {
    name: "abandoned-pilgrim-cart",
    parts: [hunting_part(wood, 18), hunting_part(iron, 17)],
  }
}

///|
let hunting_site_assets : Array[HuntingAsset] = [
  make_ruin_wall(0),
  make_ruin_wall(1),
  make_ruin_wall(2),
  make_ruin_column(),
  make_camp_tent(),
  make_camp_palisade(),
  make_camp_fire(),
  make_supply_crate(),
  make_road_sign(),
  make_broken_cart(),
  make_camp_tent(canvas=16),
]

///|
fn hunting_prop_asset(prop : @game.HuntingProp) -> HuntingAsset {
  hunting_site_assets[match prop.kind {
    @game.RuinWall => prop.variant % 3
    @game.RuinColumn => 3
    @game.Tent => if prop.variant % 2 == 0 { 4 } else { 10 }
    @game.Palisade => 5
    @game.Campfire => 6
    @game.SupplyCrate => 7
    @game.RoadSign => 8
    @game.BrokenCart => 9
  }]
}
