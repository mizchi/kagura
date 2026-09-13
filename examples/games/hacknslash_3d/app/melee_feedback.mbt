// Presentation clock is separate from combat. Menus and input continue during impact stops.

///|
struct CombatFeedbackState {
  mut hitstop : Int
  mut impacts : Int
  mut look_x : Double
  mut look_y : Double
}

///|
fn CombatFeedbackState::new() -> CombatFeedbackState {
  { hitstop: 0, impacts: 0, look_x: 0.0, look_y: 0.0, }
}

///|
fn GameState::apply_melee_feedback(
  self : GameState,
  event : @game.GameEvent,
) -> Unit {
  if event is @game.MeleeImpact(weapon, combo, _, _, _, hits) {
    if hits <= 0 {
      return
    }
    let frames = match weapon {
      @game.Cleaver => if combo == @game.Finisher { 6 } else { 4 }
      @game.Spear => 3
      @game.Knuckles => 2
      _ => 0
    }
    self.combat_feedback.hitstop = self.combat_feedback.hitstop.max(frames)
    self.combat_feedback.impacts += 1
  }
}

///|
fn GameState::update_combat_camera(self : GameState) -> Unit {
  let p = self.world.player
  let feedback = self.combat_feedback
  let (x, y) = self.combat_focus_offset()
  feedback.look_x += (x - feedback.look_x) * 0.12
  feedback.look_y += (y - feedback.look_y) * 0.12
  let height = @game.get_tile_height(self.world.dungeon, p.x, p.y)
  let target = self.camera_framing_target(height)
  self.camera = self.camera.with_target(
    @math3d.Vec3::new(
      target.x + feedback.look_x,
      target.y,
      target.z + feedback.look_y,
    ),
  )
  if self.camera_settings.mode == 1 {
    self.resolve_tps_camera(height)
  }
}

///|
struct HunterDamageView {
  x : Double
  y : Double
  amount : Int
  player : Bool
  alpha : Double
  scale : Double
} derive(ToJson)

///|
struct HunterCombatView {
  damage : Array[HunterDamageView]
  hitstop : Int
  impacts : Int
  warnings : Int
  locked : Bool
  combo_step : Int
  combo_active : Bool
  combo_recovery : Bool
} derive(ToJson)

///|
fn GameState::hunter_combat_view(self : GameState) -> HunterCombatView {
  let damage : Array[HunterDamageView] = []
  let camera = self.camera.to_camera3d()
  for popup in self.damage_popups {
    let position = @math3d.Vec3::new(
      popup.x / tile_size,
      @game.get_tile_height(self.world.dungeon, popup.x, popup.y) +
      1.25 +
      popup.rise,
      popup.y / tile_size,
    )
    if project_world_label_position(
        camera,
        position,
        screen_w.to_double(),
        screen_h.to_double(),
      )
      is Some((x, y)) {
      damage.push({
        x: x / screen_w.to_double() * 100.0,
        y: y / screen_h.to_double() * 100.0,
        amount: popup.amount,
        player: popup.color_hex == 0xFF7777,
        alpha: (popup.ttl.to_double() / 12.0).min(1.0),
        scale: 1.0 + ((popup.ttl - 40).to_double() / 8.0).max(0.0) * 0.35,
      })
    }
  }
  {
    damage,
    combo_step: if self.world.player_weapon == @game.Cleaver {
      self.world.weapon_attack
      .map(a => a.combo)
      .or(self.world.cleaver_next)
      .index() +
      1
    } else {
      0
    },
    combo_active: self.world.weapon_attack
    is Some({ weapon: @game.Cleaver, .. }),
    combo_recovery: self.world.weapon_attack
    .map(a => a.weapon == @game.Cleaver && a.frame >= a.profile().windup)
    .or(false),
    hitstop: self.combat_feedback.hitstop,
    impacts: self.combat_feedback.impacts,
    warnings: self.world.enemies
    .filter(e => {
      e.alive &&
      e.attack_motion.melee_profile() is Some(_) &&
      e.attack_frame < e.attack_windup
    })
    .length(),
    locked: self.world.melee_lock_target(
      self.world.player.facing_angle,
      self.world.player_weapon,
    )
    is Some(_),
  }
}
