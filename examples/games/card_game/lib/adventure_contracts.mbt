///|
pub(all) enum RoomKind {
  RoomBattle
  RoomElite
  RoomUnique
  RoomBoss
  RoomRest
  RoomEvent
  RoomShop
  RoomTreasure
} derive(Debug, Eq)

///|
pub(all) struct RouteNode {
  id : Int
  floor : Int
  lane : Int
  kind : RoomKind
  next : Array[Int]
} derive(Debug, Eq)

///|
pub(all) struct RouteState {
  act : Int
  nodes : Array[RouteNode]
  mut current : Int?
  visited : Array[Int]
} derive(Debug)

///|
pub(all) enum EventId {
  HealingSpring
  LostPurse
  BloodAltar
  ForgottenLibrary
} derive(Debug, Eq)

///|
priv enum EventEffect {
  Heal(Int, Int)
  RaiseMaxHp(Int, Int)
  TakeGold(Int, Int)
  EventCard(CardId, Int)
  EventRelic(RelicId, Int, Int)
  LeaveEvent
}

///|
priv struct EventOption {
  label : String
  detail : String
  effect : EventEffect
}

///|
pub(all) enum ShopItem {
  ShopCard(CardId)
  ShopRelic(RelicId)
  ShopPotion(PotionId)
} derive(Debug)

///|
pub(all) struct ShopOffer {
  item : ShopItem
  price : Int
  mut sold : Bool
} derive(Debug)

///|
pub(all) struct ShopState {
  offers : Array[ShopOffer]
} derive(Debug)

///|
pub(all) enum RunChoiceAction {
  PickNode(Int)
  ResolveEvent(Int)
  BuyShop(Int)
  OpenCardRemoval
  RemoveDeckCard(Int)
  CancelRemoval
  LeaveShop
  TakeRelic(Int)
} derive(Eq)

///|
pub struct RunChoice {
  id : String
  label : String
  action : RunChoiceAction
}

///|
pub extend RoomKind with Eq::{equal, not_equal}

///|
pub extend RoomKind with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend RouteNode with Eq::{equal, not_equal}

///|
pub extend RouteNode with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend RouteState with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend EventId with Eq::{equal, not_equal}

///|
pub extend EventId with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ShopItem with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ShopOffer with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ShopState with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend RunChoiceAction with Eq::{equal, not_equal}
