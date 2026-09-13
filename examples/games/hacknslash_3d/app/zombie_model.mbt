///|
let zombie_mesh : EnemyMeshData = build_zombie_mesh()

///|
/// An unarmed body on the shared biped rig: gaunt face, torn work clothes and one bare foot.
fn build_zombie_mesh() -> EnemyMeshData {
  let skin = @procedural3d.RigidGeometry::new()
  let cloth = @procedural3d.RigidGeometry::new()
  let dark = @procedural3d.RigidGeometry::new()
  let eyes = @procedural3d.RigidGeometry::new()
  let defaults = @procedural3d.default_biped_proportions()
  let base = @procedural3d.build_biped_base({
    ..defaults,
    head_width: 0.215,
    head_depth: 0.18,
    torso_width: 0.17,
    limb_radius: 0.058,
  })
  skin.append(base.head)
  skin.append(base.arms)
  // The open jaw and lopsided brow read from the pulled-back game camera.
  skin.box(0.015, 0.795, 0.10, 0.25, 0.105, 0.21, 2)
  dark.box(0.012, 0.857, 0.181, 0.17, 0.06, 0.035, 2)
  skin.box(0.0, 0.944, 0.193, 0.065, 0.10, 0.07, 2)
  for side in [-1.0, 1.0] {
    let y = if side < 0.0 { 1.03 } else { 1.005 }
    dark.box(side * 0.085, y, 0.167, 0.106, 0.078, 0.045, 2)
    eyes.box(side * 0.085, y - 0.004, 0.194, 0.035, 0.022, 0.012, 2)
    skin.box(side * 0.096, y + 0.055, 0.162, 0.12, 0.038, 0.07, 2)
    skin.box(side * 0.218, 0.988, -0.02, 0.065, 0.09, 0.075, 2)
    let thigh = if side < 0.0 { 7 } else { 9 }
    let shin = thigh + 1
    dark.segment(
      @math3d.Vec3::new(side * 0.105, 0.43, 0.0),
      @math3d.Vec3::new(side * 0.105, 0.22, 0.0),
      0.077,
      0.065,
      6,
      thigh,
    )
    skin.segment(
      @math3d.Vec3::new(side * 0.105, 0.22, 0.0),
      @math3d.Vec3::new(side * 0.105, 0.06, 0.025),
      0.052,
      0.037,
      6,
      shin,
    )
    if side < 0.0 {
      dark.box(side * 0.105, 0.047, 0.05, 0.16, 0.094, 0.24, shin)
      cloth.segment(
        @math3d.Vec3::new(-0.23, 0.68, 0.0),
        @math3d.Vec3::new(-0.255, 0.56, 0.02),
        0.088,
        0.073,
        6,
        3,
      )
    } else {
      skin.box(side * 0.105, 0.033, 0.065, 0.14, 0.066, 0.24, shin)
    }
    // Three uneven fingers extend the silhouette without a new hand rig.
    for i in 0..<3 {
      skin.box(
        side * 0.255 + (i - 1).to_double() * 0.036,
        0.278 - i.to_double() * 0.009,
        0.097,
        0.028,
        0.10,
        0.035,
        if side < 0.0 {
          4
        } else {
          6
        },
      )
    }
  }
  cloth.loft(
    0.0,
    0.0,
    [
      (0.35, 0.20, 0.145),
      (0.48, 0.185, 0.14),
      (0.66, 0.205, 0.155),
      (0.715, 0.135, 0.105),
    ],
    6,
    1,
  )
  for i in 0..<5 {
    let x = (i - 2).to_double() * 0.073
    cloth.triangle(
      @math3d.Vec3::new(x - 0.04, 0.39, 0.13),
      @math3d.Vec3::new(x, 0.25 + (i % 2).to_double() * 0.05, 0.16),
      @math3d.Vec3::new(x + 0.04, 0.39, 0.13),
      1,
    )
  }
  dark.box(0.025, 0.61, 0.152, 0.027, 0.13, 0.015, 1)
  // Ragged hair on the back of the skull; the forehead stays bare.
  dark.loft(0.0, -0.045, [(1.115, 0.205, 0.15), (1.185, 0.135, 0.105)], 7, 2)
  let parts = [
    monster_material("ashen_skin", skin, 0xA6B594),
    monster_material("torn_tunic", cloth, 0x426768),
    monster_material("hair_and_trousers", dark, 0x393A32),
    monster_material("clouded_eyes", eyes, 0xE7EAB2),
  ]
  combine_enemy_parts(parts)
}
