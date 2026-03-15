// Enemy spawning: room-based, with ranged and boss support

///|
pub fn make_enemy(
  cx : Double,
  cy : Double,
  kind : EnemyKind,
  hp : Int,
  speed : Double,
  size : Double,
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
pub fn spawn_enemies_in_rooms_with_params(
  rooms : Array[@terrain.Room],
  player_room_idx : Int,
  seed : Int,
  params : BalanceParams,
  floor? : Int = 1,
) -> Array[Enemy] {
  let enemies : Array[Enemy] = []
  let rng = @terrain.make_rng(seed.to_uint() + 7777)
  // Find largest non-player room for elite/mini-boss placement
  let mut largest_room_idx = -1
  let mut largest_area = 0
  for i = 0; i < rooms.length(); i = i + 1 {
    if i == player_room_idx {
      continue
    }
    let area = rooms[i].rect.w * rooms[i].rect.h
    if area > largest_area {
      largest_area = area
      largest_room_idx = i
    }
  }
  for i = 0; i < rooms.length(); i = i + 1 {
    if i == player_room_idx {
      continue
    }
    let room = rooms[i]
    let area = room.rect.w * room.rect.h
    let base_count = @cmp.minimum(3, @cmp.maximum(1, area / 20))
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
      enemies.push(make_enemy(bcx, bcy, Boss, mini_boss_hp, mini_boss_speed, 16.0))
    }
    for _j = 0; _j < count; _j = _j + 1 {
      let cx = room.rect.x.to_double() * tile_size +
        rng.rand_range(1, room.rect.w - 1).to_double() * tile_size +
        tile_size / 2.0
      let cy = room.rect.y.to_double() * tile_size +
        rng.rand_range(1, room.rect.h - 1).to_double() * tile_size +
        tile_size / 2.0
      let kind_roll = rng.next_int(20)
      let (kind, hp, spd, sz) = if kind_roll < 5 {
        (
          Basic,
          params.scale_enemy_hp_for_floor(params.basic_hp.to_int(), floor),
          params.scale_enemy_speed_for_floor(params.enemy_speed_basic, floor),
          10.0,
        )
      } else if kind_roll < 8 {
        (
          Fast,
          params.scale_enemy_hp_for_floor(params.fast_hp.to_int(), floor),
          params.scale_enemy_speed_for_floor(params.enemy_speed_fast, floor),
          8.0,
        )
      } else if kind_roll < 10 {
        (
          Tank,
          params.scale_enemy_hp_for_floor(params.tank_hp.to_int(), floor),
          params.scale_enemy_speed_for_floor(params.enemy_speed_tank, floor),
          14.0,
        )
      } else if kind_roll < 12 {
        (
          Ranged,
          params.scale_enemy_hp_for_floor(params.ranged_hp.to_int(), floor),
          params.scale_enemy_speed_for_floor(0.5, floor),
          8.0,
        )
      } else if kind_roll < 14 {
        // Exploder: fast, fragile, deadly on death
        (
          Exploder,
          params.scale_enemy_hp_for_floor(params.fast_hp.to_int(), floor),
          params.scale_enemy_speed_for_floor(params.enemy_speed_fast * 1.2, floor),
          7.0,
        )
      } else if kind_roll < 16 {
        // Berserker: medium HP, gets stronger as hurt
        (
          Berserker,
          params.scale_enemy_hp_for_floor(params.tank_hp.to_int(), floor),
          params.scale_enemy_speed_for_floor(params.enemy_speed_basic, floor),
          12.0,
        )
      } else if kind_roll < 17 {
        // Summoner: squishy, spawns minions
        (
          Summoner,
          params.scale_enemy_hp_for_floor(params.ranged_hp.to_int(), floor),
          params.scale_enemy_speed_for_floor(0.4, floor),
          9.0,
        )
      } else if kind_roll < 18 {
        // Teleporter: appears behind you
        (
          Teleporter,
          params.scale_enemy_hp_for_floor(params.fast_hp.to_int(), floor),
          params.scale_enemy_speed_for_floor(params.enemy_speed_basic, floor),
          8.0,
        )
      } else {
        // Swarm: tiny and weak but numerous
        (
          Swarm,
          params.scale_enemy_hp_for_floor(1, floor),
          params.scale_enemy_speed_for_floor(params.enemy_speed_fast, floor),
          5.0,
        )
      }
      enemies.push(make_enemy(cx, cy, kind, hp, spd, sz))
    }
  }
  enemies
}
