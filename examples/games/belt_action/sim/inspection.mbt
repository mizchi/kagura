///|
fn bounded(v : Double, low : Double, high : Double) -> Double raise {
  if !(v - v == 0.0 && v >= low && v <= high) {
    fail("Expected finite value within \{low}..\{high}")
  }
  v
}

///|
fn integer(v : Double, low : Int32, high : Int32) -> Int32 raise {
  ignore(bounded(v, low.to_double(), high.to_double()))
  let n = v.to_int()
  if n.to_double() != v {
    fail("Expected integer")
  }
  n
}

///|
pub fn Game::apply_tuning(
  self : Game,
  subject : String,
  field : String,
  value : Double,
) -> Unit raise {
  match (subject, field) {
    ("player", "hp") => {
      if self.mode != "playing" && self.mode != "paused" {
        fail("Start a shift before editing the player")
      }
      self.player.hp = integer(value, 1, self.player.max_hp)
    }
    ("player", "x") => {
      let x = bounded(
        value,
        self.stage.to_double() * 760.0 + 20.0,
        self.gate_x() - 20.0,
      )
      self.player.x = x
      self.camera = clamp(x - 320.0, 0.0, 1420.0)
    }
    ("player", "z") => self.player.z = bounded(value, 300.0, 445.0)
    ("combat", "damage") => self.damage = integer(value, 1, 4)
    ("combat", "windup") => self.windup = integer(value, 36, 120)
    _ => fail("Inspection field is not writable")
  }
}

///|
pub fn Game::snapshot(self : Game) -> String {
  let enemies : Array[Json] = self.enemies.map(e => {
    "id": e.id,
    "kind": e.kind,
    "hp": e.hp,
    "maxHp": e.max_hp,
    "x": e.x,
    "z": e.z,
    "facing": e.facing,
    "action": e.action,
    "timer": e.timer,
    "phaseTotal": e.phase_total,
    "attackHit": e.attack_hit,
    "aimZ": e.aim_z,
    "braced": e.braced(),
    "open": e.open(),
  })
  let value : Json = {
    "game": "belt_action",
    "mode": self.mode,
    "generation": self.generation,
    "frameCount": self.frames,
    "tick": self.tick,
    "stage": self.stage,
    "remaining": self.remaining(),
    "gate": self.gate_x(),
    "hp": self.player.hp,
    "camera": self.camera,
    "hitStop": self.hit_stop,
    "score": self.score,
    "player": {
      "x": self.player.x,
      "z": self.player.z,
      "facing": self.player.facing,
      "action": self.player.action,
      "age": self.player.age,
      "combo": self.player.combo,
      "invulnerable": self.player.invulnerable,
      "evadeCooldown": self.player.evade_cooldown,
    },
    "enemies": enemies,
    "damage": self.damage,
    "windup": self.windup,
    "hits": self.hits,
    "blocks": self.blocks,
    "attacks": self.attacks,
    "dodges": self.dodges,
    "taken": self.taken,
    "bestCombo": self.best_combo,
    "soundId": self.sound_id,
    "sound": self.sound,
  }
  value.stringify()
}
