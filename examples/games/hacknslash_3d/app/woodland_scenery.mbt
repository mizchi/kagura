///|
fn woodland_asset_kind(biome : Int, hash : Int) -> Int {
  if biome == 1 {
    return [1, 2, 6, 1, 2, 5][hash % 6]
  }
  if biome == 2 {
    return [4, 5, 1, 4, 2, 5][hash % 6]
  }
  [0, 4, 5, 2, 6, 4, 0, 1][hash % 8]
}

///|
fn woodland_grass_allowed(
  dungeon : @game.DungeonData,
  x : Int,
  z : Int,
) -> Bool {
  if dungeon.grid.get(x, z) != @terrain.Floor {
    return false
  }
  if dungeon.landscape is Some(land) && land.kind(x, z) != @game.Land {
    return false
  }
  if dungeon.terrain_surface is Some(field) && field.cell_slope(x, z) > 0.50 {
    return false
  }
  for dz in -1..<=1 {
    for dx in -1..<=1 {
      if dungeon.grid.get(x + dx, z + dz) == @terrain.Corridor {
        return false
      }
    }
  }
  for room in dungeon.rooms {
    let center = room.rect.center()
    if (center.x - x).abs() < 3 && (center.y - z).abs() < 3 {
      return false
    }
  }
  true
}

///|
/// Broadleaf oak, wind-bent birch and a shattered stump share existing materials.
fn make_woodland_tree(kind : Int) -> HuntingAsset {
  let bark = @procedural3d.RigidGeometry::new()
  let leaves = @procedural3d.RigidGeometry::new()
  let tips = @procedural3d.RigidGeometry::new()
  bark.loft(
    0.0,
    0.0,
    [
      (0.0, 0.38, 0.36),
      (0.18, 0.25, 0.25),
      (if kind == 2 { 0.68 } else { 1.7 }, 0.17, 0.14),
      (if kind == 2 { 0.95 } else { 2.65 }, 0.05, 0.04),
    ],
    6,
    0,
  )
  for i in 0..<4 {
    let angle = i.to_double() * 1.7
    let reach = if kind == 1 { 0.5 } else { 0.76 }
    let x = @math.cos(angle) * reach
    let z = @math.sin(angle) * reach
    let y = if kind == 2 {
      0.30 + i.to_double() * 0.08
    } else {
      1.62 + i.to_double() * 0.27
    }
    hunting_branch(
      bark,
      @math3d.Vec3::new(0.0, (y - 0.35).max(0.22), 0.0),
      @math3d.Vec3::new(x, y, z),
      0.11,
    )
    if kind != 2 {
      let g = if i % 2 == 0 { leaves } else { tips }
      let r = if kind == 1 { 0.46 } else { 0.71 }
      g.loft(
        x,
        z,
        [
          (y - 0.05, r * 0.3, r * 0.3),
          (y + 0.1, r, r * 0.8),
          (y + 0.5, r * 0.75, r * 0.7),
          (y + 0.78, 0.03, 0.02),
        ],
        6,
        0,
      )
    }
  }
  let parts = [hunting_part(bark, if kind == 1 { 9 } else { 3 })]
  if kind != 2 {
    parts.push(hunting_part(leaves, 4))
    parts.push(hunting_part(tips, 5))
  }
  { name: ["windworn-oak", "silver-birch", "shattered-stump"][kind], parts, }
}

///|
/// Small authored silhouettes placed on existing masonry footprints.
fn make_wayside_relic(kind : Int) -> HuntingAsset {
  let stone = @procedural3d.RigidGeometry::new()
  let dark = @procedural3d.RigidGeometry::new()
  stone.box(0.0, 0.07, 0.0, 0.96, 0.14, 0.92, 0)
  if kind == 0 {
    for side in [-1.0, 1.0] {
      stone.box(side * 0.34, 0.72, 0.0, 0.24, 1.3, 0.52, 0)
      for i in 0..<3 {
        stone.box(
          side * (0.30 - i.to_double() * 0.11),
          1.38 + i.to_double() * 0.2,
          0.0,
          0.24,
          0.28,
          0.50,
          0,
        )
      }
    }
    stone.box(0.0, 2.0, 0.0, 0.24, 0.45, 0.42, 0)
  } else if kind == 1 {
    stone.loft(
      0.0,
      0.0,
      [
        (0.14, 0.4, 0.36),
        (0.4, 0.32, 0.28),
        (1.7, 0.24, 0.19),
        (2.12, 0.4, 0.27),
        (2.7, 0.02, 0.03),
      ],
      6,
      0,
    )
    dark.box(0.0, 2.12, 0.25, 0.23, 0.27, 0.05, 0)
    stone.box(0.0, 1.1, 0.32, 0.72, 0.13, 0.13, 0)
  } else {
    for i in 0..<3 {
      stone.loft(
        (i - 1).to_double() * 0.28,
        0.0,
        [(0.14, 0.13, 0.35), (0.36, 0.15, 0.39), (0.61, 0.08, 0.27)],
        5,
        0,
      )
    }
    dark.box(0.13, 0.63, 0.09, 0.28, 0.06, 0.34, 0)
  }
  let parts = [hunting_part(stone, 6)]
  if !dark.indices.is_empty() {
    parts.push(hunting_part(dark, 17))
  }
  {
    name: [
      "broken-ossuary-arch", "hooded-pilgrim-effigy", "fallen-fluted-column",
    ][kind],
    parts,
  }
}
