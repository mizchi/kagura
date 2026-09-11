///|
pub fn lock_candidates(g : Game, frame : CombatFrame) -> Array[Int] {
  let direction = frame.aim.sub(frame.eye).normalize()
  let candidates : Array[(Int, Double)] = []
  for e in g.units {
    let ray = e.position.add(vec(0.0, 3.8, 0.0)).sub(frame.eye)
    let score = ray.normalize().dot(direction)
    if e.hp > 0.0 &&
      ray.length() <= 95.0 &&
      score >= 0.9 &&
      visible(frame.eye, frame.eye.add(ray), g.stage.solids) {
      candidates.push((e.id, score))
    }
  }
  candidates.sort_by(fn(a, b) {
    if a.1 > b.1 {
      -1
    } else if a.1 < b.1 {
      1
    } else {
      0
    }
  })
  let result : Array[Int] = []
  for i in 0..<candidates.length() {
    if i < 3 {
      result.push(candidates[i].0)
    }
  }
  result
}

///|
pub fn spawn_projectile(
  g : Game,
  kind : Int,
  position : @math3d.Vec3,
  velocity : @math3d.Vec3,
  target : Int,
  owner? : Int = -1,
) -> Unit {
  g.projectiles.push({
    id: g.next_id,
    kind,
    target,
    owner,
    position,
    velocity,
    age: 0.0,
    trail: [],
  })
  g.next_id += 1
}

///|
fn move_projectiles(g : Game, h : Double, hostile : Bool) -> Unit {
  let remaining : Array[Projectile] = []
  for p in g.projectiles {
    if (p.kind == 2) != hostile {
      remaining.push(p)
      continue
    }
    p.age += h
    let life = if p.kind == 0 { 1.6 } else if p.kind == 1 { 8.0 } else { 4.0 }
    if p.age > life {
      continue
    }
    if p.kind == 1 {
      if p.age < 0.65 {
        p.velocity = p.velocity.add(vec(0.0, -18.0 * h, 0.0))
      } else if p.target >= 0 &&
        p.target < g.units.length() &&
        g.units[p.target].hp > 0.0 {
        let desired = g.units[p.target].position
          .add(vec(0.0, 3.8, 0.0))
          .sub(p.position)
          .normalize()
          .scale(27.0)
        p.velocity = p.velocity.lerp(desired, 1.0 - @math.exp(-5.0 * h))
      }
    }
    let delta = p.velocity.scale(h)
    let mut nearest = 1.0
    let mut hit = -1
    let mut collided = false
    for box in g.stage.solids {
      if box_intersection(
          p.position,
          delta,
          box,
          padding=if p.kind == 1 { 0.12 } else { 0.0 },
        )
        is Some(t) {
        if t <= nearest {
          nearest = t
          collided = true
        }
      }
    }
    for e in g.units {
      if e.hp > 0.0 && e.id != p.owner {
        if box_intersection(
            p.position,
            delta,
            enemy_box(e),
            padding=if p.kind == 1 { 0.12 } else { 0.0 },
          )
          is Some(t) {
          if t <= nearest {
            nearest = t
            hit = e.id
            collided = true
          }
        }
      }
    }
    if hostile {
      let box = solid(
        "player",
        g.pilot.position.add(vec(0.0, 1.8, 0.0)),
        vec(4.8, 3.6, 4.8),
        0,
      )
      if box_intersection(p.position, delta, box) is Some(t) {
        if t < nearest {
          nearest = t
          hit = -2
          collided = true
        }
      }
    }
    if delta.y < 0.0 && p.position.y + delta.y <= 0.0 {
      let t = -p.position.y / delta.y
      if t <= nearest {
        nearest = t
        hit = -1
        collided = true
      }
    }
    p.position = p.position.add(delta.scale(nearest))
    if collided {
      if hit == -2 {
        g.hp = max(0.0, g.hp - 40.0)
        g.enemy_hits += 1
        g.damage_flash = 0.25
      } else if hit >= 0 && !hostile {
        let enemy = g.units[hit]
        enemy.hp = max(
          0.0,
          enemy.hp - (if p.kind == 0 { rifle_action(g).damage } else { 55.0 }),
        )
        g.hits += 1
        if enemy.hp == 0.0 {
          g.kills += 1
          enemy.lock = 0.0
          enemy.mode = "destroyed"
          enemy.warning = 0.0
          enemy.velocity = vec(0.0, 0.0, 0.0)
          g.effects.push({ position: p.position, kind: 2, age: 0.0, })
        }
      }
      if !hostile {
        g.effects.push({ position: p.position, kind: p.kind, age: 0.0, })
      }
    } else {
      remaining.push(p)
    }
  }
  g.projectiles = remaining
}

///|
pub fn advance_hostile_projectiles(g : Game, h : Double) -> Unit {
  move_projectiles(g, h, true)
}

///|
pub fn advance_combat(
  g : Game,
  i : Input,
  frame : CombatFrame,
  delta : Double,
) -> Unit {
  let dt = clamp(delta, 0.0, 0.1)
  if dt <= 0.0 {
    return
  }
  let candidates = lock_candidates(g, frame)
  for e in g.units {
    if !candidates.contains(e.id) {
      e.lock = 0.0
    }
  }
  if !i.lock && g.was_locking && g.missile_cooldown <= 0.0 {
    let mut count = 0
    for e in g.units {
      if e.lock >= 1.0 {
        for side in 0..<2 {
          g.queue.push({
            target: e.id,
            side,
            delay: (count * 2 + side).to_double() * 0.12,
          })
        }
        count += 1
      }
    }
    if count > 0 {
      g.missile_cooldown = 3.0
    }
  }
  if !i.lock {
    for e in g.units {
      e.lock = 0.0
    }
  }
  g.was_locking = i.lock
  let steps = (dt * 120.0).ceil().to_int()
  let h = dt / steps.to_double()
  for _ in 0..<steps {
    g.attack_age += h
    g.effects = g.effects.filter(fn(e) {
      e.age += h
      e.age < (if e.kind == 2 { 1.2 } else { 0.45 })
    })
    g.rifle_cooldown = max(0.0, g.rifle_cooldown - h)
    g.missile_cooldown = max(0.0, g.missile_cooldown - h)
    if i.lock && g.missile_cooldown <= 0.0 {
      for id in candidates {
        let e = g.units[id]
        if e.hp > 0.0 {
          e.lock = min(1.0, e.lock + h / 0.65)
        }
      }
    }
    if i.fire && g.rifle_cooldown <= 0.000000001 {
      spawn_projectile(
        g,
        0,
        frame.rifle,
        frame.aim.sub(frame.rifle).normalize().scale(130.0),
        -1,
      )
      g.shots += 1
      g.rifle_cooldown = rifle_action(g).cooldown
      g.attack_age = 0.0
    }
    for shot in g.queue {
      shot.delay -= h
      if shot.delay > 0.0 {
        continue
      }
      let e = g.units[shot.target]
      if e.hp <= 0.0 {
        continue
      }
      let p = if shot.side == 0 { frame.left } else { frame.right }
      let toward = e.position.add(vec(0.0, 3.8, 0.0)).sub(p).normalize()
      spawn_projectile(
        g,
        1,
        p,
        vec(
          toward.x * 7.0 + (if shot.side == 0 { -2.0 } else { 2.0 }),
          17.0,
          toward.z * 7.0,
        ),
        e.id,
      )
      g.missiles += 1
    }
    g.queue = g.queue.filter(fn(s) { s.delay > 0.0 })
    move_projectiles(g, h, false)
  }
  for p in g.projectiles {
    if p.kind == 1 {
      p.trail.push(p.position)
      if p.trail.length() > 22 {
        p.trail.remove(0) |> ignore
      }
    }
  }
}
