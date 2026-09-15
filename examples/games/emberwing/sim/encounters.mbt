///|
pub fn boss_max_hp() -> Double {
  180
}

///|
pub fn player_radius() -> Double {
  0.45
}

///|
pub fn enemy_center(enemy : Enemy) -> @math3d.Vec3 {
  enemy.position.add(
    vec(0, if enemy.boss { 7.5 } else { 0.6 }, if enemy.boss { 2 } else { 0 }),
  )
}

///|
pub fn enemy_radius(enemy : Enemy) -> Double {
  if enemy.boss {
    5.8
  } else if enemy.elite {
    1.65
  } else {
    1.3
  }
}

///|
pub fn lock_targets(g : Game) -> Array[LockTarget] {
  let targets : Array[LockTarget] = []
  for e in g.enemies {
    if e.hp <= 0 {
      continue
    }
    if e.boss {
      for
        i, offset in [
          vec(-3.8, 4, 0),
          vec(0, 4, 0),
          vec(3.8, 4, 0),
          vec(-2.5, 8, 2),
          vec(0, 12, 3),
          vec(2.5, 8, 2),
        ] {
        targets.push({
          id: -100 - i,
          enemy: e.id,
          position: e.position.add(offset),
          radius: 2,
          boss: true,
          elite: true,
        })
      }
    } else {
      targets.push({
        id: e.id,
        enemy: e.id,
        position: enemy_center(e),
        radius: enemy_radius(e),
        boss: false,
        elite: e.elite,
      })
    }
  }
  targets
}

///|
fn spawn_boss(g : Game) -> Unit {
  if g.boss_spawned {
    return
  }
  if g.enemies.length() >= 120 {
    ignore(g.enemies.remove(0))
  }
  g.boss_spawned = true
  g.boss_clock = 2.4
  g.boss_salvo = 0
  spawn_enemy(g, vec(0, -7, -68), 0, boss=true)
}

///|
fn push_shot(
  g : Game,
  origin : @math3d.Vec3,
  direction : @math3d.Vec3,
  speed : Double,
) -> Unit {
  if g.shots.length() >= 320 {
    return
  }
  g.shots.push({
    position: origin,
    velocity: direction.normalize().scale(speed),
    age: 0,
  })
}

///|
fn enemy_salvo(g : Game, enemy : Enemy) -> Unit {
  let count = if g.wave >= 6 { 7 } else if g.wave >= 3 { 5 } else { 3 }
  let origin = enemy_center(enemy)
  let direction = g.player.sub(origin).normalize()
  for i = 0; i < count; i = i + 1 {
    let offset = (i - (count - 1) / 2).to_double()
    let vertical = if enemy.id % 2 == 0 {
      offset * 0.025
    } else {
      offset * 0.085
    }
    push_shot(
      g,
      origin,
      direction.add(vec(offset * 0.09, vertical, 0)),
      18 + g.wave.to_double() * 1.15,
    )
  }
}

///|
fn queue_beam(
  g : Game,
  origin : @math3d.Vec3,
  aim : @math3d.Vec3,
  warning : Double,
) -> Unit {
  if g.beams.length() >= 9 {
    return
  }
  g.beams.push({
    origin,
    aim,
    direction: aim.sub(origin).normalize(),
    warning,
    radius: 0.55,
    age: 0,
    hit: false,
  })
}

///|
fn update_boss(g : Game, boss : Enemy, dt : Double) -> Unit {
  boss.position = boss.position.lerp(
    vec(
      @math.sin(g.time * 0.65) * 3.2,
      -7 + @math.sin(g.time * 0.8) * 0.65,
      -38,
    ),
    1 - @math.exp(-dt * 1.4),
  )
  g.boss_clock -= dt
  if g.boss_clock > 0 || g.boss_defeated {
    return
  }
  let enraged = boss.hp <= boss_max_hp() * 0.5
  let origin = boss.position.add(vec(0, 10.35, 7.4))
  let warning = if enraged { 0.95 } else { 1.2 }
  queue_beam(g, origin, g.player, warning)
  if enraged {
    let gap = 3.2 * clamp(g.aspect, 0.4, 1)
    queue_beam(g, origin, g.player.add(vec(-gap, 0, 0)), warning)
    queue_beam(g, origin, g.player.add(vec(gap, 0, 0)), warning)
  }
  let direction = g.player.sub(origin).normalize()
  let count = if enraged { 14 } else { 8 }
  for i = 0; i < count; i = i + 1 {
    let angle = i.to_double() * @math.PI * 2 / count.to_double() +
      g.boss_salvo.to_double() * 0.22
    push_shot(
      g,
      origin,
      direction.add(vec(@math.cos(angle) * 0.17, @math.sin(angle) * 0.17, 0)),
      21,
    )
  }
  g.boss_salvo += 1
  g.boss_clock = if enraged { 2.55 } else { 3.35 }
}

///|
fn spawn_rocks(g : Game) -> Unit {
  let count = if g.wave >= 6 { 3 } else { 2 }
  let horizontal = clamp(g.aspect, 0.4, 1)
  for i = 0; i < count; i = i + 1 {
    if g.rocks.length() >= 18 {
      break
    }
    let phase = g.time * 0.31 + i.to_double() * 2.3 + g.seed.to_double()
    let destination = if i == 0 {
      g.player
    } else {
      vec(@math.sin(phase) * 6 * horizontal, @math.cos(phase * 1.7) * 3.5, 2)
    }
    let origin = destination.add(
      vec(
        @math.sin(phase) * 11,
        5 + @math.cos(phase) * 4,
        -72 - i.to_double() * 9,
      ),
    )
    g.rocks.push({
      position: origin,
      velocity: destination
      .sub(origin)
      .normalize()
      .scale(27 + g.wave.to_double() * 0.9),
      radius: 1.0 + (i % 3).to_double() * 0.25,
      phase,
      age: 0,
    })
  }
}

///|
fn update_hazards(g : Game, dt : Double) -> Unit {
  for rock in g.rocks {
    rock.age += dt
    let next = rock.position.add(rock.velocity.scale(dt))
    if segment_distance(g.player, rock.position, next) <
      rock.radius + player_radius() {
      hurt(g, amount=2)
      rock.age = 99
    }
    rock.position = next
  }
  for beam in g.beams {
    let previous = beam.age
    beam.age += dt
    if previous < beam.warning && beam.age >= beam.warning {
      g.beam_event += 1
    }
    if beam.age >= beam.warning && !beam.hit {
      // A 220 m/s beam crosses several collision radii in one simulation tick.
      // Test its swept head and luminous tail, never just its final position.
      let start = beam.origin.add(
        beam.direction.scale(
          clamp((previous - beam.warning) * 220 - 22, 0, 200),
        ),
      )
      let end = beam.origin.add(
        beam.direction.scale(clamp((beam.age - beam.warning) * 220, 0, 200)),
      )
      if segment_distance(g.player, start, end) < beam.radius + player_radius() {
        hurt(g, amount=2)
        beam.hit = true
      }
    }
  }
  g.rocks.retain(r => r.age < 6 && r.position.z < 22)
  g.beams.retain(b => b.age < b.warning + 0.8)
}

///|
fn update_dishes(g : Game, dt : Double) -> Unit {
  for bowl in g.bowls {
    bowl.age += dt
    bowl.velocity_y -= dt * 5.8
    bowl.position = bowl.position.add(
      vec(@math.sin(bowl.phase) * dt * 0.35, bowl.velocity_y * dt, dt * 5),
    )
  }
  g.bowls.retain(b => b.age < 4.5)
}
