///|
/// Gameplay-owned anchors in unit-spaced heightfield coordinates.
pub(all) struct TerrainPad {
  x : Double
  z : Double
  height : Double
  radius : Double
} derive(ToJson)

///|
pub extend TerrainPad with ToJson::{to_json}

///|
/// A graded segment. Curves and switchbacks are represented by several segments.
pub(all) struct TerrainRoute {
  ax : Double
  az : Double
  ah : Double
  bx : Double
  bz : Double
  bh : Double
  width : Double
} derive(ToJson)

///|
pub extend TerrainRoute with ToJson::{to_json}

///|
pub fn TerrainRoute::projection(
  self : TerrainRoute,
  x : Double,
  z : Double,
) -> (Double, Double) {
  let dx = self.bx - self.ax
  let dz = self.bz - self.az
  let length2 = dx * dx + dz * dz
  let t = if length2 < 0.000001 {
    0.0
  } else {
    (((x - self.ax) * dx + (z - self.az) * dz) / length2).clamp(
      min=0.0,
      max=1.0,
    )
  }
  let ex = x - self.ax - dx * t
  let ez = z - self.az - dz * t
  ((ex * ex + ez * ez).sqrt(), self.ah + (self.bh - self.ah) * t)
}

///|
/// Grade semantic routes before decoration. Nearest footprints win; pads keep
/// combat spaces level. Call limit_slope afterwards if all terrain must be walkable.
pub fn HeightField::grade_routes(
  self : HeightField,
  pads : Array[TerrainPad],
  routes : Array[TerrainRoute],
  blend~ : Double,
) -> Unit {
  let blend = blend.max(0.001)
  for z in 0..<=self.cells_z {
    for x in 0..<=self.cells_x {
      let px = x.to_double()
      let pz = z.to_double()
      let mut distance = blend
      let mut grade = self.at(x, z)
      for route in routes {
        let (d, h) = route.projection(px, pz)
        let d = d - route.width.max(0.0)
        if d < distance {
          distance = d
          grade = h
        }
      }
      for pad in pads {
        let dx = px - pad.x
        let dz = pz - pad.z
        let d = (dx * dx + dz * dz).sqrt() - pad.radius.max(0.0)
        if d <= 0.0 || d < distance {
          distance = d
          grade = pad.height
        }
      }
      if distance < blend {
        let t = (distance / blend).clamp(min=0.0, max=1.0)
        let smooth = t * t * (3.0 - 2.0 * t)
        self.set(x, z, grade * (1.0 - smooth) + self.at(x, z) * smooth)
      }
    }
  }
}

///|
/// Maximum gradient of the two actual rendered triangles, not a bilinear approximation.
pub fn HeightField::cell_slope(self : HeightField, x : Int, z : Int) -> Double {
  let a = self.at(x, z)
  let b = self.at(x, z + 1)
  let c = self.at(x + 1, z + 1)
  let d = self.at(x + 1, z)
  ((c - b) * (c - b) + (b - a) * (b - a))
  .sqrt()
  .max(((d - a) * (d - a) + (c - d) * (c - d)).sqrt())
}
