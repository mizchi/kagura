///|
pub fn new_pilot(stage : Stage) -> Pilot {
  {
    position: stage.spawn,
    velocity: vec(0.0, 0.0, 0.0),
    yaw: 0.0,
    pitch: 0.25,
    gait: 0.0,
    boost: 0.0,
    grounded: true,
    jump_held: 0.0,
    jump_down: false,
  }
}

///|
fn footprint(p : @math3d.Vec3, box : Solid) -> Bool {
  let x = p.x -
    clamp(p.x, box.center.x - box.size.x / 2.0, box.center.x + box.size.x / 2.0)
  let z = p.z -
    clamp(p.z, box.center.z - box.size.z / 2.0, box.center.z + box.size.z / 2.0)
  x * x + z * z < 9.0
}

///|
fn depenetrate(p : @math3d.Vec3, box : Solid) -> @math3d.Vec3 {
  let ax = box.center.x - box.size.x / 2.0
  let bx = box.center.x + box.size.x / 2.0
  let az = box.center.z - box.size.z / 2.0
  let bz = box.center.z + box.size.z / 2.0
  let dx = p.x - clamp(p.x, ax, bx)
  let dz = p.z - clamp(p.z, az, bz)
  let d = (dx * dx + dz * dz).sqrt()
  if d >= 3.0 {
    return p
  }
  if d > 0.00000001 {
    return vec(p.x + dx * (3.0 - d) / d, p.y, p.z + dz * (3.0 - d) / d)
  }
  let exits = [
    vec(ax - 3.0 - p.x, 0.0, 0.0),
    vec(bx + 3.0 - p.x, 0.0, 0.0),
    vec(0.0, 0.0, az - 3.0 - p.z),
    vec(0.0, 0.0, bz + 3.0 - p.z),
  ]
  let mut best = exits[0]
  for e in exits {
    if e.length_squared() < best.length_squared() {
      best = e
    }
  }
  p.add(best)
}

///|
pub fn advance_pilot(
  previous : Pilot,
  i : Input,
  delta : Double,
  stage : Stage,
  targets : Array[Solid],
) -> Pilot {
  let p = { ..previous, yaw: i.yaw, pitch: clamp(i.pitch, -0.2, 1.05) }
  let dt = if delta >= -1.7976931348623157e308 &&
    delta <= 1.7976931348623157e308 {
    clamp(delta, 0.0, 0.1)
  } else {
    0.0
  }
  let steps = max(1.0, (dt * 120.0).ceil()).to_int()
  let h = dt / steps.to_double()
  let length = max(1.0, (i.forward * i.forward + i.strafe * i.strafe).sqrt())
  let f = i.forward / length
  let r = i.strafe / length
  let moving = f.abs() + r.abs() > 0.01
  let boxes = stage.solids.copy()
  for b in targets {
    boxes.push(b)
  }
  if dt > 0.0 && i.jump && !previous.jump_down && p.grounded {
    p.velocity = vec(p.velocity.x, 8.0, p.velocity.z)
    p.grounded = false
  }
  for _ in 0..<steps {
    p.jump_held = if i.jump { p.jump_held + h } else { 0.0 }
    let air = i.jump && p.jump_held >= 0.22 && !p.grounded
    let boosting = (i.boost && moving) || air
    let speed = if boosting { 14.4 } else { 3.2 }
    let dx = (@math.sin(p.yaw) * f - @math.cos(p.yaw) * r) * speed
    let dz = (@math.cos(p.yaw) * f + @math.sin(p.yaw) * r) * speed
    let blend = 1.0 - @math.exp(-9.0 * h)
    let vy = p.velocity.y +
      (if air {
        (7.5 - p.velocity.y) * (1.0 - @math.exp(-6.0 * h))
      } else {
        -18.0 * h
      })
    p.velocity = vec(
      p.velocity.x + (dx - p.velocity.x) * blend,
      vy,
      p.velocity.z + (dz - p.velocity.z) * blend,
    )
    let start = p.position
    p.position = p.position.add(p.velocity.scale(h))
    p.grounded = false
    let mut floor = 0.0
    for b in boxes {
      if footprint(p.position, b) {
        let top = b.center.y + b.size.y / 2.0
        let bottom = b.center.y - b.size.y / 2.0
        if start.y >= top - 0.000001 {
          floor = max(floor, top)
        }
        if p.velocity.y > 0.0 &&
          start.y + 3.6 <= bottom &&
          p.position.y + 3.6 >= bottom {
          p.position = vec(p.position.x, bottom - 3.6, p.position.z)
          p.velocity = vec(p.velocity.x, 0.0, p.velocity.z)
        }
      }
    }
    if p.velocity.y <= 0.0 && p.position.y <= floor {
      p.position = vec(p.position.x, floor, p.position.z)
      p.velocity = vec(p.velocity.x, 0.0, p.velocity.z)
      p.grounded = true
    }
    if p.position.y > 40.0 {
      p.position = vec(p.position.x, 40.0, p.position.z)
      p.velocity = vec(p.velocity.x, min(0.0, p.velocity.y), p.velocity.z)
    }
    for _ in 0..<3 {
      for b in boxes {
        if p.position.y < b.center.y + b.size.y / 2.0 - 0.000001 &&
          p.position.y + 3.6 > b.center.y - b.size.y / 2.0 + 0.000001 {
          p.position = depenetrate(p.position, b)
        }
      }
    }
    p.position = vec(
      clamp(p.position.x, stage.min_x + 3.0, stage.max_x - 3.0),
      p.position.y,
      clamp(p.position.z, stage.min_z + 3.0, stage.max_z - 3.0),
    )
    if h > 0.0 {
      p.velocity = vec(
        (p.position.x - start.x) / h,
        p.velocity.y,
        (p.position.z - start.z) / h,
      )
    }
    p.gait += distance(p.position, start) / (0.72 / (0.62 * 2.4))
    p.boost += ((if boosting { 1.0 } else { 0.0 }) - p.boost) *
      (1.0 - @math.exp(-7.0 * h))
  }
  if dt > 0.0 {
    p.jump_down = i.jump
  }
  p
}

///|
pub fn box_intersection(
  origin : @math3d.Vec3,
  delta : @math3d.Vec3,
  box : Solid,
  padding? : Double = 0.0,
) -> Double? {
  let os = [origin.x, origin.y, origin.z]
  let ds = [delta.x, delta.y, delta.z]
  let cs = [box.center.x, box.center.y, box.center.z]
  let ss = [box.size.x, box.size.y, box.size.z]
  let mut enter = 0.0
  let mut exit = 1.0
  for a in 0..<3 {
    let lo = cs[a] - ss[a] / 2.0 - padding
    let hi = cs[a] + ss[a] / 2.0 + padding
    if ds[a].abs() < 0.000000001 {
      if os[a] < lo || os[a] > hi {
        return None
      }
      continue
    }
    let x = (lo - os[a]) / ds[a]
    let y = (hi - os[a]) / ds[a]
    enter = max(enter, min(x, y))
    exit = min(exit, max(x, y))
    if enter > exit {
      return None
    }
  }
  Some(enter)
}

///|
pub fn camera_target(p : Pilot) -> @math3d.Vec3 {
  p.position.add(vec(0.0, 4.0 + p.boost * 0.5, 0.0))
}

///|
pub fn camera_aim(p : Pilot) -> @math3d.Vec3 {
  camera_target(p).add(
    vec(
      @math.sin(p.yaw) * 12.0 - @math.cos(p.yaw) * 2.4,
      0.0,
      @math.cos(p.yaw) * 12.0 + @math.sin(p.yaw) * 2.4,
    ),
  )
}

///|
pub fn camera_position(p : Pilot) -> @math3d.Vec3 {
  camera_target(p).add(
    vec(
      -@math.sin(p.yaw) * @math.cos(p.pitch) * 17.0 - @math.cos(p.yaw) * 1.5,
      @math.sin(p.pitch) * 17.0 + 1.5,
      -@math.cos(p.yaw) * @math.cos(p.pitch) * 17.0 + @math.sin(p.yaw) * 1.5,
    ),
  )
}

///|
pub fn constrain_camera(
  target : @math3d.Vec3,
  desired : @math3d.Vec3,
  boxes : Array[Solid],
) -> @math3d.Vec3 {
  let delta = desired.sub(target)
  let mut nearest = 1.0
  for b in boxes {
    if box_intersection(target, delta, b, padding=0.3) is Some(t) {
      nearest = min(nearest, max(0.01, t - 0.025))
    }
  }
  target.add(delta.scale(nearest))
}

///|
pub fn view_focus(
  eye : @math3d.Vec3,
  look : @math3d.Vec3,
  boxes : Array[Solid],
) -> @math3d.Vec3 {
  let delta = look.sub(eye).normalize().scale(100.0)
  let mut nearest = 1.0
  for b in boxes {
    if box_intersection(eye, delta, b) is Some(t) {
      nearest = min(nearest, t)
    }
  }
  if delta.y < -0.000000001 && eye.y >= 0.0 {
    nearest = min(nearest, eye.y / -delta.y)
  }
  eye.add(delta.scale(nearest))
}
