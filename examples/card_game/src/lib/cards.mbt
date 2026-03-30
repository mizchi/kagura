///|
/// Card identifiers
pub(all) enum CardId {
  // Starter
  Strike
  Defend
  Bash
  // Common Attacks
  Cleave
  Pommel_Strike
  Twin_Strike
  Iron_Wave
  Anger
  Headbutt
  // Common Skills
  Shrug_It_Off
  Armaments
  True_Grit
  Flex
  // Uncommon Attacks
  Clothesline
  Uppercut
  Body_Slam
  Sword_Boomerang
  Rampage
  // Uncommon Skills
  Bloodletting
  Offering
  Seeing_Red
  Battle_Trance
  Shockwave
  Disarm
  // Uncommon Powers
  Inflame
  Metallicize
  // Rare Attacks
  Bludgeon
  // Rare Skills
  Impervious
  // Rare Attacks (cont.)
  Whirlwind // X-cost: deal 5 to ALL X times
  Feed // 1 cost: 10 dmg, if kill +3 max HP. Exhaust
  Fiend_Fire // 2 cost: exhaust hand, 7 per card exhausted
  // Rare Skills
  Limit_Break // 1 cost: double Strength. Exhaust
  // Rare Powers
  Demon_Form
  Barricade
  Feel_No_Pain
  Corruption // 3 cost: Skills cost 0, but Exhaust
  // Common Attacks (cont.)
  Heavy_Blade // 2 cost: 14 dmg, STR applies 3x
  // Heavy/peaky additions
  Carnage // 2 cost: 20 dmg, Ethereal (exhaust if not played)
  Immolate // 2 cost: 21 dmg to ALL enemies
  Reaper // 2 cost: 4 dmg to ALL, heal for damage dealt
  Entrench // 2 cost: double current Block
  Pummel // 1 cost: 2 dmg × 4 hits (STR scaling)
} derive(Show, Eq)

///|
/// Card type determines behavior
pub(all) enum CardType {
  Attack
  Skill
  Power
} derive(Show, Eq)

///|
/// Static card definition
pub(all) struct CardDef {
  id : CardId
  name : String
  cost : Int
  card_type : CardType
  base_damage : Int
  base_block : Int
  exhaust : Bool
  description : String
} derive(Show)

///|
pub fn card_def(id : CardId) -> CardDef {
  match id {
    // === Starter ===
    Strike =>
      {
        id: Strike,
        name: "Strike",
        cost: 1,
        card_type: Attack,
        base_damage: 6,
        base_block: 0,
        exhaust: false,
        description: "Deal 6 damage.",
      }
    Defend =>
      {
        id: Defend,
        name: "Defend",
        cost: 1,
        card_type: Skill,
        base_damage: 0,
        base_block: 6,
        exhaust: false,
        description: "Gain 6 Block.",
      }
    Bash =>
      {
        id: Bash,
        name: "Bash",
        cost: 2,
        card_type: Attack,
        base_damage: 8,
        base_block: 0,
        exhaust: false,
        description: "Deal 8 damage. Apply 2 Vulnerable.",
      }
    // === Common Attacks ===
    Cleave =>
      {
        id: Cleave,
        name: "Cleave",
        cost: 1,
        card_type: Attack,
        base_damage: 8,
        base_block: 0,
        exhaust: false,
        description: "Deal 8 damage to ALL enemies.",
      }
    Pommel_Strike =>
      {
        id: Pommel_Strike,
        name: "Pommel Strike",
        cost: 1,
        card_type: Attack,
        base_damage: 9,
        base_block: 0,
        exhaust: false,
        description: "Deal 9 damage. Draw 1 card.",
      }
    Twin_Strike =>
      {
        id: Twin_Strike,
        name: "Twin Strike",
        cost: 1,
        card_type: Attack,
        base_damage: 5,
        base_block: 0,
        exhaust: false,
        description: "Deal 5 damage twice.",
      }
    Iron_Wave =>
      {
        id: Iron_Wave,
        name: "Iron Wave",
        cost: 1,
        card_type: Attack,
        base_damage: 5,
        base_block: 6,
        exhaust: false,
        description: "Gain 6 Block. Deal 5 damage.",
      }
    Anger =>
      {
        id: Anger,
        name: "Anger",
        cost: 0,
        card_type: Attack,
        base_damage: 6,
        base_block: 0,
        exhaust: false,
        description: "Deal 6 damage. Add copy to discard.",
      }
    Headbutt =>
      {
        id: Headbutt,
        name: "Headbutt",
        cost: 1,
        card_type: Attack,
        base_damage: 9,
        base_block: 0,
        exhaust: false,
        description: "Deal 9 damage. Put card from discard on draw pile.",
      }
    // === Common Skills ===
    Shrug_It_Off =>
      {
        id: Shrug_It_Off,
        name: "Shrug It Off",
        cost: 1,
        card_type: Skill,
        base_damage: 0,
        base_block: 8,
        exhaust: false,
        description: "Gain 8 Block. Draw 1 card.",
      }
    Armaments =>
      {
        id: Armaments,
        name: "Armaments",
        cost: 1,
        card_type: Skill,
        base_damage: 0,
        base_block: 5,
        exhaust: false,
        description: "Gain 5 Block.",
      }
    True_Grit =>
      {
        id: True_Grit,
        name: "True Grit",
        cost: 1,
        card_type: Skill,
        base_damage: 0,
        base_block: 7,
        exhaust: false,
        description: "Gain 7 Block. Exhaust a random card.",
      }
    Flex =>
      {
        id: Flex,
        name: "Flex",
        cost: 0,
        card_type: Skill,
        base_damage: 0,
        base_block: 0,
        exhaust: false,
        description: "Gain 2 Strength. At end of turn, lose 2 Strength.",
      }
    // === Uncommon Attacks ===
    Clothesline =>
      {
        id: Clothesline,
        name: "Clothesline",
        cost: 2,
        card_type: Attack,
        base_damage: 12,
        base_block: 0,
        exhaust: false,
        description: "Deal 12 damage. Apply 2 Weak.",
      }
    Uppercut =>
      {
        id: Uppercut,
        name: "Uppercut",
        cost: 2,
        card_type: Attack,
        base_damage: 13,
        base_block: 0,
        exhaust: false,
        description: "Deal 13 damage. Apply 1 Weak, 1 Vulnerable.",
      }
    Body_Slam =>
      {
        id: Body_Slam,
        name: "Body Slam",
        cost: 1,
        card_type: Attack,
        base_damage: 0,
        base_block: 0,
        exhaust: false,
        description: "Deal damage equal to your Block.",
      }
    Sword_Boomerang =>
      {
        id: Sword_Boomerang,
        name: "Sword Boomerang",
        cost: 1,
        card_type: Attack,
        base_damage: 3,
        base_block: 0,
        exhaust: false,
        description: "Deal 3 damage to random enemy 3 times.",
      }
    Rampage =>
      {
        id: Rampage,
        name: "Rampage",
        cost: 1,
        card_type: Attack,
        base_damage: 8,
        base_block: 0,
        exhaust: false,
        description: "Deal 8 damage. Increase by 5 each play.",
      }
    // === Uncommon Skills ===
    Bloodletting =>
      {
        id: Bloodletting,
        name: "Bloodletting",
        cost: 0,
        card_type: Skill,
        base_damage: 0,
        base_block: 0,
        exhaust: true,
        description: "Lose 3 HP. Gain 2 Energy. Exhaust.",
      }
    Offering =>
      {
        id: Offering,
        name: "Offering",
        cost: 0,
        card_type: Skill,
        base_damage: 0,
        base_block: 0,
        exhaust: true,
        description: "Lose 6 HP. Gain 2 Energy. Draw 3. Exhaust.",
      }
    Seeing_Red =>
      {
        id: Seeing_Red,
        name: "Seeing Red",
        cost: 1,
        card_type: Skill,
        base_damage: 0,
        base_block: 0,
        exhaust: true,
        description: "Gain 2 Energy. Exhaust.",
      }
    Battle_Trance =>
      {
        id: Battle_Trance,
        name: "Battle Trance",
        cost: 0,
        card_type: Skill,
        base_damage: 0,
        base_block: 0,
        exhaust: false,
        description: "Draw 3. Cannot draw more this turn.",
      }
    Shockwave =>
      {
        id: Shockwave,
        name: "Shockwave",
        cost: 2,
        card_type: Skill,
        base_damage: 0,
        base_block: 0,
        exhaust: true,
        description: "Apply 3 Weak, 3 Vulnerable to ALL enemies. Exhaust.",
      }
    Disarm =>
      {
        id: Disarm,
        name: "Disarm",
        cost: 1,
        card_type: Skill,
        base_damage: 0,
        base_block: 0,
        exhaust: true,
        description: "Enemy loses 2 Strength. Exhaust.",
      }
    // === Uncommon Powers ===
    Inflame =>
      {
        id: Inflame,
        name: "Inflame",
        cost: 1,
        card_type: Power,
        base_damage: 0,
        base_block: 0,
        exhaust: false,
        description: "Gain 2 Strength.",
      }
    Metallicize =>
      {
        id: Metallicize,
        name: "Metallicize",
        cost: 1,
        card_type: Power,
        base_damage: 0,
        base_block: 0,
        exhaust: false,
        description: "At end of turn, gain 3 Block.",
      }
    // === Rare Attacks ===
    Bludgeon =>
      {
        id: Bludgeon,
        name: "Bludgeon",
        cost: 3,
        card_type: Attack,
        base_damage: 32,
        base_block: 0,
        exhaust: false,
        description: "Deal 32 damage.",
      }
    // === Rare Skills ===
    Impervious =>
      {
        id: Impervious,
        name: "Impervious",
        cost: 2,
        card_type: Skill,
        base_damage: 0,
        base_block: 30,
        exhaust: true,
        description: "Gain 30 Block. Exhaust.",
      }
    // === Rare Powers ===
    Demon_Form =>
      {
        id: Demon_Form,
        name: "Demon Form",
        cost: 3,
        card_type: Power,
        base_damage: 0,
        base_block: 0,
        exhaust: false,
        description: "At start of turn, gain 2 Strength.",
      }
    Barricade =>
      {
        id: Barricade,
        name: "Barricade",
        cost: 3,
        card_type: Power,
        base_damage: 0,
        base_block: 0,
        exhaust: false,
        description: "Block is not removed at start of turn.",
      }
    Feel_No_Pain =>
      {
        id: Feel_No_Pain,
        name: "Feel No Pain",
        cost: 1,
        card_type: Power,
        base_damage: 0,
        base_block: 0,
        exhaust: false,
        description: "Whenever a card is Exhausted, gain 3 Block.",
      }
    Corruption =>
      {
        id: Corruption,
        name: "Corruption",
        cost: 3,
        card_type: Power,
        base_damage: 0,
        base_block: 0,
        exhaust: false,
        description: "Skills cost 0. Whenever you play a Skill, Exhaust it.",
      }
    Heavy_Blade =>
      {
        id: Heavy_Blade,
        name: "Heavy Blade",
        cost: 2,
        card_type: Attack,
        base_damage: 14,
        base_block: 0,
        exhaust: false,
        description: "Deal 14 damage. Strength applies 3x.",
      }
    Whirlwind =>
      {
        id: Whirlwind,
        name: "Whirlwind",
        cost: 0,
        card_type: Attack,
        base_damage: 5,
        base_block: 0,
        exhaust: false,
        description: "Deal 5 damage to ALL enemies X times. (X = Energy)",
      }
    Feed =>
      {
        id: Feed,
        name: "Feed",
        cost: 1,
        card_type: Attack,
        base_damage: 10,
        base_block: 0,
        exhaust: true,
        description: "Deal 10 damage. If fatal, gain 3 Max HP. Exhaust.",
      }
    Fiend_Fire =>
      {
        id: Fiend_Fire,
        name: "Fiend Fire",
        cost: 2,
        card_type: Attack,
        base_damage: 7,
        base_block: 0,
        exhaust: true,
        description: "Exhaust your hand. Deal 7 for each Exhausted. Exhaust.",
      }
    Limit_Break =>
      {
        id: Limit_Break,
        name: "Limit Break",
        cost: 1,
        card_type: Skill,
        base_damage: 0,
        base_block: 0,
        exhaust: true,
        description: "Double your Strength. Exhaust.",
      }
    Carnage =>
      {
        id: Carnage,
        name: "Carnage",
        cost: 2,
        card_type: Attack,
        base_damage: 20,
        base_block: 0,
        exhaust: false, // Ethereal handled in game logic
        description: "Ethereal. Deal 20 damage.",
      }
    Immolate =>
      {
        id: Immolate,
        name: "Immolate",
        cost: 2,
        card_type: Attack,
        base_damage: 21,
        base_block: 0,
        exhaust: false,
        description: "Deal 21 damage to ALL enemies.",
      }
    Reaper =>
      {
        id: Reaper,
        name: "Reaper",
        cost: 2,
        card_type: Attack,
        base_damage: 4,
        base_block: 0,
        exhaust: true,
        description: "Deal 4 damage to ALL. Heal HP equal to unblocked damage. Exhaust.",
      }
    Entrench =>
      {
        id: Entrench,
        name: "Entrench",
        cost: 2,
        card_type: Skill,
        base_damage: 0,
        base_block: 0,
        exhaust: false,
        description: "Double your current Block.",
      }
    Pummel =>
      {
        id: Pummel,
        name: "Pummel",
        cost: 1,
        card_type: Attack,
        base_damage: 2,
        base_block: 0,
        exhaust: true,
        description: "Deal 2 damage 4 times. Exhaust.",
      }
  }
}

///|
/// Card rarity affects reward distribution
pub(all) enum CardRarity {
  Starter
  Common
  Uncommon
  Rare
} derive(Show, Eq)

///|
fn card_rarity(id : CardId) -> CardRarity {
  match id {
    Strike | Defend | Bash => Starter
    Cleave
    | Pommel_Strike
    | Twin_Strike
    | Iron_Wave
    | Anger
    | Headbutt
    | Shrug_It_Off
    | Armaments
    | True_Grit
    | Flex => Common
    Clothesline
    | Uppercut
    | Body_Slam
    | Sword_Boomerang
    | Rampage
    | Bloodletting
    | Offering
    | Seeing_Red
    | Battle_Trance
    | Shockwave
    | Disarm
    | Inflame
    | Metallicize => Uncommon
    Bludgeon
    | Impervious
    | Demon_Form
    | Barricade
    | Feel_No_Pain
    | Corruption
    | Whirlwind
    | Feed
    | Fiend_Fire
    | Limit_Break
    | Immolate
    | Reaper => Rare
    Heavy_Blade | Pummel => Common
    Carnage | Entrench => Uncommon
  }
}

///|
/// Create starter deck (like Ironclad)
pub fn starter_deck() -> Array[CardId] {
  [Strike, Strike, Strike, Strike, Strike, Defend, Defend, Defend, Defend, Bash]
}
