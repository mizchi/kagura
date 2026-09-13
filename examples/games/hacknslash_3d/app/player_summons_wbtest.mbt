///|
test "summoner loadout exposes both casts and saves skills without live companions" {
  let s = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  s.world.apply_archetype(@game.CharacterArchetype::Summoner)
  s.world.mode = @game.Playing
  assert_eq(s.hunter_preset_skills()[0].hold, "skull")
  assert_eq(s.hunter_preset_skills()[1].name, "ゾンビ召喚")
  assert_true(
    s
    .hunter_tree_nodes()
    .any(n => n.name == "炎の頭蓋" && n.kind == "発動技"),
  )
  s.update(@core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [50]))
  for _ in 0..<20 {
    s.update(@core.empty_input_snapshot())
  }
  assert_eq(s.world.summons.zombies.length(), 1)
  let restored = GameState::new_with_params(
    seed=9,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  assert_true(restored.restore_save(s.serialize_save()))
  assert_eq(restored.world.hunter_slots, [57, 48, 52, 86])
  assert_eq(restored.world.skills.get_level(@game.SummonFlamingSkull), 1)
  assert_eq(restored.world.summons.zombies.length(), 0)
}

///|
test "held skull slot repeats and pause freezes lifetime and casting" {
  let s = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  s.world.apply_archetype(@game.CharacterArchetype::Summoner)
  s.world.mode = @game.Playing
  s.world.enemies.clear()
  let input = @core.new_input_snapshot(0.0, 0.0, 0.0, 0.0, [49])
  for _ in 0..<150 {
    s.update(input)
  }
  assert_true(s.world.summons.skulls.length() >= 3)
  let age = s.world.summons.skulls[0].age
  s.paused = true
  for _ in 0..<30 {
    s.update(input)
  }
  assert_eq(s.world.summons.skulls[0].age, age)
}

///|
test "summoned creatures batch shared meshes without CPU skinning" {
  let s = GameState::new_with_params(
    seed=42,
    @game.BalanceParams::default(),
    hunting_grounds=true,
  )
  s.world.apply_archetype(@game.CharacterArchetype::Summoner)
  s.world.mode = @game.Playing
  s.world.enemies.clear()
  for
    kind in [
      @game.RaiseZombieArt,
      @game.RaiseZombieArt,
      @game.FlamingSkullArt,
      @game.FlamingSkullArt,
      @game.FlamingSkullArt,
      @game.FlamingSkullArt,
    ] {
    s.world.cancel_hunter_action()
    s.world.summons.zombie_cooldown = 0
    s.world.summons.skull_cooldown = 0
    assert_true(s.world.request_hunter_spell(kind))
    for _ in 0..<18 {
      s.world.tick_hunter_arts(s.world.dungeon.grid)
    }
  }
  for skull in s.world.summons.skulls {
    skull.age = 12
  }
  let commands = s.draw_playing(test_engine_context())
  assert_true(
    commands.filter(c => c.instance_count == 4).length() >=
    flaming_skull_mesh.parts.length(),
  )
  assert_eq(s.enemy_models.zombie.active_keys.length(), 1)
  for part in zombie_mesh.parts {
    assert_eq(part.geometry.cpu_skin_count(), 0)
  }
  assert_true(flaming_skull_mesh.geometry.bind_mesh.vertex_count() < 2000)
  s.world.summons.clear()
  ignore(s.draw_playing(test_engine_context()))
  assert_eq(s.enemy_models.zombie.active_keys.length(), 0)
}
