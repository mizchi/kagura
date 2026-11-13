///|
pub fn AgentSession::observe(self : AgentSession) -> Json {
  let g = self.game
  let party : Array[Json] = []
  for i in 0..<6 {
    let h = g.party[i]
    party.push({
      "slot": i,
      "id": h.id,
      "name": h.name(),
      "job": h.job.name(),
      "jobCode": h.job.code(),
      "level": h.level,
      "hp": h.hp,
      "maxHp": h.max_hp(),
      "mp": h.mp,
      "maxMp": h.max_mp(),
      "attack": h.attack(),
      "armor": h.armor(),
      "speed": h.speed(),
      "front": i < 3,
    })
  }
  let known : Array[Json] = []
  for floor in 0..<2 {
    for z in 0..<9 {
      for x in 0..<9 {
        let id = cell_id(floor, x, z)
        if !g.seen[id] {
          continue
        }
        known.push({
          "floor": floor + 1,
          "x": x,
          "z": z,
          "kind": tile(floor, x, z).name(),
          "visited": g.visited[id],
          "open": g.opened.contains(id),
          "used": g.looted.contains(id) || g.used_shrines.contains(id),
        })
      }
    }
  }
  let battle : Json = match g.battle {
    None => Json::null()
    Some(b) => {
      let enemies : Array[Json] = b.foes.map(f => {
        "name": f.name,
        "hp": f.hp,
        "maxHp": f.max_hp,
        "armor": f.armor,
        "speed": f.speed,
        "intent": if f.sweeps && b.round % 2 == 1 {
          "sweep front rank"
        } else {
          "attack one front-rank hero"
        },
        "damageBase": if f.sweeps && b.round % 2 == 1 {
          g.sweep_damage()
        } else {
          f.attack
        },
      })
      let orders : Array[Json] = b.orders.map(o => {
        "actor": o.actor,
        "action": match o.action {
          Attack => "attack"
          Defend => "guard"
          Heal => "heal"
          Flame => "flame"
          Potion => "potion"
        },
        "target": o.target,
      })
      {
        "round": b.round,
        "boss": b.boss,
        "actor": if b.phase == Planning {
          g.active_actor()
        } else {
          -1
        },
        "phase": match b.phase {
          Planning => "planning"
          Review => "review"
          Report => "report"
          Won => "won"
        },
        "enemies": enemies,
        "orders": orders,
      }
    }
  }
  let choices : Array[Json] = self
    .choices()
    .map(c => {
      let action : Json = if c.command == "navigate" {
        { "kind": c.command, "x": c.arg, "z": c.z }
      } else {
        { "kind": c.command, "target": c.arg }
      }
      { "id": c.id, "label": c.label, "action": action }
    })
  {
    "schemaVersion": 2,
    "game": "dungeon_rpg",
    "engineVersion": 3,
    "revision": g.revision,
    "phase": if self.outcome != "" {
      self.outcome
    } else {
      g.mode_name()
    },
    "terminal": self.outcome != "",
    "choices": choices,
    "state": {
      "floor": g.floor + 1,
      "x": g.x,
      "z": g.z,
      "facing": ["north", "east", "south", "west"][g.facing],
      "torch": g.light,
      "danger": g.danger,
      "dangerMax": g.encounter_steps(),
      "balance": g.balance.to_json(),
      "gold": g.gold,
      "carriedGold": g.carried_gold,
      "potions": g.potions,
      "returnBells": g.bell,
      "hasSeal": g.relic,
      "party": party,
      "map": { "width": 9, "height": 9, "known": known },
      "battle": battle,
      "recentLog": g.log,
      "recentActions": self.history,
    },
  }
}
