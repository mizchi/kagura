///|
let baumgarte_factor : Double = 0.1

///|
let slop : Double = 0.01

///|
pub fn resolve_contact(
  a : RigidBody,
  b : RigidBody,
  contact : Contact,
) -> (RigidBody, RigidBody) {
  let inv_mass_sum = a.inv_mass + b.inv_mass
  if inv_mass_sum < 1.0e-12 {
    return (a, b)
  }
  let v_rel = a.velocity.sub(b.velocity)
  let v_along_normal = v_rel.dot(contact.normal)
  // Velocity impulse (only when approaching)
  let mut a_new = a
  let mut b_new = b
  if v_along_normal > 0.0 {
    let e = if a.restitution < b.restitution {
      a.restitution
    } else {
      b.restitution
    }
    let j = -(1.0 + e) * v_along_normal / inv_mass_sum
    let impulse = contact.normal.scale(j)
    a_new = {
      ..a_new,
      velocity: a_new.velocity.add(impulse.scale(a.inv_mass)),
    }
    b_new = {
      ..b_new,
      velocity: b_new.velocity.sub(impulse.scale(b.inv_mass)),
    }
    // Friction impulse
    let tangent_vel = v_rel.sub(contact.normal.scale(v_along_normal))
    let tangent_len = tangent_vel.length()
    if tangent_len > 1.0e-12 {
      let tangent = tangent_vel.scale(1.0 / tangent_len)
      let jt = -v_rel.dot(tangent) / inv_mass_sum
      let mu = (a.friction + b.friction) * 0.5
      let j_abs = j.abs()
      let friction_j = if jt.abs() < j_abs * mu {
        jt
      } else {
        j_abs * mu * (if jt >= 0.0 { 1.0 } else { -1.0 })
      }
      let friction_impulse = tangent.scale(friction_j)
      a_new = {
        ..a_new,
        velocity: a_new.velocity.add(friction_impulse.scale(a.inv_mass)),
      }
      b_new = {
        ..b_new,
        velocity: b_new.velocity.sub(friction_impulse.scale(b.inv_mass)),
      }
    }
  }
  // Position correction (always applied to fix penetration)
  let (a_final, b_final) = apply_position_correction(
    a_new, b_new, contact, inv_mass_sum,
  )
  (a_final, b_final)
}

///|
fn apply_position_correction(
  a : RigidBody,
  b : RigidBody,
  contact : Contact,
  inv_mass_sum : Double,
) -> (RigidBody, RigidBody) {
  let correction_mag = if contact.penetration - slop > 0.0 {
    (contact.penetration - slop) * baumgarte_factor / inv_mass_sum
  } else {
    0.0
  }
  if correction_mag < 1.0e-12 {
    return (a, b)
  }
  let correction = contact.normal.scale(correction_mag)
  let a_new = {
    ..a,
    position: a.position.sub(correction.scale(a.inv_mass)),
  }
  let b_new = {
    ..b,
    position: b.position.add(correction.scale(b.inv_mass)),
  }
  (a_new, b_new)
}
