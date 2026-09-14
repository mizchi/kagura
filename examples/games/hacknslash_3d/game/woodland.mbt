///|
/// Independent coordinate randomness; decor never consumes actor/loot RNG.
pub fn woodland_random(x : Int, z : Int, seed : Int) -> Double {
  let mut h = (x.to_uint() * 0x9E3779B9U) ^
    (z.to_uint() * 0x85EBCA6BU) ^
    seed.to_uint()
  h = (h ^ (h >> 16)) * 0x7FEB352DU
  h = (h ^ (h >> 15)) * 0x846CA68BU
  ((h ^ (h >> 16)) & 0xFFFFFFU).to_double() / 16777216.0
}

///|
pub fn woodland_density(x : Double, z : Double, seed : Int) -> Double {
  let phase = (seed % 719).to_double() * 0.013
  let u = x + 5.0 * @math.sin(z * 0.13 + phase)
  let v = z + 6.0 * @math.sin(x * 0.11 - phase)
  (0.5 + 0.3 * @math.sin(u * 0.16 + phase) + 0.2 * @math.cos(v * 0.19)).clamp(
    min=0.0,
    max=1.0,
  )
}

///|
/// Local priority thinning gives a one-tile clearance without grid-aligned rows.
fn woodland_tree_cell(x : Int, z : Int, seed : Int) -> Bool {
  let priority = woodland_random(x, z, seed)
  if priority >
    0.025 + woodland_density(x.to_double(), z.to_double(), seed) * 0.20 {
    return false
  }
  for dz in -1..<=1 {
    for dx in -1..<=1 {
      if (dx != 0 || dz != 0) &&
        woodland_random(x + dx, z + dz, seed) < priority {
        return false
      }
    }
  }
  true
}
