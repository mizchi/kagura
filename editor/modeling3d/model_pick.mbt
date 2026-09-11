///|
pub(all) enum SurfaceKind {
  PrimitiveSurface
  SculptSurface
  BakedSculptSurface
}

///|
pub(all) struct SurfaceHit {
  kind : SurfaceKind
  target_id : String
  distance : Double
  point : @math3d.Vec3
}

///|
fn choose_nearer_hit(current : SurfaceHit?, next : SurfaceHit?) -> SurfaceHit? {
  match (current, next) {
    (None, None) => None
    (Some(hit), None) => {
      ignore(hit.point)
      Some(hit)
    }
    (None, Some(hit)) => {
      ignore(hit.point)
      Some(hit)
    }
    (Some(a), Some(b)) => {
      ignore(a.point)
      ignore(b.point)
      if b.distance < a.distance {
        Some(b)
      } else {
        Some(a)
      }
    }
  }
}

///|
fn max3(a : Double, b : Double, c : Double) -> Double {
  let ab = if a > b { a } else { b }
  if ab > c {
    ab
  } else {
    c
  }
}

///|
fn primitive_surface_hit(node : PrimitiveNode, ray : WorldRay) -> SurfaceHit? {
  let collision_ray = @collision3d.Ray::new(ray.origin, ray.direction)
  match node.kind {
    Plane => None
    Cube => {
      let extents = node.scale.scale(0.5)
      let result = collision_ray.intersects_aabb(
        @collision3d.AABB::from_center_extents(node.position, extents),
      )
      if result.hit {
        Some({
          kind: PrimitiveSurface,
          target_id: node.id,
          distance: result.distance,
          point: result.point,
        })
      } else {
        None
      }
    }
    Sphere => {
      let radius = max3(node.scale.x, node.scale.y, node.scale.z) * 0.5
      let result = collision_ray.intersects_sphere(
        @collision3d.Sphere::new(node.position, radius),
      )
      if result.hit {
        Some({
          kind: PrimitiveSurface,
          target_id: node.id,
          distance: result.distance,
          point: result.point,
        })
      } else {
        None
      }
    }
  }
}

///|
fn baked_surface_sample_hit(
  sample : BakedSurfaceSample,
  ray : WorldRay,
) -> SurfaceHit? {
  let collision_ray = @collision3d.Ray::new(ray.origin, ray.direction)
  let extents = if sample.normal.x.abs() > 0.5 {
    @math3d.Vec3::new(sample.thickness, sample.half_span, sample.half_span)
  } else if sample.normal.y.abs() > 0.5 {
    @math3d.Vec3::new(sample.half_span, sample.thickness, sample.half_span)
  } else {
    @math3d.Vec3::new(sample.half_span, sample.half_span, sample.thickness)
  }
  let result = collision_ray.intersects_aabb(
    @collision3d.AABB::from_center_extents(sample.position, extents),
  )
  if result.hit {
    Some({
      kind: BakedSculptSurface,
      target_id: sample.layer_id,
      distance: result.distance,
      point: sample.position,
    })
  } else {
    None
  }
}

///|
fn sculpt_layer_baked_surface_hit(
  layer : SculptLayer,
  ray : WorldRay,
) -> SurfaceHit? {
  let mut best : SurfaceHit? = None
  for sample in sculpt_layer_baked_surface_samples(layer) {
    best = choose_nearer_hit(best, baked_surface_sample_hit(sample, ray))
  }
  best
}

///|
fn sculpt_layer_voxel_surface_hit(
  layer : SculptLayer,
  ray : WorldRay,
) -> SurfaceHit? {
  let collision_ray = @collision3d.Ray::new(ray.origin, ray.direction)
  let mut best : SurfaceHit? = None
  let half = layer.half_extent
  let extent = @math3d.Vec3::new(
    layer.voxel_size * 0.45,
    layer.voxel_size * 0.45,
    layer.voxel_size * 0.45,
  )
  for ix in -half..<=half {
    for iy in -half..<=half {
      for iz in -half..<=half {
        let center = voxel_cell_center(layer, ix, iy, iz)
        if sample_sculpt_layer(layer, center) {
          let result = collision_ray.intersects_aabb(
            @collision3d.AABB::from_center_extents(center, extent),
          )
          if result.hit {
            best = choose_nearer_hit(
              best,
              Some({
                kind: SculptSurface,
                target_id: layer.id,
                distance: result.distance,
                point: result.point,
              }),
            )
          }
        }
      }
    }
  }
  best
}

///|
fn sculpt_layer_surface_hit(layer : SculptLayer, ray : WorldRay) -> SurfaceHit? {
  match sculpt_layer_baked_surface_hit(layer, ray) {
    Some(hit) => Some(hit)
    None => sculpt_layer_voxel_surface_hit(layer, ray)
  }
}

///|
pub fn pick_document_surface_hit(
  doc : ModelDocument,
  ray : WorldRay,
) -> SurfaceHit? {
  let mut best : SurfaceHit? = None
  for node in doc.primitives {
    best = choose_nearer_hit(best, primitive_surface_hit(node, ray))
  }
  for layer in doc.sculpt_layers {
    best = choose_nearer_hit(best, sculpt_layer_surface_hit(layer, ray))
  }
  best
}
