// Enemy spawning: room-based

fn spawn_enemies_in_rooms(
  rooms : Array[@terrain.Room],
  player_room_idx : Int,
  seed : Int,
) -> Array[Enemy] {
  let enemies : Array[Enemy] = []
  let rng = @terrain.make_rng(seed.to_uint() + 7777)
  for i = 0; i < rooms.length(); i = i + 1 {
    if i == player_room_idx {
      continue
    }
    let room = rooms[i]
    let area = room.rect.w * room.rect.h
    let count = @cmp.minimum(3, @cmp.maximum(1, area / 20))
    for _j = 0; _j < count; _j = _j + 1 {
      let cx = room.rect.x.to_double() * tile_size +
        rng.rand_range(1, room.rect.w - 1).to_double() * tile_size +
        tile_size / 2.0
      let cy = room.rect.y.to_double() * tile_size +
        rng.rand_range(1, room.rect.h - 1).to_double() * tile_size +
        tile_size / 2.0
      let kind_roll = rng.next_int(10)
      let (kind, hp, spd, sz) = if kind_roll < 5 {
        (kind_basic, 3, enemy_speed_basic, 10.0)
      } else if kind_roll < 8 {
        (kind_fast, 2, enemy_speed_fast, 8.0)
      } else {
        (kind_tank, 8, enemy_speed_tank, 14.0)
      }
      enemies.push({
        x: cx,
        y: cy,
        vx: 0.0,
        vy: 0.0,
        hp,
        max_hp: hp,
        speed: spd,
        size: sz,
        alive: true,
        damage_timer: 0,
        kind,
        path_cache: [],
        path_index: 0,
        path_timer: 0,
      })
    }
  }
  enemies
}
