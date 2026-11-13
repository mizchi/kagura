///|
/// Evaluation records are separate from the player's observation and save data.
pub struct ExperienceRecord {
  sequence : Int32
  data : Json
}

///|
fn Game::experience_record(
  self : Game,
  kind : String,
  payload : Json,
  target~ : String = "",
  instance~ : String = "",
  causes~ : Array[Int32] = [],
) -> Int32 {
  self.experience_sequence += 1
  let sequence = self.experience_sequence
  let parents = if causes.is_empty() && self.experience_cause > 0 {
    [self.experience_cause]
  } else {
    causes
  }
  let causes = parents.map(n => "s\{n}")
  let data : Json = if target == "" {
    {
      "version": 1,
      "id": "s\{sequence}",
      "sequence": sequence,
      "source": "simulation",
      "revision": self.revision,
      "type": kind,
      "causes": causes,
      "data": payload,
    }
  } else {
    {
      "version": 1,
      "id": "s\{sequence}",
      "sequence": sequence,
      "source": "simulation",
      "revision": self.revision,
      "type": kind,
      "target": target,
      "instance": instance,
      "causes": causes,
      "data": payload,
    }
  }
  self.experience.push({ sequence, data, })
  if self.experience.length() > 8192 {
    ignore(self.experience.remove(0))
  }
  sequence
}

///|
fn Game::experience_round_id(self : Game) -> String {
  let b = self.battle.unwrap()
  "round:\{self.generation}:\{self.experience_battle}:\{b.round}"
}

///|
fn Game::experience_start_round(self : Game) -> Unit {
  self.round_inputs.clear()
  let b = self.battle.unwrap()
  ignore(
    self.experience_record(
      "loop.start",
      { "round": b.round, "boss": b.boss },
      target="combat-round",
      instance=self.experience_round_id(),
    ),
  )
}

///|
fn Game::experience_resolved(
  self : Game,
  instance : String,
  last_effect : Int32,
  defeat~ : Bool = false,
) -> Unit {
  let causes = self.round_inputs.copy()
  if self.experience_cause > 0 && !causes.contains(self.experience_cause) {
    causes.push(self.experience_cause)
  }
  let mut damage = 0
  let mut healing = 0
  for e in self.effects {
    if e.id > last_effect && e.target is Party(_) {
      if e.kind == Recovery {
        healing += e.amount
      } else {
        damage += e.amount
      }
    }
  }
  let outcome = if defeat {
    "defeat"
  } else if self.battle.unwrap().phase == Won {
    "won"
  } else {
    "report"
  }
  ignore(
    self.experience_record(
      "loop.resolved",
      {
        "outcome": outcome,
        "damage": damage,
        "healing": healing,
        "hp": self.party.map(h => h.hp),
        "maxHp": self.party.map(h => h.max_hp()),
        "mp": self.party.map(h => h.mp),
        "potions": self.potions,
        "torch": self.light,
      },
      target="combat-round",
      instance~,
      causes~,
    ),
  )
}

///|
pub fn Game::experience_events(self : Game, after : Int32) -> Json {
  let first = self.experience_sequence - self.experience.length() + 1
  {
    "version": 1,
    "firstSequence": first,
    "lastSequence": self.experience_sequence,
    "dropped": after < first - 1,
    "events": self.experience.filter(e => e.sequence > after).map(e => e.data),
  }
}
