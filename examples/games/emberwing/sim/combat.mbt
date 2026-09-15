///|
fn defeat(g : Game, enemy : Enemy) -> Unit {
  if enemy.hp > 0 {
    return
  }
  let points = if enemy.boss { 10000 } else if enemy.elite { 400 } else { 100 }
  g.score += points
  if enemy.boss {
    g.boss_defeated = true
    g.victory_clock = 2.2
  }
  g.kills += 1
  if g.bowls.length() == 48 {
    ignore(g.bowls.remove(0))
  }
  g.bowls.push({
    id: enemy.id,
    points,
    scale: if enemy.boss {
      4.0
    } else {
      1.0
    },
    position: if enemy.boss {
      enemy_center(enemy)
    } else {
      enemy.position
    },
    age: 0,
    velocity_y: 1.8,
    phase: enemy.phase,
  })
  enemy.hp = -999
}

///|
fn damage(g : Game, enemy : Enemy, amount : Double) -> Unit {
  if enemy.hp <= 0 {
    return
  }
  enemy.hp -= amount
  enemy.flash = 0.13
  if enemy.hp <= 0 {
    defeat(g, enemy)
  }
}

///|
fn hurt(g : Game, amount? : Int = 1) -> Unit {
  if g.hit_timer > 0 {
    return
  }
  g.hp = if g.hp <= amount { 0 } else { g.hp - amount }
  g.hit_timer = 1.25
  g.hit_event += 1
  if g.hp <= 0 {
    g.mode = "lost"
    g.breathing = false
    g.was_locking = false
    g.locks.clear()
  }
}

///|
fn fire_volley(g : Game) -> Unit {
  let count = g.locks.length()
  if count > g.best_chain {
    g.best_chain = count
  }
  if g.balls.length() >= 84 {
    g.locks.clear()
    return
  }
  let targets = if count > 0 { g.locks.copy() } else { [-1] }
  for i, target in targets {
    let fan = i.to_double() - (targets.length() - 1).to_double() * 0.5
    g.balls.push({
      target,
      position: mouth(g),
      velocity: vec(fan * 3, 3.5 + (i % 3).to_double() * 2, -13),
      age: 0,
      trail: [],
    })
  }
  g.volley_event += 1
  g.locks.clear()
}

///|
fn swept_hit(
  p : @math3d.Vec3,
  a : @math3d.Vec3,
  b : @math3d.Vec3,
  radius : Double,
) -> Bool {
  @math3d.Segment3::new(a, b).distance_squared(p) < radius * radius
}

///|
pub fn step(g : Game, input : Input, delta : Double) -> Unit {
  if g.mode != "playing" {
    return
  }
  let dt = clamp(delta, 0, 0.05)
  if dt <= 0 {
    return
  }
  g.time += dt
  if g.boss_defeated {
    clear_dangers(g)
    update_dishes(g, dt)
    g.victory_clock -= dt
    if g.victory_clock <= 0 {
      g.mode = "won"
    }
    return
  }
  g.aspect = clamp(input.aspect, 0.35, 4)
  g.aim_x = clamp(input.aim_x, -1, 1)
  g.aim_y = clamp(input.aim_y, -1, 1)
  g.aim = aim_point(input)
  let horizontal = clamp(g.aspect, 0.4, 1)
  let target = vec(
    clamp(g.aim_x * 4.7 + input.move_x * 3.5, -7, 7) * horizontal,
    clamp(g.aim_y * 3.5 + input.move_y * 2.5, -4, 5),
    2,
  )
  g.player = g.player.lerp(target, 1 - @math.exp(-dt * 9))
  g.hit_timer = clamp(g.hit_timer - dt, 0, 5)
  g.fire_clock -= dt
  g.lock_clock -= dt
  if g.time >= g.next_wave && g.wave < 9 {
    spawn_wave(g)
    g.next_wave += if g.wave > 5 { 7.5 } else { 9.0 }
  }
  if g.time >= 84 && !g.boss_spawned {
    spawn_boss(g)
  }
  if g.time >= g.next_rock {
    spawn_rocks(g)
    g.next_rock = g.time +
      (if g.boss_spawned { 6.0 } else { 7.0 - g.wave.to_double() * 0.25 })
  }
  for enemy in g.enemies {
    enemy.flash = clamp(enemy.flash - dt, 0, 1)
    if enemy.boss {
      update_boss(g, enemy, dt)
      continue
    }
    enemy.position = vec(
      enemy.origin.x + @math.sin(g.time * 0.8 + enemy.phase) * 0.9,
      enemy.origin.y + @math.sin(g.time * 1.1 + enemy.phase) * 0.45,
      enemy.position.z +
      dt * (if enemy.elite { 6.5 } else { 8.0 + g.wave.to_double() * 0.35 }),
    )
    enemy.shot_clock -= dt
    let shooter = if g.wave >= 4 {
      enemy.id % 2 == 0
    } else {
      enemy.id % 3 == 0
    }
    if enemy.hp > 0 &&
      shooter &&
      enemy.shot_clock <= 0 &&
      enemy.position.z < -10 {
      enemy_salvo(g, enemy)
      enemy.shot_clock = 3.4 - clamp(g.wave.to_double() * 0.16, 0, 1.5)
    }
    if enemy.hp > 0 && enemy.position.distance(g.player) < 1.7 {
      hurt(g)
      enemy.hp = -999
    }
  }
  // Resolve aim depth against the visible target. A fixed far plane makes a
  // third-person muzzle miss nearby targets that are directly under the cursor.
  let vp = camera(g.aspect).view_projection_matrix()
  let targets = lock_targets(g)
  let mut aim_distance = 0.08 * 0.08
  for target in targets {
    let p = project(vp, target.position)
    let dx = (p.x - input.aim_x) * g.aspect
    let dy = p.y - input.aim_y
    let distance = dx * dx + dy * dy
    if target.position.z < -3 && p.z > 4 && distance < aim_distance {
      aim_distance = distance
      g.aim = target.position
    }
  }
  let valid = g.locks.filter(id => {
    targets.any(t => t.id == id && t.position.z < 10)
  })
  g.locks.clear()
  for id in valid {
    g.locks.push(id)
  }
  if input.locking && g.locks.length() < 12 && g.lock_clock <= 0 {
    let mut best : LockTarget? = None
    let mut distance = 0.22 * 0.22
    for target in targets {
      let p = project(vp, target.position)
      let dx = (p.x - input.aim_x) * g.aspect
      let dy = p.y - input.aim_y
      let d = dx * dx + dy * dy
      if p.z > 4 &&
        target.position.z < -4 &&
        !g.locks.contains(target.id) &&
        d < distance {
        best = Some(target)
        distance = d
      }
    }
    if best is Some(target) {
      g.locks.push(target.id)
      g.lock_event += 1
      g.lock_clock = 0.07
    }
  }
  if g.was_locking && !input.locking {
    fire_volley(g)
  }
  g.was_locking = input.locking
  if g.overheated && g.heat < 0.2 {
    g.overheated = false
  }
  g.breathing = input.flame && !g.overheated
  g.heat = clamp(g.heat + dt * (if g.breathing { 0.24 } else { -0.32 }), 0, 1)
  if g.heat >= 1 {
    g.overheated = true
    g.breathing = false
  }
  if g.breathing && g.fire_clock <= 0 {
    let start = mouth(g)
    let end = start.add(g.aim.sub(start).normalize().scale(56))
    for enemy in g.enemies {
      if enemy.hp > 0 &&
        swept_hit(enemy_center(enemy), start, end, enemy_radius(enemy)) {
        damage(g, enemy, 0.38)
      }
    }
    g.fire_clock = 0.07
  }
  for ball in g.balls {
    ball.age += dt
    let mut destination = g.aim
    let mut target : Enemy? = None
    for point in targets {
      if point.id == ball.target {
        for enemy in g.enemies {
          if enemy.id == point.enemy && enemy.hp > 0 {
            target = Some(enemy)
            destination = point.position
          }
        }
        break
      }
    }
    if ball.age > 0.12 {
      let wanted = destination.sub(ball.position).normalize().scale(37)
      ball.velocity = ball.velocity.lerp(wanted, clamp(dt * 7.0, 0, 1))
    }
    let next = ball.position.add(ball.velocity.scale(dt))
    ball.trail.push(ball.position)
    if ball.trail.length() > 10 {
      ignore(ball.trail.remove(0))
    }
    match target {
      Some(enemy) =>
        if swept_hit(
            destination,
            ball.position,
            next,
            if enemy.boss {
              2.0
            } else {
              1.4
            },
          ) {
          damage(g, enemy, 2)
          ball.age = 99
        }
      None =>
        for enemy in g.enemies {
          if enemy.hp > 0 &&
            swept_hit(
              enemy_center(enemy),
              ball.position,
              next,
              enemy_radius(enemy),
            ) {
            damage(g, enemy, 2)
            ball.age = 99
            break
          }
        }
    }
    ball.position = next
  }
  if g.boss_defeated {
    clear_dangers(g)
    update_dishes(g, dt)
    return
  }
  for shot in g.shots {
    shot.age += dt
    let next = shot.position.add(shot.velocity.scale(dt))
    if swept_hit(g.player, shot.position, next, 0.26 + player_radius()) {
      hurt(g)
      shot.age = 99
    }
    shot.position = next
  }
  update_hazards(g, dt)
  update_dishes(g, dt)
  g.enemies.retain(e => e.hp > 0 && e.position.z < 15)
  g.balls.retain(b => b.age < 4 && b.position.z > -150)
  g.shots.retain(s => s.age < 7 && s.position.z < 25)
}

///|
fn clear_dangers(g : Game) -> Unit {
  g.enemies.clear()
  g.balls.clear()
  g.shots.clear()
  g.rocks.clear()
  g.beams.clear()
  g.breathing = false
  g.locks.clear()
  g.was_locking = false
}
