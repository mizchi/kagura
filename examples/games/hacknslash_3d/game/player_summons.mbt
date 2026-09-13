///|
fn GameWorld::zombie_spawn_point(self : GameWorld) -> (Double, Double) {
  for ring in 1..<4 {
    for i in 0..<8 {
      let angle = self.player.facing_angle + i.to_double() * @math.PI / 4.0
      let x = self.player.x + @math.cos(angle) * (ring * 16).to_double()
      let y = self.player.y + @math.sin(angle) * (ring * 16).to_double()
      if !check_wall_collision(self.dungeon.grid, x, y, 11.0) &&
        !segment_hits_wall(
          self.dungeon.grid,
          self.player.x,
          self.player.y,
          x,
          y,
          5.5,
        ) &&
        !self.enemies.any(e => {
          e.alive && (e.x - x).abs() < 12.0 && (e.y - y).abs() < 12.0
        }) &&
        !self.summons.zombies.any(z => {
          z.body.alive &&
          (z.body.x - x).abs() < 12.0 &&
          (z.body.y - y).abs() < 12.0
        }) {
        return (x, y)
      }
    }
  }
  // Friendly bodies do not block the hunter; a narrow passage can use this origin.
  (self.player.x, self.player.y)
}

///|
/// Release only at the casting contact frame. Cancelling windup costs no cooldown.
fn GameWorld::release_player_summon(
  self : GameWorld,
  kind : HunterArtKind,
) -> Unit {
  match kind {
    RaiseZombieArt => {
      if self.summons.zombies.length() >= summoned_zombie_limit {
        ignore(self.summons.zombies.remove(0))
      }
      let (x, y) = self.zombie_spawn_point()
      let hp = 24 +
        self.player_stats.spell_power * 4 +
        self.skills.get_level(RaiseZombie) * 8
      self.summons.zombies.push({
        body: make_enemy(x, y, Zombie, hp, 1.25, 11.0),
      })
      self.summons.zombie_cooldown = summoned_zombie_cooldown
      self.events.push(SummonReleased(x, y, false))
    }
    FlamingSkullArt => {
      if self.summons.skulls.length() >= flaming_skull_limit {
        ignore(self.summons.skulls.remove(0))
      }
      let angle = self.player.facing_angle
      let x = self.player.x + @math.cos(angle) * 12.0
      let y = self.player.y + @math.sin(angle) * 12.0
      self.summons.skulls.push({
        x,
        y,
        angle,
        age: 0,
        attack_cooldown: 0,
        target: None,
      })
      self.summons.skull_cooldown = flaming_skull_cooldown
      self.events.push(SummonReleased(x, y, true))
    }
    _ => ()
  }
}

///|
fn GameWorld::summon_target(
  self : GameWorld,
  x : Double,
  y : Double,
  grounded : Bool,
  grid : @terrain.Grid2D,
) -> Enemy? {
  let mut nearest = 240.0 * 240.0
  let mut target : Enemy? = None
  for enemy in self.enemies {
    let dx = enemy.x - x
    let dy = enemy.y - y
    let d = dx * dx + dy * dy
    if enemy.alive &&
      d < nearest &&
      (
        !grounded ||
        !enemy_direct_chase_path_blocked(grid, x, y, enemy.x, enemy.y, 1.0)
      ) {
      target = Some(enemy)
      nearest = d
    }
  }
  target
}

///|
fn GameWorld::summon_damage(
  self : GameWorld,
  enemy : Enemy,
  skill : SkillId,
  x : Double,
  y : Double,
) -> Unit {
  let base = if skill == RaiseZombie {
    self.player_stats.spell_power + 2
  } else {
    (self.player_stats.spell_power / 2).max(1)
  }
  let damage = (base.to_double() *
    skill_level_damage_multiplier(skill, self.skills.get_level(skill)) *
    tag_damage_multiplier(self.player_stats, skill))
    .to_int()
    .max(1)
  // Credit kills and damage numbers to the owner without granting the owner's life steal.
  apply_player_damage_to_enemy(self, enemy, damage, x, y, life_steal=false)
}

///|
pub fn GameWorld::tick_player_summons(self : GameWorld) -> Unit {
  self.tick_player_summons_with_grid(self.dungeon.grid)
}

///|
fn GameWorld::tick_player_summons_with_grid(
  self : GameWorld,
  grid : @terrain.Grid2D,
) -> Unit {
  if self.player.hp <= 0 {
    self.summons.clear()
    return
  }
  self.summons.zombie_cooldown = (self.summons.zombie_cooldown - 1).max(0)
  self.summons.skull_cooldown = (self.summons.skull_cooldown - 1).max(0)
  for zombie in self.summons.zombies {
    let body = zombie.body
    if !body.alive {
      continue
    }
    body.damage_timer = (body.damage_timer - 1).max(0)
    tick_enemy_attack(body)
    let target = self.summon_target(body.x, body.y, true, grid)
    if body.attack_motion == NoAttack && target is Some(enemy) {
      ignore(try_start_zombie_pounce(body, enemy.combat_target(), grid, []))
    }
    if !update_zombie_pounce(body) {
      let (tx, ty) = match target {
        Some(enemy) => (enemy.x, enemy.y)
        None => (self.player.x, self.player.y)
      }
      self.move_summoned_zombie(body, tx, ty, target is None, grid)
    } else {
      self.move_summoned_body(body, body.vx, body.vy, grid)
    }
    if body.attack_hit_pending {
      body.attack_hit_pending = false
      for enemy in self.enemies {
        if enemy.alive && enemy_melee_hits(body, enemy.combat_target(), grid) {
          self.summon_damage(enemy, RaiseZombie, body.x, body.y)
        }
      }
    }
  }
  for i = self.summons.zombies.length() - 1; i >= 0; i = i - 1 {
    if !self.summons.zombies[i].body.alive {
      ignore(self.summons.zombies.remove(i))
    }
  }
  for index, skull in self.summons.skulls {
    skull.age += 1
    if skull.age >= flaming_skull_lifetime {
      continue
    }
    skull.attack_cooldown = (skull.attack_cooldown - 1).max(0)
    if skull.target is Some(enemy) {
      let dx = enemy.x - skull.x
      let dy = enemy.y - skull.y
      if !enemy.alive || dx * dx + dy * dy > 240.0 * 240.0 {
        skull.target = None
      }
    }
    if skull.target is None {
      skull.target = self.summon_target(skull.x, skull.y, false, grid)
    }
    let (tx, ty) = match skull.target {
      Some(enemy) => {
        let orbit = index.to_double() * 2.4 + skull.age.to_double() * 0.025
        (enemy.x + @math.cos(orbit) * 11.0, enemy.y + @math.sin(orbit) * 11.0)
      }
      None => {
        let angle = skull.age.to_double() * 0.035 + index.to_double() * 2.4
        (
          self.player.x + @math.cos(angle) * 24.0,
          self.player.y + @math.sin(angle) * 24.0,
        )
      }
    }
    let dx = tx - skull.x
    let dy = ty - skull.y
    let distance = (dx * dx + dy * dy).sqrt()
    if distance > 0.1 {
      skull.angle = @math.atan2(dy, dx)
      let step = distance.min(3.4)
      skull.x += dx / distance * step
      skull.y += dy / distance * step
    }
    if distance <= 14.0 &&
      skull.attack_cooldown == 0 &&
      skull.target is Some(enemy) &&
      enemy.alive {
      self.summon_damage(enemy, SummonFlamingSkull, skull.x, skull.y)
      skull.attack_cooldown = 36
    }
  }
  for i = self.summons.skulls.length() - 1; i >= 0; i = i - 1 {
    if self.summons.skulls[i].age >= flaming_skull_lifetime {
      ignore(self.summons.skulls.remove(i))
    }
  }
}
