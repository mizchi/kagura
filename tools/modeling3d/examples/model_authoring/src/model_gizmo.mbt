///|
enum GizmoAxis {
  GizmoAxisX
  GizmoAxisY
  GizmoAxisZ
}

///|
struct GizmoHandleHit {
  target_id : String
  axis : GizmoAxis
  distance : Double
  point : @math3d.Vec3
}

///|
struct GizmoDragState {
  target_id : String
  axis : GizmoAxis
  base_position : @math3d.Vec3
  grab_axis_offset : Double
  plane_normal : @math3d.Vec3
}

///|
fn gizmo_axis_direction(axis : GizmoAxis) -> @math3d.Vec3 {
  match axis {
    GizmoAxisX => @math3d.Vec3::unit_x()
    GizmoAxisY => @math3d.Vec3::unit_y()
    GizmoAxisZ => @math3d.Vec3::unit_z()
  }
}

///|
fn gizmo_axis_eq(lhs : GizmoAxis, rhs : GizmoAxis) -> Bool {
  match (lhs, rhs) {
    (GizmoAxisX, GizmoAxisX) => true
    (GizmoAxisY, GizmoAxisY) => true
    (GizmoAxisZ, GizmoAxisZ) => true
    _ => false
  }
}

///|
fn primitive_node_by_id(
  doc : ModelDocument,
  target_id : String,
) -> PrimitiveNode? {
  for node in doc.primitives {
    if node.id == target_id {
      return Some(node)
    }
  }
  None
}

///|
fn gizmo_handle_offset(node : PrimitiveNode) -> Double {
  max3(node.scale.x, node.scale.y, node.scale.z) * 0.5 + 0.35
}

///|
fn gizmo_handle_thickness(_node : PrimitiveNode) -> Double {
  0.06
}

///|
fn gizmo_handle_extents(node : PrimitiveNode, axis : GizmoAxis) -> @math3d.Vec3 {
  let offset = gizmo_handle_offset(node)
  let thickness = gizmo_handle_thickness(node)
  match axis {
    GizmoAxisX => @math3d.Vec3::new(offset * 0.45, thickness, thickness)
    GizmoAxisY => @math3d.Vec3::new(thickness, offset * 0.45, thickness)
    GizmoAxisZ => @math3d.Vec3::new(thickness, thickness, offset * 0.45)
  }
}

///|
fn gizmo_handle_center(node : PrimitiveNode, axis : GizmoAxis) -> @math3d.Vec3 {
  node.position.add(gizmo_axis_direction(axis).scale(gizmo_handle_offset(node)))
}

///|
fn primitive_gizmo_handle_hit(
  node : PrimitiveNode,
  axis : GizmoAxis,
  ray : WorldRay,
) -> GizmoHandleHit? {
  let collision_ray = @collision3d.Ray::new(ray.origin, ray.direction)
  let result = collision_ray.intersects_aabb(
    @collision3d.AABB::from_center_extents(
      gizmo_handle_center(node, axis),
      gizmo_handle_extents(node, axis),
    ),
  )
  if result.hit {
    Some({
      target_id: node.id,
      axis,
      distance: result.distance,
      point: result.point,
    })
  } else {
    None
  }
}

///|
fn choose_nearer_gizmo_hit(
  current : GizmoHandleHit?,
  next : GizmoHandleHit?,
) -> GizmoHandleHit? {
  match (current, next) {
    (None, None) => None
    (Some(hit), None) => Some(hit)
    (None, Some(hit)) => Some(hit)
    (Some(a), Some(b)) =>
      if b.distance < a.distance {
        Some(b)
      } else {
        Some(a)
      }
  }
}

///|
fn pick_selected_primitive_gizmo_handle(
  doc : ModelDocument,
  selection : ModelSelection?,
  ray : WorldRay,
) -> GizmoHandleHit? {
  match selection {
    Some(current) =>
      match current.kind {
        PrimitiveSelection =>
          match primitive_node_by_id(doc, current.target_id) {
            Some(node) => {
              let mut best : GizmoHandleHit? = None
              for axis in [GizmoAxisX, GizmoAxisY, GizmoAxisZ] {
                best = choose_nearer_gizmo_hit(
                  best,
                  primitive_gizmo_handle_hit(node, axis, ray),
                )
              }
              best
            }
            None => None
          }
        SculptLayerSelection => None
      }
    None => None
  }
}

///|
fn intersect_plane(
  ray : WorldRay,
  plane_point : @math3d.Vec3,
  plane_normal : @math3d.Vec3,
) -> @math3d.Vec3? {
  let denom = ray.direction.dot(plane_normal)
  if denom.abs() < 1.0e-9 {
    if plane_point.sub(ray.origin).dot(plane_normal).abs() < 1.0e-9 {
      Some(ray.origin)
    } else {
      None
    }
  } else {
    let t = plane_point.sub(ray.origin).dot(plane_normal) / denom
    if t < 0.0 {
      None
    } else {
      Some(ray.origin.add(ray.direction.scale(t)))
    }
  }
}

///|
fn gizmo_drag_plane_normal(
  axis : GizmoAxis,
  camera_forward : @math3d.Vec3,
) -> @math3d.Vec3 {
  let axis_dir = gizmo_axis_direction(axis)
  let primary = axis_dir.cross(camera_forward)
  if primary.length() > 1.0e-6 {
    primary.normalize()
  } else {
    let fallback = axis_dir.cross(@math3d.Vec3::unit_y())
    if fallback.length() > 1.0e-6 {
      fallback.normalize()
    } else {
      axis_dir.cross(@math3d.Vec3::unit_x()).normalize()
    }
  }
}

///|
fn begin_gizmo_drag(
  doc : ModelDocument,
  hit : GizmoHandleHit,
  camera_forward : @math3d.Vec3,
) -> GizmoDragState? {
  match primitive_node_by_id(doc, hit.target_id) {
    Some(node) => {
      let axis_dir = gizmo_axis_direction(hit.axis)
      Some({
        target_id: hit.target_id,
        axis: hit.axis,
        base_position: node.position,
        grab_axis_offset: hit.point.sub(node.position).dot(axis_dir),
        plane_normal: gizmo_drag_plane_normal(hit.axis, camera_forward),
      })
    }
    None => None
  }
}

///|
fn set_primitive_position(
  doc : ModelDocument,
  target_id : String,
  next_position : @math3d.Vec3,
) -> ModelDocument {
  let primitives = doc.primitives.copy()
  for i in 0..<primitives.length() {
    let node = primitives[i]
    if node.id == target_id {
      primitives[i] = {
        id: node.id,
        kind: node.kind,
        position: next_position,
        scale: node.scale,
        color_hex: node.color_hex,
      }
      return {
        name: doc.name,
        notes: doc.notes,
        primitives,
        sculpt_layers: doc.sculpt_layers,
      }
    }
  }
  doc
}

///|
fn apply_gizmo_drag(
  doc : ModelDocument,
  drag : GizmoDragState,
  ray : WorldRay,
) -> ModelDocument {
  match intersect_plane(ray, drag.base_position, drag.plane_normal) {
    Some(hit_point) => {
      let axis_dir = gizmo_axis_direction(drag.axis)
      let axis_value = hit_point.sub(drag.base_position).dot(axis_dir)
      let next_position = drag.base_position.add(
        axis_dir.scale(axis_value - drag.grab_axis_offset),
      )
      set_primitive_position(doc, drag.target_id, next_position)
    }
    None => doc
  }
}
