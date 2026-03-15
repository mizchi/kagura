// --- Affix Tables ---

// Affix profile IDs for selecting different affix table sets

///|
pub(all) enum AffixProfile {
  Classic // original 10+10
  GlassCannon // high atk, negative hp/def
  Tank // high def/hp, sustain
  Mobility // speed & cooldown focused
  Expanded // all axes mixed
}

///|
fn a(
  name : String,
  atk? : Int = 0,
  def? : Int = 0,
  hp? : Int = 0,
  str? : Int = 0,
  int_? : Int = 0,
  dex? : Int = 0,
  crit? : Double = 0.0,
  ls? : Double = 0.0,
  spd? : Double = 0.0,
  cdr? : Double = 0.0,
  str_scale? : Double = 0.0,
  int_scale? : Double = 0.0,
  dex_scale? : Double = 0.0,
  spell_dmg? : Double = 0.0,
  chain? : Int = 0,
) -> Affix {
  {
    name,
    atk,
    def,
    hp,
    str_bonus: str,
    int_bonus: int_,
    dex_bonus: dex,
    crit,
    life_steal: ls,
    speed_bonus: spd,
    cooldown_reduction: cdr,
    str_scaling: str_scale,
    int_scaling: int_scale,
    dex_scaling: dex_scale,
    spell_damage_pct: spell_dmg,
    chain_bonus: chain,
  }
}

///|
pub fn prefix_table() -> Array[Affix] {
  prefix_table_for(Classic)
}

///|
pub fn suffix_table() -> Array[Affix] {
  suffix_table_for(Classic)
}

///|
pub fn prefix_table_for(profile : AffixProfile) -> Array[Affix] {
  let classic : Array[Affix] = [
    a("Keen", atk=2, crit=0.05),
    a("Brutal", atk=4),
    a("Sturdy", def=3, hp=2),
    a("Vampiric", atk=1, ls=0.08),
    a("Blazing", atk=3, crit=0.03),
    a("Iron", def=4),
    a("Mighty", atk=5, def=-1),
    a("Blessed", atk=1, def=1, hp=3, ls=0.02),
    a("Savage", atk=3, crit=0.08),
    a("Arcane", atk=2, hp=2, crit=0.04),
    a("Crackling", int_=2, spell_dmg=0.12, chain=1),
    a("Volatile", atk=1, spell_dmg=0.15),
  ]
  match profile {
    Classic => classic
    GlassCannon =>
      [
        a("Deadly", atk=6, hp=-3),
        a("Frenzied", atk=5, crit=0.1, def=-2),
        a("Reckless", atk=7, def=-3, hp=-2),
        a("Brutal", atk=4),
        a("Keen", atk=2, crit=0.05),
        a("Savage", atk=3, crit=0.08),
        a("Blazing", atk=3, crit=0.03),
        a("Piercing", atk=4, crit=0.06, hp=-1),
        a("Berserker", atk=6, crit=0.04, def=-2),
        a("Wrathful", atk=5, ls=0.03, hp=-2),
      ]
    Tank =>
      [
        a("Fortified", def=5, hp=3),
        a("Stalwart", def=4, hp=4),
        a("Iron", def=4),
        a("Sturdy", def=3, hp=2),
        a("Blessed", atk=1, def=1, hp=3, ls=0.02),
        a("Guardian", def=3, hp=2, ls=0.04),
        a("Resilient", def=2, hp=5),
        a("Warden", def=6, atk=-1),
        a("Enduring", hp=4, ls=0.05),
        a("Titanic", def=3, hp=6, atk=-2),
      ]
    Mobility =>
      [
        a("Swift", spd=0.15, atk=1),
        a("Fleet", spd=0.2),
        a("Rapid", cdr=0.15, atk=1),
        a("Hasty", spd=0.1, cdr=0.1),
        a("Nimble", spd=0.12, crit=0.03),
        a("Windborne", spd=0.18, def=-1),
        a("Keen", atk=2, crit=0.05),
        a("Relentless", cdr=0.2, hp=-1),
        a("Agile", spd=0.1, def=1),
        a("Tempest", spd=0.15, cdr=0.1, atk=2, hp=-2),
      ]
    Expanded => {
      // Mix of all axes
      let result : Array[Affix] = []
      // classic core
      result.push(a("Keen", atk=2, crit=0.05))
      result.push(a("Brutal", atk=4))
      result.push(a("Sturdy", def=3, hp=2))
      result.push(a("Vampiric", atk=1, ls=0.08))
      // glass cannon
      result.push(a("Deadly", atk=6, hp=-3))
      result.push(a("Frenzied", atk=5, crit=0.1, def=-2))
      // tank
      result.push(a("Fortified", def=5, hp=3))
      result.push(a("Guardian", def=3, hp=2, ls=0.04))
      // mobility
      result.push(a("Swift", spd=0.15, atk=1))
      result.push(a("Rapid", cdr=0.15, atk=1))
      result.push(a("Hasty", spd=0.1, cdr=0.1))
      result.push(a("Tempest", spd=0.15, cdr=0.1, atk=2, hp=-2))
      result
    }
  }
}

///|
pub fn suffix_table_for(profile : AffixProfile) -> Array[Affix] {
  let classic : Array[Affix] = [
    a("of Power", atk=3),
    a("of the Bear", def=2, hp=5),
    a("of Precision", crit=0.1),
    a("of Leeching", ls=0.1),
    a("of Thorns", def=4),
    a("of Haste", atk=1, crit=0.05),
    a("of Vitality", hp=6),
    a("of Fury", atk=4, hp=-2, crit=0.06),
    a("of the Wolf", atk=2, def=1, hp=2, ls=0.03),
    a("of Fortune", atk=1, def=1, hp=1, crit=0.03, ls=0.03),
    a("of Arcing", int_=1, chain=1, spell_dmg=0.08),
    a("of Storms", spell_dmg=0.2, int_=2),
  ]
  match profile {
    Classic => classic
    GlassCannon =>
      [
        a("of Annihilation", atk=5, def=-2),
        a("of Fury", atk=4, hp=-2, crit=0.06),
        a("of Slaughter", atk=4, crit=0.08),
        a("of Power", atk=3),
        a("of Precision", crit=0.1),
        a("of Carnage", atk=6, hp=-4, crit=0.05),
        a("of Ruin", atk=5, def=-1, crit=0.04),
        a("of the Blade", atk=3, crit=0.07),
        a("of Leeching", ls=0.1),
        a("of Devastation", atk=7, hp=-3),
      ]
    Tank =>
      [
        a("of the Bear", def=2, hp=5),
        a("of the Mountain", def=5, hp=3),
        a("of Vitality", hp=6),
        a("of Thorns", def=4),
        a("of Regeneration", hp=3, ls=0.06),
        a("of the Bulwark", def=6, atk=-1),
        a("of Leeching", ls=0.1),
        a("of Stone", def=3, hp=4),
        a("of the Sentinel", def=4, hp=2, ls=0.02),
        a("of Endurance", hp=8, atk=-2),
      ]
    Mobility =>
      [
        a("of the Wind", spd=0.2),
        a("of Alacrity", cdr=0.2),
        a("of Swiftness", spd=0.15, atk=1),
        a("of Tempo", cdr=0.15, crit=0.03),
        a("of the Gale", spd=0.18, cdr=0.08),
        a("of Celerity", spd=0.12, cdr=0.12),
        a("of Haste", atk=1, crit=0.05),
        a("of Quickening", cdr=0.18, hp=-1),
        a("of the Falcon", spd=0.15, crit=0.05),
        a("of Lightning", spd=0.1, cdr=0.1, atk=2),
      ]
    Expanded => {
      let result : Array[Affix] = []
      // classic core
      result.push(a("of Power", atk=3))
      result.push(a("of the Bear", def=2, hp=5))
      result.push(a("of Precision", crit=0.1))
      result.push(a("of Leeching", ls=0.1))
      // glass cannon
      result.push(a("of Fury", atk=4, hp=-2, crit=0.06))
      result.push(a("of Annihilation", atk=5, def=-2))
      // tank
      result.push(a("of Vitality", hp=6))
      result.push(a("of Regeneration", hp=3, ls=0.06))
      // mobility
      result.push(a("of the Wind", spd=0.2))
      result.push(a("of Alacrity", cdr=0.2))
      result.push(a("of the Gale", spd=0.18, cdr=0.08))
      result.push(a("of Lightning", spd=0.1, cdr=0.1, atk=2))
      result
    }
  }
}

///|
pub fn scale_affix(affix : Affix, floor : Int) -> Affix {
  let scale = 1 + floor / 5
  {
    name: affix.name,
    atk: affix.atk * scale,
    def: affix.def * scale,
    hp: affix.hp * scale,
    str_bonus: affix.str_bonus * scale,
    int_bonus: affix.int_bonus * scale,
    dex_bonus: affix.dex_bonus * scale,
    crit: affix.crit,
    life_steal: affix.life_steal,
    speed_bonus: affix.speed_bonus,
    cooldown_reduction: affix.cooldown_reduction,
    str_scaling: affix.str_scaling,
    int_scaling: affix.int_scaling,
    dex_scaling: affix.dex_scaling,
    spell_damage_pct: affix.spell_damage_pct,
    chain_bonus: affix.chain_bonus,
  }
}

// --- Item Generation ---

///|
pub fn generate_item(seed : Int, floor : Int) -> ItemData {
  generate_item_with_profile(seed, floor, Classic)
}

///|
pub fn generate_item_with_profile(
  seed : Int,
  floor : Int,
  profile : AffixProfile,
) -> ItemData {
  generate_item_with_profile_and_drop_config(
    seed,
    floor,
    profile,
    DropTableConfig::default(),
  )
}
