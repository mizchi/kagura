///|
fn CharacterModel::sample_guard(self : CharacterModel) -> Unit {
  let lift = (self.action_time * 12.0).min(1.0)
  self.rotate_bone(1, 0.14 * lift, 0.22 * lift, 0.0)
  self.rotate_bone(6, -1.15 * lift, 0.2 * lift, 0.28 * lift)
  self.rotate_bone(7, -1.15 * lift, 0.0, -0.35 * lift)
  self.rotate_bone(2, -0.35, 0.0, -0.45)
  self.rotate_bone(3, -0.7, 0.0, 0.0)
  self.rotate_bone(5, -0.10, -0.20, 0.0)
}

///|
fn CharacterModel::sample_hunter_art(
  self : CharacterModel,
  kind : @game.HunterArtKind,
) -> Unit {
  let frame = self.action_time * 60.0
  let release = match kind {
    LightningArt => 10.0
    FlameArt => 14.0
    AstralArt => 24.0
    DashArt => 16.0
  }
  let windup = (frame / release).min(1.0)
  let follow = ((frame - release) / (36.0 - release)).max(0.0).min(1.0)
  let power = if frame < release { windup } else { 1.0 - follow }
  match kind {
    DashArt => {
      let drive = if frame < 16.0 {
        (frame / 4.0).min(1.0)
      } else {
        1.0 - follow
      }
      self.rotate_bone(
        1,
        drive * 0.4,
        if frame < 16.0 {
          -0.75 * windup
        } else {
          0.9 * power
        },
        0.0,
      )
      self.rotate_bone(
        2,
        if frame < 16.0 {
          -1.6 * windup
        } else {
          -0.45 * power
        },
        0.0,
        -0.7 * power,
      )
      self.rotate_bone(3, -0.45 * power, 0.0, 0.0)
      self.rotate_bone(6, 0.5 * drive, 0.0, 0.35 * drive)
      self.rotate_bone(8, -0.75 * drive, 0.0, 0.0)
      self.rotate_bone(10, 0.7 * drive, 0.0, 0.0)
      self.rotate_bone(12, -0.8 * drive, 0.0, 0.0)
      self.rotate_bone(13, -0.8 * drive, 0.0, 0.0)
    }
    AstralArt => {
      self.rotate_bone(1, -0.18 * power, 0.0, 0.0)
      self.rotate_bone(2, -2.5 * power, 0.0, -0.35 * power)
      self.rotate_bone(6, -2.4 * power, 0.0, 0.35 * power)
      self.rotate_bone(3, -0.6 * power, 0.0, 0.0)
      self.rotate_bone(7, -0.6 * power, 0.0, 0.0)
      self.rotate_bone(5, -0.15 * power, 0.0, 0.0)
    }
    _ => {
      self.rotate_bone(1, -0.12 * power, -0.32 * power, 0.0)
      self.rotate_bone(2, -1.4 * power, 0.0, -0.25 * power)
      self.rotate_bone(
        3,
        if frame < release {
          -1.4 * windup
        } else {
          -0.12 * power
        },
        0.0,
        0.0,
      )
      self.rotate_bone(6, -0.65 * power, 0.0, 0.65 * power)
      self.rotate_bone(7, -0.6 * power, 0.0, 0.0)
    }
  }
}
