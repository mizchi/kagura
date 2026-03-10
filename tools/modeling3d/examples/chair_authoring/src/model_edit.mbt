///|
struct WorldRay {
  origin : @math3d.Vec3
  direction : @math3d.Vec3
}

///|
fn clamp_double(
  value : Double,
  min_value : Double,
  max_value : Double,
) -> Double {
  if value < min_value {
    min_value
  } else if value > max_value {
    max_value
  } else {
    value
  }
}

///|
fn clip_to_world(
  inv_view_projection : @math3d.Mat4,
  clip : @math3d.Vec4,
) -> @math3d.Vec3 {
  let world = inv_view_projection.mul_vec4(clip)
  if world.w.abs() < 1.0e-9 {
    world.to_vec3()
  } else {
    @math3d.Vec3::new(world.x / world.w, world.y / world.w, world.z / world.w)
  }
}

///|
fn camera_ray_from_cursor(
  camera : @camera3d.Camera3D,
  screen_w : Int,
  screen_h : Int,
  cursor_x : Double,
  cursor_y : Double,
) -> WorldRay {
  let ndc_x = cursor_x / screen_w.to_double() * 2.0 - 1.0
  let ndc_y = 1.0 - cursor_y / screen_h.to_double() * 2.0
  let inv_view_projection = camera.view_projection_matrix().inverse()
  let near_world = clip_to_world(
    inv_view_projection,
    @math3d.Vec4::new(ndc_x, ndc_y, 0.0, 1.0),
  )
  let far_world = clip_to_world(
    inv_view_projection,
    @math3d.Vec4::new(ndc_x, ndc_y, 1.0, 1.0),
  )
  { origin: near_world, direction: far_world.sub(near_world).normalize() }
}

///|
fn intersect_horizontal_plane(
  ray : WorldRay,
  plane_y : Double,
) -> @math3d.Vec3? {
  if ray.direction.y.abs() < 1.0e-9 {
    if (ray.origin.y - plane_y).abs() < 1.0e-9 {
      Some(ray.origin)
    } else {
      None
    }
  } else {
    let t = (plane_y - ray.origin.y) / ray.direction.y
    if t < 0.0 {
      None
    } else {
      Some(ray.origin.add(ray.direction.scale(t)))
    }
  }
}

///|
fn clamp_point_to_layer_bounds(
  layer : SculptLayer,
  point : @math3d.Vec3,
) -> @math3d.Vec3 {
  let max_axis = layer.voxel_size * layer.half_extent.to_double()
  let focus_y = layer_focus_y(layer)
  @math3d.Vec3::new(
    clamp_double(point.x, -max_axis, max_axis),
    clamp_double(point.y, focus_y - max_axis, focus_y + max_axis),
    clamp_double(point.z, -max_axis, max_axis),
  )
}

///|
fn layer_focus_y(layer : SculptLayer) -> Double {
  let mut total = 0.0
  let mut count = 0
  for stamp in layer.stamps {
    match stamp.mode {
      Add => {
        total = total + stamp.center.y
        count = count + 1
      }
      Subtract => ()
    }
  }
  if count == 0 {
    0.0
  } else {
    total / count.to_double()
  }
}

///|
fn sculpt_mode_name_lower(mode : SculptMode) -> String {
  match mode {
    Add => "add"
    Subtract => "subtract"
  }
}

///|
fn make_sculpt_stamp_id(
  layer_id : String,
  mode : SculptMode,
  stamp_index : Int,
  mirrored : Bool,
) -> String {
  let base = layer_id +
    "_" +
    sculpt_mode_name_lower(mode) +
    "_" +
    stamp_index.to_string()
  if mirrored {
    base + "_mirror"
  } else {
    base
  }
}

///|
fn should_append_mirrored_stamp(center : @math3d.Vec3) -> Bool {
  center.x.abs() > 1.0e-6
}

///|
fn mirrored_stamp_center(center : @math3d.Vec3) -> @math3d.Vec3 {
  @math3d.Vec3::new(-center.x, center.y, center.z)
}

///|
fn append_sculpt_stamp_with_symmetry(
  doc : ModelDocument,
  layer_index : Int,
  mode : SculptMode,
  center : @math3d.Vec3,
  radius : Double,
  mirror_x : Bool,
) -> ModelDocument {
  match doc.sculpt_layers.get(layer_index) {
    None => doc
    Some(layer) => {
      let layers = doc.sculpt_layers.copy()
      let stamps = layer.stamps.copy()
      let clamped_center = clamp_point_to_layer_bounds(layer, center)
      let stamp_count = stamps.length()
      stamps.push({
        id: make_sculpt_stamp_id(layer.id, mode, stamp_count, false),
        mode,
        center: clamped_center,
        radius,
      })
      if mirror_x && should_append_mirrored_stamp(clamped_center) {
        stamps.push({
          id: make_sculpt_stamp_id(layer.id, mode, stamp_count + 1, true),
          mode,
          center: clamp_point_to_layer_bounds(
            layer,
            mirrored_stamp_center(clamped_center),
          ),
          radius,
        })
      }
      layers[layer_index] = {
        id: layer.id,
        voxel_size: layer.voxel_size,
        half_extent: layer.half_extent,
        color_hex: layer.color_hex,
        muted_stamp_ids: layer.muted_stamp_ids,
        stamps,
      }
      {
        name: doc.name,
        notes: doc.notes,
        primitives: doc.primitives,
        sculpt_layers: layers,
      }
    }
  }
}

///|
fn append_sculpt_stamp(
  doc : ModelDocument,
  layer_index : Int,
  mode : SculptMode,
  center : @math3d.Vec3,
  radius : Double,
) -> ModelDocument {
  append_sculpt_stamp_with_symmetry(
    doc, layer_index, mode, center, radius, false,
  )
}
