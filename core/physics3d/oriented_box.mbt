///|
fn box_axes(rotation : @math3d.Quaternion) -> Array[@math3d.Vec3] {
  [
    rotation.rotate_vec3(@math3d.Vec3::unit_x()),
    rotation.rotate_vec3(@math3d.Vec3::unit_y()),
    rotation.rotate_vec3(@math3d.Vec3::unit_z()),
  ]
}

///|
fn box_frame(
  body : RigidBody,
) -> (@math3d.Vec3, @math3d.Vec3, @math3d.Quaternion) {
  match body.collider {
    AABBShape(he, offset) =>
      (body.position.add(offset), he, @math3d.Quaternion::identity())
    BoxShape(he, offset) =>
      (body.position.add(body.rotation.rotate_vec3(offset)), he, body.rotation)
    SphereShape(_, _) => abort("Expected box collider")
  }
}

///|
pub fn RigidBody::raycast(
  self : RigidBody,
  ray : @collision3d.Ray,
) -> @collision3d.HitResult {
  match self.collider {
    SphereShape(offset, radius) =>
      ray.intersects_sphere(
        @collision3d.Sphere::new(self.position.add(offset), radius),
      )
    AABBShape(_, _) => ray.intersects_aabb(self.world_aabb())
    BoxShape(_, _) => {
      let (center, he, rotation) = box_frame(self)
      let inverse = rotation.conjugate()
      let local_space = @collision3d.Ray::new(
        inverse.rotate_vec3(ray.origin.sub(center)),
        inverse.rotate_vec3(ray.direction),
      )
      let hit = local_space.intersects_aabb(
        @collision3d.AABB::new(he.negate(), he),
      )
      { ..hit, point: center.add(rotation.rotate_vec3(hit.point)), }
    }
  }
}

///|
pub fn RigidBody::intersects_sphere(
  self : RigidBody,
  sphere : @collision3d.Sphere,
) -> Bool {
  match self.collider {
    SphereShape(offset, radius) =>
      @collision3d.Sphere::new(self.position.add(offset), radius).intersects_sphere(
        sphere,
      )
    AABBShape(_, _) => self.world_aabb().intersects_sphere(sphere)
    BoxShape(_, _) => {
      let (center, he, rotation) = box_frame(self)
      let point = rotation.conjugate().rotate_vec3(sphere.center.sub(center))
      @collision3d.AABB::new(he.negate(), he).intersects_sphere(
        @collision3d.Sphere::new(point, sphere.radius),
      )
    }
  }
}

///|
fn sphere_box(
  sphere : RigidBody,
  offset : @math3d.Vec3,
  radius : Double,
  box : RigidBody,
  he : @math3d.Vec3,
  box_offset : @math3d.Vec3,
  swapped : Bool,
) -> Contact? {
  let center = box.position.add(box.rotation.rotate_vec3(box_offset))
  let local_sphere = {
    ..sphere,
    position: box.rotation
    .conjugate()
    .rotate_vec3(sphere.position.add(offset).sub(center)),
  }
  let local_box = { ..box, position: @math3d.Vec3::zero(), }
  match
    sphere_aabb(
      local_sphere,
      @math3d.Vec3::zero(),
      radius,
      local_box,
      he,
      @math3d.Vec3::zero(),
      swapped,
    ) {
    None => None
    Some(contact) =>
      Some({
        ..contact,
        normal: box.rotation.rotate_vec3(contact.normal),
        contact_point: center.add(
          box.rotation.rotate_vec3(contact.contact_point),
        ),
      })
  }
}

///|
fn box_radius(
  axes : Array[@math3d.Vec3],
  half : @math3d.Vec3,
  n : @math3d.Vec3,
) -> Double {
  axes[0].dot(n).abs() * half.x +
  axes[1].dot(n).abs() * half.y +
  axes[2].dot(n).abs() * half.z
}

///|
/// SAT: the six face normals plus the nine edge cross products separate boxes.
/// Unlike a manifold solver, this engine retains one representative contact.
fn box_box(a : RigidBody, b : RigidBody) -> Contact? {
  let (ca, ha, qa) = box_frame(a)
  let (cb, hb, qb) = box_frame(b)
  let aa = box_axes(qa)
  let ab = box_axes(qb)
  let axes = aa.copy()
  for n in ab {
    axes.push(n)
  }
  for u in aa {
    for v in ab {
      let n = u.cross(v)
      if n.length_squared() > 1.0e-12 {
        axes.push(n.normalize())
      }
    }
  }
  let delta = cb.sub(ca)
  let mut penetration = 1.0e30
  let mut normal = @math3d.Vec3::unit_y()
  for axis in axes {
    let overlap = box_radius(aa, ha, axis) +
      box_radius(ab, hb, axis) -
      delta.dot(axis).abs()
    if overlap <= 0.0 {
      return None
    }
    if overlap < penetration {
      penetration = overlap
      normal = if delta.dot(axis) >= 0.0 { axis } else { axis.negate() }
    }
  }
  // Project the smaller box center onto the larger box; retain its tangential
  // location so a small box on a large slab does not get a remote contact arm.
  let (surface_center, surface_half, surface_rotation, point) = if ha.length_squared() >
    hb.length_squared() {
    (ca, ha, qa, cb)
  } else {
    (cb, hb, qb, ca)
  }
  let local_space = surface_rotation
    .conjugate()
    .rotate_vec3(point.sub(surface_center))
  let closest = @collision3d.AABB::new(surface_half.negate(), surface_half).closest_point(
    local_space,
  )
  let contact_point = surface_center.add(surface_rotation.rotate_vec3(closest))
  Some({ body_a_id: a.id, body_b_id: b.id, normal, penetration, contact_point, })
}
