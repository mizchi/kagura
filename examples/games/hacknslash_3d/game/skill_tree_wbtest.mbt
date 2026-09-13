///|
test "hunter tree spends points atomically, enforces prerequisites and updates combat stats" {
  let world = GameWorld::new(seed=42, hunting_grounds=true)
  world.mode = Playing
  world.ui_mode = Skills
  assert_eq(world.skills.skill_points, 3)
  let hp = world.player_stats.max_hp
  assert_false(world.allocate_skill(LifeSteal))
  assert_eq(world.skills.skill_points, 3)
  assert_true(world.allocate_skill(Vitality))
  assert_eq(world.player_stats.max_hp, hp + 3)
  assert_true(world.allocate_skill(CriticalHit))
  assert_eq(world.skills.skill_points, 0)
  assert_false(world.allocate_skill(LifeSteal))
  world.skills.skill_points = 3
  assert_true(world.allocate_skill(LifeSteal))
  assert_true(world.player_stats.life_steal > 0.0)
  world.skills.skill_points = 20
  for _ in 0..<4 {
    assert_true(world.allocate_skill(Vitality))
  }
  let points = world.skills.skill_points
  assert_false(world.allocate_skill(Vitality))
  assert_eq(world.skills.skill_points, points)
  world.ui_mode = UIMode::None
  assert_false(world.allocate_skill(DashMastery))
}

///|
test "counter ranks shorten the actual stance cooldown" {
  let world = GameWorld::new(seed=42, hunting_grounds=true)
  world.mode = Playing
  world.ui_mode = Skills
  world.skills.skill_points = 6
  for _ in 0..<3 {
    assert_true(world.allocate_skill(Counter))
  }
  world.ui_mode = UIMode::None
  activate_skill(world, 7)
  assert_eq(world.player.counter_cooldown_timer, 240)
}

///|
test "hunter tree allows hybrid paths and replenishes points only when leveling" {
  let world = GameWorld::new(seed=42, hunting_grounds=true, archetype=Melee)
  world.mode = Playing
  world.ui_mode = Skills
  assert_true(world.allocate_skill(FireMastery))
  let points = world.skills.skill_points
  ignore(
    world.level_progress.add_xp(
      world.skills,
      Melee,
      ArchetypeAligned,
      100,
      17,
      world.params.levelup_config(),
    ),
  )
  let earned = world.level_progress.level - 1
  assert_true(earned > 1)
  assert_eq(world.skills.skill_points, points + earned)
  ignore(
    world.level_progress.add_xp(
      world.skills,
      Melee,
      ArchetypeAligned,
      0,
      17,
      world.params.levelup_config(),
    ),
  )
  assert_eq(world.skills.skill_points, points + earned)
  assert_true(world.apply_levelup_offer_choice(0, 17))
  assert_eq(world.skills.skill_points, points + earned)
}

///|
test "buying a pending level reward cannot strand a maxed offer" {
  let world = GameWorld::new(seed=42, hunting_grounds=true)
  world.mode = Playing
  world.ui_mode = Skills
  world.skills.find(Vitality).unwrap().level = 4
  world.level_progress.pending_choices = 1
  world.level_progress.current_offers = [Vitality]
  assert_true(world.allocate_skill(Vitality))
  assert_false(world.level_progress.current_offers.contains(Vitality))
  assert_true(world.apply_levelup_offer_choice(0, 17))
}
