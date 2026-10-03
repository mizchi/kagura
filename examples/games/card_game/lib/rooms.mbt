///|
fn event_title(id : EventId) -> String {
  match id {
    HealingSpring => "THE HEALING SPRING"
    LostPurse => "A PURSE IN THE THORNS"
    BloodAltar => "THE BLOOD ALTAR"
    ForgottenLibrary => "THE FORGOTTEN LIBRARY"
  }
}

///|
fn event_copy(id : EventId) -> String {
  match id {
    HealingSpring =>
      "Warm water glows beneath the ash. Drink freely, or leave an offering for a lasting blessing."
    LostPurse =>
      "Coins glitter inside a thorn bush. Reach into the thorns, or collect only what lies on the path."
    BloodAltar =>
      "An ancient altar promises strength. Its price is written plainly: blood for power."
    ForgottenLibrary =>
      "A keeper offers two forgotten techniques. Pay for a lesson, or continue with the deck you have."
  }
}

///|
fn event_options(id : EventId) -> Array[EventOption] {
  let leave : EventOption = {
    label: "LEAVE",
    detail: "Continue without changing your resources",
    effect: LeaveEvent,
  }
  match id {
    HealingSpring =>
      [
        { label: "DRINK", detail: "Recover 16 HP", effect: Heal(16, 0), },
        {
          label: "MAKE AN OFFERING",
          detail: "Pay 35 gold; gain 4 maximum HP and heal 4 HP",
          effect: RaiseMaxHp(4, 35),
        },
        leave,
      ]
    LostPurse =>
      [
        {
          label: "REACH INTO THE THORNS",
          detail: "Lose 8 HP; gain 75 gold",
          effect: TakeGold(75, 8),
        },
        {
          label: "TAKE THE LOOSE COINS",
          detail: "Gain 25 gold",
          effect: TakeGold(25, 0),
        },
        leave,
      ]
    BloodAltar =>
      [
        {
          label: "ACCEPT THE PACT",
          detail: "Lose 12 HP; gain Vajra (+1 starting Strength)",
          effect: EventRelic(Vajra, 0, 12),
        },
        {
          label: "SELL A MEMORY",
          detail: "Lose 6 HP; gain 45 gold",
          effect: TakeGold(45, 6),
        },
        leave,
      ]
    ForgottenLibrary =>
      [
        {
          label: "STUDY THE BATTLE TRANCE",
          detail: "Pay 45 gold; add Battle Trance (draw 3, cost 0)",
          effect: EventCard(Battle_Trance, 45),
        },
        {
          label: "STUDY THE IRON WAVE",
          detail: "Pay 40 gold; add Iron Wave (damage and Block)",
          effect: EventCard(Iron_Wave, 40),
        },
        leave,
      ]
  }
}

///|
fn event_option_enabled(run : RunState, option : EventOption) -> Bool {
  match option.effect {
    Heal(_, cost) | RaiseMaxHp(_, cost) | EventCard(_, cost) => run.gold >= cost
    TakeGold(_, hp) => run.player_hp > hp
    EventRelic(relic, cost, hp) =>
      run.gold >= cost && run.player_hp > hp && !run.relics.contains(relic)
    LeaveEvent => true
  }
}

///|
fn resolve_event(run : RunState, index : Int) -> Unit {
  let option = event_options(run.event.unwrap())[index]
  match option.effect {
    Heal(amount, cost) => {
      run.gold -= cost
      run.player_hp = (run.player_hp + amount).min(run.player_max_hp)
    }
    RaiseMaxHp(amount, cost) => {
      run.gold -= cost
      run.player_max_hp += amount
      run.player_hp += amount
    }
    TakeGold(amount, hp) => {
      run.gold += amount
      run.player_hp -= hp
    }
    EventCard(card, cost) => {
      run.gold -= cost
      run.deck.push(card)
    }
    EventRelic(relic, cost, hp) => {
      run.gold -= cost
      run.player_hp -= hp
      claim_relic(run, relic) |> ignore
    }
    LeaveEvent => ()
  }
  complete_room(run)
}

///|
fn ShopState::new(run : RunState) -> ShopState {
  let cards = [
    Pommel_Strike,
    Shrug_It_Off,
    Inflame,
    Cleave,
    Iron_Wave,
    Heavy_Blade,
    Battle_Trance,
    Uppercut,
    Reaper,
    Impervious,
  ]
  let offers : Array[ShopOffer] = []
  let remaining = cards.copy()
  for _ in 0..<3 {
    let index = run_random(run) % remaining.length()
    let card = remaining[index]
    let price = if card == Reaper || card == Impervious {
      120
    } else if card_def(card).cost >= 2 {
      85
    } else {
      55
    }
    offers.push({ item: ShopCard(card), price, sold: false, })
    remaining.remove(index) |> ignore
  }
  let relics = [Vajra, Orichalcum, PenNib, OrnamentalFan, HappyFlower, Lantern].filter(id => {
      !run.relics.contains(id)
    },
  )
  if !relics.is_empty() {
    offers.push({
      item: ShopRelic(relics[run_random(run) % relics.length()]),
      price: 140,
      sold: false,
    })
  }
  offers.push({
    item: ShopPotion(
      if run_random(run) % 2 == 0 {
        FirePotion
      } else {
        BlockPotion
      },
    ),
    price: 35,
    sold: false,
  })
  { offers, }
}

///|
fn shop_item_name(item : ShopItem) -> String {
  match item {
    ShopCard(card) => card_def(card).name
    ShopRelic(relic) => relic_def(relic).name
    ShopPotion(potion) => potion_def(potion).name
  }
}

///|
fn shop_item_detail(item : ShopItem) -> String {
  match item {
    ShopCard(card) => card_def(card).description
    ShopRelic(relic) => relic_def(relic).description
    ShopPotion(potion) => potion_def(potion).description
  }
}

///|
fn shop_price(run : RunState, price : Int) -> Int {
  if run.relics.contains(MerchantCharm) {
    price * 80 / 100
  } else {
    price
  }
}

///|
fn card_removal_price(run : RunState) -> Int {
  shop_price(run, 50 + run.cards_removed * 25)
}

///|
fn shop_offer_enabled(run : RunState, offer : ShopOffer) -> Bool {
  if offer.sold || run.gold < shop_price(run, offer.price) {
    return false
  }
  match offer.item {
    ShopRelic(relic) => !run.relics.contains(relic)
    ShopPotion(_) => run.potions.length() < max_potions
    ShopCard(_) => true
  }
}

///|
/// Shared semantic choices drive both controller/pointer UI and the agent.
pub fn run_choices(run : RunState) -> Array[RunChoice] {
  let choices : Array[RunChoice] = []
  match run.phase {
    RouteMap =>
      for node in available_rooms(run) {
        choices.push({
          id: "node:\{node.id}",
          label: "Floor \{node.floor}, lane \{node.lane + 1}: \{room_name(node.kind)}. \{room_detail(node.kind)}",
          action: PickNode(node.id),
        })
      }
    EventRoom =>
      if run.event is Some(id) {
        for index, option in event_options(id) {
          if event_option_enabled(run, option) {
            choices.push({
              id: "event:\{index}",
              label: "\{option.label}: \{option.detail}",
              action: ResolveEvent(index),
            })
          }
        }
      }
    ShopRoom =>
      if run.shop is Some(shop) {
        for index, offer in shop.offers {
          if shop_offer_enabled(run, offer) {
            choices.push({
              id: "buy:\{index}",
              label: "Buy \{shop_item_name(offer.item)} for \{shop_price(run, offer.price)} gold. \{shop_item_detail(offer.item)}",
              action: BuyShop(index),
            })
          }
        }
        if run.deck.length() > 1 && run.gold >= card_removal_price(run) {
          choices.push({
            id: "remove_card",
            label: "Remove a card from the permanent deck for \{card_removal_price(run)} gold; choose the card next",
            action: OpenCardRemoval,
          })
        }
        choices.push({
          id: "leave_shop",
          label: "Leave the shop and choose the next room",
          action: LeaveShop,
        })
      }
    CardRemoval => {
      if run.deck.length() > 1 && run.gold >= card_removal_price(run) {
        for index, card in run.deck {
          choices.push({
            id: "remove:\{index}",
            label: "Remove \{card_def(card).name} (deck slot \{index}) for \{card_removal_price(run)} gold",
            action: RemoveDeckCard(index),
          })
        }
      }
      choices.push({
        id: "cancel_removal",
        label: "Return to the shop without removing a card or paying",
        action: CancelRemoval,
      })
    }
    TreasureRoom =>
      for index, relic in run.treasure_rewards {
        if !run.relics.contains(relic) {
          choices.push({
            id: "relic:\{index}",
            label: "Take \{relic_def(relic).name}: \{relic_def(relic).description}",
            action: TakeRelic(index),
          })
        }
      }
    _ => ()
  }
  choices
}

///|
pub fn apply_run_choice(run : RunState, id : String) -> Bool {
  let mut selected : RunChoice? = None
  for choice in run_choices(run) {
    if choice.id == id {
      selected = Some(choice)
      break
    }
  }
  guard selected is Some(choice) else { return false }
  match choice.action {
    PickNode(id) => enter_room(run, id)
    ResolveEvent(index) => resolve_event(run, index)
    BuyShop(index) => {
      let offer = run.shop.unwrap().offers[index]
      run.gold -= shop_price(run, offer.price)
      offer.sold = true
      match offer.item {
        ShopCard(card) => run.deck.push(card)
        ShopRelic(relic) => claim_relic(run, relic) |> ignore
        ShopPotion(potion) => run.potions.push(potion)
      }
    }
    OpenCardRemoval => run.phase = CardRemoval
    RemoveDeckCard(index) => {
      run.gold -= card_removal_price(run)
      run.deck.remove(index) |> ignore
      run.cards_removed += 1
      run.phase = ShopRoom
    }
    CancelRemoval => run.phase = ShopRoom
    LeaveShop => complete_room(run)
    TakeRelic(index) => {
      let relic = run.treasure_rewards[index]
      claim_relic(run, relic) |> ignore
      run.last_relic = Some(relic)
      complete_room(run)
    }
  }
  true
}
