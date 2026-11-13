///|
pub fn Game::snapshot(self : Game) -> String {
  let party : Array[Json] = []
  for i in 0..<6 {
    let h = self.party[i]
    party.push({
      "id": h.id,
      "name": h.name(),
      "job": h.job.name(),
      "jobCode": h.job.code(),
      "level": h.level,
      "xp": h.xp,
      "hp": h.hp,
      "maxHp": h.max_hp(),
      "mp": h.mp,
      "maxMp": h.max_mp(),
      "front": i < 3,
    })
  }
  let cells : Array[Json] = []
  for z in 0..<9 {
    for x in 0..<9 {
      let id = cell_id(self.floor, x, z)
      cells.push({
        "x": x,
        "z": z,
        "kind": if self.seen[id] {
          tile(self.floor, x, z).name()
        } else {
          "unknown"
        },
        "visited": self.visited[id],
        "used": self.looted.contains(id) || self.used_shrines.contains(id),
        "open": self.opened.contains(id),
      })
    }
  }
  let battle : Json = match self.battle {
    None => Json::null()
    Some(b) => {
      let foes : Array[Json] = b.foes.map(f => {
        "kind": f.kind,
        "name": f.name,
        "hp": f.hp,
        "maxHp": f.max_hp,
        "intent": if f.sweeps && b.round % 2 == 1 {
          "前衛全体を薙ぎ払う"
        } else {
          "前衛への単体攻撃"
        },
      })
      let orders : Array[Json] = b.orders.map(o => {
        "actor": o.actor,
        "action": match o.action {
          Attack => "攻撃"
          Defend => "防御"
          Heal => "治癒"
          Flame => "火炎"
          Potion => "回復薬"
        },
        "target": o.target,
      })
      {
        "foes": foes,
        "orders": orders,
        "boss": b.boss,
        "round": b.round,
        "phase": match b.phase {
          Planning => "planning"
          Review => "review"
          Report => "report"
          Won => "won"
        },
        "active": if b.phase == Planning {
          self.active_actor()
        } else {
          -1
        },
        "reward": b.reward,
      }
    }
  }
  let effects : Array[Json] = self.effects.map(e => {
    let (team, target) = match e.target {
      Party(i) => ("party", i)
      Enemy(i) => ("enemy", i)
    }
    {
      "id": e.id,
      "kind": match e.kind {
        Impact => "hit"
        FlameHit => "fire"
        Recovery => "heal"
        GuardHit => "guard"
      },
      "team": team,
      "target": target,
      "amount": e.amount,
    }
  })
  let result : Json = {
    "schema": 1,
    "effects": effects,
    "revision": self.revision,
    "generation": self.generation,
    "mode": self.mode_name(),
    "selected": self.selected,
    "floor": self.floor,
    "x": self.x,
    "z": self.z,
    "facing": self.facing,
    "steps": self.steps,
    "light": self.light,
    "danger": self.danger,
    "dangerMax": self.encounter_steps(),
    "balance": self.balance.to_json(),
    "gold": self.gold,
    "carriedGold": self.carried_gold,
    "potions": self.potions,
    "bell": self.bell,
    "relic": self.relic,
    "clears": self.clears,
    "party": party,
    "battle": battle,
    "cells": cells,
    "log": self.log,
    "eventId": self.event_id,
    "event": self.event,
    "tile": tile(self.floor, self.x, self.z).name(),
  }
  result.stringify()
}
