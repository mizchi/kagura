///|
pub fn Game::command(self : Game, action : String, arg : Int32) -> Unit raise {
  let instance = if self.mode == Fighting &&
    (
      self.battle.unwrap().phase == Planning ||
      self.battle.unwrap().phase == Review
    ) {
    self.experience_round_id()
  } else {
    ""
  }
  let target = if instance == "" { "" } else { "combat-round" }
  let request = self.experience_record(
    "input.requested",
    { "action": action, "arg": arg },
    target~,
    instance~,
  )
  self.experience_cause = request
  errdefer {
    ignore(
      self.experience_record(
        "input.rejected",
        { "action": action },
        target~,
        instance~,
      ),
    )
    self.experience_cause = 0
  }
  self.apply_command(action, arg)
  if instance != "" {
    self.round_inputs.push(request)
    if self.mode == Exploring {
      ignore(
        self.experience_record(
          "loop.interrupted",
          { "reason": "escape" },
          target~,
          instance~,
        ),
      )
    }
  }
  ignore(
    self.experience_record(
      "input.accepted",
      { "action": action },
      target~,
      instance~,
    ),
  )
  self.experience_cause = 0
}

///|
fn Game::apply_command(self : Game, action : String, arg : Int32) -> Unit raise {
  match action {
    "enter" => {
      if self.mode != Town && self.mode != Cleared {
        fail("宿場から出発してください")
      }
      if self.party.all(h => h.hp <= 0) {
        fail("宿で休んでください")
      }
      self.enter()
    }
    "rest" => {
      if self.mode != Town && self.mode != Cleared {
        fail("宿場でのみ休めます")
      }
      self.gold = (self.gold - 8).max(0)
      for h in self.party {
        h.hp = h.max_hp()
        h.mp = h.max_mp()
      }
      self.note(
        "宿で休み、全員のHP・MPを回復した。所持金が足りない分は宿の厚意。",
        event="heal",
      )
    }
    "buy" => {
      if (self.mode != Town && self.mode != Cleared) ||
        self.gold < 6 ||
        self.potions >= 99 {
        fail("回復薬は宿場で6Gで購入できます")
      }
      self.gold -= 6
      self.potions += 1
      self.note("回復薬を1個買った。")
    }
    "swap" => {
      if (self.mode != Town && self.mode != Cleared) || arg < 0 || arg >= 6 {
        fail("宿場で仲間を2人選んでください")
      }
      if self.selected < 0 {
        self.selected = arg
      } else {
        let old = self.party[self.selected]
        self.party[self.selected] = self.party[arg]
        self.party[arg] = old
        self.selected = -1
        self.note("隊列を入れ替えた。前の3人が前衛。")
      }
    }
    "forward"
    | "backward"
    | "left"
    | "right"
    | "strafe-left"
    | "strafe-right"
    | "interact"
    | "recall" => {
      if self.mode != Exploring {
        fail("探索中のみ使えます")
      }
      match action {
        "forward" => self.walk(1)
        "backward" => self.walk(-1)
        "strafe-left" => self.walk(1, strafe=-1)
        "strafe-right" => self.walk(1, strafe=1)
        "left" => self.facing = (self.facing + 3) % 4
        "right" => self.facing = (self.facing + 1) % 4
        "interact" => self.interact()
        _ => {
          if self.bell <= 0 {
            fail("帰還の鐘がありません")
          }
          self.bell -= 1
          self.return_town(true)
        }
      }
    }
    "field-heal" | "field-potion" => {
      if self.mode != Exploring ||
        arg < 0 ||
        arg >= 6 ||
        self.party[arg].hp <= 0 ||
        self.party[arg].hp >= self.party[arg].max_hp() {
        fail("探索中、負傷している仲間を選んでください")
      }
      let before_hp = self.party[arg].hp
      if action == "field-heal" {
        let caster = self.party
          .filter(h => h.job == Priest && h.hp > 0 && h.mp >= 2)
          .get(0)
        guard caster is Some(h) else { fail("僧侶のMPが2必要です") }
        h.mp -= 2
        self.party[arg].hp = (self.party[arg].hp + 12).min(
          self.party[arg].max_hp(),
        )
      } else {
        if self.potions <= 0 {
          fail("回復薬がありません")
        }
        self.potions -= 1
        self.party[arg].hp = (self.party[arg].hp + 14).min(
          self.party[arg].max_hp(),
        )
      }
      self.cue(
        Recovery,
        Party(self.party[arg].id),
        self.party[arg].hp - before_hp,
      )
      self.note("\{self.party[arg].name()} を回復した。", event="heal")
    }
    "loot" => {
      if self.mode != Looting || (arg != 0 && arg != 1) {
        fail("宝箱の開け方を選んでください")
      }
      self.loot(arg == 0)
    }
    "back" =>
      if self.mode == Warning {
        self.x = self.previous_x
        self.z = self.previous_z
        self.set_mode(Exploring)
      } else if self.mode == Looting {
        self.set_mode(Exploring)
      } else {
        fail("戻れません")
      }
    "challenge" => {
      if self.mode != Warning {
        fail("守護者の部屋でのみ使えます")
      }
      self.begin_battle(true)
    }
    "attack"
    | "guard"
    | "heal"
    | "flame"
    | "potion"
    | "undo"
    | "resolve"
    | "continue"
    | "all-attack"
    | "all-guard"
    | "flee" => {
      if self.mode != Fighting {
        fail("戦闘中のみ使えます")
      }
      let b = self.battle.unwrap()
      match action {
        "continue" =>
          if b.phase == Won {
            ignore(
              self.experience_record(
                "loop.ready",
                {},
                target="combat-round",
                instance=self.experience_round_id(),
              ),
            )
            self.set_mode(Exploring)
            self.battle = None
          } else if b.phase == Report {
            ignore(
              self.experience_record(
                "loop.ready",
                {},
                target="combat-round",
                instance=self.experience_round_id(),
              ),
            )
            b.round += 1
            b.phase = Planning
            b.orders.clear()
            self.experience_start_round()
          } else {
            fail("行動を選択してください")
          }
        "undo" => {
          if (b.phase != Planning && b.phase != Review) || b.orders.is_empty() {
            fail("取り消せる行動がありません")
          }
          ignore(b.orders.pop())
          b.phase = Planning
        }
        "resolve" => {
          if b.phase != Review {
            fail("全員の行動を選択してください")
          }
          self.resolve_round()
        }
        "all-attack" | "all-guard" => {
          if b.phase != Planning && b.phase != Review {
            fail("結果を確認してください")
          }
          b.orders.clear()
          b.phase = Planning
          for i in 0..<6 {
            if self.party[i].hp > 0 {
              self.plan(
                if action == "all-attack" {
                  Attack
                } else {
                  Defend
                },
                if action == "all-attack" {
                  b.foes.search_by(f => f.hp > 0).unwrap()
                } else {
                  -1
                },
              )
            }
          }
          self.resolve_round()
        }
        "flee" => {
          if b.boss || (b.phase != Planning && b.phase != Review) {
            fail("逃走できません")
          }
          let chance = if self.party.any(h => h.job == Thief && h.hp > 0) {
            75
          } else {
            45
          }
          if self.roll(100) < chance {
            self.set_mode(Exploring)
            self.battle = None
            self.danger = 0
            self.note("敵を振り切った。", event="step")
          } else {
            b.orders.clear()
            self.note("逃走失敗！ 敵に隙を突かれた。")
            self.resolve_round()
          }
        }
        _ =>
          self.plan(
            match action {
              "attack" => Attack
              "guard" => Defend
              "heal" => Heal
              "flame" => Flame
              _ => Potion
            },
            arg,
          )
      }
    }
    _ => fail("不明な操作です")
  }
  self.revision += 1
}
