///|
fn hex_to_vec4(hex : Int) -> @math3d.Vec4 {
  let r = ((hex >> 16) & 0xFF).to_double() / 255.0
  let g = ((hex >> 8) & 0xFF).to_double() / 255.0
  let b = (hex & 0xFF).to_double() / 255.0
  @math3d.Vec4::new(r, g, b, 1.0)
}

///|
fn primitive_mesh(kind : PrimitiveKind) -> @mesh3d.Mesh3D {
  match kind {
    Cube => @mesh3d.Mesh3D::cube(1.0)
    Sphere => @mesh3d.Mesh3D::sphere(0.5, 16, 12)
    Plane => @mesh3d.Mesh3D::plane(1.0, 1.0, subdivisions=1)
  }
}

///|
fn highlight_overlay_color() -> @math3d.Vec4 {
  @math3d.Vec4::new(1.0, 0.9, 0.5, 0.72)
}

///|
fn gizmo_axis_color(axis : GizmoAxis, active : Bool) -> @math3d.Vec4 {
  match (axis, active) {
    (GizmoAxisX, false) => @math3d.Vec4::new(0.95, 0.3, 0.3, 0.92)
    (GizmoAxisY, false) => @math3d.Vec4::new(0.35, 0.9, 0.4, 0.92)
    (GizmoAxisZ, false) => @math3d.Vec4::new(0.35, 0.55, 0.98, 0.92)
    (GizmoAxisX, true) => @math3d.Vec4::new(1.0, 0.72, 0.72, 0.98)
    (GizmoAxisY, true) => @math3d.Vec4::new(0.72, 1.0, 0.74, 0.98)
    (GizmoAxisZ, true) => @math3d.Vec4::new(0.72, 0.82, 1.0, 0.98)
  }
}

///|
fn build_render_objects(doc : ModelDocument) -> Array[@scene3d.Object3D] {
  let objects : Array[@scene3d.Object3D] = []
  for node in doc.primitives {
    objects.push(
      @scene3d.object3d(
        mesh=primitive_mesh(node.kind),
        position=node.position,
        scale=node.scale,
        color=hex_to_vec4(node.color_hex),
      ),
    )
  }
  for layer in doc.sculpt_layers {
    append_sculpt_layer_mesh_object(
      objects,
      layer,
      hex_to_vec4(layer.color_hex),
      layer.voxel_size * 0.18,
    )
  }
  objects
}

///|
fn build_gizmo_handle_objects(
  doc : ModelDocument,
  selection : ModelSelection?,
  hover_hit : GizmoHandleHit?,
  drag : GizmoDragState?,
) -> Array[@scene3d.Object3D] {
  let objects : Array[@scene3d.Object3D] = []
  let cube = @mesh3d.Mesh3D::cube(1.0)
  match selection {
    Some(current) =>
      match current.kind {
        PrimitiveSelection =>
          match primitive_node_by_id(doc, current.target_id) {
            Some(node) =>
              for axis in [GizmoAxisX, GizmoAxisY, GizmoAxisZ] {
                let active = match (hover_hit, drag) {
                  (Some(hit), Some(current_drag)) =>
                    hit.target_id == node.id &&
                    gizmo_axis_eq(hit.axis, axis) &&
                    current_drag.target_id == node.id &&
                    gizmo_axis_eq(current_drag.axis, axis)
                  (Some(hit), None) =>
                    hit.target_id == node.id && gizmo_axis_eq(hit.axis, axis)
                  (None, Some(current_drag)) =>
                    current_drag.target_id == node.id &&
                    gizmo_axis_eq(current_drag.axis, axis)
                  (None, None) => false
                }
                let scale = gizmo_handle_extents(node, axis).scale(
                  if active {
                    2.3
                  } else {
                    2.0
                  },
                )
                objects.push(
                  @scene3d.object3d(
                    mesh=cube,
                    position=gizmo_handle_center(node, axis),
                    scale~,
                    color=gizmo_axis_color(axis, active),
                  ),
                )
              }
            None => ()
          }
        SculptLayerSelection => ()
      }
    None => ()
  }
  objects
}

///|
fn build_selection_overlay_objects(
  doc : ModelDocument,
  selection : ModelSelection?,
) -> Array[@scene3d.Object3D] {
  let objects : Array[@scene3d.Object3D] = []
  match selection {
    Some(current) =>
      match current.kind {
        PrimitiveSelection =>
          for node in doc.primitives {
            if node.id == current.target_id {
              objects.push(
                @scene3d.object3d(
                  mesh=primitive_mesh(node.kind),
                  position=node.position,
                  scale=node.scale.scale(1.08),
                  color=highlight_overlay_color(),
                ),
              )
              break
            }
          }
        SculptLayerSelection =>
          for layer in doc.sculpt_layers {
            if layer.id == current.target_id {
              append_sculpt_layer_mesh_object(
                objects,
                layer,
                highlight_overlay_color(),
                layer.voxel_size * 0.28,
              )
              break
            }
          }
      }
    None => ()
  }
  objects
}

///|
fn append_sculpt_layer_mesh_object(
  objects : Array[@scene3d.Object3D],
  layer : SculptLayer,
  color : @math3d.Vec4,
  inflate : Double,
) -> Unit {
  let mesh = sculpt_layer_baked_mesh_with_inflate(layer, inflate)
  if mesh.triangle_count() > 0 {
    objects.push(@scene3d.object3d(mesh~, color~))
  }
}

///|
fn append_sculpt_layer_objects(
  objects : Array[@scene3d.Object3D],
  layer : SculptLayer,
) -> Unit {
  append_sculpt_layer_mesh_object(
    objects,
    layer,
    hex_to_vec4(layer.color_hex),
    layer.voxel_size * 0.18,
  )
}

///|
fn append_sculpt_layer_objects_with_style(
  objects : Array[@scene3d.Object3D],
  layer : SculptLayer,
  color : @math3d.Vec4,
  cube_scale : Double,
) -> Unit {
  let cube = @mesh3d.Mesh3D::cube(layer.voxel_size * cube_scale)
  let half = layer.half_extent
  for ix in -half..<=half {
    for iy in -half..<=half {
      for iz in -half..<=half {
        let center = voxel_cell_center(layer, ix, iy, iz)
        if sample_sculpt_layer(layer, center) {
          objects.push(@scene3d.object3d(mesh=cube, position=center, color~))
        }
      }
    }
  }
}

///|
fn layer_occupied_voxel_count(layer : SculptLayer) -> Int {
  let mut count = 0
  let half = layer.half_extent
  for ix in -half..<=half {
    for iy in -half..<=half {
      for iz in -half..<=half {
        if sample_sculpt_layer(layer, voxel_cell_center(layer, ix, iy, iz)) {
          count = count + 1
        }
      }
    }
  }
  count
}

///|
fn voxel_cell_center(
  layer : SculptLayer,
  ix : Int,
  iy : Int,
  iz : Int,
) -> @math3d.Vec3 {
  let cell = layer.voxel_size
  @math3d.Vec3::new(
    ix.to_double() * cell,
    iy.to_double() * cell,
    iz.to_double() * cell,
  )
}

///|
fn sample_sculpt_layer(layer : SculptLayer, point : @math3d.Vec3) -> Bool {
  let mut filled = false
  for stamp in layer.stamps {
    if !is_sculpt_stamp_enabled(layer, stamp.id) {
      continue
    }
    let dist = point.distance(stamp.center)
    if dist <= stamp.radius {
      match stamp.mode {
        Add => filled = true
        Subtract => filled = false
      }
    }
  }
  filled
}
