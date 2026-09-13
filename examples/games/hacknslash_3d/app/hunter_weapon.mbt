// The hunter has a different rig from the biped enemies. Its equipment still
// owns its geometry and attack sampler independently of body/locomotion.

///|
struct HunterWeaponSet {
  kind : @game.PlayerWeaponKind
  id : String
  parts : Array[CharacterPart]
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
  sample_cleaver_cut(t, side, @game.Opening)
}

///|
fn CharacterModel::attack_duration(self : CharacterModel) -> Double {
  if self.weapon.kind == @game.Cleaver {
    let p = self.cleaver_combo.profile()
    (p.windup + p.recovery).to_double() / 60.0
  } else {
    self.weapon.attack_duration
  }
}

///|
fn sample_cleaver_combo(
  t : Double,
  step : @game.CleaverComboStep,
) -> Array[(Int, Double, Double, Double)] {
  sample_cleaver_cut(t, if step == @game.Return { 1.0 } else { -1.0 }, step)
}

///|
fn sample_cleaver_cut(
  t : Double,
  side : Double,
  step : @game.CleaverComboStep,
) -> Array[(Int, Double, Double, Double)] {
  let p = step.profile()
  let t = t.max(0.0).min(1.0)
  let contact = p.windup.to_double() / (p.windup + p.recovery).to_double()
  let phase = if t <= contact {
    t / contact * 0.5
  } else {
    0.5 + (t - contact) / (1.0 - contact) * 0.5
  }
  let phase = melee_motion_phase(phase)
  // Plant the leading foot during the same anticipation frames as the world lunge.
  let plant = if phase < 0.5 {
    (phase / 0.5).min(1.0)
  } else {
    (1.0 - phase) / 0.5
  }
  if step == @game.Finisher {
    let arm = if phase < 0.16 {
      -0.15 - phase / 0.16 * 2.65
    } else if phase < 0.5 {
      -2.8 + (phase - 0.16) / 0.34 * 1.45
    } else if phase < 0.65 {
      -1.35 + (phase - 0.5) / 0.15 * 1.55
    } else {
      0.2 - (phase - 0.65) / 0.35 * 0.35
    }
    let bend = if phase < 0.5 {
      -plant * 0.16
    } else if phase < 0.65 {
      -0.16 + (phase - 0.5) / 0.15 * 0.64
    } else {
      0.48 * (1.0 - phase) / 0.35
    }
    let forearm = -0.12 - (if phase < 0.5 { plant * 0.85 } else { 0.0 })
    let blade = if phase < 0.16 {
      -phase / 0.16 * 1.8
    } else if phase < 0.5 {
      -1.8 + (phase - 0.16) / 0.34 * 1.8
    } else if phase < 0.65 {
      (phase - 0.5) / 0.15 * 0.65
    } else {
      0.65 * (1.0 - phase) / 0.35
    }
    return [
      (1, bend, -plant * 0.12, 0.0),
      (2, arm, 0.05, -0.18 - plant * 0.16),
      (3, forearm, 0.0, -0.12),
      // The mesh extends along local +Z; compensate the raised arm at the wrist.
      (4, blade - bend - arm - forearm, 0.0, 0.0),
      (6, -0.2 - plant * 1.7, 0.0, plant * 0.2),
      (7, -plant * 0.9, 0.0, 0.0),
      (5, -bend * 0.5, 0.0, 0.0),
      (8, -plant * 0.5, 0.0, 0.0),
      (9, plant * 0.45, 0.0, 0.0),
      (10, plant * 0.3, 0.0, 0.0),
      (11, plant * 0.12, 0.0, 0.0),
      (12, -plant * 0.45, 0.0, 0.0),
      (13, -plant * 0.4, 0.0, 0.0),
    ]
  }
  let swing = if phase < 0.16 {
    -phase / 0.16 * 1.1
  } else if phase < 0.5 {
    -1.1 + (phase - 0.16) / 0.34 * 1.25
  } else if phase < 0.65 {
    0.15 + (phase - 0.5) / 0.15 * 1.3
  } else {
    1.45 * (1.0 - (phase - 0.65) / 0.35)
  }
  let lift = if phase < 0.5 { phase * 0.4 } else { (1.0 - phase) * 0.4 }
  [
    (1, 0.08 + lift * 0.2, swing * side * 0.55, -swing * side * 0.08),
    (
      2,
      (if step == @game.Return { -0.8 } else { -1.1 }) - lift,
      swing * side,
      -0.35,
    ),
    (3, -0.30 - lift, 0.0, -0.3),
    (4, (if step == @game.Return { 1.15 } else { 1.32 }) + lift * 1.8, 0.0, 0.0),
    (5, 0.0, -swing * side * 0.22, 0.0),
    (8, -plant * 0.65 * side, 0.0, 0.0),
    (9, plant * (if side > 0.0 { 0.35 } else { 0.1 }), 0.0, 0.0),
    (10, plant * 0.65 * side, 0.0, 0.0),
    (11, plant * (if side < 0.0 { 0.35 } else { 0.1 }), 0.0, 0.0),
    (12, -plant * 0.45, 0.0, -plant * side * 0.12),
    (13, -plant * 0.45, 0.0, plant * side * 0.12),
  ]
}

///|
fn melee_motion_phase(phase : Double) -> Double {
  if phase < 0.35 {
    phase / 0.35 * 0.16
  } else if phase < 0.5 {
    0.16 + (phase - 0.35) / 0.15 * 0.34
  } else if phase < 0.60 {
    0.5 + (phase - 0.5) / 0.10 * 0.15
  } else {
    0.65 + (phase - 0.60) / 0.40 * 0.35
  }
}
