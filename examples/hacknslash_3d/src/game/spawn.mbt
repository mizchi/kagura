// Enemy spawning: room-based, with ranged and boss support

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
    charge_timer: 0,
    charge_cooldown: 0,
  }
}

pub fn spawn_enemies_for_floor(
  rooms : Array[@terrain.Room],
  player_room_idx : Int,
  seed : Int,
  floor : Int,
) -> Array[Enemy] {
  spawn_enemies_for_floor_with_params(rooms, player_room_idx, seed, floor, BalanceParams::default())
}

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
  spawn_enemies_in_rooms_with_params(rooms, player_room_idx, seed, params)
}

pub fn spawn_boss(
  rooms : Array[@terrain.Room],
  player_room_idx : Int,
  seed : Int,
  floor : Int,
) -> Array[Enemy] {
  spawn_boss_with_params(rooms, player_room_idx, seed, floor, BalanceParams::default())
}

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
    (room.rect.w.to_double() / 2.0) * tile_size + tile_size / 2.0
  let cy = room.rect.y.to_double() * tile_size +
    (room.rect.h.to_double() / 2.0) * tile_size + tile_size / 2.0
  let boss_hp = params.boss_hp_base.to_int() + floor * params.boss_hp_per_floor.to_int()
  enemies.push(make_enemy(cx, cy, Boss, boss_hp, 0.6, 20.0))
  for _i = 0; _i < 2; _i = _i + 1 {
    let mx = room.rect.x.to_double() * tile_size +
      rng.rand_range(1, room.rect.w - 1).to_double() * tile_size + tile_size / 2.0
    let my = room.rect.y.to_double() * tile_size +
      rng.rand_range(1, room.rect.h - 1).to_double() * tile_size + tile_size / 2.0
    enemies.push(make_enemy(mx, my, Basic, params.basic_hp.to_int(), params.enemy_speed_basic, 10.0))
  }
  enemies
}

pub fn spawn_enemies_in_rooms(
  rooms : Array[@terrain.Room],
  player_room_idx : Int,
  seed : Int,
) -> Array[Enemy] {
  spawn_enemies_in_rooms_with_params(rooms, player_room_idx, seed, BalanceParams::default())
}

pub fn spawn_enemies_in_rooms_with_params(
  rooms : Array[@terrain.Room],
  player_room_idx : Int,
  seed : Int,
  params : BalanceParams,
) -> Array[Enemy] {
  let enemies : Array[Enemy] = []
  let rng = @terrain.make_rng(seed.to_uint() + 7777)
  for i = 0; i < rooms.length(); i = i + 1 {
    if i == player_room_idx {
      continue
    }
    let room = rooms[i]
    let area = room.rect.w * room.rect.h
    let base_count = @cmp.minimum(3, @cmp.maximum(1, area / 20))
    let count = @cmp.maximum(1, (base_count.to_double() * params.spawn_density).to_int())
    for _j = 0; _j < count; _j = _j + 1 {
      let cx = room.rect.x.to_double() * tile_size +
        rng.rand_range(1, room.rect.w - 1).to_double() * tile_size +
        tile_size / 2.0
      let cy = room.rect.y.to_double() * tile_size +
        rng.rand_range(1, room.rect.h - 1).to_double() * tile_size +
        tile_size / 2.0
      let kind_roll = rng.next_int(10)
      let (kind, hp, spd, sz) = if kind_roll < 4 {
        (Basic, params.basic_hp.to_int(), params.enemy_speed_basic, 10.0)
      } else if kind_roll < 7 {
        (Fast, params.fast_hp.to_int(), params.enemy_speed_fast, 8.0)
      } else if kind_roll < 9 {
        (Tank, params.tank_hp.to_int(), params.enemy_speed_tank, 14.0)
      } else {
        (Ranged, params.ranged_hp.to_int(), 0.5, 8.0)
      }
      enemies.push(make_enemy(cx, cy, kind, hp, spd, sz))
    }
  }
  enemies
}
