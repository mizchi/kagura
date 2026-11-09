///|
pub fn Game::tuning_subjects(self : Game) -> Array[@inspection.Subject] {
  [
    {
      id: "game",
      name: "Flight",
      fields: [
        @inspection.Field::Text("mode", "Mode", self.mode, false),
        @inspection.number("time", self.time, label="Elapsed", unit="s"),
        @inspection.number("wave", self.wave.to_double(), label="Wave"),
        @inspection.number("score", self.score.to_double(), label="Score"),
        @inspection.number(
          "enemies",
          self.enemies.length().to_double(),
          label="Enemies",
        ),
      ],
    },
    {
      id: "player",
      name: "Dragon",
      fields: [
        @inspection.number("hp", self.hp.to_double(), label="HP", editable=true),
        @inspection.number("heat", self.heat, label="Heat", editable=true),
        @inspection.Field::Boolean(
          "overheated",
          "Overheated",
          self.overheated,
          false,
        ),
        @inspection.number(
          "position.x",
          self.player.x,
          label="Position X",
          unit="m",
        ),
        @inspection.number(
          "position.y",
          self.player.y,
          label="Position Y",
          unit="m",
        ),
      ],
    },
  ]
}

///|
pub fn Game::tuning_state(self : Game) -> Json {
  {
    "mode": self.mode,
    "time": self.time,
    "hp": self.hp,
    "heat": self.heat,
    "overheated": self.overheated,
    "wave": self.wave,
    "score": self.score,
    "enemies": self.enemies.length(),
    "player": [self.player.x, self.player.y, self.player.z],
  }
}

///|
pub fn Game::apply_tuning(
  self : Game,
  subject : String,
  field : String,
  value : Double,
) -> Unit raise {
  if subject != "player" {
    fail("Inspection subject is not writable")
  }
  match field {
    "hp" => self.hp = @inspection.bounded_integer(value, 1, 6)
    "heat" => {
      let heat = @inspection.bounded_number(value, 0.0, 1.0)
      self.heat = heat
      if heat >= 1.0 {
        self.overheated = true
        self.breathing = false
      } else if heat < 0.2 {
        self.overheated = false
      }
    }
    _ => fail("Inspection field is not writable")
  }
}
