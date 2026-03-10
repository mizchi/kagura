///|
fn primitive_kind_name(kind : PrimitiveKind) -> String {
  match kind {
    Cube => "cube"
    Sphere => "sphere"
    Plane => "plane"
  }
}

///|
fn sculpt_mode_name(mode : SculptMode) -> String {
  match mode {
    Add => "add"
    Subtract => "subtract"
  }
}

///|
fn document_stats(doc : ModelDocument) -> DocumentStats {
  let mut occupied_voxel_count = 0
  let mut sculpt_render_object_count = 0
  let mut baked_vertex_count = 0
  let mut baked_triangle_count = 0
  for layer in doc.sculpt_layers {
    occupied_voxel_count = occupied_voxel_count +
      layer_occupied_voxel_count(layer)
    let layer_vertices = layer_baked_vertex_count(layer)
    let layer_triangles = layer_baked_triangle_count(layer)
    baked_vertex_count = baked_vertex_count + layer_vertices
    baked_triangle_count = baked_triangle_count + layer_triangles
    if layer_triangles > 0 {
      sculpt_render_object_count = sculpt_render_object_count + 1
    }
  }
  {
    primitive_count: doc.primitives.length(),
    sculpt_layer_count: doc.sculpt_layers.length(),
    occupied_voxel_count,
    render_object_count: doc.primitives.length() + sculpt_render_object_count,
    baked_vertex_count,
    baked_triangle_count,
  }
}

///|
fn document_summary(doc : ModelDocument) -> String {
  let stats = document_stats(doc)
  let buf = StringBuilder::new()
  buf.write_string("MODEL ")
  buf.write_string(doc.name)
  buf.write_string("\n")
  buf.write_string("notes: ")
  buf.write_string(doc.notes)
  buf.write_string("\n")
  buf.write_string("primitives: ")
  buf.write_string(stats.primitive_count.to_string())
  buf.write_string(", sculpt_layers: ")
  buf.write_string(stats.sculpt_layer_count.to_string())
  buf.write_string(", occupied_voxels: ")
  buf.write_string(stats.occupied_voxel_count.to_string())
  buf.write_string(", baked_triangles: ")
  buf.write_string(stats.baked_triangle_count.to_string())
  buf.write_string("\n")
  buf.write_string(
    "edit loop: change primitive/stamp params in model_doc.mbt, rebuild, compare screenshot + JSON context\n",
  )
  buf.to_string()
}

///|
fn selection_kind_name(kind : ModelSelectionKind) -> String {
  match kind {
    PrimitiveSelection => "primitive"
    SculptLayerSelection => "sculpt_layer"
  }
}

///|
fn selection_summary_text(selection : ModelSelection?) -> String {
  match selection {
    Some(current) => selection_kind_name(current.kind) + ":" + current.target_id
    None => "none"
  }
}

///|
fn active_sculpt_layer_id(
  doc : ModelDocument,
  selection : ModelSelection?,
) -> String? {
  match resolve_active_sculpt_layer_index(doc, selection, None) {
    Some(index) =>
      match doc.sculpt_layers.get(index) {
        Some(layer) => Some(layer.id)
        None => None
      }
    None => None
  }
}

///|
fn editor_summary(doc : ModelDocument, selection : ModelSelection?) -> String {
  let buf = StringBuilder::new()
  buf.write_string(document_summary(doc))
  buf.write_string("selection: ")
  buf.write_string(selection_summary_text(selection))
  buf.write_string("\n")
  buf.write_string("active_sculpt_layer: ")
  match active_sculpt_layer_id(doc, selection) {
    Some(layer_id) => buf.write_string(layer_id)
    None => buf.write_string("none")
  }
  buf.write_string("\n")
  buf.to_string()
}

///|
fn document_context_json(doc : ModelDocument) -> String {
  let buf = StringBuilder::new()
  buf.write_string("{")
  append_document_context_fields(buf, doc)
  buf.write_string("}")
  buf.to_string()
}

///|
fn append_document_context_fields(
  buf : StringBuilder,
  doc : ModelDocument,
) -> Unit {
  let stats = document_stats(doc)
  buf.write_string("\"name\":\"")
  buf.write_string(json_escape(doc.name))
  buf.write_string("\",")
  buf.write_string("\"notes\":\"")
  buf.write_string(json_escape(doc.notes))
  buf.write_string("\",")
  buf.write_string("\"stats\":{")
  buf.write_string("\"primitive_count\":")
  buf.write_string(stats.primitive_count.to_string())
  buf.write_string(",\"sculpt_layer_count\":")
  buf.write_string(stats.sculpt_layer_count.to_string())
  buf.write_string(",\"occupied_voxel_count\":")
  buf.write_string(stats.occupied_voxel_count.to_string())
  buf.write_string(",\"render_object_count\":")
  buf.write_string(stats.render_object_count.to_string())
  buf.write_string(",\"baked_vertex_count\":")
  buf.write_string(stats.baked_vertex_count.to_string())
  buf.write_string(",\"baked_triangle_count\":")
  buf.write_string(stats.baked_triangle_count.to_string())
  buf.write_string("},")
  buf.write_string("\"primitives\":[")
  for i in 0..<doc.primitives.length() {
    if i > 0 {
      buf.write_string(",")
    }
    buf.write_string(primitive_node_json(doc.primitives[i]))
  }
  buf.write_string("],")
  buf.write_string("\"sculpt_layers\":[")
  for i in 0..<doc.sculpt_layers.length() {
    if i > 0 {
      buf.write_string(",")
    }
    buf.write_string(sculpt_layer_json(doc.sculpt_layers[i]))
  }
  buf.write_string("]")
}

///|
fn editor_context_json(
  doc : ModelDocument,
  selection : ModelSelection?,
) -> String {
  let active_layer_index = resolve_active_sculpt_layer_index(
    doc,
    selection,
    None,
  )
  let recent_stamps = match active_layer_index {
    Some(index) => recent_sculpt_history(doc, index, 4)
    None => []
  }
  let buf = StringBuilder::new()
  buf.write_string("{")
  append_document_context_fields(buf, doc)
  buf.write_string(",\"selection\":")
  match selection {
    Some(current) => buf.write_string(selection_json(current))
    None => buf.write_string("null")
  }
  buf.write_string(",\"active_sculpt_layer_id\":")
  match active_sculpt_layer_id(doc, selection) {
    Some(layer_id) => {
      buf.write_string("\"")
      buf.write_string(json_escape(layer_id))
      buf.write_string("\"")
    }
    None => buf.write_string("null")
  }
  buf.write_string(",\"recent_stamps\":[")
  for i in 0..<recent_stamps.length() {
    if i > 0 {
      buf.write_string(",")
    }
    buf.write_string(stamp_history_entry_json(recent_stamps[i]))
  }
  buf.write_string("]}")
  buf.to_string()
}

///|
fn selection_json(selection : ModelSelection) -> String {
  let buf = StringBuilder::new()
  buf.write_string("{\"kind\":\"")
  buf.write_string(selection_kind_name(selection.kind))
  buf.write_string("\",\"target_id\":\"")
  buf.write_string(json_escape(selection.target_id))
  buf.write_string("\"}")
  buf.to_string()
}

///|
fn primitive_node_json(node : PrimitiveNode) -> String {
  let buf = StringBuilder::new()
  buf.write_string("{")
  buf.write_string("\"id\":\"")
  buf.write_string(json_escape(node.id))
  buf.write_string("\",\"kind\":\"")
  buf.write_string(primitive_kind_name(node.kind))
  buf.write_string("\",\"position\":")
  buf.write_string(vec3_json(node.position))
  buf.write_string(",\"scale\":")
  buf.write_string(vec3_json(node.scale))
  buf.write_string(",\"color_hex\":\"#")
  buf.write_string(hex6(node.color_hex))
  buf.write_string("\"}")
  buf.to_string()
}

///|
fn sculpt_layer_json(layer : SculptLayer) -> String {
  let buf = StringBuilder::new()
  buf.write_string("{")
  buf.write_string("\"id\":\"")
  buf.write_string(json_escape(layer.id))
  buf.write_string("\",\"voxel_size\":")
  buf.write_string(layer.voxel_size.to_string())
  buf.write_string(",\"half_extent\":")
  buf.write_string(layer.half_extent.to_string())
  buf.write_string(",\"color_hex\":\"#")
  buf.write_string(hex6(layer.color_hex))
  buf.write_string("\",\"muted_stamp_count\":")
  buf.write_string(layer.muted_stamp_ids.length().to_string())
  buf.write_string(",\"occupied_voxel_count\":")
  buf.write_string(layer_occupied_voxel_count(layer).to_string())
  buf.write_string(",\"surface_sample_count\":")
  buf.write_string(layer_baked_surface_sample_count(layer).to_string())
  buf.write_string(",\"baked_vertex_count\":")
  buf.write_string(layer_baked_vertex_count(layer).to_string())
  buf.write_string(",\"baked_triangle_count\":")
  buf.write_string(layer_baked_triangle_count(layer).to_string())
  buf.write_string(",\"stamps\":[")
  for i in 0..<layer.stamps.length() {
    if i > 0 {
      buf.write_string(",")
    }
    buf.write_string(sculpt_stamp_json(layer, layer.stamps[i]))
  }
  buf.write_string("]}")
  buf.to_string()
}

///|
fn sculpt_stamp_json(layer : SculptLayer, stamp : SculptStamp) -> String {
  let buf = StringBuilder::new()
  buf.write_string("{")
  buf.write_string("\"id\":\"")
  buf.write_string(json_escape(stamp.id))
  buf.write_string("\",\"mode\":\"")
  buf.write_string(sculpt_mode_name(stamp.mode))
  buf.write_string("\",\"enabled\":")
  buf.write_string(
    if is_sculpt_stamp_enabled(layer, stamp.id) {
      "true"
    } else {
      "false"
    },
  )
  buf.write_string(",\"center\":")
  buf.write_string(vec3_json(stamp.center))
  buf.write_string(",\"radius\":")
  buf.write_string(stamp.radius.to_string())
  buf.write_string("}")
  buf.to_string()
}

///|
fn stamp_history_entry_json(entry : StampHistoryEntry) -> String {
  let buf = StringBuilder::new()
  buf.write_string("{\"layer_id\":\"")
  buf.write_string(json_escape(entry.layer_id))
  buf.write_string("\",\"id\":\"")
  buf.write_string(json_escape(entry.stamp_id))
  buf.write_string("\",\"mode\":\"")
  buf.write_string(sculpt_mode_name(entry.mode))
  buf.write_string("\",\"enabled\":")
  buf.write_string(if entry.enabled { "true" } else { "false" })
  buf.write_string(",\"center\":")
  buf.write_string(vec3_json(entry.center))
  buf.write_string(",\"radius\":")
  buf.write_string(entry.radius.to_string())
  buf.write_string("}")
  buf.to_string()
}

///|
fn vec3_json(v : @math3d.Vec3) -> String {
  "[" + v.x.to_string() + "," + v.y.to_string() + "," + v.z.to_string() + "]"
}

///|
fn json_escape(text : String) -> String {
  text
  .replace_all(old="\\", new="\\\\")
  .replace_all(old="\"", new="\\\"")
  .replace_all(old="\n", new="\\n")
  .replace_all(old="\r", new="\\r")
  .replace_all(old="\t", new="\\t")
}

///|
fn hex6(value : Int) -> String {
  let buf = StringBuilder::new()
  let digits : Array[Char] = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F',
  ]
  for shift in [20, 16, 12, 8, 4, 0] {
    let idx = (value >> shift) & 0xF
    buf.write_char(digits[idx])
  }
  buf.to_string()
}
