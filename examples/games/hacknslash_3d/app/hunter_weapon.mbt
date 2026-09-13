// The hunter has a different rig from the biped enemies. Its equipment still
// owns its geometry and attack sampler independently of body/locomotion.

///|
struct HunterWeaponSet {
  kind : @game.PlayerWeaponKind
  id : String
  parts : Array[HunterPart]
  attack_duration : Double
  sample_attack : (Double, Double) -> Array[(Int, Double, Double, Double)]
  clip : @animation3d.AnimationClip?
}

///|
fn build_hunter_weapon_set() -> HunterWeaponSet {
  let leather = @procedural3d.RigidGeometry::new()
  let trim = @procedural3d.RigidGeometry::new()
  let steel = @procedural3d.RigidGeometry::new()
  // Right-hand cleaver: long steel silhouette, six saw teeth, bound handle.
  leather.box(0.33, 0.34, 0.15, 0.065, 0.075, 0.29, 4)
  trim.box(0.33, 0.34, 0.27, 0.19, 0.07, 0.04, 4)
  steel.loft(
    0.33,
    0.61,
    [(0.31, 0.085, 0.33), (0.36, 0.095, 0.33), (0.39, 0.065, 0.28)],
    4,
    4,
  )
  for i in 0..<6 {
    let z = 0.35 + i.to_double() * 0.10
    steel.triangle(
      @math3d.Vec3::new(0.25, 0.35, z),
      @math3d.Vec3::new(0.18, 0.35, z + 0.07),
      @math3d.Vec3::new(0.25, 0.35, z + 0.08),
      4,
    )
    steel.triangle(
      @math3d.Vec3::new(0.25, 0.35, z + 0.08),
      @math3d.Vec3::new(0.18, 0.35, z + 0.07),
      @math3d.Vec3::new(0.25, 0.35, z),
      4,
    )
  }
  // Off-hand flintlock, slightly oversized muzzle.
  leather.box(-0.32, 0.32, 0.13, 0.075, 0.14, 0.12, 7)
  steel.box(-0.32, 0.39, 0.26, 0.10, 0.085, 0.30, 7)
  trim.box(-0.32, 0.39, 0.40, 0.13, 0.105, 0.04, 7)

  let profile = @game.Cleaver.profile()
  {
    kind: @game.Cleaver,
    id: profile.id,
    parts: [
      finish_hunter_part(leather, "leather", 0x443735),
      finish_hunter_part(trim, "brass", 0xB29462),
      finish_hunter_part(steel, "weapon", 0xAFBCC2),
    ],
    attack_duration: (profile.windup + profile.recovery).to_double() / 60.0,
    sample_attack: sample_hunter_cleaver_attack,
    clip: None,
  }
}

///|
fn sample_hunter_cleaver_attack(
  t : Double,
  side : Double,
) -> Array[(Int, Double, Double, Double)] {
  let swing = if t < 0.24 {
    t / 0.24 * -0.65
  } else if t < 0.62 {
    -0.65 + (t - 0.24) / 0.38 * 2.1
  } else {
    1.45 * (1.0 - (t - 0.62) / 0.38)
  }
  [
    (1, 0.08, swing * side * 0.45, 0.0),
    (2, -1.0, swing * side, -0.35),
    (3, -0.35, 0.0, -0.3),
    (5, 0.0, -swing * side * 0.2, 0.0),
  ]
}

///|
fn equip_hunter_parts(
  body : Array[HunterPart],
  weapon : HunterWeaponSet,
) -> Array[HunterPart] {
  let result = body.copy()
  for part in weapon.parts {
    let mut found = -1
    for i in 0..<result.length() {
      if result[i].name == part.name &&
        result[i].color.x == part.color.x &&
        result[i].color.y == part.color.y &&
        result[i].color.z == part.color.z &&
        result[i].color.w == part.color.w {
        found = i
        break
      }
    }
    if found < 0 {
      result.push(part)
    } else {
      let (mesh, skin) = combine_hunter_parts([result[found], part])
      result[found] = {
        name: part.name,
        mesh,
        skin,
        color: part.color,
        packed: @skeleton3d.build_skinned_vertex_data(mesh, skin),
      }
    }
  }
  result
}
