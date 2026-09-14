///|
/// Stateless coordinate roll in [0, 1), independent of generation order and
/// actor/loot RNG. Uses the height-field hash, with a half-open normalization
/// suitable for choosing array indices. Negative coordinates and seeds work.
pub fn coordinate_random(x : Int, z : Int, seed : Int) -> Double {
  (terrain_hash(x, z, seed) & 0xFFFFFFU).to_double() / 16777216.0
}

///|
/// Two low-frequency waves with sinusoidal domain warping. Frequencies are in
/// radians per world unit; warp amplitudes are in world units. Finite inputs
/// produce a continuous density in 0..1. Seed-to-phase mapping belongs to the
/// caller, so multiple placement layers can share or decorrelate their fields.
pub(all) struct WarpedDensityField {
  frequency_x : Double
  frequency_z : Double
  warp_x : Double
  warp_z : Double
  warp_frequency_x : Double
  warp_frequency_z : Double
}

///|
pub fn WarpedDensityField::sample(
  self : WarpedDensityField,
  x : Double,
  z : Double,
  phase? : Double = 0.0,
) -> Double {
  let u = x + self.warp_x * @math.sin(z * self.warp_frequency_z + phase)
  let v = z + self.warp_z * @math.sin(x * self.warp_frequency_x - phase)
  (0.5 +
  0.3 * @math.sin(u * self.frequency_x + phase) +
  0.2 * @math.cos(v * self.frequency_z)).clamp(min=0.0, max=1.0)
}

///|
/// Local priority thinning with a square (Chebyshev) exclusion radius in cells.
/// Evaluate in global cell coordinates, including across chunk boundaries.
/// All neighboring priorities compete, even if masked by the caller or below
/// their own density threshold. Thus order never matters, but this is not a
/// maximal packing. Apply road/water/footprint masks separately.
/// Probability <=0 rejects, >=1 admits every local minimum; radius <0 means 0.
pub fn priority_scatter_cell(
  x : Int,
  z : Int,
  seed : Int,
  probability~ : Double,
  radius? : Int = 1,
) -> Bool {
  let priority = coordinate_random(x, z, seed)
  if probability.is_nan() || probability <= 0.0 || priority > probability {
    return false
  }
  let radius = radius.max(0)
  for dz in -radius..<=radius {
    for dx in -radius..<=radius {
      if dx == 0 && dz == 0 {
        continue
      }
      let other = coordinate_random(x + dx, z + dz, seed)
      // Equal 24-bit priorities use lexicographic cell order, including halos.
      if other < priority ||
        (other == priority && (dx < 0 || (dx == 0 && dz < 0))) {
        return false
      }
    }
  }
  true
}
