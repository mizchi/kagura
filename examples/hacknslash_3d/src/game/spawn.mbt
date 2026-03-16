// Enemy spawning: room-based, with ranged and boss support

///|
pub fn make_enemy(
  cx : Double,
  cy : Double,
  kind : EnemyKind,
  hp : Int,
  speed : Double,
  size : Double,
  room_index~ : Int = -1,
) -> Enemy {
  {
    x: cx,
    y: cy,
    vx: 0.0,
    vy: 0.0,
    hp,
    max_hp: hp,
    speed,
    size,
    alive: true,
    damage_timer: 0,
    kind,
    path_cache: [],
    path_index: 0,
    path_timer: 0,
    shoot_cooldown: 0,
    pending_bolt_timer: 0,
    pending_bolt_target_x: cx,
    pending_bolt_target_y: cy,
    charge_timer: 0,
    charge_cooldown: 0,
    meteor_cast_timer: 0,
    meteor_target_x: cx,
    meteor_target_y: cy,
    beam_cast_timer: 0,
    beam_target_x: cx,
    beam_target_y: cy,
    room_index,
  }
}

///|
pub fn spawn_enemies_for_floor(
  rooms : Array[@terrain.Room],
  player_room_idx : Int,
  seed : Int,
  floor : Int,
) -> Array[Enemy] {
  spawn_enemies_for_floor_with_params(
    rooms,
    player_room_idx,
    seed,
    floor,
    BalanceParams::default(),
  )
}

///|
pub fn spawn_enemies_for_floor_with_params(
  rooms : Array[@terrain.Room],
  player_room_idx : Int,
  seed : Int,
  floor : Int,
  params : BalanceParams,
) -> Array[Enemy] {
  if floor > 1 && floor % 5 == 0 {
    return spawn_boss_with_params(rooms, player_room_idx, seed, floor, params)
  }
  spawn_enemies_in_rooms_with_params(
    rooms,
    player_room_idx,
    seed,
    params,
    floor~,
  )
}

///|
pub fn spawn_boss(
  rooms : Array[@terrain.Room],
  player_room_idx : Int,
  seed : Int,
  floor : Int,
) -> Array[Enemy] {
  spawn_boss_with_params(
    rooms,
    player_room_idx,
    seed,
    floor,
    BalanceParams::default(),
  )
}

///|
pub fn spawn_boss_with_params(
  rooms : Array[@terrain.Room],
  player_room_idx : Int,
  seed : Int,
  floor : Int,
  params : BalanceParams,
) -> Array[Enemy] {
  let enemies : Array[Enemy] = []
  let rng = @terrain.make_rng(seed.to_uint() + 7777)
  let mut best_idx = -1
  let mut best_area = 0
  for i = 0; i < rooms.length(); i = i + 1 {
    if i == player_room_idx {
      continue
    }
    let area = rooms[i].rect.w * rooms[i].rect.h
    if area > best_area {
      best_area = area
      best_idx = i
    }
  }
  if best_idx < 0 {
    best_idx = if rooms.length() > 1 { 1 } else { 0 }
  }
  let room = rooms[best_idx]
  let cx = room.rect.x.to_double() * tile_size +
    room.rect.w.to_double() / 2.0 * tile_size +
    tile_size / 2.0
  let cy = room.rect.y.to_double() * tile_size +
    room.rect.h.to_double() / 2.0 * tile_size +
    tile_size / 2.0
  let boss_hp = params.scale_enemy_hp_for_floor(
    params.boss_hp_base.to_int() + floor * params.boss_hp_per_floor.to_int(),
    floor,
  )
  let boss_speed = params.scale_enemy_speed_for_floor(0.6, floor)
  enemies.push(make_enemy(cx, cy, Boss, boss_hp, boss_speed, 20.0))
  for _i = 0; _i < 2; _i = _i + 1 {
    let mx = room.rect.x.to_double() * tile_size +
      rng.rand_range(1, room.rect.w - 1).to_double() * tile_size +
      tile_size / 2.0
    let my = room.rect.y.to_double() * tile_size +
      rng.rand_range(1, room.rect.h - 1).to_double() * tile_size +
      tile_size / 2.0
    enemies.push(
      make_enemy(
        mx,
        my,
        Basic,
        params.scale_enemy_hp_for_floor(params.basic_hp.to_int(), floor),
        params.scale_enemy_speed_for_floor(params.enemy_speed_basic, floor),
        10.0,
      ),
    )
  }
  enemies
}

///|
pub fn spawn_enemies_in_rooms(
  rooms : Array[@terrain.Room],
  player_room_idx : Int,
  seed : Int,
) -> Array[Enemy] {
  spawn_enemies_in_rooms_with_params(
    rooms,
    player_room_idx,
    seed,
    BalanceParams::default(),
  )
}

///|
///|
fn pick_enemy_type(rng : @terrain.RNG) -> EnemyTypeConfig {
  let configs = enemy_type_configs()
  let mut total_weight = 0
  for config in configs {
    total_weight = total_weight + config.spawn_weight
  }
  let roll = rng.next_int(total_weight)
  let mut acc = 0
  for config in configs {
    acc = acc + config.spawn_weight
    if roll < acc {
      return config
    }
  }
  configs[0]
}

///|
pub fn spawn_enemies_in_rooms_with_params(
  rooms : Array[@terrain.Room],
  player_room_idx : Int,
  seed : Int,
  params : BalanceParams,
  floor? : Int = 1,
) -> Array[Enemy] {
  let enemies : Array[Enemy] = []
  let rng = @terrain.make_rng(seed.to_uint() + 7777)
  // Safe zone: player room + nearby rooms (within distance threshold)
  let player_room_center = if player_room_idx >= 0 &&
    player_room_idx < rooms.length() {
    let r = rooms[player_room_idx].rect
    (r.x + r.w / 2, r.y + r.h / 2)
  } else {
    (0, 0)
  }
  let safe_distance = spawn_safe_distance
  // Find largest non-player room for elite/mini-boss placement
  let mut largest_room_idx = -1
  let mut largest_area = 0
  for i = 0; i < rooms.length(); i = i + 1 {
    if i == player_room_idx {
      continue
    }
    let rc = rooms[i].rect
    let rcx = rc.x + rc.w / 2
    let rcy = rc.y + rc.h / 2
    let dx = (rcx - player_room_center.0).abs()
    let dy = (rcy - player_room_center.1).abs()
    if dx + dy < safe_distance {
      continue // too close to player start
    }
    let area = rc.w * rc.h
    if area > largest_area {
      largest_area = area
      largest_room_idx = i
    }
  }
  for i = 0; i < rooms.length(); i = i + 1 {
    if i == player_room_idx {
      continue
    }
    // Skip rooms in safe zone near player spawn
    let rc = rooms[i].rect
    let rcx = rc.x + rc.w / 2
    let rcy = rc.y + rc.h / 2
    let dx = (rcx - player_room_center.0).abs()
    let dy = (rcy - player_room_center.1).abs()
    if dx + dy < safe_distance {
      continue
    }
    let room = rooms[i]
    let area = room.rect.w * room.rect.h
    let base_count = @cmp.minimum(
      spawn_base_count_max,
      @cmp.maximum(1, area / spawn_area_divisor),
    )
    let large_room_bonus = if area >= 100 {
      params.pack_large_room_bonus
    } else {
      0.0
    }
    let count = @cmp.maximum(
      1,
      (base_count.to_double() * params.spawn_density * (1.0 + large_room_bonus)).to_int(),
    )
    // Place mini-boss in largest room (every floor)
    if i == largest_room_idx {
      let bcx = room.rect.x.to_double() * tile_size +
        (room.rect.w.to_double() / 2.0) * tile_size +
        tile_size / 2.0
      let bcy = room.rect.y.to_double() * tile_size +
        (room.rect.h.to_double() / 2.0) * tile_size +
        tile_size / 2.0
      let mini_boss_hp = params.scale_enemy_hp_for_floor(
        params.boss_hp_base.to_int() / 2 +
        floor * (params.boss_hp_per_floor.to_int() / 2),
        floor,
      )
      let mini_boss_speed = params.scale_enemy_speed_for_floor(0.5, floor)
      enemies.push(make_enemy(bcx, bcy, Boss, mini_boss_hp, mini_boss_speed, 16.0, room_index=i))
    }
    for _j = 0; _j < count; _j = _j + 1 {
      let cx = room.rect.x.to_double() * tile_size +
        rng.rand_range(1, room.rect.w - 1).to_double() * tile_size +
        tile_size / 2.0
      let cy = room.rect.y.to_double() * tile_size +
        rng.rand_range(1, room.rect.h - 1).to_double() * tile_size +
        tile_size / 2.0
      // Pick enemy type from weighted config table
      let config = pick_enemy_type(rng)
      let base_hp = (params.basic_hp * config.hp_param).to_int().max(1)
      let hp = params.scale_enemy_hp_for_floor(base_hp, floor)
      let spd = params.scale_enemy_speed_for_floor(
        params.enemy_speed_basic * config.speed_param,
        floor,
      )
      let kind = config.kind
      let sz = config.size
      enemies.push(make_enemy(cx, cy, kind, hp, spd, sz, room_index=i))
    }
    // Large rooms (area >= 120): add elite guards for bonus challenge
    if area >= 120 && i != largest_room_idx {
      let elite_count = @cmp.minimum(3, area / 80)
      for _e = 0; _e < elite_count; _e = _e + 1 {
        let ecx = room.rect.x.to_double() * tile_size +
          rng.rand_range(2, room.rect.w - 2).to_double() * tile_size +
          tile_size / 2.0
        let ecy = room.rect.y.to_double() * tile_size +
          rng.rand_range(2, room.rect.h - 2).to_double() * tile_size +
          tile_size / 2.0
        // Elite: Tank with boosted HP
        let elite_hp = params.scale_enemy_hp_for_floor(
          (params.basic_hp * 3.0).to_int().max(3),
          floor,
        )
        let elite_spd = params.scale_enemy_speed_for_floor(
          params.enemy_speed_basic * 0.7,
          floor,
        )
        enemies.push(make_enemy(ecx, ecy, Tank, elite_hp, elite_spd, 14.0, room_index=i))
      }
    }
  }
  enemies
}
