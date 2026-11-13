///|
fn subjects(g : @sim.Game) -> Array[@inspection.Subject] {
  let result : Array[@inspection.Subject] = [
    {
      id: "expedition",
      name: "Expedition",
      fields: [
        @inspection.Field::Text("mode", "Mode", g.mode_name(), false),
        @inspection.number("floor", g.floor.to_double() + 1, label="Floor"),
        @inspection.number("steps", g.steps.to_double(), label="Steps"),
        @inspection.number("light", g.light.to_double(), label="Light"),
        @inspection.number(
          "loot",
          g.carried_gold.to_double(),
          label="Carried gold",
        ),
      ],
    },
  ]
  for i in 0..<6 {
    let h = g.party[i]
    result.push({
      id: "hero:\{h.id}",
      name: h.name(),
      fields: [
        @inspection.number("rank", i.to_double() + 1, label="Rank"),
        @inspection.number("hp", h.hp.to_double(), label="HP"),
        @inspection.number("mp", h.mp.to_double(), label="MP"),
        @inspection.number("level", h.level.to_double(), label="Level"),
      ],
    })
  }
  if g.battle is Some(b) {
    for i in 0..<b.foes.length() {
      let f = b.foes[i]
      result.push({
        id: "foe:\{i}",
        name: f.name,
        fields: [
          @inspection.number("hp", f.hp.to_double(), label="HP"),
          @inspection.number("round", b.round.to_double(), label="Round"),
        ],
      })
    }
  }
  result
}

///|
fn App::register_inspection(self : App) -> Unit {
  self.control.register_fields(
    game="dungeon_rpg",
    scope=() => {
      self.control.scope("dungeon_rpg") +
      ":" +
      self.game.floor.to_string() +
      ":" +
      self.game.mode_name()
    },
    subjects=() => subjects(self.game),
    state=() => @json.parse(self.game.snapshot()) catch { _ => Json::null() },
    pause=value => self.control.set_paused(value),
    edit=(_, _, _) => fail("FATHOMの状態は読み取り専用です"),
  )
}
