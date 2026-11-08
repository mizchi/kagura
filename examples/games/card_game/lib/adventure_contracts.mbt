///|
#derive(Debug, Eq)
pub(all) enum RoomKind {
  RoomBattle
  RoomElite
  RoomUnique
  RoomBoss
  RoomRest
  RoomEvent
  RoomShop
  RoomTreasure
}

///|
#derive(Debug, Eq)
pub(all) struct RouteNode {
  id : Int32
  floor : Int32
  lane : Int32
  kind : RoomKind
  next : Array[Int32]
}

///|
#derive(Debug)
pub(all) struct RouteState {
  act : Int32
  nodes : Array[RouteNode]
  mut current : Int32?
  visited : Array[Int32]
}

///|
#derive(Debug, Eq)
pub(all) enum EventId {
  HealingSpring
  LostPurse
  BloodAltar
  ForgottenLibrary
}

///|
priv enum EventEffect {
  Heal(Int32, Int32)
  RaiseMaxHp(Int32, Int32)
  TakeGold(Int32, Int32)
  EventCard(CardId, Int32)
  EventRelic(RelicId, Int32, Int32)
  LeaveEvent
}

///|
priv struct EventOption {
  label : String
  detail : String
  effect : EventEffect
}

///|
#derive(Debug)
pub(all) enum ShopItem {
  ShopCard(CardId)
  ShopRelic(RelicId)
  ShopPotion(PotionId)
}

///|
#derive(Debug)
pub(all) struct ShopOffer {
  item : ShopItem
  price : Int32
  mut sold : Bool
}

///|
#derive(Debug)
pub(all) struct ShopState {
  offers : Array[ShopOffer]
}

///|
#derive(Eq)
pub(all) enum RunChoiceAction {
  PickNode(Int32)
  ResolveEvent(Int32)
  BuyShop(Int32)
  OpenCardRemoval
  RemoveDeckCard(Int32)
  CancelRemoval
  LeaveShop
  TakeRelic(Int32)
}

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
