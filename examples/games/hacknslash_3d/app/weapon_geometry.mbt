// Weapon geometry and attack clips are independent of species meshes.

///|
fn build_knuckles_weapon() -> EnemyMeshData {
  let iron = @procedural3d.RigidGeometry::new()
  let cloth = @procedural3d.RigidGeometry::new()
  // Broad knuckles make the punch readable from the overhead camera.
  for side in [-1.0, 1.0] {
    iron.box(
      side * 0.275,
      0.34,
      0.083,
      0.18,
      0.14,
      0.17,
      if side < 0.0 {
        4
      } else {
        6
      },
    )
    cloth.box(
      side * 0.268,
      0.43,
      0.04,
      0.13,
      0.07,
      0.12,
      if side < 0.0 {
        4
      } else {
        6
      },
    )
  }

  combine_enemy_parts([
    monster_material("iron", iron, 0xA3AAA3),
    monster_material("cloth", cloth, 0x8B4B43),
  ])
}

///|
fn build_spear_weapon(length_scale? : Double = 1.0) -> EnemyMeshData {
  // Extend the shaft ahead of the grip, keeping the hand anchor, width and head shape.
  let extension = 1.05 * (length_scale - 1.0)
  let iron = @procedural3d.RigidGeometry::new()
  let cloth = @procedural3d.RigidGeometry::new()
  let dark = @procedural3d.RigidGeometry::new()
  dark.segment(
    @math3d.Vec3::new(0.34, 0.16, 0.14),
    @math3d.Vec3::new(0.34, 1.18 + extension, 0.14),
    0.022,
    0.022,
    6,
    12,
  )
  iron.loft(
    0.34,
    0.14,
    [
      (1.12 + extension, 0.015, 0.012),
      (1.20 + extension, 0.066, 0.021),
      (1.39 + extension, 0.003, 0.003),
    ],
    4,
    12,
  )
  cloth.box(0.34, 1.08 + extension, 0.14, 0.09, 0.10, 0.06, 12)

  combine_enemy_parts([
    monster_material("shadow", dark, 0x372B27),
    monster_material("iron", iron, 0xA3AAA3),
    monster_material("cloth", cloth, 0x3F6B73),
  ])
}

///|
fn build_focus_weapon() -> EnemyMeshData {
  let iron = @procedural3d.RigidGeometry::new()
  let cloth = @procedural3d.RigidGeometry::new()
  let glow = @procedural3d.RigidGeometry::new()
  iron.box(-0.275, 0.35, 0.08, 0.085, 0.065, 0.10, 4)
  glow.loft(
    -0.275,
    0.12,
    [(0.32, 0.025, 0.025), (0.37, 0.065, 0.065), (0.45, 0.003, 0.003)],
    6,
    4,
  )

  combine_enemy_parts([
    monster_material("iron", iron, 0xA3AAA3),
    monster_material("eyes", glow, 0x8DDCD5),
  ])
}

///|
fn build_bow_weapon() -> EnemyMeshData {
  let iron = @procedural3d.RigidGeometry::new()
  let cloth = @procedural3d.RigidGeometry::new()
  let bone = @procedural3d.RigidGeometry::new()
  cloth.segment(
    @math3d.Vec3::new(0.105, 0.43, -0.16),
    @math3d.Vec3::new(0.105, 0.75, -0.16),
    0.068,
    0.068,
    6,
    1,
  )
  for x in [0.08, 0.13] {
    iron.segment(
      @math3d.Vec3::new(x, 0.68, -0.16),
      @math3d.Vec3::new(x, 0.88, -0.16),
      0.009,
      0.009,
      4,
      1,
    )
  }

  build_skeleton_bow(bone, cloth, iron)
  combine_enemy_parts([
    monster_material("bone", bone, 0xD2CFB2),
    monster_material("cloth", cloth, 0x8B4B43),
    monster_material("iron", iron, 0xA3AAA3),
  ])
}

///|
/// A curved bone bow; string endpoints follow the bow and its center follows
/// the pulling hand. All geometry shares the existing material/GPU batches.
fn build_skeleton_bow(
  bone : @procedural3d.RigidGeometry,
  wrap : @procedural3d.RigidGeometry,
  metal : @procedural3d.RigidGeometry,
) -> Unit {
  let points = [
    @math3d.Vec3::new(-0.275, -0.10, -0.07),
    @math3d.Vec3::new(-0.275, 0.06, 0.07),
    @math3d.Vec3::new(-0.275, 0.22, 0.11),
    @math3d.Vec3::new(-0.275, 0.35, 0.06),
    @math3d.Vec3::new(-0.275, 0.48, 0.11),
    @math3d.Vec3::new(-0.275, 0.64, 0.07),
    @math3d.Vec3::new(-0.275, 0.80, -0.07),
  ]
  for i in 0..<(points.length() - 1) {
    bone.segment(points[i], points[i + 1], 0.028, 0.024, 5, 13)
  }
  wrap.box(-0.275, 0.35, 0.06, 0.074, 0.14, 0.075, 13)
  for tip in [points[0], points[6]] {
    let start = metal.vertices.length() / 8
    let middle = @math3d.Vec3::new(-0.275, 0.35, -0.07)
    metal.segment(tip, middle, 0.008, 0.008, 4, 13)
    // Segment emits end rings plus caps. Classify the endpoint by its Y;
    // each vertex stays rigidly attached, with no runtime geometry edits.
    for v in start..<(metal.vertices.length() / 8) {
      if (metal.vertices[v * 8 + 1] - 0.35).abs() < 0.02 {
        metal.joints[v * 4] = 14
      }
    }
  }
  wrap.segment(
    @math3d.Vec3::new(-0.275, 0.35, -0.07),
    @math3d.Vec3::new(-0.275, 0.35, 0.73),
    0.012,
    0.009,
    4,
    15,
  )
  metal.segment(
    @math3d.Vec3::new(-0.275, 0.35, 0.70),
    @math3d.Vec3::new(-0.275, 0.35, 0.86),
    0.034,
    0.001,
    4,
    15,
  )
  wrap.box(-0.275, 0.35, -0.02, 0.065, 0.012, 0.09, 15)
}
