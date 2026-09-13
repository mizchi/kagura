///|
/// One channel, independent of the equipped weapon's normal attack clip.
pub(all) struct WhirlwindChannel {
  mut active : Bool
  mut frame : Int
  mut interrupted : Bool
}

///|
pub let whirlwind_cycle_frames : Int = 24

///|
pub let whirlwind_contact_frame : Int = 6

///|
pub let whirlwind_recovery_frames : Int = 12

///|
pub fn GameWorld::whirlwind_radius(self : GameWorld) -> Double {
  // Projectile range must never become the radius of a melee sweep.
  let reach = match self.player_weapon {
    Spear => 44.0
    Knuckles => 24.0
    _ => 32.0
  }
  effective_aoe_radius(self.player_stats, Whirlwind, reach)
}

///|
pub fn GameWorld::stop_whirlwind(self : GameWorld) -> Unit {
  let channel = self.arts.whirlwind
  if channel.active {
    channel.active = false
    channel.interrupted = true
    self.attack_timer = self.attack_timer.max(whirlwind_recovery_frames)
  }
}

///|
pub fn GameWorld::set_whirlwind(
  self : GameWorld,
  held : Bool,
  pressed? : Bool = false,
) -> Unit {
  let channel = self.arts.whirlwind
  // The browser retains press edges, including release/re-press within one tick.
  // An extra finger while already held must not generate a new edge.
  if pressed {
    channel.interrupted = false
  }
  if !held {
    self.stop_whirlwind()
    channel.interrupted = false
    return
  }
  if channel.active ||
    channel.interrupted ||
    self.skills.get_level(Whirlwind) <= 0 ||
    !self.can_begin_art() {
    return
  }
  channel.active = true
  channel.frame = 0
}

///|
fn GameWorld::whirlwind_contact(self : GameWorld) -> Unit {
  let radius = self.whirlwind_radius()
  let damage = (player_basic_attack_damage(self.player_stats, self.archetype).to_double() *
    skill_level_damage_multiplier(Whirlwind, self.skills.get_level(Whirlwind)))
    .to_int()
    .max(1)
  let hits = self.damage_visible_circle(
    self.player.x,
    self.player.y,
    radius,
    damage,
  )
  self.events.push(
    CombatImpact(WhirlwindCut, self.player.x, self.player.y, radius, hits),
  )
}

///|
fn GameWorld::tick_whirlwind(self : GameWorld) -> Unit {
  let channel = self.arts.whirlwind
  if !channel.active {
    return
  }
  if self.player.hp <= 0 ||
    self.player.dash_timer > 0 ||
    self.mode != Playing ||
    self.ui_mode != UIMode::None {
    self.stop_whirlwind()
    return
  }
  // Bounded phase stays precise even during a long hold. A repeated held input
  // never resets this phase or produces additional contact frames.
  channel.frame = channel.frame % whirlwind_cycle_frames + 1
  if channel.frame == whirlwind_contact_frame {
    self.whirlwind_contact()
  }
}
