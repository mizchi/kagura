///|
pub fn Game::tuning_subjects(self : Game) -> Array[@inspection.Subject] {
  [
    {
      id: "game",
      name: "Game",
      fields: [
        @inspection.Field::Text("phase", "Phase", self.phase, false),
        @inspection.number("elapsed", self.elapsed, label="Elapsed", unit="s"),
        @inspection.number("kills", self.kills.to_double(), label="Kills"),
      ],
    },
    {
      id: "player",
      name: "Pilot",
      fields: [
        @inspection.number("hp", self.hp, label="HP", editable=true),
        @inspection.number(
          "position.x",
          self.pilot.position.x,
          label="Position X",
          unit="m",
        ),
        @inspection.number(
          "position.z",
          self.pilot.position.z,
          label="Position Z",
          unit="m",
        ),
        @inspection.number("boost", self.pilot.boost, label="Boost blend"),
      ],
    },
    {
      id: "weapons",
      name: "Weapons",
      fields: [
        @inspection.number(
          "rifleCooldown",
          self.rifle_cooldown,
          label="Rifle cooldown",
          unit="s",
          editable=true,
        ),
        @inspection.number(
          "missileCooldown",
          self.missile_cooldown,
          label="Missile cooldown",
          unit="s",
          editable=true,
        ),
      ],
    },
  ]
}

///|
pub fn Game::apply_tuning(
  self : Game,
  subject : String,
  field : String,
  value : Double,
) -> Unit raise {
  match (subject, field) {
    ("player", "hp") => self.hp = @inspection.bounded_number(value, 1.0, 1000.0)
    ("weapons", "rifleCooldown") =>
      self.rifle_cooldown = @inspection.bounded_number(value, 0.0, 5.0)
    ("weapons", "missileCooldown") =>
      self.missile_cooldown = @inspection.bounded_number(value, 0.0, 10.0)
    _ => fail("Inspection field is not writable")
  }
}
