///|
pub fn sweep_sphere_sphere(
  pos_a : @math3d.Vec3,
  vel_a : @math3d.Vec3,
  radius_a : Double,
  pos_b : @math3d.Vec3,
  vel_b : @math3d.Vec3,
  radius_b : Double,
) -> Double? {
  let r = radius_a + radius_b
  let d = pos_a.sub(pos_b)
  let v = vel_a.sub(vel_b)
  let a = v.dot(v)
  let b = d.dot(v)
  let c = d.dot(d) - r * r
  if c <= 0.0 {
    return Some(0.0)
  }
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
pub fn sweep_sphere_aabb(
  sphere_pos : @math3d.Vec3,
  sphere_vel : @math3d.Vec3,
  sphere_radius : Double,
  aabb_min : @math3d.Vec3,
  aabb_max : @math3d.Vec3,
) -> Double? {
  let expanded_min = @math3d.Vec3::new(
    aabb_min.x - sphere_radius,
    aabb_min.y - sphere_radius,
    aabb_min.z - sphere_radius,
  )
  let expanded_max = @math3d.Vec3::new(
    aabb_max.x + sphere_radius,
    aabb_max.y + sphere_radius,
    aabb_max.z + sphere_radius,
  )
  if sphere_pos.x >= expanded_min.x &&
    sphere_pos.x <= expanded_max.x &&
    sphere_pos.y >= expanded_min.y &&
    sphere_pos.y <= expanded_max.y &&
    sphere_pos.z >= expanded_min.z &&
    sphere_pos.z <= expanded_max.z {
    return Some(0.0)
  }
  // Slab ray-cast
  let mut t_min = 0.0
  let mut t_max = 1.0
  // X slab
  if sphere_vel.x.abs() < 1.0e-12 {
    if sphere_pos.x < expanded_min.x || sphere_pos.x > expanded_max.x {
      return None
    }
  } else {
    let inv_d = 1.0 / sphere_vel.x
    let mut t1 = (expanded_min.x - sphere_pos.x) * inv_d
    let mut t2 = (expanded_max.x - sphere_pos.x) * inv_d
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
  if sphere_vel.y.abs() < 1.0e-12 {
    if sphere_pos.y < expanded_min.y || sphere_pos.y > expanded_max.y {
      return None
    }
  } else {
    let inv_d = 1.0 / sphere_vel.y
    let mut t1 = (expanded_min.y - sphere_pos.y) * inv_d
    let mut t2 = (expanded_max.y - sphere_pos.y) * inv_d
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
  // Z slab
  if sphere_vel.z.abs() < 1.0e-12 {
    if sphere_pos.z < expanded_min.z || sphere_pos.z > expanded_max.z {
      return None
    }
  } else {
    let inv_d = 1.0 / sphere_vel.z
    let mut t1 = (expanded_min.z - sphere_pos.z) * inv_d
    let mut t2 = (expanded_max.z - sphere_pos.z) * inv_d
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
pub fn ccd_sweep_body3d(
  bullet_idx : Int,
  bodies : Array[RigidBody],
  dt : Double,
) -> Double? {
  let bullet = bodies[bullet_idx]
  let displacement = bullet.velocity.scale(dt)
  let speed = displacement.length()
  let bullet_radius = match bullet.collider {
    SphereShape(_, r) => r
    AABBShape(he, _) => he.length()
  }
  if speed < bullet_radius * 0.5 {
    return None
  }
  let mut min_toi : Double? = None
  for i = 0; i < bodies.length(); i = i + 1 {
    if i == bullet_idx {
      // skip self
    } else {
      let other = bodies[i]
      let other_vel = other.velocity.scale(dt)
      let toi : Double? = match (bullet.collider, other.collider) {
        (SphereShape(off_a, r_a), SphereShape(off_b, r_b)) =>
          sweep_sphere_sphere(
            bullet.position.add(off_a),
            displacement,
            r_a,
            other.position.add(off_b),
            other_vel,
            r_b,
          )
        (SphereShape(off_a, r_a), AABBShape(he, off_b)) => {
          let center = other.position.add(off_b)
          sweep_sphere_aabb(
            bullet.position.add(off_a),
            displacement.sub(other_vel),
            r_a,
            center.sub(he),
            center.add(he),
          )
        }
        _ => None
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
