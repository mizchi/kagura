///|
fn enemy_overlap_pair_count(enemies : Array[Enemy]) -> Int {
  let mut count = 0
  for i = 0; i < enemies.length(); i = i + 1 {
    let a = enemies[i]
    if not(a.alive) {
      continue
    }
    for j = i + 1; j < enemies.length(); j = j + 1 {
      let b = enemies[j]
      if not(b.alive) {
        continue
      }
      let dx = a.x - b.x
      let dy = a.y - b.y
      let min_dist = (a.size + b.size) / 2.0
      if dx * dx + dy * dy < min_dist * min_dist {
        count = count + 1
      }
    }
  }
  count
}

///|
fn find_same_room_point_near_distance(
  world : GameWorld,
  target_dist : Double,
) -> (Double, Double) {
  let room_idx = find_room_at(
    world.dungeon.rooms,
    world.player.x,
    world.player.y,
  )
  let room = world.dungeon.rooms[room_idx]
  let mut best_x = world.player.x
  let mut best_y = world.player.y
  let mut best_err = 1000000000.0
  for tx in (room.rect.x + 1)..<(room.rect.x + room.rect.w - 1) {
    for ty in (room.rect.y + 1)..<(room.rect.y + room.rect.h - 1) {
      let x = tx.to_double() * tile_size + tile_size * 0.5
      let y = ty.to_double() * tile_size + tile_size * 0.5
      let dx = x - world.player.x
      let dy = y - world.player.y
      let err = ((dx * dx + dy * dy).sqrt() - target_dist).abs()
      if err < best_err {
        best_err = err
        best_x = x
        best_y = y
      }
    }
  }
  (best_x, best_y)
}

///|
fn unlock_spell_for_world_test(world : GameWorld, id : SkillId) -> Unit {
  ignore(world.skills.learn_from_levelup(id))
}

///|
test "enemy separation grid index clamps into 2d bounds" {
  let cols = enemy_separation_grid_cols()
  let rows = enemy_separation_grid_rows()
  let start = enemy_separation_grid_index(-10.0, -10.0, cols, rows)
  let end = enemy_separation_grid_index(10000.0, 10000.0, cols, rows)
  assert_eq(start, 0)
  assert_eq(end, cols * rows - 1)
}

///|
test "enemy separation grid index changes by row and column" {
  let cols = enemy_separation_grid_cols()
  let rows = enemy_separation_grid_rows()
  let a = enemy_separation_grid_index(0.0, 0.0, cols, rows)
  let b = enemy_separation_grid_index(20.0, 0.0, cols, rows)
  let c = enemy_separation_grid_index(0.0, 20.0, cols, rows)
  assert_eq(b, a + 1)
  assert_eq(c, a + cols)
}

///|
test "resolve_enemy_enemy_separation reduces overlap count in dense cluster" {
  let world = GameWorld::new(seed=42)
  let px = world.player.x
  let py = world.player.y
  world.enemies = [
    make_enemy(px, py, Basic, 3, 1.0, 10.0),
    make_enemy(px + 1.0, py, Fast, 2, 1.0, 8.0),
    make_enemy(px + 2.0, py, Tank, 5, 1.0, 14.0),
  ]
  let before = enemy_overlap_pair_count(world.enemies)
  world.resolve_enemy_enemy_separation()
  let after = enemy_overlap_pair_count(world.enemies)
  assert_true(before > after)
}

///|
test "resolve_enemy_enemy_separation keeps distant enemies unchanged" {
  let world = GameWorld::new(seed=42)
  let px = world.player.x
  let py = world.player.y
  world.enemies = [
    make_enemy(px, py, Basic, 3, 1.0, 10.0),
    make_enemy(px + 64.0, py + 64.0, Fast, 2, 1.0, 8.0),
  ]
  let before0 = world.enemies[0].x
  let before1 = world.enemies[1].x
  world.resolve_enemy_enemy_separation()
  assert_eq(enemy_overlap_pair_count(world.enemies), 0)
  assert_eq(world.enemies[0].x, before0)
  assert_eq(world.enemies[1].x, before1)
}

///|
test "tick_projectiles_phase applies enemy projectile damage and compacts" {
  let world = GameWorld::new(seed=42)
  let before_hp = world.player.hp
  world.projectiles = [
    {
      x: world.player.x,
      y: world.player.y,
      vx: 0.0,
      vy: 0.0,
      age: 0,
      alive: true,
      damage: 2,
      is_player: false,
      kind: EnemyBolt,
    },
  ]
  world.tick_projectiles_phase()
  assert_true(world.player.hp < before_hp)
  assert_eq(world.projectiles.length(), 0)
}

///|
test "tick_projectiles_phase removes projectile that crosses wall in one frame" {
  let world = GameWorld::new(seed=42)
  let px = world.player.x
  let py = world.player.y
  let start_col = (px / tile_size).to_int()
  let row = (py / tile_size).to_int()
  world.dungeon.grid.set(start_col + 1, row, @terrain.Wall)
  world.projectiles = [
    {
      x: px,
      y: py,
      vx: tile_size * 2.5,
      vy: 0.0,
      age: 0,
      alive: true,
      damage: 2,
      is_player: false,
      kind: EnemyBolt,
    },
  ]

  world.tick_projectiles_phase()

  assert_eq(world.projectiles.length(), 0)
}

///|
test "tick_enemy_movement_and_contact_phase applies contact damage once" {
  let world = GameWorld::new(seed=42)
  let before_hp = world.player.hp
  world.enemies = [
    make_enemy(world.player.x, world.player.y, Basic, 3, 1.0, 10.0),
    make_enemy(world.player.x + 1.0, world.player.y, Fast, 2, 1.0, 8.0),
  ]
  world.tick_enemy_movement_and_contact_phase()
  assert_true(world.player.hp < before_hp)
  assert_true(world.player.iframe_timer > 0)
}

///|
test "tick_items_phase collects score item and compacts" {
  let world = GameWorld::new(seed=42)
  let before_score = world.score
  world.items = [
    {
      x: world.player.x,
      y: world.player.y,
      vx: 0.0,
      vy: 0.0,
      kind: Score,
      alive: true,
      spawn_frame: world.frame_count,
    },
  ]
  world.tick_items_phase()
  assert_eq(world.score, before_score + 5)
  assert_eq(world.items.length(), 0)
}

///|
test "GameWorld::new marks only the start room as discovered" {
  let world = GameWorld::new(seed=42)
  let start_room = find_room_at(
    world.dungeon.rooms,
    world.player.x,
    world.player.y,
  )
  let mut discovered_count = 0
  for i in 0..<world.discovered_rooms.length() {
    if world.discovered_rooms[i] {
      discovered_count += 1
      assert_eq(i, start_room)
    }
  }
  assert_eq(discovered_count, 1)
}

///|
test "tick marks the entered room as discovered" {
  let world = GameWorld::new(seed=42)
  let start_room = find_room_at(
    world.dungeon.rooms,
    world.player.x,
    world.player.y,
  )
  let mut target_room = -1
  for i in 0..<world.dungeon.rooms.length() {
    if i != start_room {
      target_room = i
      break
    }
  }
  let center = world.dungeon.rooms[target_room].rect.center()
  world.player.x = center.x.to_double() * tile_size + tile_size * 0.5
  world.player.y = center.y.to_double() * tile_size + tile_size * 0.5

  world.tick(0.0, 0.0)

  assert_true(world.discovered_rooms[target_room])
}

///|
test "tick_items_phase in auto_play replaces oldest inventory item and auto equips stronger pickup" {
  let world = GameWorld::new(seed=42)
  world.auto_play = true
  let old_weapon : ItemData = {
    name: "Old Weapon",
    rarity: Common,
    slot: Weapon,
    atk_bonus: 1,
    def_bonus: 0,
    hp_bonus: 0,
    str_bonus: 0,
    int_bonus: 0,
    dex_bonus: 0,
    str_scaling: 0.0,
    int_scaling: 0.0,
    dex_scaling: 0.0,
    prefix: None,
    suffix: None,
    icon_id: 0,
  }
  let old_armor : ItemData = {
    name: "Old Armor",
    rarity: Common,
    slot: Armor,
    atk_bonus: 0,
    def_bonus: 1,
    hp_bonus: 0,
    str_bonus: 0,
    int_bonus: 0,
    dex_bonus: 0,
    str_scaling: 0.0,
    int_scaling: 0.0,
    dex_scaling: 0.0,
    prefix: None,
    suffix: None,
    icon_id: 1,
  }
  ignore(world.inventory.add_fifo(old_weapon))
  ignore(world.inventory.add_fifo(old_armor))
  for i in 0..<(world.inventory.capacity - 2) {
    ignore(
      world.inventory.add_fifo({
        name: "Filler \{i}",
        rarity: Common,
        slot: Accessory,
        atk_bonus: 0,
        def_bonus: 0,
        hp_bonus: 1,
        str_bonus: 0,
        int_bonus: 0,
        dex_bonus: 0,
        str_scaling: 0.0,
        int_scaling: 0.0,
        dex_scaling: 0.0,
        prefix: None,
        suffix: None,
        icon_id: 10 + i,
      }),
    )
  }
  ignore(
    world.equipment.equip({
      name: "Weak Sword",
      rarity: Common,
      slot: Weapon,
      atk_bonus: 2,
      def_bonus: 0,
      hp_bonus: 0,
      str_bonus: 0,
      int_bonus: 0,
      dex_bonus: 0,
      str_scaling: 0.0,
      int_scaling: 0.0,
      dex_scaling: 0.0,
      prefix: None,
      suffix: None,
      icon_id: 2,
    }),
  )
  world.items = [
    {
      x: world.player.x,
      y: world.player.y,
      vx: 0.0,
      vy: 0.0,
      kind: Equipment({
        name: "Strong Sword",
        rarity: Rare,
        slot: Weapon,
        atk_bonus: 6,
        def_bonus: 0,
        hp_bonus: 0,
        str_bonus: 0,
        int_bonus: 0,
        dex_bonus: 0,
        str_scaling: 0.0,
        int_scaling: 0.0,
        dex_scaling: 0.0,
        prefix: Some({
          name: "Keen",
          atk: 1,
          def: 0,
          hp: 0,
          crit: 0.02,
          life_steal: 0.0,
          speed_bonus: 0.0,
          cooldown_reduction: 0.0,
          str_bonus: 0,
          int_bonus: 0,
          dex_bonus: 0,
          str_scaling: 0.0,
          int_scaling: 0.0,
          dex_scaling: 0.0,
        }),
        suffix: None,
        icon_id: 3,
      }),
      alive: true,
      spawn_frame: world.frame_count,
    },
  ]

  world.tick_items_phase()

  let equipped = match world.equipment.weapon {
    Some(item) => item
    None => panic()
  }
  assert_eq(equipped.name, "Strong Sword")
  assert_eq(world.inventory.count(), world.inventory.capacity)
  let inv0 = match world.inventory.items[0] {
    Some(item) => item.name
    None => panic()
  }
  assert_eq(inv0, "Old Armor")
  let inv_last = match world.inventory.items[world.inventory.capacity - 1] {
    Some(item) => item.name
    None => panic()
  }
  assert_eq(inv_last, "Weak Sword")
  assert_eq(world.items.length(), 0)
}

///|
test "spawn_enemies_for_floor_with_params scales hp and speed on deeper floors" {
  let world = GameWorld::new(seed=42)
  let params = {
    ..BalanceParams::default(),
    enemy_hp_floor_scale: 0.2,
    enemy_speed_floor_scale: 0.05,
  }
  let enemies_floor_1 = spawn_enemies_for_floor_with_params(
    world.dungeon.rooms,
    0,
    42,
    1,
    params,
  )
  let enemies_floor_4 = spawn_enemies_for_floor_with_params(
    world.dungeon.rooms,
    0,
    42,
    4,
    params,
  )
  assert_true(enemies_floor_1.length() > 0)
  assert_eq(enemies_floor_1.length(), enemies_floor_4.length())
  assert_true(enemies_floor_4[0].max_hp > enemies_floor_1[0].max_hp)
  assert_true(enemies_floor_4[0].speed > enemies_floor_1[0].speed)
}

///|
test "tick auto-casts ice nova for nearby enemy" {
  let world = GameWorld::new(seed=42)
  unlock_spell_for_world_test(world, IceNova)
  let (ex, ey) = find_same_room_point_near_distance(world, 24.0)
  world.attack_timer = 999
  world.enemies = [make_enemy(ex, ey, Basic, 12, 1.0, 10.0)]

  world.tick(0.0, 0.0)

  assert_true(world.ice_nova_cooldown_timer > 0)
}

///|
test "tick auto-casts chain lightning for mid-range enemy" {
  let world = GameWorld::new(seed=42)
  unlock_spell_for_world_test(world, ChainLightning)
  let (ex, ey) = find_same_room_point_near_distance(world, 88.0)
  world.attack_timer = 999
  world.enemies = [make_enemy(ex, ey, Basic, 12, 1.0, 10.0)]

  world.tick(0.0, 0.0)

  assert_true(world.chain_lightning_cooldown_timer > 0)
}

///|
test "tick auto-casts splitting fireball for far visible enemy" {
  let world = GameWorld::new(seed=42)
  unlock_spell_for_world_test(world, SplittingFireball)
  let (ex, ey) = find_same_room_point_near_distance(world, 152.0)
  world.attack_timer = 999
  world.homing_missile_cooldown_timer = 10
  world.enemies = [make_enemy(ex, ey, Basic, 12, 1.0, 10.0)]

  world.tick(0.0, 0.0)

  assert_true(world.splitting_fireball_cooldown_timer > 0)
  assert_true(world.homing_missile_cooldown_timer > 0)
}

///|
test "tick auto-casts homing missile for semi-far visible enemy" {
  let world = GameWorld::new(seed=42)
  unlock_spell_for_world_test(world, HomingMissile)
  let (ex, ey) = find_same_room_point_near_distance(world, 132.0)
  world.attack_timer = 999
  world.enemies = [make_enemy(ex, ey, Basic, 12, 1.0, 10.0)]

  world.tick(0.0, 0.0)

  assert_true(world.homing_missile_cooldown_timer > 0)
  assert_eq(world.splitting_fireball_cooldown_timer, 0)
}

///|
test "tick does not auto-cast locked spells" {
  let world = GameWorld::new(seed=42)
  let (ex, ey) = find_same_room_point_near_distance(world, 88.0)
  world.attack_timer = 999
  world.enemies = [make_enemy(ex, ey, Basic, 12, 1.0, 10.0)]

  world.tick(0.0, 0.0)

  assert_eq(world.chain_lightning_cooldown_timer, 0)
  assert_eq(world.splitting_fireball_cooldown_timer, 0)
  assert_eq(world.ice_nova_cooldown_timer, 0)
  assert_eq(world.homing_missile_cooldown_timer, 0)
}
