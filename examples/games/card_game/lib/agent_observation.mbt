///|
fn agent_card_json(card : CardId, cost : Int) -> Json {
  let def = card_def(card)
  {
    "id": card.to_string(),
    "name": def.name,
    "type": def.card_type.to_string(),
    "cost": cost,
    "printedCost": def.cost,
    "description": def.description,
    "baseDamage": def.base_damage,
    "baseBlock": def.base_block,
    "exhaust": def.exhaust,
    "needsTarget": card_needs_target(card),
  }
}

///|
/// A sorted multiset provides inspectable contents without disclosing the
/// shuffled draw order or advancing the game's random generator.
fn agent_pile_json(cards : Array[CardId]) -> Json {
  let counts : Map[String, Int] = Map([])
  let ids : Array[String] = []
  for card in cards {
    let id = card.to_string()
    if !counts.contains(id) {
      ids.push(id)
    }
    counts[id] = counts.get(id).unwrap_or(0) + 1
  }
  ids.sort()
  let entries : Array[Json] = ids.map(id => {
    "id": id,
    "count": counts.get(id).unwrap_or(0),
  })
  { "count": cards.length(), "cards": entries }
}

///|
fn agent_fighter_json(fighter : Fighter) -> Json {
  {
    "name": fighter.name,
    "hp": fighter.hp,
    "maxHp": fighter.max_hp,
    "block": fighter.block,
    "energy": fighter.energy,
    "maxEnergy": fighter.max_energy,
    "strength": fighter.status.strength,
    "weak": fighter.status.weak,
    "vulnerable": fighter.status.vulnerable,
  }
}

///|
fn agent_intent_json(enemy : Enemy, player : Fighter) -> Json {
  let (kind, base, hits) = match enemy.intent {
    AttackIntent(amount) => ("attack", amount, 1)
    MultiAttack(amount, times) => ("attack", amount, times)
    DefendIntent(amount) => ("defend", amount, 0)
    BuffIntent => ("buff", 0, 0)
    DebuffIntent => ("debuff", 0, 0)
  }
  let damage = if hits > 0 && !enemy.fighter.is_dead() {
    calculate_received_damage(
      calculate_attack_damage(base, enemy.fighter),
      player,
    ) *
    hits
  } else {
    0
  }
  { "kind": kind, "base": base, "hits": hits, "damageBeforeBlock": damage }
}

///|
fn AgentChoice::to_json(self : AgentChoice) -> Json {
  let action : Json = match self.action {
    Begin => { "kind": "begin" }
    ChooseCharacter(character) =>
      { "kind": "choose_character", "character": character_name(character) }
    ChooseStage(stage) =>
      { "kind": "choose_stage", "stage": stage.to_repr().to_string() }
    PlayCard(index, target) =>
      { "kind": "play_card", "handIndex": index, "targetIndex": target }
    UsePotion(index, target) =>
      { "kind": "use_potion", "potionIndex": index, "targetIndex": target }
    EndTurn => { "kind": "end_turn" }
    ContinueBattle => { "kind": "continue" }
    ChooseReward(index) => { "kind": "choose_reward", "rewardIndex": index }
    SkipReward => { "kind": "skip_reward" }
    Rest => { "kind": "rest" }
    Explore(action) =>
      match action {
        PickNode(id) => { "kind": "choose_node", "nodeId": id }
        ResolveEvent(index) => { "kind": "choose_event", "optionIndex": index }
        BuyShop(index) => { "kind": "buy", "offerIndex": index }
        OpenCardRemoval => { "kind": "open_card_removal" }
        RemoveDeckCard(index) => { "kind": "remove_card", "deckIndex": index }
        CancelRemoval => { "kind": "cancel_removal" }
        LeaveShop => { "kind": "leave_shop" }
        TakeRelic(index) => { "kind": "choose_relic", "relicIndex": index }
      }
  }
  { "id": self.id, "label": self.label, "action": action }
}

///|
fn AgentSession::phase_name(self : AgentSession) -> String {
  match self.scene {
    Title => "title"
    CharacterSelect => "character_select"
    StageSelect => "stage_select"
    Settings => "settings"
    Playing => {
      guard self.run is Some(run) else { return "title" }
      match run.phase {
        Battle =>
          match run.battle {
            Some({ phase: Victory, .. }) => "battle_victory"
            Some({ phase: Defeat, .. }) => "battle_defeat"
            _ => "battle"
          }
        RouteMap => "map"
        EventRoom => "event"
        ShopRoom => "shop"
        CardRemoval => "card_removal"
        TreasureRoom => "treasure"
        CardReward => "card_reward"
        RestSite => "rest"
        RunVictory => "victory"
        RunDefeat => "defeat"
      }
    }
  }
}

///|
fn agent_battle_json(b : BattleState) -> Json {
  let hand : Array[Json] = []
  for index, card in b.hand {
    let entry = agent_card_json(card, card_play_cost(b, card))
    if entry is Object(fields) {
      fields["handIndex"] = index.to_json()
      fields["playable"] = can_play_card(b, index).to_json()
    }
    hand.push(entry)
  }
  let enemies : Array[Json] = []
  let mut incoming = 0
  for index, enemy in b.enemies {
    let intent = agent_intent_json(enemy, b.player)
    if intent is Object(fields) &&
      fields.get("damageBeforeBlock") is Some(Number(damage, ..)) {
      incoming += damage.to_int()
    }
    enemies.push({
      "enemyIndex": index,
      "id": enemy.id.to_string(),
      "alive": !enemy.fighter.is_dead(),
      "unique": is_unique_enemy(enemy.id),
      "pattern": unique_enemy_detail(enemy.id),
      "fighter": agent_fighter_json(enemy.fighter),
      "intent": intent,
    })
  }
  {
    "turn": b.turn,
    "player": agent_fighter_json(b.player),
    "hand": hand,
    "enemies": enemies,
    "incomingDamageBeforeBlock": incoming,
    "drawPile": agent_pile_json(b.draw_pile),
    "discardPile": agent_pile_json(b.discard_pile),
    "exhaustPile": agent_pile_json(b.exhaust_pile),
    "powers": {
      "metallicize": b.powers.metallicize,
      "demonForm": b.powers.demon_form,
      "barricade": b.powers.barricade,
      "feelNoPain": b.powers.feel_no_pain,
      "flexLoss": b.powers.flex_loss,
      "rampageBonus": b.powers.rampage_bonus,
      "corruption": b.powers.corruption,
      "regen": b.powers.regen,
    },
    "recentEvents": [
      for i in (b.logs.length() - 8).max(0)..<b.logs.length() => {
        b.logs[i].to_json()
      }
    ],
  }
}

///|
/// JSON is the versioned host boundary, not a serialization of mutable state.
/// No rendering, browser globals, wall-clock delay or external API is required.
pub fn AgentSession::observe(self : AgentSession) -> Json {
  let run_json : Json = match self.run {
    None => Json::null()
    Some(run) => {
      let battle = if run.phase == Battle {
        run.battle.map(agent_battle_json).unwrap_or(Json::null())
      } else {
        Json::null()
      }
      let relics : Array[Json] = run.relics.map(id => {
        "id": id.to_string(),
        "name": relic_def(id).name,
        "description": relic_def(id).description,
      })
      let potions : Array[Json] = []
      for index, id in run.potions {
        potions.push({
          "potionIndex": index,
          "id": id.to_string(),
          "name": potion_def(id).name,
          "description": potion_def(id).description,
        })
      }
      {
        "character": character_name(run.character),
        "stage": run.stage.to_repr().to_string(),
        "floor": run.floor,
        "gold": run.gold,
        "room": run.current_room
        .map(kind => room_name(kind).to_json())
        .unwrap_or(Json::null()),
        "map": agent_route_json(run),
        "event": agent_event_json(run),
        "shop": agent_shop_json(run),
        "treasure": run.treasure_rewards.map(agent_relic_json),
        "removalDeck": if run.phase == CardRemoval {
          run.deck.map(card => agent_card_json(card, card_def(card).cost))
        } else {
          []
        },
        "act": floor_act(run.floor),
        "hp": if run.phase == Battle {
          run.battle.map(b => b.player.hp).unwrap_or(run.player_hp)
        } else {
          run.player_hp
        },
        "maxHp": if run.phase == Battle {
          run.battle.map(b => b.player.max_hp).unwrap_or(run.player_max_hp)
        } else {
          run.player_max_hp
        },
        "deck": agent_pile_json(run.deck),
        "relics": relics,
        "potions": potions,
        "rewards": run.card_rewards.map(card => {
          agent_card_json(card, card_def(card).cost)
        }),
        "battle": battle,
      }
    }
  }
  let choices : Array[Json] = self.choices().map(choice => choice.to_json())
  {
    "schemaVersion": 2,
    "revision": self.revision,
    "phase": self.phase_name(),
    "terminal": self.is_terminal(),
    "run": run_json,
    "choices": choices,
  }
}

///|
fn agent_relic_json(id : RelicId) -> Json {
  {
    "id": id.to_string(),
    "name": relic_def(id).name,
    "description": relic_def(id).description,
  }
}

///|
fn agent_route_json(run : RunState) -> Json {
  guard run.route is Some(route) else { return Json::null() }
  let available = available_rooms(run).map(n => n.id)
  let nodes : Array[Json] = route.nodes.map(n => {
    "id": n.id,
    "floor": n.floor,
    "lane": n.lane,
    "kind": room_name(n.kind),
    "next": n.next,
    "visited": route.visited.contains(n.id),
    "available": available.contains(n.id),
  })
  {
    "act": route.act,
    "current": route.current.map(id => id.to_json()).unwrap_or(Json::null()),
    "nodes": nodes,
  }
}

///|
fn agent_event_json(run : RunState) -> Json {
  guard run.event is Some(id) else { return Json::null() }
  let options : Array[Json] = []
  for index, option in event_options(id) {
    options.push({
      "index": index,
      "label": option.label,
      "description": option.detail,
      "enabled": event_option_enabled(run, option),
    })
  }
  {
    "id": id.to_repr().to_string(),
    "title": event_title(id),
    "story": event_copy(id),
    "options": options,
  }
}

///|
fn agent_shop_json(run : RunState) -> Json {
  guard run.shop is Some(shop) else { return Json::null() }
  let offers : Array[Json] = []
  for index, offer in shop.offers {
    let kind = match offer.item {
      ShopCard(_) => "card"
      ShopRelic(_) => "relic"
      ShopPotion(_) => "potion"
    }
    offers.push({
      "index": index,
      "kind": kind,
      "name": shop_item_name(offer.item),
      "description": shop_item_detail(offer.item),
      "price": shop_price(run, offer.price),
      "sold": offer.sold,
      "enabled": shop_offer_enabled(run, offer),
    })
  }
  {
    "offers": offers,
    "removalPrice": card_removal_price(run),
    "removalEnabled": run.deck.length() > 1 &&
    run.gold >= card_removal_price(run),
    "discountPercent": if run.relics.contains(MerchantCharm) {
      20
    } else {
      0
    },
  }
}
