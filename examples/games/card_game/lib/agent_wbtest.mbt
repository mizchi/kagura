///|
fn agent_ids(session : AgentSession) -> Array[String] {
  session.choices().map(choice => choice.id)
}

///|
fn agent_field(value : Json, key : String) -> Json? {
  value.as_object().unwrap().get(key)
}

///|
test "agent character choice starts the first act without a stage menu" {
  let session = AgentSession::new(seed=17)
  assert_eq(agent_ids(session), ["begin"])
  assert_eq(session.step(0, "begin"), Applied)
  assert_eq(agent_ids(session), ["character:ironclad", "character:warden"])
  assert_eq(session.step(1, "character:warden"), Applied)
  assert_eq(agent_ids(session), ["node:0", "node:1", "node:2"])
  let run = session.run.unwrap()
  assert_eq(run.floor, 0)
  assert_eq(run.player_hp, 96)
  assert_true(run.deck.contains(Body_Slam))
  assert_eq(agent_field(session.observe(), "revision"), Some((2).to_json()))
  assert_eq(session.step(2, "node:1"), Applied)
  assert_eq(run.battle.unwrap().player.block, 10)
}

///|
test "agent enumerates only affordable card and living target combinations" {
  let session = agent_test_battle(Ironclad)
  let b = session.run.unwrap().battle.unwrap()
  b.hand.clear()
  b.hand.append([Strike, Defend, Bash, Cleave, Disarm])
  b.player.energy = 1
  b.enemies.clear()
  b.enemies.append([
    spawn_enemy(GreenLouse),
    spawn_enemy(RedLouse),
    spawn_enemy(JawWorm),
  ])
  b.enemies[1].fighter.hp = 0
  assert_eq(agent_ids(session), [
    "play:0:0", "play:0:2", "play:1:-1", "play:3:-1", "play:4:0", "play:4:2", "end_turn",
  ])
  let before = session.observe()
  assert_eq(session.step(0, "play:2:0"), IllegalChoice)
  assert_eq(session.step(0, "play:0:1"), IllegalChoice)
  assert_eq(session.observe(), before)
}

///|
test "agent keeps zero cost corruption and X cost choices at zero energy" {
  let session = agent_test_battle(Ironclad)
  let b = session.run.unwrap().battle.unwrap()
  b.hand.clear()
  b.hand.append([Strike, Defend, Anger, Whirlwind])
  b.player.energy = 0
  b.powers.corruption = true
  let ids = agent_ids(session)
  assert_true(ids.contains("play:1:-1"))
  assert_true(ids.contains("play:2:0"))
  assert_true(ids.contains("play:3:-1"))
  assert_false(ids.contains("play:0:0"))
  assert_eq(session.step(0, "play:1:-1"), Applied)
  assert_eq(b.player.energy, 0)
  assert_true(b.exhaust_pile.contains(Defend))
}

///|
test "agent rejects a stale answer before hand indices can be reinterpreted" {
  let session = agent_test_battle(Ironclad)
  let b = session.run.unwrap().battle.unwrap()
  b.hand.clear()
  b.hand.append([Defend, Defend])
  assert_eq(session.step(0, "play:0:-1"), Applied)
  let after = session.observe()
  assert_eq(session.step(0, "play:0:-1"), StaleRevision)
  assert_eq(session.observe(), after)
  assert_eq(b.player.block, 6)
  assert_eq(b.hand.length(), 1)
}

///|
test "agent observations are detached and hide shuffle order and RNG internals" {
  let session = agent_test_battle(Ironclad)
  let b = session.run.unwrap().battle.unwrap()
  b.draw_pile.clear()
  b.draw_pile.append([Bash, Strike, Strike])
  let before = session.observe()
  let rng = b.rng_seed
  b.draw_pile.clear()
  b.draw_pile.append([Strike, Bash, Strike])
  assert_eq(session.observe(), before)
  assert_eq(b.rng_seed, rng)
  if before is Object(fields) {
    fields["revision"] = (99).to_json()
  }
  assert_eq(agent_field(session.observe(), "revision"), Some((0).to_json()))
  assert_false(session.observe().stringify().contains("rng_seed"))
  assert_false(session.observe().stringify().contains("pattern_index"))
}

///|
test "agent synchronous end turn matches the existing battle rules" {
  let session = agent_test_battle(Warden, seed=71)
  let control = RunState::start(Warden, Ascent, seed=71)
  end_player_turn(control.battle.unwrap())
  assert_eq(session.step(0, "end_turn"), Applied)
  let b = session.run.unwrap().battle.unwrap()
  let expected = control.battle.unwrap()
  assert_eq(b.player.hp, expected.player.hp)
  assert_eq(b.player.energy, expected.player.energy)
  assert_eq(b.hand, expected.hand)
  assert_eq(b.logs, expected.logs)
  assert_eq(b.rng_seed, expected.rng_seed)
}

///|
test "agent reward rest boss and terminal actions remain phase scoped" {
  let session = agent_test_battle(Ironclad)
  let run = session.run.unwrap()
  run.floor = 4
  run.battle.unwrap().phase = Victory
  assert_eq(agent_ids(session), ["continue"])
  assert_eq(session.step(0, "continue"), Applied)
  assert_eq(run.phase, CardReward)
  assert_true(agent_ids(session).contains("skip_reward"))
  assert_eq(session.step(1, "skip_reward"), Applied)
  assert_eq(run.phase, RestSite)
  assert_eq(agent_ids(session), ["rest"])
  assert_eq(session.step(2, "rest"), Applied)
  assert_eq(run.floor, 6)
  let boss = AgentSession::start(Warden, GuardianTrial)
  boss.run.unwrap().battle.unwrap().phase = Victory
  assert_eq(boss.step(0, "continue"), Applied)
  assert_eq(boss.run.unwrap().phase, RunVictory)
  assert_true(boss.choices().is_empty())
  assert_eq(agent_field(boss.observe(), "terminal"), Some(true.to_json()))
  assert_eq(boss.step(1, "end_turn"), Terminal)
}

///|
test "agent potions enumerate legal targets and consume exactly once" {
  let session = agent_test_battle(Ironclad)
  let run = session.run.unwrap()
  let b = run.battle.unwrap()
  run.potions.append([FirePotion, BlockPotion, FruitJuice])
  b.enemies.clear()
  b.enemies.append([spawn_enemy(GreenLouse), spawn_enemy(RedLouse)])
  b.enemies[1].fighter.hp = 0
  assert_true(agent_ids(session).contains("potion:0:0"))
  assert_true(agent_ids(session).contains("potion:1:-1"))
  assert_false(agent_ids(session).contains("potion:0:1"))
  assert_false(agent_ids(session).contains("potion:2:-1"))
  assert_eq(session.step(0, "potion:0:0"), Applied)
  assert_eq(run.potions, [BlockPotion, FruitJuice])
  assert_eq(b.phase, Victory)
  assert_eq(agent_ids(session), ["continue"])
}

///|
fn agent_test_battle(character : CharacterId, seed? : Int = 42) -> AgentSession {
  let session = AgentSession::start(character, GuardianTrial, seed~)
  session.run = Some(RunState::start(character, Ascent, seed~))
  session
}

///|
test "agent map events shops and relics expose the exact shared legal choices" {
  let session = AgentSession::start(Warden, Ascent)
  let run = session.run.unwrap()
  assert_eq(agent_ids(session), run_choices(run).map(c => c.id))
  assert_eq(session.step(0, "node:1"), Applied)
  assert_eq(run.phase, Battle)
  run.battle.unwrap().phase = Victory
  assert_eq(session.step(1, "continue"), Applied)
  assert_eq(session.step(2, "skip_reward"), Applied)
  assert_eq(run.phase, RouteMap)
  run.phase = ShopRoom
  run.shop = Some(ShopState::new(run))
  run.gold = 0
  assert_eq(agent_ids(session), ["leave_shop"])
  assert_eq(session.step(3, "buy:0"), IllegalChoice)
  run.gold = 300
  assert_eq(agent_ids(session), run_choices(run).map(c => c.id))
  assert_eq(session.step(3, "buy:0"), Applied)
  assert_false(agent_ids(session).contains("buy:0"))
  assert_eq(session.step(4, "leave_shop"), Applied)
  run.phase = EventRoom
  run.event = Some(HealingSpring)
  run.gold = 0
  assert_eq(agent_ids(session), ["event:0", "event:2"])
  assert_eq(session.step(5, "event:2"), Applied)
  open_treasure(run)
  assert_true(agent_ids(session).all(id => id.has_prefix("relic:")))
  assert_eq(session.step(6, "relic:0"), Applied)
  assert_eq(run.phase, RouteMap)
}
