///|
let wolf_skeleton : @skeleton3d.Skeleton = @procedural3d.build_quadruped_skeleton(
  @procedural3d.default_quadruped_proportions(),
)

///|
let wolf_mesh : EnemyMeshData = build_wolf_mesh()

///|
fn build_wolf_mesh() -> EnemyMeshData {
  let fur = @procedural3d.RigidGeometry::new()
  let dark = @procedural3d.RigidGeometry::new()
  let cream = @procedural3d.RigidGeometry::new()
  let black = @procedural3d.RigidGeometry::new()
  let amber = @procedural3d.RigidGeometry::new()
  // Angular barrel, higher withers, narrow waist. The silhouette is long and low.
  fur.loft(
    0.0,
    -0.05,
    [(0.43, 0.16, 0.36), (0.62, 0.25, 0.56), (0.79, 0.18, 0.43)],
    8,
    1,
  )
  dark.loft(
    0.0,
    -0.08,
    [(0.72, 0.19, 0.46), (0.82, 0.11, 0.32), (0.84, 0.035, 0.23)],
    6,
    1,
  )
  fur.segment(
    @math3d.Vec3::new(0.0, 0.60, 0.27),
    @math3d.Vec3::new(0.0, 0.78, 0.60),
    0.24,
    0.18,
    6,
    2,
  )
  cream.segment(
    @math3d.Vec3::new(0.0, 0.51, 0.36),
    @math3d.Vec3::new(0.0, 0.72, 0.62),
    0.14,
    0.11,
    5,
    2,
  )
  fur.loft(
    0.0,
    0.65,
    [(0.70, 0.12, 0.14), (0.81, 0.21, 0.23), (0.93, 0.15, 0.17)],
    6,
    3,
  )
  cream.segment(
    @math3d.Vec3::new(0.0, 0.78, 0.73),
    @math3d.Vec3::new(0.0, 0.75, 1.07),
    0.12,
    0.07,
    5,
    3,
  )
  black.box(0.0, 0.755, 1.105, 0.135, 0.095, 0.085, 3)
  cream.segment(
    @math3d.Vec3::new(0.0, 0.695, 0.76),
    @math3d.Vec3::new(0.0, 0.68, 1.055),
    0.08,
    0.055,
    5,
    4,
  )
  black.box(0.0, 0.715, 0.94, 0.115, 0.028, 0.26, 4)
  // Tetrahedral ears, amber eyes and four exposed fangs survive a pulled-back camera.
  for side in [-1.0, 1.0] {
    let a = @math3d.Vec3::new(side * 0.065, 0.87, 0.62)
    let b = @math3d.Vec3::new(side * 0.235, 0.86, 0.61)
    let c = @math3d.Vec3::new(side * 0.145, 0.86, 0.46)
    let tip = @math3d.Vec3::new(side * 0.185, 1.15, 0.55)
    fur.triangle(a, b, tip, 3)
    fur.triangle(b, c, tip, 3)
    fur.triangle(c, a, tip, 3)
    dark.triangle(a, tip, b, 3)
    black.box(side * 0.14, 0.847, 0.788, 0.070, 0.041, 0.030, 3)
    amber.box(side * 0.14, 0.848, 0.805, 0.030, 0.025, 0.014, 3)
    for z in [0.87, 1.01] {
      cream.segment(
        @math3d.Vec3::new(side * 0.063, 0.735, z),
        @math3d.Vec3::new(side * 0.055, 0.66, z + 0.015),
        0.023,
        0.002,
        3,
        3,
      )
    }
    let upper_front = if side < 0.0 { 7 } else { 9 }
    let upper_rear = if side < 0.0 { 11 } else { 13 }
    let x = side * 0.21
    fur.segment(
      @math3d.Vec3::new(x, 0.67, 0.36),
      @math3d.Vec3::new(x, 0.31, 0.38),
      0.095,
      0.06,
      5,
      upper_front,
    )
    cream.segment(
      @math3d.Vec3::new(x, 0.31, 0.38),
      @math3d.Vec3::new(x, 0.085, 0.44),
      0.055,
      0.04,
      5,
      upper_front + 1,
    )
    fur.segment(
      @math3d.Vec3::new(x, 0.60, -0.42),
      @math3d.Vec3::new(x, 0.24, -0.59),
      0.13,
      0.05,
      5,
      upper_rear,
    )
    cream.segment(
      @math3d.Vec3::new(x, 0.24, -0.59),
      @math3d.Vec3::new(x, 0.08, -0.40),
      0.047,
      0.035,
      5,
      upper_rear + 1,
    )
    for (z, bone) in [(0.48, upper_front + 1), (-0.37, upper_rear + 1)] {
      dark.box(x, 0.06, z, 0.14, 0.12, 0.21, bone)
      for claw in [-1.0, 0.0, 1.0] {
        cream.box(x + claw * 0.034, 0.037, z + 0.107, 0.019, 0.028, 0.034, bone)
      }
    }
  }
  fur.segment(
    @math3d.Vec3::new(0.0, 0.62, -0.52),
    @math3d.Vec3::new(0.0, 0.38, -0.92),
    0.12,
    0.14,
    6,
    5,
  )
  dark.segment(
    @math3d.Vec3::new(0.0, 0.38, -0.92),
    @math3d.Vec3::new(0.0, 0.24, -1.24),
    0.14,
    0.025,
    6,
    6,
  )
  combine_enemy_parts([
    monster_material("ash fur", fur, 0x737F86),
    monster_material("charcoal guard hair", dark, 0x394750),
    monster_material("pale muzzle and paws", cream, 0xB9B9A6),
    monster_material("nose and mouth", black, 0x192128),
    monster_material("amber eyes", amber, 0xEBC16B),
  ])
}
