///|
/// Artistic scale and deformation for this world's forest/clearing pattern.
let woodland_field : @terrain3d.WarpedDensityField = {
  frequency_x: 0.16,
  frequency_z: 0.19,
  warp_x: 5.0,
  warp_z: 6.0,
  warp_frequency_x: 0.11,
  warp_frequency_z: 0.13,
}

///|
pub fn woodland_density(x : Double, z : Double, seed : Int) -> Double {
  woodland_field.sample(x, z, phase=(seed % 719).to_double() * 0.013)
}

///|
/// Local priority thinning gives a one-tile clearance without grid-aligned rows.
fn woodland_tree_cell(x : Int, z : Int, seed : Int) -> Bool {
  @terrain3d.priority_scatter_cell(
    x,
    z,
    seed,
    probability=0.025 +
      woodland_density(x.to_double(), z.to_double(), seed) * 0.20,
    radius=1,
  )
}
