///|
pub(all) enum PlayerWeaponKind {
  Cleaver
  Spear
  Knuckles
  Focus
  Bow
} derive(Eq, Debug)

///|
/// Frame timing is shared by combat, rig playback and portable motion exports.
pub(all) struct PlayerWeaponProfile {
  id : String
  name : String
  action : String
  windup : Int
  recovery : Int
  reach : Double
  width : Double
}

///|
let player_weapon_profiles : Array[PlayerWeaponProfile] = [
  {
    id: "cleaver_flintlock",
    name: "狩人の鉈",
    action: "斬撃",
    windup: 7,
    recovery: 12,
    reach: 28.0,
    width: 28.0,
  },
  {
    id: "spear",
    name: "狩猟槍",
    action: "刺突",
    windup: 16,
    recovery: 18,
    reach: 44.0,
    width: 6.0,
  },
  {
    id: "knuckles",
    name: "鉄の拳具",
    action: "殴打",
    windup: 10,
    recovery: 14,
    reach: 20.0,
    width: 10.0,
  },
  {
    id: "focus",
    name: "燐火の触媒",
    action: "魔法弾",
    windup: 24,
    recovery: 20,
    reach: 180.0,
    width: 0.0,
  },
  {
    id: "bow",
    name: "骨の長弓",
    action: "射撃",
    windup: 30,
    recovery: 22,
    reach: 220.0,
    width: 0.0,
  },
]

///|
pub fn PlayerWeaponKind::index(self : PlayerWeaponKind) -> Int {
  match self {
    Cleaver => 0
    Spear => 1
    Knuckles => 2
    Focus => 3
    Bow => 4
  }
}

///|
pub fn player_weapon_from_index(index : Int) -> PlayerWeaponKind? {
  match index {
    0 => Some(Cleaver)
    1 => Some(Spear)
    2 => Some(Knuckles)
    3 => Some(Focus)
    4 => Some(Bow)
    _ => None
  }
}

///|
pub fn PlayerWeaponKind::profile(
  self : PlayerWeaponKind,
) -> PlayerWeaponProfile {
  player_weapon_profiles[self.index()]
}

///|
pub fn player_weapon_from_id(id : String) -> PlayerWeaponKind? {
  for i in 0..<player_weapon_profiles.length() {
    if player_weapon_profiles[i].id == id {
      return player_weapon_from_index(i)
    }
  }
  None
}

///|
pub(all) struct PlayerWeaponAttack {
  weapon : PlayerWeaponKind
  angle : Double
  mut frame : Int
}

///|
pub fn GameWorld::equip_player_weapon(
  self : GameWorld,
  weapon : PlayerWeaponKind,
) -> Bool {
  if self.hunter_action_locked() ||
    self.mode != Playing ||
    self.ui_mode != UIMode::None ||
    self.weapon_attack is Some(_) ||
    self.player_charge is Some(_) ||
    self.player.dash_timer > 0 {
    return false
  }
  self.player_weapon = weapon
  true
}

///|
pub fn GameWorld::tick_player_weapon_attack(self : GameWorld) -> Unit {
  guard self.weapon_attack is Some(attack) else { return }
  if self.player.dash_timer > 0 || self.player.hp <= 0 {
    self.weapon_attack = None
    return
  }
  attack.frame += 1
  let profile = attack.weapon.profile()
  // Keep the committed attack direction while moving, so contact matches the rig.
  self.player.facing_angle = attack.angle
  if attack.frame == profile.windup {
    let crit_roll = (self.frame_count * 31 + self.seed * 7) % 100
    let physical = if crit_roll.to_double() / 100.0 <
      self.player_stats.crit_chance {
      self.player_stats.atk * 2
    } else {
      self.player_stats.atk
    }
    let x = self.player.x
    let y = self.player.y
    let c = @math.cos(attack.angle)
    let s = @math.sin(attack.angle)
    match attack.weapon {
      Bow | Focus => {
        let magic = attack.weapon == Focus
        let speed = if magic {
          self.params.arrow_speed * 0.75
        } else {
          self.params.arrow_speed
        }
        self.projectiles.push({
          x: x + c * 8.0,
          y: y + s * 8.0,
          vx: c * speed,
          vy: s * speed,
          age: 0,
          alive: true,
          damage: if magic {
            self.player_stats.spell_power.max(1)
          } else {
            physical.max(1)
          },
          is_player: true,
          kind: if magic {
            Fireball(0)
          } else {
            Arrow
          },
        })
        if magic {
          self.events.push(FireballCast(x, y))
        }
      }
      _ => {
        let damage = (physical.to_double() *
          self.archetype.basic_attack_multiplier())
          .to_int()
          .max(1)
        for enemy in self.enemies {
          if !enemy.alive {
            continue
          }
          let dx = enemy.x - x
          let dy = enemy.y - y
          let forward = dx * c + dy * s
          let lateral = (dx * s - dy * c).abs()
          if forward >= 0.0 &&
            forward <= profile.reach + enemy.size / 2.0 &&
            lateral <= profile.width + enemy.size / 2.0 &&
            !enemy_direct_chase_path_blocked(
              self.dungeon.grid,
              x,
              y,
              enemy.x,
              enemy.y,
              1.0,
            ) {
            apply_player_damage_to_enemy(self, enemy, damage, x, y)
          }
        }
        if attack.weapon == Cleaver {
          self.events.push(MeleeSlash(x, y, profile.reach))
        }
      }
    }
  }
  if attack.frame >= profile.windup + profile.recovery {
    self.weapon_attack = None
  }
}
