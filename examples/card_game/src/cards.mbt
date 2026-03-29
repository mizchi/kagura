///|
/// Card identifiers
pub(all) enum CardId {
  Strike
  Defend
  Bash
  Cleave
  Pommel_Strike
  Shrug_It_Off
  Inflame
  // New cards
  Body_Slam
  Twin_Strike
  Clothesline
  Iron_Wave
  Bloodletting
  Offering
  Uppercut
  Seeing_Red
  Armaments
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
fn card_def(id : CardId) -> CardDef {
  match id {
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
        base_block: 5,
        exhaust: false,
        description: "Gain 5 Block.",
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
    Iron_Wave =>
      {
        id: Iron_Wave,
        name: "Iron Wave",
        cost: 1,
        card_type: Attack,
        base_damage: 5,
        base_block: 5,
        exhaust: false,
        description: "Gain 5 Block. Deal 5 damage.",
      }
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
  }
}

///|
/// Create starter deck (like Ironclad)
fn starter_deck() -> Array[CardId] {
  [Strike, Strike, Strike, Strike, Strike, Defend, Defend, Defend, Defend, Bash]
}
