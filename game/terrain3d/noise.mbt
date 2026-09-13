// Algorithm descriptions and primary references are in README.md. These are
// independent 2D implementations, with seed-based coordinate hashes throughout.

///|
fn terrain_hash(x : Int, z : Int, seed : Int) -> UInt {
  let mut h = (x.to_uint() * 0x9E3779B9U) ^
    (z.to_uint() * 0x85EBCA6BU) ^
    seed.to_uint()
  h = (h ^ (h >> 16)) * 0x7FEB352DU
  h = (h ^ (h >> 15)) * 0x846CA68BU
  h ^ (h >> 16)
}

///|
fn terrain_random(x : Int, z : Int, seed : Int) -> Double {
  (terrain_hash(x, z, seed) & 0xFFFFFFU).to_double() / 16777215.0
}

///|
fn noise_fade(t : Double) -> Double {
  t * t * t * (t * (t * 6.0 - 15.0) + 10.0)
}

///|
fn noise_lerp(a : Double, b : Double, t : Double) -> Double {
  a + (b - a) * t
}

///|
fn perlin_gradient(
  x : Int,
  z : Int,
  seed : Int,
  dx : Double,
  dz : Double,
) -> Double {
  match (terrain_hash(x, z, seed) & 7U).to_int() {
    0 => dx
    1 => -dx
    2 => dz
    3 => -dz
    4 => (dx + dz) * 0.7071067811865476
    5 => (dx - dz) * 0.7071067811865476
    6 => (-dx + dz) * 0.7071067811865476
    _ => (-dx - dz) * 0.7071067811865476
  }
}

///|
fn perlin_noise(x : Double, z : Double, seed : Int) -> Double {
  let ix = @math.floor(x).to_int()
  let iz = @math.floor(z).to_int()
  let fx = x - ix.to_double()
  let fz = z - iz.to_double()
  let u = noise_fade(fx)
  let v = noise_fade(fz)
  noise_lerp(
    noise_lerp(
      perlin_gradient(ix, iz, seed, fx, fz),
      perlin_gradient(ix + 1, iz, seed, fx - 1.0, fz),
      u,
    ),
    noise_lerp(
      perlin_gradient(ix, iz + 1, seed, fx, fz - 1.0),
      perlin_gradient(ix + 1, iz + 1, seed, fx - 1.0, fz - 1.0),
      u,
    ),
    v,
  )
}

///|
fn fractal_perlin(
  x : Double,
  z : Double,
  seed : Int,
  roughness : Double,
) -> Double {
  let mut value = 0.0
  let mut weight = 1.0
  let mut total = 0.0
  let mut frequency = 1.0
  for octave in 0..<4 {
    value += perlin_noise(
        x * frequency + 0.37,
        z * frequency + 0.71,
        seed + octave * 1013,
      ) *
      weight
    total += weight
    weight *= roughness
    frequency *= 2.0
  }
  (0.5 + value / total * 0.9).clamp(min=0.0, max=1.0)
}

///|
/// F2-F1 is continuous across Voronoi cell boundaries but has sharp changes in
/// slope. It produces raised cellular rocks without discontinuous walking steps.
fn cellular_relief(x : Double, z : Double, seed : Int) -> Double {
  let ix = @math.floor(x).to_int()
  let iz = @math.floor(z).to_int()
  let mut first = 1.0e9
  let mut second = first
  for dz in -2..<=2 {
    for dx in -2..<=2 {
      let gx = ix + dx
      let gz = iz + dz
      let px = gx.to_double() + 0.1 + terrain_random(gx, gz, seed) * 0.8
      let pz = gz.to_double() + 0.1 + terrain_random(gx, gz, seed + 719) * 0.8
      let d = (px - x) * (px - x) + (pz - z) * (pz - z)
      if d < first {
        second = first
        first = d
      } else if d < second {
        second = d
      }
    }
  }
  ((second.sqrt() - first.sqrt()) * 1.35).clamp(min=0.0, max=1.0)
}

///|
fn diamond_square_height_field(
  cells_x : Int,
  cells_z : Int,
  config : TerrainConfig,
) -> HeightField {
  let mut size = 1
  while size < cells_x.max(cells_z) {
    size *= 2
  }
  let field = HeightField::new(
    size,
    size,
    Array::make((size + 1) * (size + 1), 0.0),
  )
  let mut step = 4
  while step < config.scale.to_int() && step < size {
    step *= 2
  }
  step = step.min(size)
  for z = 0; z <= size; z = z + step {
    for x = 0; x <= size; x = x + step {
      field.set(x, z, terrain_random(x, z, config.seed) * 2.0 - 1.0)
    }
  }
  let mut displacement = 0.6
  let mut level = 0
  while step > 1 {
    let half = step / 2
    for z = half; z < size; z = z + step {
      for x = half; x < size; x = x + step {
        let avg = (
            field.at(x - half, z - half) +
            field.at(x + half, z - half) +
            field.at(x - half, z + half) +
            field.at(x + half, z + half)
          ) /
          4.0
        field.set(
          x,
          z,
          avg +
          (terrain_random(x, z, config.seed + level * 101 + 1) * 2.0 - 1.0) *
          displacement,
        )
      }
    }
    for z = 0; z <= size; z = z + half {
      let start = if z % step == 0 { half } else { 0 }
      for x = start; x <= size; x = x + step {
        let mut sum = 0.0
        let mut count = 0.0
        for (dx, dz) in [(-half, 0), (half, 0), (0, -half), (0, half)] {
          if x + dx >= 0 && z + dz >= 0 && x + dx <= size && z + dz <= size {
            sum += field.at(x + dx, z + dz)
            count += 1.0
          }
        }
        field.set(
          x,
          z,
          sum / count +
          (terrain_random(x, z, config.seed + level * 101 + 2) * 2.0 - 1.0) *
          displacement,
        )
      }
    }
    step = half
    displacement *= config.roughness
    level += 1
  }
  let cropped = field.crop(0, 0, cells_x, cells_z)
  for i in 0..<cropped.values.length() {
    cropped.values[i] = (0.5 + cropped.values[i] * 0.4).clamp(min=0.0, max=1.0) *
      config.amplitude
  }
  cropped
}
