///|
fn defeat(g : Game, enemy : Enemy) -> Unit {
  if enemy.hp > 0 {
    return
  }
  g.score += if enemy.elite { 400 } else { 100 }
  g.kills += 1
  if g.bowls.length() == 48 {
    ignore(g.bowls.remove(0))
  }
  g.bowls.push({
    id: enemy.id,
    points: if enemy.elite {
      400
    } else {
      100
    },
    position: enemy.position,
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
fn hurt(g : Game) -> Unit {
  if g.hit_timer > 0 {
    return
  }
  g.hp -= 1
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
fn segment_distance(
  p : @math3d.Vec3,
  a : @math3d.Vec3,
  b : @math3d.Vec3,
) -> Double {
  let d = b.sub(a)
  let t = clamp(
    p.sub(a).dot(d) / clamp(d.length_squared(), 0.0001, 100000),
    0,
    1,
  )
  p.distance(a.add(d.scale(t)))
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
  g.player = g.player.lerp(target, 1 - @math.exp(-dt * 4))
  g.hit_timer = clamp(g.hit_timer - dt, 0, 5)
  g.fire_clock -= dt
  g.lock_clock -= dt
  if g.time >= g.next_wave && g.wave < 9 {
    spawn_wave(g)
    g.next_wave += if g.wave > 5 { 8.0 } else { 10.0 }
  }
  for enemy in g.enemies {
    enemy.position = vec(
      enemy.origin.x + @math.sin(g.time * 0.8 + enemy.phase) * 0.9,
      enemy.origin.y + @math.sin(g.time * 1.1 + enemy.phase) * 0.45,
      enemy.position.z +
      dt * (if enemy.elite { 5.5 } else { 7.0 + (g.wave % 3).to_double() }),
    )
    enemy.flash = clamp(enemy.flash - dt, 0, 1)
    enemy.shot_clock -= dt
    if enemy.hp > 0 &&
      enemy.id % 5 == 0 &&
      enemy.shot_clock <= 0 &&
      enemy.position.z < -10 &&
      g.shots.length() < 100 {
      g.shots.push({
        position: enemy.position,
        velocity: g.player.sub(enemy.position).normalize().scale(13),
        age: 0,
      })
      enemy.shot_clock = 4.5
    }
    if enemy.hp > 0 && enemy.position.distance(g.player) < 1.7 {
      hurt(g)
      enemy.hp = -999
    }
  }
  // Resolve aim depth against the visible target. A fixed far plane makes a
  // third-person muzzle miss nearby targets that are directly under the cursor.
  let vp = camera(g.aspect).view_projection_matrix()
  let mut aim_distance = 0.08 * 0.08
  for enemy in g.enemies {
    let center = enemy.position.add(vec(0, 0.6, 0))
    let p = project(vp, center)
    let dx = (p.x - input.aim_x) * g.aspect
    let dy = p.y - input.aim_y
    let distance = dx * dx + dy * dy
    if enemy.hp > 0 &&
      enemy.position.z < -3 &&
      p.z > 4 &&
      distance < aim_distance {
      aim_distance = distance
      g.aim = center
    }
  }
  let valid = g.locks.filter(id => {
    g.enemies.any(e => e.id == id && e.hp > 0 && e.position.z < 10)
  })
  g.locks.clear()
  for id in valid {
    g.locks.push(id)
  }
  if input.locking && g.locks.length() < 12 && g.lock_clock <= 0 {
    let mut best : Enemy? = None
    let mut distance = 0.22 * 0.22
    for enemy in g.enemies {
      let p = project(vp, enemy.position.add(vec(0, 0.9, 0)))
      let dx = (p.x - input.aim_x) * input.aspect
      let dy = p.y - input.aim_y
      let d = dx * dx + dy * dy
      if enemy.hp > 0 &&
        p.z > 4 &&
        enemy.position.z < -4 &&
        !g.locks.contains(enemy.id) &&
        d < distance {
        best = Some(enemy)
        distance = d
      }
    }
    if best is Some(enemy) {
      g.locks.push(enemy.id)
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
        segment_distance(enemy.position.add(vec(0, 0.6, 0)), start, end) < 1.3 {
        damage(g, enemy, 0.38)
      }
    }
    g.fire_clock = 0.07
  }
  for ball in g.balls {
    ball.age += dt
    let mut destination = g.aim
    let mut target : Enemy? = None
    for enemy in g.enemies {
      if enemy.id == ball.target && enemy.hp > 0 {
        target = Some(enemy)
        destination = enemy.position.add(vec(0, 0.6, 0))
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
        if segment_distance(destination, ball.position, next) < 1.4 {
          damage(g, enemy, 2)
          ball.age = 99
        }
      None =>
        for enemy in g.enemies {
          if enemy.hp > 0 &&
            segment_distance(
              enemy.position.add(vec(0, 0.6, 0)),
              ball.position,
              next,
            ) <
            1.1 {
            damage(g, enemy, 2)
            ball.age = 99
            break
          }
        }
    }
    ball.position = next
  }
  for shot in g.shots {
    shot.age += dt
    let next = shot.position.add(shot.velocity.scale(dt))
    if segment_distance(g.player, shot.position, next) < 1.15 {
      hurt(g)
      shot.age = 99
    }
    shot.position = next
  }
  for bowl in g.bowls {
    bowl.age += dt
    bowl.velocity_y -= dt * 5.8
    bowl.position = bowl.position.add(
      vec(@math.sin(bowl.phase) * dt * 0.35, bowl.velocity_y * dt, dt * 5),
    )
  }
  g.enemies.retain(e => e.hp > 0 && e.position.z < 15)
  g.balls.retain(b => b.age < 4 && b.position.z > -150)
  g.shots.retain(s => s.age < 9 && s.position.z < 25)
  g.bowls.retain(b => b.age < 4.5)
  if g.time >= 96 && g.mode == "playing" {
    g.mode = "won"
    g.breathing = false
    g.locks.clear()
    g.was_locking = false
  }
}
