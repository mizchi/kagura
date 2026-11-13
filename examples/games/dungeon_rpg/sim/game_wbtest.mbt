///|
test "the expedition starts immediately and walls cost neither light nor danger" {
  let g = new_game()
  g.command("enter", -1)
  assert_eq(g.mode, Exploring)
  assert_eq(g.party.length(), 6)
  let light = g.light
  let danger = g.danger
  g.command("left", -1)
  g.command("forward", -1)
  assert_eq(g.x, 1)
  assert_eq(g.z, 1)
  assert_eq(g.light, light)
  assert_eq(g.danger, danger)
  assert_false(g.seen[cell_id(1, 7, 7)])
}

///|
test "all floors connect their entrance, stairs, treasure and guardian" {
  for floor in 0..<2 {
    let reached : Array[(Int32, Int32)] = [(1, 1)]
    for i = 0; i < reached.length(); i = i + 1 {
      let (x, z) = reached[i]
      for (dx, dz) in [(1, 0), (-1, 0), (0, 1), (0, -1)] {
        let p = (x + dx, z + dz)
        if tile(floor, p.0, p.1) != Wall && !reached.contains(p) {
          reached.push(p)
        }
      }
    }
    for z in 0..<9 {
      for x in 0..<9 {
        if [Down, Up, Chest, Shrine, Guardian].contains(tile(floor, x, z)) {
          assert_true(reached.contains((x, z)))
        }
      }
    }
  }
}

///|
test "waiting and planning never advance a battle or spend mana" {
  let g = new_game()
  g.command("enter", -1)
  g.begin_battle(false)
  let before = g.snapshot()
  for _ in 0..<100 {
    ignore(g.snapshot())
  }
  assert_eq(g.snapshot(), before)
  let hp = g.party[0].hp
  g.command("attack", 0)
  assert_eq(g.party[0].hp, hp)
  assert_eq(g.battle.unwrap().round, 1)
}

///|
test "front rank receives melee attacks and guard reduces their damage" {
  let a = new_game()
  let b = new_game()
  for g in [a, b] {
    g.command("enter", -1)
    g.begin_battle(false)
    let battle = g.battle.unwrap()
    battle.foes.clear()
    battle.foes.push(g.spawn_foe("guardian"))
    battle.round = 2
  }
  let back = a.party[3].hp
  a.command("all-attack", -1)
  b.command("all-guard", -1)
  assert_eq(a.party[3].hp, back)
  let damage_a = a.party
    .map(h => h.max_hp() - h.hp)
    .fold(init=0, (sum, n) => sum + n)
  let damage_b = b.party
    .map(h => h.max_hp() - h.hp)
    .fold(init=0, (sum, n) => sum + n)
  assert_true(damage_a > 0)
  assert_true(damage_b < damage_a)
}

///|
test "commands validate resources without corrupting the current round" {
  let g = new_game()
  g.command("enter", -1)
  g.begin_battle(false)
  let before = g.snapshot()
  assert_true(
    try {
      g.command("heal", 0)
      false
    } catch {
      _ => true
    },
  )
  assert_eq(g.snapshot(), before)
  assert_true(
    try {
      g.command("attack", 99)
      false
    } catch {
      _ => true
    },
  )
  assert_eq(g.snapshot(), before)
}

///|
test "the guild swaps ranks and town rest cannot leave a poor party stuck" {
  let g = new_game()
  g.command("swap", 0)
  g.command("swap", 4)
  assert_eq(g.party[0].job, Mage)
  assert_eq(g.party[4].job, Fighter)
  g.gold = 0
  for h in g.party {
    h.hp = 1
    h.mp = 0
  }
  g.command("rest", -1)
  assert_true(g.party.all(h => h.hp == h.max_hp() && h.mp == h.max_mp()))
}

///|
test "defeat returns to town without losing the party" {
  let g = new_game()
  g.command("enter", -1)
  g.begin_battle(false)
  for h in g.party {
    h.hp = 0
  }
  g.resolve_round()
  assert_eq(g.mode, Town)
  assert_true(g.party.all(h => h.hp == 1))
  g.command("rest", -1)
  assert_true(g.party.all(h => h.hp > 1))
}

///|
test "treasure and shrines are single-use and the relic must be brought home" {
  let g = new_game()
  g.command("enter", -1)
  g.x = 7
  g.z = 2
  g.command("interact", -1)
  g.command("loot", 0)
  let gold = g.carried_gold
  g.command("interact", -1)
  assert_eq(g.carried_gold, gold)
  g.relic = true
  assert_eq(g.mode, Exploring)
  g.x = 1
  g.z = 1
  g.floor = 0
  g.command("interact", -1)
  assert_eq(g.mode, Cleared)
  assert_eq(g.clears, 1)
  assert_true(g.gold > 40)
}

///|
test "town saves restore formation and reject invalid data atomically" {
  let g = new_game()
  g.command("swap", 0)
  g.command("swap", 3)
  let source = g.save_town()
  let restored = new_game()
  restored.load_town(source)
  assert_eq(restored.party[0].id, g.party[0].id)
  assert_eq(restored.gold, g.gold)
  let before = restored.snapshot()
  assert_true(
    try {
      restored.load_town("{\"schema\":999}")
      false
    } catch {
      _ => true
    },
  )
  assert_eq(restored.snapshot(), before)
}

///|
fn test_battle(g : Game) -> Unit raise {
  for _ in 0..<40 {
    if g.mode != Fighting {
      return
    }
    let b = g.battle.unwrap()
    if b.phase == Won || b.phase == Report {
      g.command("continue", -1)
      continue
    }
    if b.phase == Review {
      g.command("resolve", -1)
      continue
    }
    let actor = g.party[g.active_actor()]
    let mut wounded = -1
    for i in 0..<6 {
      if g.party[i].hp > 0 &&
        g.party[i].max_hp() - g.party[i].hp >= 8 &&
        (wounded < 0 || g.party[i].hp < g.party[wounded].hp) {
        wounded = i
      }
    }
    if actor.job == Priest && actor.mp >= 2 && wounded >= 0 {
      g.command("heal", wounded)
    } else if actor.job == Mage &&
      actor.mp >= 3 &&
      b.foes.filter(f => f.hp > 0).length() >= 2 {
      g.command("flame", -1)
    } else if wounded >= 0 &&
      g.party[wounded].hp < 8 &&
      g.potions > b.orders.filter(o => o.action == Potion).length() {
      g.command("potion", wounded)
    } else {
      g.command("attack", b.foes.search_by(f => f.hp > 0).unwrap())
    }
  }
  fail("battle did not finish")
}

///|
fn test_walk(g : Game, tx : Int32, tz : Int32) -> Unit raise {
  let paths : Array[Array[(Int32, Int32)]] = [[(g.x, g.z)]]
  let seen : Array[(Int32, Int32)] = [(g.x, g.z)]
  let mut route : Array[(Int32, Int32)] = []
  for i = 0; i < paths.length(); i = i + 1 {
    let path = paths[i]
    let (x, z) = path[path.length() - 1]
    if x == tx && z == tz {
      route = path
      break
    }
    for (dx, dz) in [(1, 0), (-1, 0), (0, 1), (0, -1)] {
      let next = (x + dx, z + dz)
      if tile(g.floor, next.0, next.1) != Wall && !seen.contains(next) {
        seen.push(next)
        let p = path.copy()
        p.push(next)
        paths.push(p)
      }
    }
  }
  assert_true(route.length() > 0)
  for i in 1..<route.length() {
    let (x, z) = route[i]
    let facing = if x > g.x {
      1
    } else if x < g.x {
      3
    } else if z > g.z {
      2
    } else {
      0
    }
    while g.facing != facing {
      g.command("right", -1)
    }
    if g.blocked(x, z) {
      g.command("interact", -1)
    }
    g.command("forward", -1)
    if g.mode == Fighting {
      test_battle(g)
    }
    if g.mode == Town {
      fail("party was defeated on the route")
    }
  }
}

///|
test "an ordinary six-hero party can find the seal and carry it home" {
  let g = new_game()
  g.command("enter", -1)
  test_walk(g, 7, 2)
  g.command("interact", -1)
  g.command("loot", 0)
  test_walk(g, 7, 7)
  g.command("interact", -1)
  assert_eq(g.floor, 1)
  test_walk(g, 1, 6)
  g.command("interact", -1)
  test_walk(g, 6, 7)
  assert_eq(g.mode, Warning)
  g.command("challenge", -1)
  test_battle(g)
  assert_true(g.relic)
  assert_eq(g.mode, Exploring)
  g.command("recall", -1)
  assert_eq(g.mode, Cleared)
  assert_true(g.party.any(h => h.hp > 0))
  assert_true(g.gold > 40)
}

///|
test "healing consumes exactly one resource and invalid field targets change nothing" {
  let g = new_game()
  g.command("enter", -1)
  let before = g.snapshot()
  assert_true(
    try {
      g.command("field-potion", 0)
      false
    } catch {
      _ => true
    },
  )
  assert_eq(g.snapshot(), before)
  g.party[0].hp = 5
  g.command("field-heal", 0)
  assert_eq(g.party[0].hp, 17)
  assert_eq(g.party[3].mp, 6)
  g.command("field-potion", 0)
  assert_eq(g.party[0].hp, 24)
  assert_eq(g.potions, 2)
}

///|
test "spell planning is undoable and mana is charged only on resolution" {
  let g = new_game()
  g.command("enter", -1)
  g.begin_battle(true)
  for _ in 0..<4 {
    g.command("guard", -1)
  }
  g.command("flame", -1)
  assert_eq(g.party[4].mp, 10)
  g.command("undo", -1)
  assert_eq(g.battle.unwrap().orders.length(), 4)
  g.command("flame", -1)
  g.command("guard", -1)
  g.command("resolve", -1)
  assert_eq(g.party[4].mp, 7)
}

///|
test "doors reveal only after opening, torch expires safely and shrines are single-use" {
  let g = new_game()
  g.command("enter", -1)
  g.x = 3
  g.z = 5
  g.facing = 1
  g.light = 1
  g.command("forward", -1)
  assert_eq(g.x, 3)
  assert_eq(g.light, 1)
  g.command("interact", -1)
  g.command("forward", -1)
  assert_eq(g.x, 4)
  assert_eq(g.light, 0)
  assert_true(g.seen[cell_id(0, 5, 5)])
  g.floor = 1
  g.x = 1
  g.z = 6
  g.party[0].hp = 1
  g.party[3].mp = 0
  g.command("interact", -1)
  assert_eq(g.party[0].hp, 7)
  assert_eq(g.party[3].mp, 2)
  g.command("interact", -1)
  assert_eq(g.party[0].hp, 7)
}

///|
test "duplicate identities in a save are rejected before touching the live party" {
  let g = new_game()
  let good : TownSave = @json.from_json(@json.parse(g.save_town()))
  let bad : TownSave = { ..good, party: Array::make(6, good.party[0]), }
  let before = g.snapshot()
  assert_true(
    try {
      g.load_town(@json.ToJson::to_json(bad).stringify())
      false
    } catch {
      _ => true
    },
  )
  assert_eq(g.snapshot(), before)
  g.command("enter", -1)
  assert_true(
    try {
      ignore(g.save_town())
      false
    } catch {
      _ => true
    },
  )
}

///|
test "the party can retrace both floors with the seal without using the recall bell" {
  let g = new_game()
  g.command("enter", -1)
  test_walk(g, 7, 2)
  g.command("interact", -1)
  g.command("loot", 0)
  test_walk(g, 7, 7)
  g.command("interact", -1)
  test_walk(g, 1, 6)
  g.command("interact", -1)
  test_walk(g, 6, 7)
  g.command("challenge", -1)
  test_battle(g)
  test_walk(g, 1, 1)
  g.command("interact", -1)
  assert_eq(g.floor, 0)
  test_walk(g, 1, 1)
  g.command("interact", -1)
  assert_eq(g.mode, Cleared)
  assert_eq(g.bell, 1)
}
