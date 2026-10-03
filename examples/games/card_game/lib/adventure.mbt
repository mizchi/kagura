///|
fn room_name(kind : RoomKind) -> String {
  match kind {
    RoomBattle => "BATTLE"
    RoomElite => "ELITE"
    RoomUnique => "UNIQUE"
    RoomBoss => "BOSS"
    RoomRest => "REST"
    RoomEvent => "EVENT"
    RoomShop => "SHOP"
    RoomTreasure => "TREASURE"
  }
}

///|
fn room_detail(kind : RoomKind) -> String {
  match kind {
    RoomBattle => "Fight enemies for gold and a card reward"
    RoomElite => "A dangerous encounter with a guaranteed relic and more gold"
    RoomUnique =>
      "A named enemy with its own pattern and a guaranteed signature relic"
    RoomBoss => "Defeat the act boss to advance"
    RoomRest => "Recover 25% of maximum HP"
    RoomEvent => "Choose a story outcome with explicit costs and rewards"
    RoomShop => "Buy cards, relics and potions, or remove a card"
    RoomTreasure => "Choose one unowned relic for free"
  }
}

///|
fn route_row_kind(row : Int, lane : Int, seed : Int) -> RoomKind {
  if row == 1 {
    return RoomBattle
  }
  if row == 14 {
    return RoomRest
  }
  if row == 15 {
    return RoomBoss
  }
  let column = (lane + ((seed & 0x7FFF) + row * 7) % 3) % 3
  let kinds = match row {
    2 => [RoomEvent, RoomShop, RoomBattle]
    3 => [RoomBattle, RoomEvent, RoomRest]
    4 => [RoomElite, RoomBattle, RoomEvent]
    5 => [RoomRest, RoomShop, RoomTreasure]
    6 => [RoomBattle, RoomEvent, RoomBattle]
    7 => [RoomShop, RoomUnique, RoomTreasure]
    8 => [RoomElite, RoomBattle, RoomEvent]
    9 => [RoomRest, RoomTreasure, RoomShop]
    10 => [RoomBattle, RoomEvent, RoomElite]
    11 => [RoomShop, RoomBattle, RoomEvent]
    12 => [RoomRest, RoomEvent, RoomTreasure]
    _ => [RoomElite, RoomBattle, RoomElite]
  }
  kinds[column]
}

///|
fn make_route(act : Int, seed : Int, visited? : Array[Int] = []) -> RouteState {
  let start = (act - 1) * 15 + 1
  let nodes : Array[RouteNode] = []
  for row in 1..<16 {
    let floor = start + row - 1
    for lane in 0..<3 {
      if row == 15 && lane != 1 {
        continue
      }
      let next : Array[Int] = []
      if row == 14 {
        next.push(floor * 3 + 1)
      } else if row < 14 {
        for target in 0..<3 {
          if (target - lane).abs() <= 1 {
            next.push(floor * 3 + target)
          }
        }
      }
      nodes.push({
        id: (floor - 1) * 3 + lane,
        floor,
        lane,
        kind: route_row_kind(row, lane, seed),
        next,
      })
    }
  }
  { act, nodes, current: None, visited: visited.copy(), }
}

///|
/// The legacy linear constructor remains available for balance simulations.
pub fn RunState::adventure(
  character : CharacterId,
  stage : StageId,
  seed? : Int = 42,
) -> RunState {
  if stage == GuardianTrial {
    return RunState::start(character, stage, seed~)
  }
  let run = create_run_state(character, stage, seed)
  run.route = Some(make_route(if stage == ActTwo { 2 } else { 1 }, seed))
  run.phase = RouteMap
  run
}

///|
pub fn available_rooms(run : RunState) -> Array[RouteNode] {
  if run.phase != RouteMap {
    return []
  }
  guard run.route is Some(route) else { return [] }
  guard route.current is Some(current) else {
    return route.nodes.filter(n => {
      n.floor == (route.act - 1) * 15 + 1 &&
      n.floor == run.floor + 1 &&
      !route.visited.contains(n.id)
    })
  }
  let mut ids : Array[Int] = []
  for node in route.nodes {
    if node.id == current {
      ids = node.next
      break
    }
  }
  route.nodes.filter(n => {
    ids.contains(n.id) &&
    n.floor == run.floor + 1 &&
    !route.visited.contains(n.id)
  })
}

///|
fn complete_room(run : RunState) -> Unit {
  if run.route is None {
    advance_floor(run)
    return
  }
  run.battle = None
  run.event = None
  run.shop = None
  run.treasure_rewards.clear()
  run.current_room = None
  if run.floor >= 30 {
    run.phase = RunVictory
    return
  }
  if run.floor == 15 {
    run.player_hp = run.player_max_hp
    run.route = Some(
      make_route(2, run.rng_seed, visited=run.route.unwrap().visited),
    )
  }
  run.phase = RouteMap
}

///|
fn enter_room(run : RunState, id : Int) -> Unit {
  let mut selected : RouteNode? = None
  for node in available_rooms(run) {
    if node.id == id {
      selected = Some(node)
      break
    }
  }
  guard selected is Some(node) else { return }
  let route = run.route.unwrap()
  route.current = Some(id)
  route.visited.push(id)
  run.floor = node.floor
  run.current_room = Some(node.kind)
  run.last_relic = None
  run.last_gold = 0
  match node.kind {
    RoomBattle | RoomElite | RoomBoss => {
      let tier : EncounterTier = if node.kind == RoomBoss {
        Boss
      } else if node.kind == RoomElite {
        Elite
      } else if node.floor <= 3 {
        Easy
      } else {
        Normal
      }
      run.battle = Some(start_run_battle(run, pick_encounter(run, tier)))
      run.phase = Battle
    }
    RoomUnique => {
      run.battle = Some(start_unique_battle(run))
      run.phase = Battle
    }
    RoomRest => run.phase = RestSite
    RoomEvent => {
      let pool = [HealingSpring, LostPurse, BloodAltar, ForgottenLibrary]
      run.event = Some(pool[run_random(run) % pool.length()])
      run.phase = EventRoom
    }
    RoomShop => {
      run.shop = Some(ShopState::new(run))
      run.phase = ShopRoom
    }
    RoomTreasure => open_treasure(run)
  }
}

///|
fn combat_gold(run : RunState, kind : RoomKind) -> Int {
  let base = match kind {
    RoomBoss => 100
    RoomUnique => 70
    RoomElite => 50
    _ => 20
  }
  base + run.floor % 11 + (if run.relics.contains(Wayfinder) { 10 } else { 0 })
}

///|
fn claim_relic(run : RunState, relic : RelicId) -> Bool {
  if run.relics.contains(relic) {
    return false
  }
  run.relics.push(relic)
  true
}

///|
fn open_treasure(run : RunState) -> Unit {
  run.treasure_rewards.clear()
  let available = relic_reward_pool().filter(id => !run.relics.contains(id))
  while !available.is_empty() && run.treasure_rewards.length() < 3 {
    let index = run_random(run) % available.length()
    run.treasure_rewards.push(available[index])
    available.remove(index) |> ignore
  }
  if run.treasure_rewards.is_empty() {
    run.gold += 60
    complete_room(run)
  } else {
    run.phase = TreasureRoom
  }
}
