///|
let floors : Array[Array[String]] = [
  [
    "#########", "#E..#...#", "#.#.#.#T#", "#.#...#.#", "#.###.#.#", "#...D...#",
    "###.#.#.#", "#T..#..>#", "#########",
  ],
  [
    "#########", "#<..#..T#", "#.#.#.#.#", "#.#...#.#", "#...#...#", "###.###.#",
    "#S..#...#", "#...D.B.#", "#########",
  ],
]

///|
pub fn tile(floor : Int32, x : Int32, z : Int32) -> Tile {
  if floor < 0 || floor > 1 || x < 0 || x > 8 || z < 0 || z > 8 {
    return Wall
  }
  match floors[floor][z][x].to_int() {
    35 => Wall
    69 => Exit
    62 => Down
    60 => Up
    84 => Chest
    83 => Shrine
    68 => Door
    66 => Guardian
    _ => Passage
  }
}

///|
pub fn Tile::name(self : Tile) -> String {
  match self {
    Wall => "wall"
    Passage => "floor"
    Exit => "exit"
    Down => "down"
    Up => "up"
    Chest => "chest"
    Shrine => "shrine"
    Door => "door"
    Guardian => "guardian"
  }
}

///|
pub fn cell_id(floor : Int32, x : Int32, z : Int32) -> Int32 {
  floor * 81 + z * 9 + x
}

///|
pub fn Game::blocked(self : Game, x : Int32, z : Int32) -> Bool {
  let t = tile(self.floor, x, z)
  t == Wall || (t == Door && !self.opened.contains(cell_id(self.floor, x, z)))
}

///|
pub fn direction(facing : Int32) -> (Int32, Int32) {
  [(0, -1), (1, 0), (0, 1), (-1, 0)][(facing + 4) % 4]
}

///|
fn Game::reveal(self : Game) -> Unit {
  self.visited[cell_id(self.floor, self.x, self.z)] = true
  self.seen[cell_id(self.floor, self.x, self.z)] = true
  for (dx, dz) in [(1, 0), (-1, 0), (0, 1), (0, -1)] {
    for d in 1..<3 {
      let x = self.x + dx * d
      let z = self.z + dz * d
      if x < 0 || z < 0 || x > 8 || z > 8 {
        break
      }
      self.seen[cell_id(self.floor, x, z)] = true
      if self.blocked(x, z) {
        break
      }
    }
  }
}

///|
fn Game::enter(self : Game) -> Unit {
  self.effects.clear()
  self.set_mode(Exploring)
  self.generation += 1
  self.floor = 0
  self.x = 1
  self.z = 1
  self.facing = 1
  self.steps = 0
  self.light = 70
  self.danger = 0
  self.carried_gold = 0
  self.bell = 1
  self.relic = false
  self.battle = None
  self.selected = -1
  self.seen.fill(false)
  self.visited.fill(false)
  self.opened.clear()
  self.looted.clear()
  self.used_shrines.clear()
  self.reveal()
  self.note(
    "地下1階。灯りと呪文を残し、印章を持って地上へ帰ろう。",
    event="enter",
  )
}

///|
fn Game::walk(self : Game, sign : Int32, strafe~ : Int32 = 0) -> Unit {
  let (dx, dz) = direction(self.facing + strafe)
  let x = self.x + dx * sign
  let z = self.z + dz * sign
  if self.blocked(x, z) {
    self.note(
      if tile(self.floor, x, z) == Door {
        "扉だ。『調べる』で開けられる。"
      } else {
        "石壁が行く手を遮っている。"
      },
      event="bump",
    )
    return
  }
  self.previous_x = self.x
  self.previous_z = self.z
  self.x = x
  self.z = z
  self.steps += 1
  self.light = (self.light - 1).max(0)
  self.reveal()
  self.event_id += 1
  self.event = "step"
  if tile(self.floor, x, z) == Guardian && !self.relic {
    self.set_mode(Warning)
    self.note(
      "封印の間。奥から重い足音がする。準備を整えてから進もう。",
    )
    return
  }
  if (x - 1).abs() + (z - 1).abs() > 2 || self.floor > 0 {
    self.danger += if self.light == 0 { 2 } else { 1 }
    if self.danger >= self.encounter_steps() {
      self.danger = 0
      self.begin_battle(false)
    }
  }
}

///|
fn Game::interact(self : Game) -> Unit {
  let id = cell_id(self.floor, self.x, self.z)
  match tile(self.floor, self.x, self.z) {
    Exit => self.return_town(false)
    Down => {
      self.floor = 1
      self.x = 1
      self.z = 1
      self.facing = 1
      self.reveal()
      ignore(
        self.experience_record(
          "arc.reached",
          { "floor": 2 },
          target="b2-arrival",
          instance="b2:\{self.generation}:\{self.experience_sequence+1}",
        ),
      )
      self.note(
        "地下2階。守護者の気配が濃くなった。",
        event="stairs",
      )
    }
    Up => {
      self.floor = 0
      self.x = 7
      self.z = 7
      self.facing = 0
      self.reveal()
      self.note("地下1階へ戻った。", event="stairs")
    }
    Chest if !self.looted.contains(id) => {
      self.set_mode(Looting)
      self.note(
        "古い宝箱。盗賊に罠を調べさせるか、そのまま開けるか。",
      )
    }
    Shrine if !self.used_shrines.contains(id) => {
      self.used_shrines.push(id)
      for h in self.party {
        if h.hp > 0 {
          let before_hp = h.hp
          h.hp = (h.hp + 6).min(h.max_hp())
          self.cue(Recovery, Party(h.id), h.hp - before_hp)
          h.mp = (h.mp + 2).min(h.max_mp())
        }
      }
      self.note(
        "祈りの灯が一度だけ応えた。HPとMPを少し回復した。",
        event="heal",
      )
    }
    _ => {
      let (dx, dz) = direction(self.facing)
      let front = cell_id(self.floor, self.x + dx, self.z + dz)
      if tile(self.floor, self.x + dx, self.z + dz) == Door &&
        !self.opened.contains(front) {
        self.opened.push(front)
        self.reveal()
        self.note("扉を押し開けた。", event="door")
      } else {
        self.note("ここには、もう調べるものはない。")
      }
    }
  }
}

///|
fn Game::loot(self : Game, careful : Bool) -> Unit raise {
  if careful && !self.party.any(h => h.job == Thief && h.hp > 0) {
    fail("生きている盗賊が必要です")
  }
  let id = cell_id(self.floor, self.x, self.z)
  if self.looted.contains(id) {
    fail("この宝箱は空です")
  }
  if !careful {
    let victim = self.party.filter(h => h.hp > 0).get(0)
    if victim is Some(h) {
      let damage = (h.hp - 1).min(3)
      h.hp -= damage
      self.cue(Impact, Party(h.id), damage)
    }
    self.note(
      "罠の針。先頭の仲間が3ダメージを受けた。",
      event="hurt",
    )
  }
  self.looted.push(id)
  self.carried_gold += 12
  self.potions = (self.potions + 1).min(99)
  self.light = (self.light + 8).min(70)
  self.set_mode(Exploring)
  self.note(
    "銀貨12G、回復薬1個、灯油を手に入れた。",
    event="loot",
  )
}

///|
fn Game::return_town(self : Game, emergency : Bool) -> Unit {
  let reward = if emergency { self.carried_gold / 2 } else { self.carried_gold }
  self.gold += reward
  self.carried_gold = 0
  self.battle = None
  self.selected = -1
  self.set_mode(if self.relic {
    self.clears += 1
    Cleared
  } else {
    Town
  })
  self.note(
    if self.relic {
      "灯火の印章を持ち帰った。遠征達成！"
    } else {
      "宿場へ帰還した。戦利金 \{reward}G を預けた。"
    },
    event="return",
  )
}
