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
        description: "Gain 2 Strength.",
      }
  }
}

///|
/// Create starter deck (like Ironclad)
fn starter_deck() -> Array[CardId] {
  [Strike, Strike, Strike, Strike, Strike, Defend, Defend, Defend, Defend, Bash]
}
