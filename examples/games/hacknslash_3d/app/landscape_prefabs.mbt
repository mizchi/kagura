///|
/// Authored modular timber crossing. The navigation contract owns the span;
/// planks follow exactly the same triangle-sampled deck as characters.
fn append_landscape_bridge(
  accum : Array[@procedural3d.RigidGeometry],
  dungeon : @game.DungeonData,
  span : @terrain3d.TerrainRoute,
) -> Unit {
  let dx = span.bx - span.ax
  let dz = span.bz - span.az
  let length = (dx * dx + dz * dz).sqrt()
  if length < 0.1 {
    return
  }
  let nx = -dz / length
  let nz = dx / length
  let steps = (length / 0.48).to_int().max(1)
  fn p(t : Double, side : Double, lift : Double) -> @math3d.Vec3 {
    let x = span.ax + dx * t + nx * side
    let z = span.az + dz * t + nz * side
    @math3d.Vec3::new(
      x,
      @game.get_tile_height(dungeon, x * tile_size, z * tile_size) + lift,
      z,
    )
  }
  for i in 0..<steps {
    let a = i.to_double() / steps.to_double()
    let b = (i.to_double() + 0.94) / steps.to_double()
    let g = accum[if i % 4 == 0 { 3 } else { 18 }]
    let w = span.width
    g.quad(p(a, w, 0.016), p(b, w, 0.016), p(b, -w, 0.016), p(a, -w, 0.016), 0)
  }
  // Handrails sit beyond the navigable strip. Cross braces and piles read as
  // a structure spanning water, rather than an earth road painted brown.
  for side in [-1.0, 1.0] {
    let w = side * (span.width + 0.25)
    let n = (length / 2.4).to_int().max(1)
    for i in 0..<=n {
      let t = i.to_double() / n.to_double()
      let a = p(t, w, 0.0)
      hunting_branch(accum[3], a, @math3d.Vec3::new(a.x, -3.7, a.z), 0.13)
      hunting_branch(accum[18], a, p(t, w, 1.0), 0.09)
      if i < n {
        let b = (i + 1).to_double() / n.to_double()
        hunting_branch(accum[18], p(t, w, 0.9), p(b, w, 0.9), 0.065)
        hunting_branch(accum[3], p(t, w, -0.3), p(b, w, -1.1), 0.09)
      }
    }
  }
}

///|
/// A rock gallery with two open mouths and a separate roof material. No hidden
/// teleport: enemies and the player use the same continuous grid under it.
fn append_landscape_cave(
  accum : Array[@procedural3d.RigidGeometry],
  dungeon : @game.DungeonData,
  cave : @terrain3d.TerrainRoute,
) -> Unit {
  let x = cave.ax
  for i in 0..<5 {
    let za = 12.0 + i.to_double() * 2.6
    let zb = za + 2.6
    fn p(dx : Double, z : Double, h : Double) -> @math3d.Vec3 {
      @math3d.Vec3::new(
        x + dx,
        @game.get_tile_height(dungeon, x * tile_size, z * tile_size) + h,
        z,
      )
    }
    let ridge = 5.7 + @math.sin(i.to_double() * 1.7) * 0.45
    let next_ridge = 5.7 + @math.sin((i + 1).to_double() * 1.7) * 0.45
    for side in [-1.0, 1.0] {
      let wall = accum[22]
      let a = p(side * 2.5, za, 0.0)
      let b = p(side * 2.5, zb, 0.0)
      let c = p(side * 2.7, zb, 4.0)
      let d = p(side * 2.7, za, 4.0)
      if side < 0.0 {
        wall.quad(d, c, b, a, 0)
      } else {
        wall.quad(a, b, c, d, 0)
      }
      let outer = accum[6]
      let e = p(side * 6.0, za, -0.1)
      let f = p(side * 6.0, zb, -0.1)
      let ca = p(side * 3.6, za, ridge)
      let cb = p(side * 3.6, zb, next_ridge)
      let ia = p(side * 2.7, za, 4.0)
      let ib = p(side * 2.7, zb, 4.0)
      if side < 0.0 {
        outer.quad(f, cb, ca, e, 0)
        outer.quad(ca, cb, ib, ia, 0)
      } else {
        outer.quad(e, ca, cb, f, 0)
        outer.quad(ia, ib, cb, ca, 0)
      }
    }
    accum[23].quad(
      p(-3.6, za, ridge),
      p(-3.6, zb, next_ridge),
      p(3.6, zb, next_ridge),
      p(3.6, za, ridge),
      0,
    )
    accum[23].quad(
      p(2.7, za, 4.0),
      p(2.7, zb, 4.0),
      p(-2.7, zb, 4.0),
      p(-2.7, za, 4.0),
      0,
    )
    if i == 0 {
      accum[23].quad(
        p(3.6, za, 4.0),
        p(3.6, za, ridge),
        p(-3.6, za, ridge),
        p(-3.6, za, 4.0),
        0,
      )
    }
    if i == 4 {
      accum[23].quad(
        p(-3.6, zb, 4.0),
        p(-3.6, zb, next_ridge),
        p(3.6, zb, next_ridge),
        p(3.6, zb, 4.0),
        0,
      )
    }
    if i % 2 == 0 {
      // Old mine supports provide scale and warm navigation cues.
      for side in [-1.0, 1.0] {
        hunting_branch(
          accum[3],
          p(side * 2.35, za, 0.0),
          p(side * 2.35, za, 3.8),
          0.13,
        )
        accum[8].loft(
          x + side * 2.25,
          za,
          [(p(0.0, za, 1.4).y, 0.09, 0.09), (p(0.0, za, 1.8).y, 0.13, 0.13)],
          5,
          0,
        )
      }
      hunting_branch(accum[3], p(-2.35, za, 3.8), p(2.35, za, 3.8), 0.16)
    }
  }
  // Uneven stone lips around each mouth; center stays open all the way through.
  for z in [12.0, 25.0] {
    let y = @game.get_tile_height(dungeon, x * tile_size, z * tile_size)
    for side in [-1.0, 1.0] {
      accum[6].loft(
        x + side * 3.8,
        z,
        [(y, 1.4, 1.4), (y + 3.6, 1.2, 1.0), (y + 5.4, 0.45, 0.65)],
        5,
        0,
      )
    }
  }
}

///|
/// A ruined beacon above the sea. A large silhouette matters at a distance;
/// its small steps and buttresses belong only to the near mesh.
fn append_landscape_beacon(
  accum : Array[@procedural3d.RigidGeometry],
  dungeon : @game.DungeonData,
) -> Unit {
  let x = 15.5
  let z = 55.5
  let y = @game.get_tile_height(dungeon, x * tile_size, z * tile_size)
  accum[13].loft(
    x,
    z,
    [
      (y, 1.6, 1.6),
      (y + 0.45, 1.4, 1.4),
      (y + 5.8, 0.85, 0.85),
      (y + 6.4, 1.05, 1.05),
    ],
    7,
    0,
  )
  accum[17].loft(x, z, [(y + 6.4, 0.78, 0.78), (y + 6.8, 0.78, 0.78)], 7, 0)
  accum[8].loft(x, z, [(y + 6.8, 0.4, 0.4), (y + 7.8, 0.08, 0.08)], 5, 0)
  for a in 0..<4 {
    let angle = a.to_double() * @math.PI / 2.0
    hunting_branch(
      accum[6],
      @math3d.Vec3::new(
        x + @math.cos(angle) * 2.0,
        y,
        z + @math.sin(angle) * 2.0,
      ),
      @math3d.Vec3::new(
        x + @math.cos(angle) * 1.0,
        y + 2.6,
        z + @math.sin(angle) * 1.0,
      ),
      0.3,
    )
  }
}
