///|
#derive(FromJson, ToJson)
priv struct SavedHero {
  id : Int32
  level : Int32
  xp : Int32
  hp : Int32
  mp : Int32
}

///|
#derive(FromJson, ToJson)
priv struct TownSave {
  schema : Int32
  party : Array[SavedHero]
  gold : Int32
  potions : Int32
  clears : Int32
}

///|
pub fn Game::save_town(self : Game) -> String raise {
  if self.mode != Town && self.mode != Cleared {
    fail("宿場でのみ保存できます")
  }
  let data : TownSave = {
    schema: 1,
    party: self.party.map(h => {
      id: h.id,
      level: h.level,
      xp: h.xp,
      hp: h.hp,
      mp: h.mp,
    }),
    gold: self.gold,
    potions: self.potions,
    clears: self.clears,
  }
  @json.ToJson::to_json(data).stringify()
}

///|
pub fn Game::load_town(self : Game, source : String) -> Unit raise {
  let data : TownSave = @json.from_json(@json.parse(source))
  if data.schema != 1 ||
    data.party.length() != 6 ||
    data.gold < 0 ||
    data.gold > 1000000 ||
    data.potions < 0 ||
    data.potions > 99 ||
    data.clears < 0 ||
    data.clears > 10000 {
    fail("保存データが不正です")
  }
  let party : Array[Hero] = []
  for s in data.party {
    if s.id < 0 ||
      s.id > 5 ||
      party.any(h => h.id == s.id) ||
      s.level < 1 ||
      s.level > 20 ||
      s.xp < (s.level - 1) * 20 ||
      s.xp > 1000000 ||
      (s.level < 20 && s.xp >= s.level * 20) {
      fail("仲間の保存データが不正です")
    }
    let h = new_hero(s.id, [Fighter, Knight, Thief, Priest, Mage, Ranger][s.id])
    h.level = s.level
    h.xp = s.xp
    if s.hp < 0 || s.hp > h.max_hp() || s.mp < 0 || s.mp > h.max_mp() {
      fail("HP・MPの保存データが不正です")
    }
    h.hp = s.hp
    h.mp = s.mp
    party.push(h)
  }
  // Validate the whole payload before changing any live state.
  self.enter()
  self.party.clear()
  for h in party {
    self.party.push(h)
  }
  self.mode = Town
  self.gold = data.gold
  self.potions = data.potions
  self.clears = data.clears
  self.log.clear()
  self.note(
    "宿場の記録を読み込んだ。隊列と所持品は出発前の状態。",
  )
  self.revision += 1
}
