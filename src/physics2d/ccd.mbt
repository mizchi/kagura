///|
/// Compute Time of Impact (TOI) for two moving circles.
/// Returns Some(toi) where 0 <= toi <= 1 if they collide during the sweep,
/// or None if no collision.
/// pos_a, vel_a: circle A center and displacement this frame
/// pos_b, vel_b: circle B center and displacement this frame
/// radius_a, radius_b: radii
pub fn sweep_circle_circle(
  pos_a : @vector.Vec2,
  vel_a : @vector.Vec2,
  radius_a : Double,
  pos_b : @vector.Vec2,
  vel_b : @vector.Vec2,
  radius_b : Double,
) -> Double? {
  let r = radius_a + radius_b
  let d = pos_a.sub(pos_b) // relative position
  let v = vel_a.sub(vel_b) // relative velocity
  // Solve |d + v*t|^2 = r^2
  // a*t^2 + 2*b*t + c = 0
  let a = v.dot(v)
  let b = d.dot(v)
  let c = d.dot(d) - r * r
  // Already overlapping at t=0
  if c <= 0.0 {
    return Some(0.0)
  }
  // Not moving toward each other
  if a < 1.0e-12 {
    return None
  }
  let discriminant = b * b - a * c
  if discriminant < 0.0 {
    return None
  }
  let sqrt_disc = discriminant.sqrt()
  let t = (-b - sqrt_disc) / a
  if t >= 0.0 && t <= 1.0 {
    Some(t)
  } else {
    None
  }
}

///|
/// Compute TOI for a moving circle against a static/slow AABB.
/// Uses Minkowski sum approach: expand AABB by circle radius, then ray-cast.
pub fn sweep_circle_aabb(
  circle_pos : @vector.Vec2,
  circle_vel : @vector.Vec2,
  circle_radius : Double,
  aabb_min : @vector.Vec2,
  aabb_max : @vector.Vec2,
) -> Double? {
  // Expand AABB by circle radius (Minkowski sum)
  let expanded_min = @vector.Vec2::new(
    aabb_min.x - circle_radius,
    aabb_min.y - circle_radius,
  )
  let expanded_max = @vector.Vec2::new(
    aabb_max.x + circle_radius,
    aabb_max.y + circle_radius,
  )
  // Check if circle is already inside expanded AABB
  if circle_pos.x >= expanded_min.x &&
    circle_pos.x <= expanded_max.x &&
    circle_pos.y >= expanded_min.y &&
    circle_pos.y <= expanded_max.y {
    return Some(0.0)
  }
  // Ray-cast: find t where circle_pos + circle_vel * t enters expanded AABB
  // Slab method
  let mut t_min = 0.0
  let mut t_max = 1.0
  // X slab
  if circle_vel.x.abs() < 1.0e-12 {
    if circle_pos.x < expanded_min.x || circle_pos.x > expanded_max.x {
      return None
    }
  } else {
    let inv_d = 1.0 / circle_vel.x
    let mut t1 = (expanded_min.x - circle_pos.x) * inv_d
    let mut t2 = (expanded_max.x - circle_pos.x) * inv_d
    if t1 > t2 {
      let tmp = t1
      t1 = t2
      t2 = tmp
    }
    if t1 > t_min {
      t_min = t1
    }
    if t2 < t_max {
      t_max = t2
    }
    if t_min > t_max {
      return None
    }
  }
  // Y slab
  if circle_vel.y.abs() < 1.0e-12 {
    if circle_pos.y < expanded_min.y || circle_pos.y > expanded_max.y {
      return None
    }
  } else {
    let inv_d = 1.0 / circle_vel.y
    let mut t1 = (expanded_min.y - circle_pos.y) * inv_d
    let mut t2 = (expanded_max.y - circle_pos.y) * inv_d
    if t1 > t2 {
      let tmp = t1
      t1 = t2
      t2 = tmp
    }
    if t1 > t_min {
      t_min = t1
    }
    if t2 < t_max {
      t_max = t2
    }
    if t_min > t_max {
      return None
    }
  }
  if t_min >= 0.0 && t_min <= 1.0 {
    Some(t_min)
  } else {
    None
  }
}

///|
/// Perform CCD for a bullet body against all other bodies.
/// Returns the minimum TOI found, or None if no tunnel detected.
pub fn ccd_sweep_body(
  bullet_idx : Int,
  bodies : Array[RigidBody2D],
  dt : Double,
) -> Double? {
  let bullet = bodies[bullet_idx]
  let displacement = bullet.velocity.scale(dt)
  let speed = displacement.length()
  // Skip CCD if displacement is small relative to body size
  let bullet_radius = match bullet.collider {
    CircleShape(_, r) => r
    AABBShape2D(he, _) | OBBShape2D(he, _) => {
      let r = he.length()
      if r < 1.0e-8 { 0.5 } else { r }
    }
  }
  if speed < bullet_radius * 0.5 {
    return None
  }
  let mut min_toi : Double? = None
  for i = 0; i < bodies.length(); i = i + 1 {
    if i == bullet_idx {
      // skip self — use a noop instead of continue (MoonBit JS codegen bug)
    } else {
      let other = bodies[i]
      let other_vel = other.velocity.scale(dt)
      let toi : Double? = match (bullet.collider, other.collider) {
        (CircleShape(off_a, r_a), CircleShape(off_b, r_b)) =>
          sweep_circle_circle(
            bullet.position.add(off_a),
            displacement,
            r_a,
            other.position.add(off_b),
            other_vel,
            r_b,
          )
        (CircleShape(off_a, r_a), AABBShape2D(he, off_b)) => {
          let center = other.position.add(off_b)
          sweep_circle_aabb(
            bullet.position.add(off_a),
            displacement.sub(other_vel),
            r_a,
            center.sub(he),
            center.add(he),
          )
        }
        _ => None // Only circle bullets for now
      }
      match toi {
        Some(t) =>
          match min_toi {
            Some(prev) => if t < prev { min_toi = Some(t) }
            None => min_toi = Some(t)
          }
        None => ()
      }
    }
  }
  min_toi
}
