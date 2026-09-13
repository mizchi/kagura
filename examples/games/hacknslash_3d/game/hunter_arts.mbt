// Simulation owns contact frames, guard direction and damage footprints.

///|
pub(all) enum HunterArtKind {
  LightningArt
  FlameArt
  AstralArt
  DashArt
} derive(Eq, Debug)

///|
pub(all) enum CombatImpactKind {
  FlameBlast
  AstralBlast
  DashCut
} derive(Eq, Debug)

///|
pub(all) struct HunterArt {
  kind : HunterArtKind
  angle : Double
  mut frame : Int
}

///|
pub(all) struct GroundStrike {
  x : Double
  y : Double
  radius : Double
  mut frame : Int
}

///|
pub(all) struct HunterArts {
  mut guarding : Bool
  mut guard_frame : Int
  mut guard_energy : Double
  mut guard_recovery : Int
  mut action : HunterArt?
  mut strike : GroundStrike?
  mut ground_cooldown : Int
  mut dash_cooldown : Int
}

///|
pub fn HunterArts::new() -> HunterArts {
  {
    guarding: false,
    guard_frame: 0,
    guard_energy: 100.0,
    guard_recovery: 0,
    action: None,
    strike: None,
    ground_cooldown: 0,
    dash_cooldown: 0,
  }
}

///|
pub let ground_strike_radius : Double = 40.0

///|
pub let ground_strike_range : Double = 176.0

///|
pub let ground_strike_delay : Int = 30

///|
pub let ground_strike_cooldown : Int = 240

///|
pub let dash_strike_cooldown : Int = 150

///|
pub fn GameWorld::hunter_action_locked(self : GameWorld) -> Bool {
  self.arts.guarding || self.arts.action is Some(_)
}

///|
fn GameWorld::can_begin_art(self : GameWorld) -> Bool {
  self.mode == Playing &&
  self.ui_mode == UIMode::None &&
  self.player.hp > 0 &&
  !self.hunter_action_locked() &&
  self.weapon_attack is None &&
  self.player_charge is None &&
  self.player.dash_timer <= 0 &&
  self.attack_timer <= 0
}

///|
pub fn GameWorld::cancel_hunter_action(self : GameWorld) -> Unit {
  self.arts.guarding = false
  self.arts.action = None
}

///|
pub fn GameWorld::set_guard(
  self : GameWorld,
  held : Bool,
  angle : Double,
) -> Unit {
  if !held {
    self.arts.guarding = false
    self.arts.guard_frame = 0
    return
  }
  if self.arts.guarding {
    self.player.facing_angle = angle
    return
  }
  if !self.can_begin_art() ||
    self.arts.guard_recovery > 0 ||
    self.arts.guard_energy < 15.0 {
    return
  }
  self.arts.guarding = true
  self.arts.guard_frame = 0
  self.player.facing_angle = angle
}

///|
fn GameWorld::guard_damage(
  self : GameWorld,
  damage : Int,
  source : (Double, Double)?,
) -> Int {
  guard self.arts.guarding && source is Some((x, y)) else { return damage }
  let dx = x - self.player.x
  let dy = y - self.player.y
  let distance = (dx * dx + dy * dy).sqrt()
  if distance < 0.001 ||
    (
      dx * @math.cos(self.player.facing_angle) +
      dy * @math.sin(self.player.facing_angle)
    ) /
    distance <
    0.5 {
    return damage
  }
  let perfect = self.arts.guard_frame <= 8
  self.arts.guard_energy = (self.arts.guard_energy -
  (if perfect { 8.0 } else { 20.0 })).max(0.0)
  self.events.push(GuardBlocked(self.player.x, self.player.y, perfect))
  self.player.iframe_timer = 10
  if self.arts.guard_energy <= 0.0 {
    self.arts.guarding = false
    self.arts.guard_recovery = 90
  }
  if perfect {
    0
  } else {
    (damage.to_double() * 0.2).ceil().to_int().max(1)
  }
}

///|
pub fn GameWorld::ground_strike_target(
  self : GameWorld,
  x : Double,
  y : Double,
) -> (Double, Double) {
  let dx = x - self.player.x
  let dy = y - self.player.y
  let distance = (dx * dx + dy * dy).sqrt()
  let scale = if distance > ground_strike_range {
    ground_strike_range / distance
  } else {
    1.0
  }
  (self.player.x + dx * scale, self.player.y + dy * scale)
}

///|
pub fn GameWorld::ground_strike_target_valid(
  self : GameWorld,
  x : Double,
  y : Double,
) -> Bool {
  x >= 0.0 &&
  y >= 0.0 &&
  x < world_w &&
  y < world_h &&
  !check_wall_collision(self.dungeon.grid, x, y, 2.0) &&
  !segment_hits_wall(self.dungeon.grid, self.player.x, self.player.y, x, y, 0.0)
}

///|
pub fn GameWorld::request_ground_strike(
  self : GameWorld,
  x : Double,
  y : Double,
) -> Bool {
  if !self.can_begin_art() || self.arts.ground_cooldown > 0 {
    return false
  }
  let (x, y) = self.ground_strike_target(x, y)
  if !self.ground_strike_target_valid(x, y) {
    return false
  }
  let radius = effective_aoe_radius(
    self.player_stats,
    AoEMastery,
    ground_strike_radius,
  )
  self.arts.strike = Some({ x, y, radius, frame: 0, })
  self.arts.action = Some({
    kind: AstralArt,
    angle: @math.atan2(y - self.player.y, x - self.player.x),
    frame: 0,
  })
  self.arts.ground_cooldown = ground_strike_cooldown
  true
}

///|
pub fn GameWorld::request_dash_strike(self : GameWorld, angle : Double) -> Bool {
  if !self.can_begin_art() || self.arts.dash_cooldown > 0 {
    return false
  }
  self.arts.action = Some({ kind: DashArt, angle, frame: 0, })
  self.arts.dash_cooldown = dash_strike_cooldown
  self.player.facing_angle = angle
  true
}

///|
pub fn GameWorld::request_hunter_spell(
  self : GameWorld,
  kind : HunterArtKind,
) -> Bool {
  if !self.can_begin_art() {
    return false
  }
  let ready = match kind {
    LightningArt =>
      self.skills.get_level(ChainLightning) > 0 &&
      self.chain_lightning_cooldown_timer <= 0
    FlameArt =>
      self.skills.get_level(SplittingFireball) > 0 &&
      self.splitting_fireball_cooldown_timer <= 0
    _ => false
  }
  if !ready {
    return false
  }
  let angle = match find_nearest_enemy(self, chain_lightning_range) {
    Some(enemy) => @math.atan2(enemy.y - self.player.y, enemy.x - self.player.x)
    None => self.player.facing_angle
  }
  self.arts.action = Some({ kind, angle, frame: 0, })
  true
}

///|
fn GameWorld::damage_visible_circle(
  self : GameWorld,
  x : Double,
  y : Double,
  radius : Double,
  damage : Int,
) -> Int {
  let mut hits = 0
  for enemy in self.enemies {
    let dx = enemy.x - x
    let dy = enemy.y - y
    if enemy.alive &&
      dx * dx + dy * dy <= radius * radius &&
      !segment_hits_wall(self.dungeon.grid, x, y, enemy.x, enemy.y, 0.0) {
      apply_player_damage_to_enemy(self, enemy, damage, x, y)
      hits += 1
    }
  }
  hits
}

///|
pub fn GameWorld::tick_hunter_arts(
  self : GameWorld,
  grid : @terrain.Grid2D,
) -> Unit {
  let arts = self.arts
  if self.player.hp <= 0 {
    self.cancel_hunter_action()
    arts.strike = None
    return
  }
  arts.ground_cooldown = (arts.ground_cooldown - 1).max(0)
  arts.dash_cooldown = (arts.dash_cooldown - 1).max(0)
  arts.guard_recovery = (arts.guard_recovery - 1).max(0)
  if arts.guarding {
    arts.guard_frame += 1
    arts.guard_energy = (arts.guard_energy - 0.45).max(0.0)
    if arts.guard_energy <= 0.0 {
      arts.guarding = false
      arts.guard_recovery = 90
    }
  } else if arts.guard_recovery <= 0 {
    arts.guard_energy = (arts.guard_energy + 1.0).min(100.0)
  }
  if arts.strike is Some(strike) {
    strike.frame += 1
    if strike.frame >= ground_strike_delay {
      let damage = player_spell_damage(
          self.player_stats,
          self.params,
          self.archetype,
          ChainLightning,
          skill_level=self.skills.get_level(ChainLightning).max(1),
        ) *
        2
      let hits = self.damage_visible_circle(
        strike.x,
        strike.y,
        strike.radius,
        damage,
      )
      self.events.push(
        CombatImpact(AstralBlast, strike.x, strike.y, strike.radius, hits),
      )
      arts.strike = None
    }
  }
  guard arts.action is Some(action) else { return }
  if self.player.dash_timer > 0 {
    self.cancel_hunter_action()
    return
  }
  action.frame += 1
  self.player.facing_angle = action.angle
  match action.kind {
    LightningArt => if action.frame == 10 { ignore(cast_chain_lightning(self)) }
    FlameArt => if action.frame == 14 { ignore(cast_splitting_fireball(self)) }
    AstralArt => ()
    DashArt => {
      if action.frame >= 4 && action.frame < 16 {
        let speed = self.params.player_speed * 3.3
        let steps = speed.ceil().to_int().max(1)
        for _ in 0..<steps {
          let x = self.player.x +
            @math.cos(action.angle) * speed / steps.to_double()
          let y = self.player.y +
            @math.sin(action.angle) * speed / steps.to_double()
          if check_wall_collision(grid, x, y, self.player.size) {
            action.frame = 16
            break
          }
          self.player.x = x
          self.player.y = y
          if self.enemies.any(enemy => {
              let dx = enemy.x - x
              let dy = enemy.y - y
              enemy.alive &&
              dx * dx + dy * dy <= 400.0 &&
              dx * @math.cos(action.angle) + dy * @math.sin(action.angle) > 0.0 &&
              !segment_hits_wall(grid, x, y, enemy.x, enemy.y, 0.0)
            }) {
            action.frame = 16
            break
          }
        }
        if action.frame % 3 == 0 {
          self.events.push(DashTrail(self.player.x, self.player.y))
        }
      }
      if action.frame == 16 {
        let mut hits = 0
        let reach = 36.0
        for enemy in self.enemies {
          let dx = enemy.x - self.player.x
          let dy = enemy.y - self.player.y
          let distance = (dx * dx + dy * dy).sqrt()
          if enemy.alive &&
            distance <= reach &&
            (
              distance < 0.001 ||
              (dx * @math.cos(action.angle) + dy * @math.sin(action.angle)) /
              distance >
              -0.2
            ) &&
            !segment_hits_wall(
              grid,
              self.player.x,
              self.player.y,
              enemy.x,
              enemy.y,
              0.0,
            ) {
            apply_player_damage_to_enemy(
              self,
              enemy,
              (self.player_stats.atk * 3).max(1),
              self.player.x,
              self.player.y,
            )
            hits += 1
          }
        }
        self.events.push(
          CombatImpact(DashCut, self.player.x, self.player.y, reach, hits),
        )
      }
    }
  }
  if action.frame >= 36 {
    arts.action = None
  }
}
