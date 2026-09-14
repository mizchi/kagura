///|
pub(all) enum EnemyAwareness {
  Resting
  Waking(Int)
  Alert
} derive(Eq, Debug, ToJson, FromJson)

///|
pub(all) enum EnemyRestPose {
  Standing
  Sitting
} derive(Eq, Debug, ToJson, FromJson)

///|
pub(all) struct EnemyCamp {
  pack_id : Int
  pose : EnemyRestPose
  mut awareness : EnemyAwareness
} derive(ToJson, FromJson)

///|
/// Stable site/room membership: an alarm never chains to an unrelated nearby pack.
fn configure_enemy_camps(enemies : Array[Enemy], seed : Int) -> Unit {
  for enemy in enemies {
    if enemy.camp is Some(_) {
      continue
    }
    let mut pack = 4 + enemy.room_index.max(0)
    let mut center_x = enemy.x
    let mut center_z = enemy.y
    let mut nearest = 9.0 * 9.0 * tile_size * tile_size
    for site in hunting_sites {
      let dx = enemy.x - (site.x.to_double() + 0.5) * tile_size
      let dz = enemy.y - (site.z.to_double() + 0.5) * tile_size
      let d = dx * dx + dz * dz
      if d < nearest {
        nearest = d
        pack = site.id
        center_x = (site.x.to_double() + 0.5) * tile_size
        center_z = (site.z.to_double() + 0.5) * tile_size
      }
    }
    enemy.camp = Some({
      pack_id: pack,
      pose: if woodland_random(enemy.x.to_int(), enemy.y.to_int(), seed) > 0.45 {
        Sitting
      } else {
        Standing
      },
      awareness: if enemy.hp < enemy.max_hp {
        Alert
      } else {
        Resting
      },
    })
    enemy.move_angle = if center_x != enemy.x || center_z != enemy.y {
      @math.atan2(center_z - enemy.y, center_x - enemy.x)
    } else {
      woodland_random(pack, 17, seed) * @math.PI * 2.0
    }
  }
}

///|
fn update_enemy_camps(
  enemies : Array[Enemy],
  player : Player,
  grid : @terrain.Grid2D,
  zombies : Array[SummonedZombie],
) -> Unit {
  let alarms : Map[Int, Bool] = Map([])
  fn noticed(enemy : Enemy, x : Double, y : Double) -> Bool {
    let dx = enemy.x - x
    let dy = enemy.y - y
    dx * dx + dy * dy < tile_size * tile_size * 42.25 &&
    @physics2d.grid_line_of_sight_clear(
      grid,
      enemy.x,
      enemy.y,
      x,
      y,
      0.0,
      tile_size,
    )
  }
  for enemy in enemies {
    guard enemy.camp is Some(camp) else { continue }
    if camp.awareness != Resting ||
      enemy.hp < enemy.max_hp ||
      (
        enemy.alive &&
        (
          noticed(enemy, player.x, player.y) ||
          zombies.any(z => z.body.alive && noticed(enemy, z.body.x, z.body.y))
        )
      ) {
      alarms[camp.pack_id] = true
    }
  }
  for enemy in enemies {
    guard enemy.camp is Some(camp) else { continue }
    match camp.awareness {
      Resting =>
        if alarms.contains(camp.pack_id) {
          camp.awareness = Waking(36)
        }
      Waking(n) => {
        let target = enemy_aggro_target(enemy, player, zombies, grid)
        let delta = @math.atan2(target.y - enemy.y, target.x - enemy.x) -
          enemy.move_angle
        enemy.move_angle += @math.atan2(@math.sin(delta), @math.cos(delta)) *
          0.10
        camp.awareness = if n <= 1 { Alert } else { Waking(n - 1) }
      }
      Alert => ()
    }
  }
}
