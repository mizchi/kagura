///|
fn SurvivorState::set_inspection_paused(
  self : SurvivorState,
  value : Bool,
) -> Unit {
  self.inspection.set_paused(value)
  self.input = @inpututil.new_input_helper()
}

///|
fn SurvivorState::tuning_subjects(
  self : SurvivorState,
) -> Array[@inspection.Subject] {
  [
    {
      id: "game",
      name: "Game",
      fields: [
        @inspection.Field::Text("mode", "Mode", self.snapshot_state(), false),
        @inspection.number(
          "frameCount",
          self.frame_count.to_double(),
          label="Frame count",
          unit="ticks",
        ),
        @inspection.number("score", self.score.to_double(), label="Score"),
        @inspection.number("level", self.level.to_double(), label="Level"),
        @inspection.number(
          "enemies",
          self.enemies.filter(e => e.alive).length().to_double(),
          label="Enemies",
        ),
      ],
    },
    {
      id: "player",
      name: "Player",
      fields: [
        @inspection.number(
          "hp",
          self.player.hp.to_double(),
          label="HP",
          editable=true,
        ),
        @inspection.number(
          "maxHp",
          self.player.max_hp.to_double(),
          label="Max HP",
        ),
        @inspection.number(
          "position.x",
          self.player.x,
          label="Position X",
          unit="px",
          editable=true,
        ),
        @inspection.number(
          "position.y",
          self.player.y,
          label="Position Y",
          unit="px",
          editable=true,
        ),
      ],
    },
    {
      id: "weapon",
      name: "Projectile weapon",
      fields: [
        @inspection.number(
          "damage",
          self.projectile_weapon.damage.to_double(),
          label="Damage",
          editable=true,
        ),
        @inspection.number(
          "interval",
          self.projectile_weapon.interval.to_double(),
          label="Fire interval",
          unit="ticks",
          editable=true,
        ),
      ],
    },
  ]
}

///|
fn SurvivorState::tuning_state(self : SurvivorState) -> Json {
  {
    "mode": self.snapshot_state(),
    "frameCount": self.frame_count,
    "hp": self.player.hp,
    "player": [self.player.x, self.player.y],
    "score": self.score,
    "level": self.level,
    "xp": self.xp,
    "enemies": self.enemies.filter(e => e.alive).length(),
    "projectiles": self.projectiles.length(),
    "weapon": {
      "damage": self.projectile_weapon.damage,
      "interval": self.projectile_weapon.interval,
    },
  }
}

///|
fn SurvivorState::apply_tuning(
  self : SurvivorState,
  subject : String,
  field : String,
  value : Double,
) -> Unit raise {
  match (subject, field) {
    ("player", "hp") =>
      self.player.hp = @inspection.bounded_integer(value, 1, self.player.max_hp)
    ("player", "position.x") | ("player", "position.y") => {
      let bound = if field == "position.x" {
        self.world_w
      } else {
        self.world_h
      }
      let position = @inspection.bounded_number(
        value,
        self.player.size,
        bound - self.player.size,
      )
      if field == "position.x" {
        self.player.x = position
      } else {
        self.player.y = position
      }
      self.camera.follow_target(self.player.x, self.player.y)
    }
    ("weapon", "damage") =>
      self.projectile_weapon.damage = @inspection.bounded_integer(value, 1, 100)
    ("weapon", "interval") =>
      self.projectile_weapon.interval = @inspection.bounded_integer(
        value, 1, 600,
      )
    _ => fail("Inspection field is not writable")
  }
}
