///|
fn Game::begin_battle(self : Game, boss : Bool) -> Unit {
  self.experience_battle += 1
  let foes = if boss {
    self.spawn_encounter("guardian")
  } else if self.floor == 0 {
    if self.roll(2) == 0 {
      self.spawn_encounter("b1_a")
    } else {
      self.spawn_encounter("b1_b")
    }
  } else {
    self.spawn_encounter("b2")
  }
  let foes = foes.map(f => {
    let hp = (f.max_hp.to_double() * self.balance.enemy_hp_scale + 0.5)
      .to_int()
      .max(1)
    {
      ..f,
      max_hp: hp,
      hp,
      attack: (f.attack.to_double() * self.balance.enemy_damage_scale + 0.5)
      .to_int()
      .max(1),
    }
  })
  self.battle = Some({
    foes,
    orders: [],
    boss,
    phase: Planning,
    round: 1,
    reward: 0,
  })
  self.set_mode(Fighting)
  self.note(
    if boss {
      "守護者が立ちはだかった！ 逃走はできない。"
    } else {
      "敵が現れた。敵の予告を見て6人の行動を決めよう。"
    },
    event="battle",
  )
  self.experience_start_round()
}

///|
fn Game::plan(self : Game, action : Action, target : Int32) -> Unit raise {
  let b = self.battle.unwrap()
  if b.phase != Planning {
    fail("行動を選べる段階ではありません")
  }
  let actor = self.active_actor()
  if actor < 0 {
    fail("全員の行動を選択済みです")
  }
  let h = self.party[actor]
  match action {
    Attack =>
      if target < 0 || target >= b.foes.length() || b.foes[target].hp <= 0 {
        fail("生きている敵を選んでください")
      }
    Heal | Potion => {
      if target < 0 || target >= 6 || self.party[target].hp <= 0 {
        fail("生きている仲間を選んでください")
      }
      if action == Heal && (h.job != Priest || h.mp < 2) {
        fail("僧侶のMPが2必要です")
      }
      if action == Potion &&
        self.potions <= b.orders.filter(o => o.action == Potion).length() {
        fail("回復薬がありません")
      }
    }
    Flame =>
      if h.job != Mage || h.mp < 3 {
        fail("魔術師のMPが3必要です")
      }
    Defend => ()
  }
  b.orders.push({ actor, action, target, })
  if self.active_actor() < 0 {
    b.phase = Review
  }
}

///|
fn Game::rescue(self : Game) -> Unit {
  self.set_mode(Town)
  self.battle = None
  self.relic = false
  self.carried_gold = 0
  self.gold = (self.gold - 5).max(0)
  for h in self.party {
    h.hp = 1
    h.mp = 0
  }
  self.note(
    "全滅……救護隊が宿場へ運んだ。戦利金を失った。宿で休もう。",
    event="defeat",
  )
}

///|
fn Game::victory(self : Game, b : Battle) -> Unit {
  b.phase = Won
  b.reward = if b.boss { 40 } else if self.floor == 0 { 8 } else { 14 }
  self.carried_gold += b.reward
  let xp = if b.boss { 18 } else { 8 }
  for h in self.party {
    if h.hp > 0 {
      h.xp += xp
      while h.level < 20 && h.xp >= h.level * 20 {
        h.level += 1
        h.hp += 4
        if h.max_mp() > 0 {
          h.mp += 1
        }
        self.note("\{h.name()} がレベル \{h.level} になった！")
      }
    }
  }
  if b.boss {
    self.relic = true
  }
  self.note(
    if b.boss {
      "守護者を倒し、灯火の印章を得た！ 生きて地上へ持ち帰ろう。"
    } else {
      "勝利。戦利金 \{b.reward}G と経験値 \{xp} を得た。"
    },
    event="victory",
  )
}

///|
fn Game::resolve_round(self : Game) -> Unit {
  let b = self.battle.unwrap()
  let experience_instance = self.experience_round_id()
  let last_effect = self.next_effect_id
  if self.party.all(h => h.hp <= 0) {
    self.experience_resolved(experience_instance, last_effect, defeat=true)
    self.rescue()
    ignore(
      self.experience_record(
        "loop.ready",
        {},
        target="combat-round",
        instance=experience_instance,
      ),
    )
    return
  }
  let guarding = Array::make(6, false)
  for o in b.orders {
    if o.action == Defend && self.party[o.actor].hp > 0 {
      guarding[o.actor] = true
    }
  }
  let queue : Array[(Int32, Int32)] = []
  for o in b.orders {
    queue.push((self.party[o.actor].speed(), o.actor))
  }
  for i in 0..<b.foes.length() {
    queue.push((b.foes[i].speed, 6 + i))
  }
  queue.sort_by((a, b) => {
    if a.0 != b.0 {
      b.0.compare(a.0)
    } else {
      a.1.compare(b.1)
    }
  })
  let mut intercepted = false
  for (_, who) in queue {
    if b.foes.all(f => f.hp <= 0) || self.party.all(h => h.hp <= 0) {
      break
    }
    if who < 6 {
      let h = self.party[who]
      if h.hp <= 0 {
        continue
      }
      let o = b.orders.filter(o => o.actor == who)[0]
      match o.action {
        Defend => ()
        Attack => {
          let target = if b.foes[o.target].hp > 0 {
            o.target
          } else {
            b.foes.search_by(f => f.hp > 0).unwrap()
          }
          let f = b.foes[target]
          let power = if who >= 3 && h.job != Ranger {
            (h.attack() + 1) / 2
          } else {
            h.attack()
          }
          let damage = (power + self.roll(3) - f.armor).max(1)
          self.cue(Impact, Enemy(target), damage.min(f.hp))
          f.hp = (f.hp - damage).max(0)
          self.note("\{h.name()} → \{f.name} に \{damage}。")
        }
        Flame =>
          if h.mp >= 3 {
            h.mp -= 3
            for i in 0..<b.foes.length() {
              let f = b.foes[i]
              if f.hp > 0 {
                let damage = (6 + self.roll(3)).min(f.hp)
                f.hp -= damage
                self.cue(FlameHit, Enemy(i), damage)
              }
            }
            self.note(
              "\{h.name()} の火炎。敵全体を焼いた。",
              event="spell",
            )
          }
        Heal | Potion => {
          let target = if self.party[o.target].hp > 0 {
            Some(o.target)
          } else {
            self.party.search_by(h => h.hp > 0 && h.hp < h.max_hp())
          }
          if target is Some(t) {
            let can = if o.action == Heal {
              h.mp >= 2
            } else {
              self.potions > 0
            }
            if can {
              if o.action == Heal {
                h.mp -= 2
              } else {
                self.potions -= 1
              }
              let other = self.party[t]
              let before_hp = other.hp
              other.hp = (other.hp + (if o.action == Heal { 12 } else { 14 })).min(
                other.max_hp(),
              )
              self.cue(Recovery, Party(other.id), other.hp - before_hp)
              self.note(
                "\{h.name()} が \{other.name()} を回復した。",
                event="heal",
              )
            }
          }
        }
      }
    } else {
      let f = b.foes[who - 6]
      if f.hp <= 0 {
        continue
      }
      let front : Array[Int32] = []
      for i in 0..<3 {
        if self.party[i].hp > 0 {
          front.push(i)
        }
      }
      if front.is_empty() {
        for i in 3..<6 {
          if self.party[i].hp > 0 {
            front.push(i)
          }
        }
      }
      if front.is_empty() {
        break
      }
      let sweep = f.sweeps && b.round % 2 == 1
      let targets = if sweep {
        front
      } else {
        [front[self.roll(front.length())]]
      }
      for original in targets {
        let mut target = original
        if !sweep && !intercepted {
          for i in 0..<6 {
            if self.party[i].job == Knight &&
              self.party[i].hp > 0 &&
              guarding[i] {
              target = i
              intercepted = true
              break
            }
          }
        }
        let h = self.party[target]
        let raw = ((if sweep { self.sweep_damage() } else { f.attack }) +
        self.roll(2) -
        h.armor()).max(1)
        let damage = if guarding[target] { (raw + 1) / 2 } else { raw }
        self.cue(
          if guarding[target] {
            GuardHit
          } else {
            Impact
          },
          Party(h.id),
          damage.min(h.hp),
        )
        h.hp = (h.hp - damage).max(0)
        self.note("\{f.name} → \{h.name()} に \{damage}。", event="hurt")
      }
    }
  }
  if self.party.all(h => h.hp <= 0) {
    self.experience_resolved(experience_instance, last_effect, defeat=true)
    self.rescue()
    ignore(
      self.experience_record(
        "loop.ready",
        {},
        target="combat-round",
        instance=experience_instance,
      ),
    )
  } else if b.foes.all(f => f.hp <= 0) {
    self.victory(b)
    self.experience_resolved(experience_instance, last_effect)
  } else {
    b.phase = Report
    self.experience_resolved(experience_instance, last_effect)
  }
}
