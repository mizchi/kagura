///|
/// Probe the spherical character's feet using the same narrowphase as physics.
/// Walls, ceilings, self hits and separating launches do not count as ground.
pub fn sphere_ground_contact(
  body : @physics3d.RigidBody,
  bodies : Array[@physics3d.RigidBody],
  config : MotorConfig,
) -> GroundContact? {
  guard body.collider is SphereShape(offset, radius) else { return None }
  let probe = {
    ..body,
    collider: @physics3d.SphereShape(offset, radius + config.probe_distance),
  }
  let bounds = probe.world_aabb()
  let mut best : GroundContact? = None
  for other in bodies {
    if other.id == body.id || !bounds.intersects_aabb(other.world_aabb()) {
      continue
    }
    guard @physics3d.generate_contact(probe, other) is Some(contact) else {
      continue
    }
    let normal = contact.normal.negate()
    if normal.y < config.max_slope_cos {
      continue
    }
    let velocity = other.velocity.add(
      other.angular_velocity.cross(contact.contact_point.sub(other.position)),
    )
    if body.velocity.sub(velocity).dot(normal) > 0.5 {
      continue
    }
    if best is Some(previous) && previous.normal.y >= normal.y {
      continue
    }
    best = Some({ body_id: other.id, normal, velocity, })
  }
  best
}
