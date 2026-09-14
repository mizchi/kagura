///|
pub(all) enum TerrainPattern {
  Flat
  Perlin
  DiamondSquare
  Voronoi
  Hybrid
} derive(Eq, Debug, ToJson, FromJson)

///|
pub(all) struct TerrainConfig {
  pattern : TerrainPattern
  seed : Int
  amplitude : Double
  scale : Double
  roughness : Double
} derive(Eq, ToJson, FromJson)

///|
pub fn TerrainConfig::default() -> TerrainConfig {
  { pattern: Perlin, seed: 42, amplitude: 4.0, scale: 18.0, roughness: 0.5, }
}

///|
pub fn TerrainConfig::validated(self : TerrainConfig) -> TerrainConfig {
  fn finite_clamp(
    value : Double,
    fallback : Double,
    lo : Double,
    hi : Double,
  ) -> Double {
    if value.is_nan() {
      fallback
    } else {
      value.clamp(min=lo, max=hi)
    }
  }
  {
    ..self,
    amplitude: finite_clamp(self.amplitude, 4.0, 0.0, 32.0),
    scale: finite_clamp(self.scale, 18.0, 4.0, 128.0),
    roughness: finite_clamp(self.roughness, 0.5, 0.1, 0.85),
  }
}

///|
/// Unit-spaced corner samples. Each cell is split along (0,0)→(1,1).
/// Rendering and collision must use this same triangulation, not bilinear heights.
pub struct HeightField {
  cells_x : Int
  cells_z : Int
  values : Array[Double]
}

///|
pub fn HeightField::new(
  cells_x : Int,
  cells_z : Int,
  values : Array[Double],
) -> HeightField {
  guard cells_x > 0 &&
    cells_z > 0 &&
    values.length() == (cells_x + 1) * (cells_z + 1) else {
    abort("Invalid height field dimensions")
  }
  { cells_x, cells_z, values, }
}

///|
pub fn HeightField::at(self : HeightField, x : Int, z : Int) -> Double {
  self.values[z.clamp(min=0, max=self.cells_z) * (self.cells_x + 1) +
  x.clamp(min=0, max=self.cells_x)]
}

///|
pub fn HeightField::set(
  self : HeightField,
  x : Int,
  z : Int,
  value : Double,
) -> Unit {
  self.values[z * (self.cells_x + 1) + x] = value
}

///|
pub fn HeightField::sample(
  self : HeightField,
  x : Double,
  z : Double,
) -> Double {
  let x = x.clamp(min=0.0, max=self.cells_x.to_double())
  let z = z.clamp(min=0.0, max=self.cells_z.to_double())
  let ix = x.to_int().min(self.cells_x - 1)
  let iz = z.to_int().min(self.cells_z - 1)
  let fx = x - ix.to_double()
  let fz = z - iz.to_double()
  let a = self.at(ix, iz)
  let c = self.at(ix + 1, iz + 1)
  if fx <= fz {
    let b = self.at(ix, iz + 1)
    a + (c - b) * fx + (b - a) * fz
  } else {
    let d = self.at(ix + 1, iz)
    a + (d - a) * fx + (c - d) * fz
  }
}

///|
pub fn HeightField::crop(
  self : HeightField,
  x : Int,
  z : Int,
  cells_x : Int,
  cells_z : Int,
) -> HeightField {
  HeightField::new(
    cells_x,
    cells_z,
    Array::makei((cells_x + 1) * (cells_z + 1), i => {
      self.at(x + i % (cells_x + 1), z + i / (cells_x + 1))
    }),
  )
}

///|
/// Manhattan lower envelope: keeps low road/pad constraints intact and limits
/// each grid edge, hence each triangle's gradient is bounded by sqrt(2)*rise.
pub fn HeightField::limit_slope(self : HeightField, rise : Double) -> Unit {
  let rise = rise.max(0.001)
  for z in 0..<=self.cells_z {
    for x in 0..<=self.cells_x {
      let mut h = self.at(x, z)
      if x > 0 {
        h = h.min(self.at(x - 1, z) + rise)
      }
      if z > 0 {
        h = h.min(self.at(x, z - 1) + rise)
      }
      self.set(x, z, h)
    }
  }
  for z = self.cells_z; z >= 0; z = z - 1 {
    for x = self.cells_x; x >= 0; x = x - 1 {
      let mut h = self.at(x, z)
      if x < self.cells_x {
        h = h.min(self.at(x + 1, z) + rise)
      }
      if z < self.cells_z {
        h = h.min(self.at(x, z + 1) + rise)
      }
      self.set(x, z, h)
    }
  }
}

///|
pub(all) struct HeightFieldStats {
  minimum : Double
  maximum : Double
  max_slope : Double
  triangles : Int
} derive(ToJson)

///|
pub fn HeightField::statistics(self : HeightField) -> HeightFieldStats {
  let mut minimum = self.values[0]
  let mut maximum = minimum
  let mut max_slope = 0.0
  for h in self.values {
    minimum = minimum.min(h)
    maximum = maximum.max(h)
  }
  for z in 0..<self.cells_z {
    for x in 0..<self.cells_x {
      max_slope = max_slope.max(self.cell_slope(x, z))
    }
  }
  { minimum, maximum, max_slope, triangles: self.cells_x * self.cells_z * 2, }
}

///|
pub fn generate_height_field(
  cells_x : Int,
  cells_z : Int,
  config : TerrainConfig,
) -> HeightField {
  let cells_x = cells_x.clamp(min=1, max=512)
  let cells_z = cells_z.clamp(min=1, max=512)
  let config = config.validated()
  let field = HeightField::new(
    cells_x,
    cells_z,
    Array::make((cells_x + 1) * (cells_z + 1), 0.0),
  )
  if config.pattern == Flat || config.amplitude == 0.0 {
    return field
  }
  if config.pattern == DiamondSquare {
    return diamond_square_height_field(cells_x, cells_z, config)
  }
  for z in 0..<=cells_z {
    for x in 0..<=cells_x {
      let px = x.to_double() / config.scale
      let pz = z.to_double() / config.scale
      let value = match config.pattern {
        Voronoi => cellular_relief(px, pz, config.seed)
        Hybrid =>
          cellular_relief(px, pz, config.seed) * 0.65 +
          fractal_perlin(px, pz, config.seed, config.roughness) * 0.35
        _ => fractal_perlin(px, pz, config.seed, config.roughness)
      }
      field.set(x, z, value.clamp(min=0.0, max=1.0) * config.amplitude)
    }
  }
  field
}
