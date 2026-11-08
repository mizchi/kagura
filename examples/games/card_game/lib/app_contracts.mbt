///|
#derive(Eq)
enum AppScene {
  Title
  Settings
  CharacterSelect
  Playing
}

///|
#derive(Debug, Eq)
pub(all) enum CharacterId {
  Ironclad
  Warden
}

///|
#derive(Debug, Eq)
pub(all) enum StageId {
  Ascent
  ActTwo
  GuardianTrial
}

///|
#derive(Eq)
enum MotionMode {
  System
  Reduced
  Full
}

///|
#derive(Eq)
enum PileKind {
  Deck
  Draw
  Discard
}

///|
#derive(Eq)
enum CombatFocus {
  Hand(Int32)
  Target(Int32) // -1 is the player / battlefield for untargeted cards
  EndTurn
  DrawPile
  DiscardPile
  DeckButton
}

///|
fn character_name(id : CharacterId) -> String {
  match id {
    Ironclad => "Ironclad"
    Warden => "Warden"
  }
}

///|
fn character_deck(id : CharacterId) -> Array[CardId] {
  match id {
    Ironclad => starter_deck()
    Warden =>
      [
        Strike,
        Strike,
        Strike,
        Strike,
        Defend,
        Defend,
        Defend,
        Defend,
        Defend,
        Body_Slam,
      ]
  }
}

///|
pub extend CharacterId with Eq::{equal, not_equal}

///|
pub extend StageId with Eq::{equal, not_equal}

///|
pub extend CharacterId with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend StageId with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend AppScene with Eq::{equal, not_equal}

///|
pub extend MotionMode with Eq::{equal, not_equal}

///|
pub extend PileKind with Eq::{equal, not_equal}

///|
pub extend CombatFocus with Eq::{equal, not_equal}
