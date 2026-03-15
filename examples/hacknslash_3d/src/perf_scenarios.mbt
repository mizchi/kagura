///|
fn stress_enemy_kind(index : Int) -> @game.EnemyKind {
  match index % 5 {
    0 => @game.Basic
    1 => @game.Fast
    2 => @game.Tank
    3 => @game.Ranged
    _ => @game.Boss
  }
}

///|
fn stress_enemy_stats(kind : @game.EnemyKind) -> (Int, Double, Double) {
  match kind {
    @game.Basic | @game.Swarm => (3, 1.0, 10.0)
    @game.Fast | @game.Exploder | @game.Teleporter => (2, 1.4, 8.0)
    @game.Tank | @game.Berserker => (5, 0.7, 14.0)
    @game.Ranged | @game.Summoner => (2, 0.5, 8.0)
    @game.Boss => (12, 0.6, 20.0)
  }
}

///|
fn enemy_stress_grid_side(count : Int) -> Int {
  let mut side = 1
  while side * side < count {
    side = side + 1
  }
  side
}

///|
fn apply_enemy_stress_scenario(world : @game.GameWorld, count : Int) -> Unit {
  if count <= 0 {
    return
  }
  let side = enemy_stress_grid_side(count)
  let spacing = tile_size * 0.75
  let center = (side - 1).to_double() / 2.0
  let enemies : Array[@game.Enemy] = []
  for i = 0; i < count; i = i + 1 {
    let col = i % side
    let row = i / side
    let kind = stress_enemy_kind(i)
    let (hp, speed, size) = stress_enemy_stats(kind)
    let offset_x = (col.to_double() - center) * spacing
    let offset_y = (row.to_double() - center) * spacing
    enemies.push(
      @game.make_enemy(
        world.player.x + offset_x,
        world.player.y + offset_y,
        kind,
        hp,
        speed,
        size,
      ),
    )
  }
  world.enemies = enemies
}
