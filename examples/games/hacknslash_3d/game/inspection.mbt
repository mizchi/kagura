///|
pub fn GameWorld::tuning_subjects(
  self : GameWorld,
) -> Array[@inspection.Subject] {
  [
    {
      id: "game",
      name: "Game",
      fields: [
        @inspection.number(
          "frameCount",
          self.frame_count.to_double(),
          label="Frame count",
          unit="ticks",
        ),
        @inspection.number("floor", self.floor.to_double(), label="Floor"),
        @inspection.number("score", self.score.to_double(), label="Score"),
        @inspection.number(
          "enemies",
          self.enemies.filter(e => e.alive).length().to_double(),
          label="Enemies",
        ),
      ],
    },
    {
      id: "player",
      name: "Hunter",
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
          "guardEnergy",
          self.arts.guard_energy,
          label="Guard energy",
          editable=true,
        ),
        @inspection.Field::Boolean(
          "guarding",
          "Guarding",
          self.arts.guarding,
          false,
        ),
        @inspection.number(
          "position.x",
          self.player.x / tile_size,
          label="Position X",
          unit="m",
        ),
        @inspection.number(
          "position.z",
          self.player.y / tile_size,
          label="Position Z",
          unit="m",
        ),
      ],
    },
  ]
}

///|
pub fn GameWorld::apply_tuning(
  self : GameWorld,
  subject : String,
  field : String,
  value : Double,
) -> Unit raise {
  if subject != "player" {
    fail("Inspection subject is not writable")
  }
  match field {
    "hp" =>
      self.player.hp = @inspection.bounded_integer(value, 1, self.player.max_hp)
    "guardEnergy" => {
      let energy = @inspection.bounded_number(value, 0.0, 100.0)
      self.arts.guard_energy = energy
      if energy == 0.0 {
        self.arts.guarding = false
        self.arts.guard_frame = 0
      }
    }
    _ => fail("Inspection field is not writable")
  }
}
