///|
/// Intersect the same two triangles used by `sample`, visiting only cells along
/// the ray with a 2D DDA. Direction need not be normalized; max_distance bounds
/// the ray parameter (world distance when direction has unit length).
pub fn HeightField::raycast(
  self : HeightField,
  ox : Double,
  oy : Double,
  oz : Double,
  dx : Double,
  dy : Double,
  dz : Double,
  max_distance? : Double = 256.0,
) -> (Double, Double, Double)? {
  if [ox, oy, oz, dx, dy, dz, max_distance].any(v => {
      v.is_nan() || v.abs() > 1.0e12
    }) ||
    max_distance <= 0.0 {
    return None
  }
  let mut enter = 0.0
  let mut leave = max_distance
  for
    (origin, direction, bound) in [
      (ox, dx, self.cells_x.to_double()),
      (oz, dz, self.cells_z.to_double()),
    ] {
    if direction.abs() < 1.0e-10 {
      if origin < 0.0 || origin > bound {
        return None
      }
    } else {
      let a = -origin / direction
      let b = (bound - origin) / direction
      enter = enter.max(a.min(b))
      leave = leave.min(a.max(b))
    }
  }
  if enter > leave {
    return None
  }
  let mut t = enter
  for _ in 0..<(self.cells_x + self.cells_z + 2) {
    let x = (ox +
      dx * t +
      (if dx > 0.0 { 1.0e-8 } else if dx < 0.0 { -1.0e-8 } else { 0.0 }))
      .floor()
      .to_int()
      .max(0)
      .min(self.cells_x - 1)
    let z = (oz +
      dz * t +
      (if dz > 0.0 { 1.0e-8 } else if dz < 0.0 { -1.0e-8 } else { 0.0 }))
      .floor()
      .to_int()
      .max(0)
      .min(self.cells_z - 1)
    let next_x = if dx.abs() < 1.0e-10 {
      leave
    } else {
      ((if dx > 0.0 { x + 1 } else { x }).to_double() - ox) / dx
    }
    let next_z = if dz.abs() < 1.0e-10 {
      leave
    } else {
      ((if dz > 0.0 { z + 1 } else { z }).to_double() - oz) / dz
    }
    let end = leave.min(next_x).min(next_z)
    let a = self.at(x, z)
    let b = self.at(x, z + 1)
    let c = self.at(x + 1, z + 1)
    let d = self.at(x + 1, z)
    let mut closest : Double? = None
    for triangle in 0..<2 {
      let gx = if triangle == 0 { c - b } else { d - a }
      let gz = if triangle == 0 { b - a } else { c - d }
      let denominator = dy - gx * dx - gz * dz
      if denominator.abs() < 1.0e-10 {
        continue
      }
      let hit = (a + gx * (ox - x.to_double()) + gz * (oz - z.to_double()) - oy) /
        denominator
      if hit < t - 1.0e-8 || hit > end + 1.0e-8 {
        continue
      }
      let fx = ox + dx * hit - x.to_double()
      let fz = oz + dz * hit - z.to_double()
      if (triangle == 0 && fx <= fz + 1.0e-8) ||
        (triangle == 1 && fx >= fz - 1.0e-8) {
        closest = Some(closest.map(v => v.min(hit)).or(hit))
      }
    }
    if closest is Some(hit) {
      return Some((ox + dx * hit, oy + dy * hit, oz + dz * hit))
    }
    if end >= leave {
      break
    }
    t = end
  }
  None
}
