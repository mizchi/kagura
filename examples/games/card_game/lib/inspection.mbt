///|
pub fn Game::set_inspection_paused(self : Game, value : Bool) -> Unit {
  self.inspection.set_paused(value)
  self.input = @inpututil.new_input_helper()
  self.navigation = @ui.UINavigationInputAdapter::new()
  self.cancel_card()
  self.last_frame_ms = None
}

///|
/// Native/headless hosts use the same guarded boundary as browser adapters.
pub fn Game::read_inspection(self : Game) -> String {
  self.inspection.fields_json(self.tuning_scope(), self.tuning_subjects())
}

///|
pub fn Game::observe_inspection(self : Game) -> String {
  self.inspection.observation_json(
    self.tuning_state(),
    self.tuning_scope(),
    self.tuning_subjects(),
  )
}

///|
pub fn Game::edit_inspection(
  self : Game,
  subject : String,
  field : String,
  value : Double,
  revision : Int32,
  scope : String,
) -> Unit raise {
  self.inspection.commit(revision, scope, self.tuning_scope(), () => {
    self.apply_tuning(subject, field, value)
  })
}

///|
fn Game::tuning_scope(self : Game) -> String {
  self.inspection.scope("card_game") + ":\{self.run.get().floor}"
}

///|
fn Game::can_tune(self : Game) -> Bool {
  self.scene == Playing && self.presentation is None
}

///|
fn Game::can_tune_battle(self : Game) -> Bool {
  self.can_tune() &&
  self.popup is None &&
  self.run.get().phase == Battle &&
  self.run.get().battle is Some({ phase: PlayerTurn, .. })
}

///|
fn Game::tuning_subjects(self : Game) -> Array[@inspection.Subject] {
  let run = self.run.get()
  let fields = [
    @inspection.number(
      "hp",
      run.player_hp.to_double(),
      label="HP",
      editable=self.can_tune(),
    ),
    @inspection.number("maxHp", run.player_max_hp.to_double(), label="Max HP"),
  ]
  if run.battle is Some(battle) {
    fields.push(
      @inspection.number(
        "energy",
        battle.player.energy.to_double(),
        label="Energy",
        editable=self.can_tune_battle(),
      ),
    )
    fields.push(
      @inspection.number(
        "block",
        battle.player.block.to_double(),
        label="Block",
        editable=self.can_tune_battle(),
      ),
    )
    fields.push(
      @inspection.number("turn", battle.turn.to_double(), label="Turn"),
    )
  }
  [
    {
      id: "run",
      name: "Run",
      fields: [
        @inspection.Field::Text("scene", "Scene", self.snapshot_state(), false),
        @inspection.number("floor", run.floor.to_double(), label="Floor"),
        @inspection.number(
          "gold",
          run.gold.to_double(),
          label="Gold",
          editable=self.can_tune(),
        ),
      ],
    },
    { id: "player", name: "Player", fields, },
  ]
}

///|
fn Game::tuning_state(self : Game) -> Json {
  let run = self.run.get()
  let battle : Json = match run.battle {
    Some(b) =>
      {
        "hp": b.player.hp,
        "energy": b.player.energy,
        "block": b.player.block,
        "turn": b.turn,
        "hand": b.hand.length(),
        "drawPile": b.draw_pile.length(),
      }
    None => Json::null()
  }
  {
    "scene": self.snapshot_state(),
    "hp": run.player_hp,
    "gold": run.gold,
    "floor": run.floor,
    "battle": battle,
  }
}

///|
fn Game::apply_tuning(
  self : Game,
  subject : String,
  field : String,
  value : Double,
) -> Unit raise {
  if !self.can_tune() {
    fail("Wait for an idle game scene before tuning")
  }
  let run = self.run.get()
  match (subject, field) {
    ("player", "hp") => {
      let limit = match run.battle {
        Some(b) => run.player_max_hp.min(b.player.max_hp)
        None => run.player_max_hp
      }
      let hp = @inspection.bounded_integer(value, 1, limit)
      run.player_hp = hp
      if run.battle is Some(battle) {
        battle.player.hp = hp
      }
    }
    ("run", "gold") => run.gold = @inspection.bounded_integer(value, 0, 99999)
    ("player", "energy") | ("player", "block") => {
      if !self.can_tune_battle() {
        fail("Wait for an idle player turn before tuning battle resources")
      }
      let number = @inspection.bounded_integer(
        value,
        0,
        if field == "energy" {
          99
        } else {
          999
        },
      )
      let battle = run.battle.unwrap()
      if field == "energy" {
        battle.player.energy = number
      } else {
        battle.player.block = number
      }
    }
    _ => fail("Inspection field is not writable")
  }
  self.run.set(run)
}
