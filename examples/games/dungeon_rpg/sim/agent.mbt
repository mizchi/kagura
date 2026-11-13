///|
pub(all) struct AgentChoice {
  id : String
  label : String
  command : String
  arg : Int32
  z : Int32
}

///|
pub(all) struct AgentSession {
  game : Game
  history : Array[Json]
  mut started : Bool
  mut outcome : String
}

///|
pub fn AgentSession::new(seed~ : Int32 = 731) -> AgentSession {
  let game = new_game()
  game.seed = (seed % 65521 + 65521) % 65521
  { game, history: [], started: false, outcome: "", }
}

///|
fn option(
  id : String,
  label : String,
  command : String,
  arg~ : Int32 = -1,
  z~ : Int32 = -1,
) -> AgentChoice {
  { id, label, command, arg, z, }
}

///|
/// BFS only consults cells the party has actually seen. A route never crosses
/// an unknown cell or silently walks through a guardian's chamber.
fn AgentSession::route(
  self : AgentSession,
  tx : Int32,
  tz : Int32,
) -> Array[(Int32, Int32)] {
  let g = self.game
  let paths : Array[Array[(Int32, Int32)]] = [[(g.x, g.z)]]
  let reached : Array[(Int32, Int32)] = [(g.x, g.z)]
  for i = 0; i < paths.length(); i = i + 1 {
    let path = paths[i]
    let (x, z) = path[path.length() - 1]
    if x == tx && z == tz {
      return path
    }
    for (dx, dz) in [(1, 0), (0, 1), (-1, 0), (0, -1)] {
      let nx = x + dx
      let nz = z + dz
      if nx < 0 || nx > 8 || nz < 0 || nz > 8 || reached.contains((nx, nz)) {
        continue
      }
      let id = cell_id(g.floor, nx, nz)
      if !g.seen[id] || tile(g.floor, nx, nz) == Wall {
        continue
      }
      if tile(g.floor, nx, nz) == Guardian && !g.relic && (nx != tx || nz != tz) {
        continue
      }
      reached.push((nx, nz))
      let next = path.copy()
      next.push((nx, nz))
      paths.push(next)
    }
  }
  []
}

///|
pub fn AgentSession::choices(self : AgentSession) -> Array[AgentChoice] {
  if self.outcome != "" {
    return []
  }
  let g = self.game
  let choices : Array[AgentChoice] = []
  match g.mode {
    Town | Cleared => {
      if g.party.any(h => h.hp < h.max_hp() || h.mp < h.max_mp()) {
        choices.push(
          option(
            "rest", "Rest: restore all HP/MP and revive everyone; costs up to 8G",
            "rest",
          ),
        )
      }
      if g.gold >= 6 && g.potions < 12 {
        choices.push(
          option("buy", "Buy one healing potion for 6G (heals 14 HP)", "buy"),
        )
      }
      if g.party.any(h => h.hp > 0) {
        choices.push(
          option(
            "enter", "Enter B1 with the six adventurers. Goal: recover the B2 seal and bring it home.",
            "enter",
          ),
        )
      }
    }
    Exploring => {
      let current = tile(g.floor, g.x, g.z)
      let id = cell_id(g.floor, g.x, g.z)
      let interact = match current {
        Exit =>
          Some(
            if g.relic {
              "Return home with the seal: complete the expedition"
            } else {
              "Return to town WITHOUT the seal: end this expedition incomplete"
            },
          )
        Down => Some("Descend the stairs to B2")
        Up => Some("Ascend the stairs to B1")
        Chest if !g.looted.contains(id) =>
          Some("Inspect this treasure chest and choose how to open it")
        Shrine if !g.used_shrines.contains(id) =>
          Some("Use the shrine once: living heroes recover 6 HP and 2 MP")
        _ => None
      }
      if interact is Some(label) {
        choices.push(option("interact", label, "interact"))
      }
      for z in 0..<9 {
        for x in 0..<9 {
          let id = cell_id(g.floor, x, z)
          if !g.seen[id] ||
            tile(g.floor, x, z) == Wall ||
            (x == g.x && z == g.z) {
            continue
          }
          let t = tile(g.floor, x, z)
          let useful = !g.visited[id] ||
            [Exit, Down, Up].contains(t) ||
            (t == Chest && !g.looted.contains(id)) ||
            (t == Shrine && !g.used_shrines.contains(id)) ||
            (t == Guardian && !g.relic)
          if !useful {
            continue
          }
          let path = self.route(x, z)
          if path.is_empty() {
            continue
          }
          let goal = if !g.visited[id] { "unexplored " } else { "" }
          choices.push(
            option(
              "go:\{x}:\{z}",
              "Travel to \{goal}\{t.name()} at (\{x},\{z}), \{path.length()-1} known steps. Stops if enemies appear.",
              "navigate",
              arg=x,
              z~,
            ),
          )
        }
      }
      let caster = g.party.any(h => h.job == Priest && h.hp > 0 && h.mp >= 2)
      for i in 0..<6 {
        let h = g.party[i]
        if h.hp <= 0 || h.hp >= h.max_hp() {
          continue
        }
        if caster {
          choices.push(
            option(
              "field-heal:\{i}",
              "Priest heals \{h.name()} (\{h.hp}/\{h.max_hp()} HP) by 12, costs 2 MP",
              "field-heal",
              arg=i,
            ),
          )
        }
        if g.potions > 0 {
          choices.push(
            option(
              "field-potion:\{i}",
              "Use a potion on \{h.name()} (\{h.hp}/\{h.max_hp()} HP), heals 14",
              "field-potion",
              arg=i,
            ),
          )
        }
      }
      if g.bell > 0 {
        choices.push(
          option(
            "recall",
            if g.relic {
              "Ring the return bell: bring the seal home now; keep half the carried gold"
            } else {
              "Emergency recall WITHOUT the seal: end incomplete, keep half the carried gold"
            },
            "recall",
          ),
        )
      }
    }
    Looting => {
      if g.party.any(h => h.job == Thief && h.hp > 0) {
        choices.push(
          option(
            "loot:0",
            "Thief disarms the trap and collects 12G, one potion and 8 torch fuel",
            "loot",
            arg=0,
          ),
        )
      }
      choices.push(
        option(
          "loot:1",
          "Force the chest: first living hero takes up to 3 damage, collect the treasure",
          "loot",
          arg=1,
        ),
      )
      choices.push(option("back", "Leave the chest unopened", "back"))
    }
    Warning => {
      choices.push(
        option(
          "challenge", "Challenge the B2 guardian and its spirit. Cannot flee; win the seal, then return home.",
          "challenge",
        ),
      )
      choices.push(
        option(
          "back", "Step out of the guardian chamber to heal or explore first", "back",
        ),
      )
    }
    Fighting => {
      let b = g.battle.unwrap()
      if b.phase == Report || b.phase == Won {
        return [
          option(
            "continue",
            if b.phase == Won {
              "Continue exploration after victory"
            } else {
              "Start planning the next round"
            },
            "continue",
          ),
        ]
      }
      if b.phase == Review {
        return [option("resolve", "Execute the complete round plan", "resolve")]
      }
      let actor = g.active_actor()
      if actor < 0 {
        return []
      }
      let h = g.party[actor]
      for i in 0..<b.foes.length() {
        if b.foes[i].hp > 0 {
          choices.push(
            option(
              "attack:\{i}",
              "\{h.name()} attacks \{b.foes[i].name} (\{b.foes[i].hp} HP)",
              "attack",
              arg=i,
            ),
          )
        }
      }
      choices.push(
        option(
          "guard",
          "\{h.name()} guards: halve damage; a guarding knight intercepts one single-target hit",
          "guard",
        ),
      )
      if h.job == Mage && h.mp >= 3 {
        choices.push(
          option(
            "flame",
            "\{h.name()} casts flame: 6-8 damage to every living enemy, costs 3 MP",
            "flame",
          ),
        )
      }
      let potions = g.potions -
        b.orders.filter(o => o.action == Potion).length()
      for i in 0..<6 {
        let target = g.party[i]
        if target.hp <= 0 || target.hp >= target.max_hp() {
          continue
        }
        if h.job == Priest && h.mp >= 2 {
          choices.push(
            option(
              "heal:\{i}",
              "\{h.name()} heals \{target.name()} (\{target.hp}/\{target.max_hp()} HP) by 12 for 2 MP",
              "heal",
              arg=i,
            ),
          )
        }
        if potions > 0 {
          choices.push(
            option(
              "potion:\{i}",
              "\{h.name()} uses a potion to heal \{target.name()} by 14",
              "potion",
              arg=i,
            ),
          )
        }
      }
      if b.orders.is_empty() {
        choices.push(
          option(
            "all-attack", "Commit all living heroes to normal attacks immediately; saves planning, spends no spells",
            "all-attack",
          ),
        )
        if !b.boss {
          choices.push(
            option(
              "flee", "Attempt escape: 75% with a living thief, otherwise 45%; failure gives enemies a free round",
              "flee",
            ),
          )
        }
      }
    }
  }
  choices
}

///|
pub fn AgentSession::step(
  self : AgentSession,
  revision : Int32,
  choice_id : String,
) -> Unit raise {
  if self.outcome != "" {
    fail("terminal")
  }
  if revision != self.game.revision {
    fail("stale_revision")
  }
  let selected = self.choices().filter(c => c.id == choice_id).get(0)
  guard selected is Some(c) else { fail("illegal_choice") }
  let g = self.game
  if c.command == "navigate" {
    let path = self.route(c.arg, c.z)
    for i in 1..<path.length() {
      let (x, z) = path[i]
      let facing = if x > g.x {
        1
      } else if x < g.x {
        3
      } else if z > g.z {
        2
      } else {
        0
      }
      while g.facing != facing {
        g.command("right", -1)
      }
      if g.blocked(x, z) {
        g.command("interact", -1)
      }
      if g.mode != Exploring {
        break
      }
      g.command("forward", -1)
      if g.mode != Exploring {
        break
      }
    }
  } else {
    g.command(c.command, c.arg)
  }
  if c.command == "enter" {
    self.started = true
  }
  if g.mode == Fighting && g.battle.unwrap().phase == Review {
    g.command("resolve", -1)
  }
  if g.mode == Cleared {
    self.outcome = "victory"
  } else if self.started && g.mode == Town {
    self.outcome = if g.event == "defeat" { "defeat" } else { "returned" }
  }
  self.history.push({
    "choice": c.id,
    "floor": g.floor + 1,
    "x": g.x,
    "z": g.z,
    "phase": g.mode_name(),
  })
  if self.history.length() > 8 {
    ignore(self.history.remove(0))
  }
}
