///|
fn ground(p : @math3d.Vec3) -> @math3d.Vec3 {
  vec(p.x, 0.0, p.z)
}

///|
fn in_bounds(p : @math3d.Vec3, s : Stage) -> Bool {
  p.x >= s.min_x + 2.8 &&
  p.x <= s.max_x - 2.8 &&
  p.z >= s.min_z + 2.8 &&
  p.z <= s.max_z - 2.8
}

///|
fn ground_solids(s : Stage) -> Array[Solid] {
  s.solids.filter(fn(b) {
    b.center.y - b.size.y / 2.0 < 6.0 && b.center.y + b.size.y / 2.0 > 0.0
  })
}

///|
pub fn clear_segment(a : @math3d.Vec3, b : @math3d.Vec3, stage : Stage) -> Bool {
  for s in ground_solids(stage) {
    let box = {
      ..s,
      center: ground(s.center),
      size: vec(s.size.x, 2.0, s.size.z),
    }
    if box_intersection(ground(a), ground(b).sub(ground(a)), box, padding=2.8)
      is Some(_) {
      return false
    }
  }
  true
}

///|
pub fn find_route(
  start : @math3d.Vec3,
  goal : @math3d.Vec3,
  stage : Stage,
) -> Array[@math3d.Vec3] {
  let origin = ground(start)
  let end = ground(goal)
  if in_bounds(end, stage) && clear_segment(origin, end, stage) {
    return [end]
  }
  let nodes = [origin]
  for s in ground_solids(stage) {
    for x in [-1.0, 1.0] {
      for z in [-1.0, 1.0] {
        let p = vec(
          s.center.x + x * (s.size.x / 2.0 + 2.95),
          0.0,
          s.center.z + z * (s.size.z / 2.0 + 2.95),
        )
        if in_bounds(p, stage) && clear_segment(p, p, stage) {
          nodes.push(p)
        }
      }
    }
  }
  if in_bounds(end, stage) && clear_segment(end, end, stage) {
    nodes.push(end)
  }
  let costs = Array::make(nodes.length(), 1.0e100)
  let parents = Array::make(nodes.length(), -1)
  let done = Array::make(nodes.length(), false)
  costs[0] = 0.0
  for _ in 0..<nodes.length() {
    let mut current = -1
    for i in 0..<nodes.length() {
      if !done[i] && (current < 0 || costs[i] < costs[current]) {
        current = i
      }
    }
    if current < 0 || costs[current] >= 1.0e100 {
      break
    }
    done[current] = true
    for i in 1..<nodes.length() {
      if !done[i] && clear_segment(nodes[current], nodes[i], stage) {
        let cost = costs[current] + distance(nodes[current], nodes[i])
        if cost < costs[i] {
          costs[i] = cost
          parents[i] = current
        }
      }
    }
  }
  let mut best = 0
  for i in 0..<nodes.length() {
    if done[i] && distance(nodes[i], end) < distance(nodes[best], end) {
      best = i
    }
  }
  let result : Array[@math3d.Vec3] = []
  while best > 0 {
    result.push(nodes[best])
    best = parents[best]
  }
  result.rev()
}

///|
pub fn enemy_muzzle(e : Enemy) -> @math3d.Vec3 {
  let x = -1.63
  let z = 0.30 - 0.25 * @math.sin(0.13) + 2.27 * @math.cos(0.13)
  let y = 2.68 - 0.25 * @math.cos(0.13) - 2.27 * @math.sin(0.13)
  e.position.add(
    vec(
      x * @math.cos(e.yaw) + z * @math.sin(e.yaw),
      y,
      -x * @math.sin(e.yaw) + z * @math.cos(e.yaw),
    ),
  )
}

///|
fn move_enemy(e : Enemy, goal : @math3d.Vec3, h : Double, g : Game) -> Unit {
  let length = distance(e.position, goal)
  if length < 0.05 {
    return
  }
  let step = min(length, 2.4 * h)
  let p = e.position.add(ground(goal.sub(e.position)).scale(step / length))
  if !in_bounds(p, g.stage) || !clear_segment(e.position, p, g.stage) {
    return
  }
  if g.pilot.position.y < 6.0 && distance(p, g.pilot.position) < 5.8 {
    return
  }
  for other in g.units {
    if other.id != e.id && other.hp > 0.0 && distance(p, other.position) < 5.6 {
      return
    }
  }
  e.velocity = p.sub(e.position).scale(1.0 / h)
  e.position = p
}

///|
fn update_enemy(e : Enemy, h : Double, g : Game) -> Unit {
  let player = g.pilot.position.add(vec(0.0, 1.8, 0.0))
  let eye = e.position.add(vec(0.0, 4.3, 0.0))
  let range = distance(e.position, g.pilot.position)
  let seen = eye.distance(player) < 62.0 && visible(eye, player, g.stage.solids)
  if seen {
    e.last_seen = Some(g.pilot.position)
    e.memory = 6.0
  } else {
    e.memory = max(0.0, e.memory - h)
    if e.memory == 0.0 {
      e.last_seen = None
    }
  }
  e.cooldown = max(0.0, e.cooldown - h)
  e.repath -= h
  e.velocity = vec(0.0, 0.0, 0.0)
  let previous = e.mode
  e.mode = if seen {
    if range <= 42.0 {
      "attack"
    } else {
      "chase"
    }
  } else if e.last_seen is Some(_) {
    "search"
  } else {
    "patrol"
  }
  if previous != e.mode {
    e.path = []
    e.repath = 0.0
  }
  let mut goal = e.home
  if e.mode == "attack" {
    let ray = ground(g.pilot.position.sub(e.position)).scale(
      1.0 / max(range, 0.000001),
    )
    let toward = if range > 29.0 {
      1.0
    } else if range < 17.0 {
      -1.0
    } else {
      0.0
    }
    goal = e.position.add(
      vec(
        ray.x * toward * 8.0 + ray.z * e.strafe * 3.0,
        0.0,
        ray.z * toward * 8.0 - ray.x * e.strafe * 3.0,
      ),
    )
    if !clear_segment(e.position, goal, g.stage) || !in_bounds(goal, g.stage) {
      e.strafe = -e.strafe
      goal = e.position.add(
        vec(
          ray.x * toward * 8.0 + ray.z * e.strafe * 3.0,
          0.0,
          ray.z * toward * 8.0 - ray.x * e.strafe * 3.0,
        ),
      )
      if !clear_segment(e.position, goal, g.stage) || !in_bounds(goal, g.stage) {
        goal = e.position.add(ray.scale(toward * 8.0))
      }
    }
  } else if e.last_seen is Some(p) {
    goal = ground(p)
  } else {
    goal = e.home.add(vec(e.patrol_side * 5.0, 0.0, 0.0))
    if distance(e.position, goal) < 0.5 ||
      !in_bounds(goal, g.stage) ||
      !clear_segment(goal, goal, g.stage) {
      e.patrol_side = -e.patrol_side
      goal = e.home.add(vec(e.patrol_side * 5.0, 0.0, 0.0))
    }
  }
  if e.repath <= 0.0 {
    e.path = find_route(e.position, goal, g.stage)
    e.repath = 0.8
  }
  if e.path.length() > 0 && distance(e.position, e.path[0]) < 0.2 {
    e.path.remove(0) |> ignore
  }
  if e.warning == 0.0 && e.path.length() > 0 {
    move_enemy(e, e.path[0], h, g)
  }
  let look = if seen {
    player
  } else {
    e.last_seen.unwrap_or(if e.path.length() > 0 { e.path[0] } else { goal })
  }
  let ray = look.sub(e.position)
  let yaw = @math.atan2(ray.x, ray.z)
  let turn = @math.atan2(@math.sin(yaw - e.yaw), @math.cos(yaw - e.yaw))
  e.yaw += clamp(turn, -1.8 * h, 1.8 * h)
  let muzzle = enemy_muzzle(e)
  let can_shoot = e.mode == "attack" &&
    turn.abs() < 0.2 &&
    visible(muzzle, player, g.stage.solids)
  if !can_shoot {
    e.warning = 0.0
    return
  }
  if e.warning > 0.0 {
    e.warning = max(0.0, e.warning - h)
    if e.warning == 0.0 {
      spawn_projectile(
        g,
        2,
        muzzle,
        e.aim.sub(muzzle).normalize().scale(28.0),
        -1,
        owner=e.id,
      )
      g.enemy_shots += 1
      e.cooldown = 2.4
    }
  } else if e.cooldown == 0.0 {
    e.warning = 0.8
    e.aim = player
  }
}

///|
pub fn advance_enemies(g : Game, delta : Double) -> Unit {
  if !g.ai || g.phase != "playing" || g.hp <= 0.0 {
    return
  }
  let dt = clamp(delta, 0.0, 0.1)
  if dt <= 0.0 {
    return
  }
  let steps = (dt * 120.0).ceil().to_int()
  let h = dt / steps.to_double()
  for _ in 0..<steps {
    if g.hp <= 0.0 {
      break
    }
    g.damage_flash = max(0.0, g.damage_flash - h)
    for e in g.units {
      if e.hp > 0.0 {
        update_enemy(e, h, g)
      }
    }
    advance_hostile_projectiles(g, h)
  }
}

///|
pub fn advance_motion(g : Game, i : Input, dt : Double) -> Unit {
  if g.phase != "playing" {
    return
  }
  let boxes : Array[Solid] = []
  for e in g.units {
    if e.hp > 0.0 {
      boxes.push(enemy_box(e))
    }
  }
  g.pilot = advance_pilot(g.pilot, i, dt, g.stage, boxes)
  advance_enemies(g, dt)
}

///|
pub fn finish_mission(g : Game, dt : Double) -> Unit {
  if g.phase != "playing" || !g.ai {
    return
  }
  g.elapsed += clamp(dt, 0.0, 0.1)
  if g.hp <= 0.0 {
    g.phase = "lost"
    cancel_combat(g)
    return
  }
  let cleared = g.units.all(fn(e) { e.hp <= 0.0 })
  if cleared {
    if g.wave + 1 == wave_count(g) {
      g.phase = "won"
      cancel_combat(g)
      return
    }
    g.wave += 1
    append_wave(g)
    g.hp = min(1000.0, g.hp + 200.0)
  }
  if g.elapsed >= mission_time(g) {
    g.elapsed = mission_time(g)
    g.phase = "lost"
    cancel_combat(g)
  }
}
