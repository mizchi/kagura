///|
struct RoundTripImportedNode {
  source_id : String
  node_kind : String
  translation : @math3d.Vec3
  scale : @math3d.Vec3
  color : @math3d.Vec4
  primitive_kind : String?
  stamp_count : Int?
}

///|
struct RoundTripImport {
  filename : String
  document_name : String
  nodes : Array[RoundTripImportedNode]
}

///|
struct RoundTripDiffReport {
  filename : String
  imported_document_name : String
  recognized_node_count : Int
  missing_source_ids : Array[String]
  extra_source_ids : Array[String]
  moved_source_ids : Array[String]
  rescaled_source_ids : Array[String]
  color_mismatches : Array[String]
  node_kind_mismatches : Array[String]
  primitive_kind_mismatches : Array[String]
  stamp_count_mismatches : Array[String]
}

///|
fn roundtrip_json_get(obj : Json, key : String) -> Json? {
  match obj {
    Object(map) => map.get(key)
    _ => None
  }
}

///|
fn roundtrip_json_string(val : Json) -> String {
  match val {
    String(s) => s
    _ => ""
  }
}

///|
fn roundtrip_json_int_opt(val : Json) -> Int? {
  match val {
    Number(n, ..) => Some(n.to_int())
    _ => None
  }
}

///|
fn roundtrip_json_double(val : Json) -> Double {
  match val {
    Number(n, ..) => n
    _ => 0.0
  }
}

///|
fn roundtrip_json_array(val : Json) -> Array[Json] {
  match val {
    Array(arr) => arr
    _ => []
  }
}

///|
fn roundtrip_json_vec3(obj : Json, key : String) -> @math3d.Vec3 {
  let values = match roundtrip_json_get(obj, key) {
    Some(value) => roundtrip_json_array(value)
    None => []
  }
  if values.length() >= 3 {
    @math3d.Vec3::new(
      roundtrip_json_double(values[0]),
      roundtrip_json_double(values[1]),
      roundtrip_json_double(values[2]),
    )
  } else {
    @math3d.Vec3::zero()
  }
}

///|
fn roundtrip_json_vec4(obj : Json, key : String) -> @math3d.Vec4 {
  let values = match roundtrip_json_get(obj, key) {
    Some(value) => roundtrip_json_array(value)
    None => []
  }
  if values.length() >= 4 {
    @math3d.Vec4::new(
      roundtrip_json_double(values[0]),
      roundtrip_json_double(values[1]),
      roundtrip_json_double(values[2]),
      roundtrip_json_double(values[3]),
    )
  } else {
    @math3d.Vec4::new(1.0, 1.0, 1.0, 1.0)
  }
}

///|
fn roundtrip_json_object(val : Json) -> Map[String, Json]? {
  match val {
    Object(map) => Some(map)
    _ => None
  }
}

///|
fn roundtrip_material_color(root : Json, node : Json) -> @math3d.Vec4 {
  let mesh_index = match roundtrip_json_get(node, "mesh") {
    Some(value) => roundtrip_json_int_opt(value)
    None => None
  }
  match mesh_index {
    Some(index) => {
      let meshes = match roundtrip_json_get(root, "meshes") {
        Some(value) => roundtrip_json_array(value)
        None => []
      }
      let materials = match roundtrip_json_get(root, "materials") {
        Some(value) => roundtrip_json_array(value)
        None => []
      }
      match meshes.get(index) {
        Some(mesh) =>
          match roundtrip_json_get(mesh, "primitives") {
            Some(value) =>
              match roundtrip_json_array(value).get(0) {
                Some(primitive) =>
                  match roundtrip_json_get(primitive, "material") {
                    Some(material_index_json) =>
                      match roundtrip_json_int_opt(material_index_json) {
                        Some(material_index) =>
                          match materials.get(material_index) {
                            Some(material) =>
                              match
                                roundtrip_json_get(
                                  material, "pbrMetallicRoughness",
                                ) {
                                Some(pbr) =>
                                  roundtrip_json_vec4(pbr, "baseColorFactor")
                                None => @math3d.Vec4::new(1.0, 1.0, 1.0, 1.0)
                              }
                            None => @math3d.Vec4::new(1.0, 1.0, 1.0, 1.0)
                          }
                        None => @math3d.Vec4::new(1.0, 1.0, 1.0, 1.0)
                      }
                    None => @math3d.Vec4::new(1.0, 1.0, 1.0, 1.0)
                  }
                None => @math3d.Vec4::new(1.0, 1.0, 1.0, 1.0)
              }
            None => @math3d.Vec4::new(1.0, 1.0, 1.0, 1.0)
          }
        None => @math3d.Vec4::new(1.0, 1.0, 1.0, 1.0)
      }
    }
    None => @math3d.Vec4::new(1.0, 1.0, 1.0, 1.0)
  }
}

///|
fn parse_roundtrip_import(
  filename : String,
  glb : Bytes,
) -> RoundTripImport raise @gltf.GltfError {
  let (json_text, _buffers) = @gltf.parse_glb(glb)
  let root = @json.parse(json_text) catch { _ => Json::null() }
  let document_name = match roundtrip_json_get(root, "extras") {
    Some(extras) =>
      match roundtrip_json_get(extras, "kagura_document_name") {
        Some(value) => roundtrip_json_string(value)
        None => ""
      }
    None => ""
  }
  let nodes : Array[RoundTripImportedNode] = []
  let json_nodes = match roundtrip_json_get(root, "nodes") {
    Some(value) => roundtrip_json_array(value)
    None => []
  }
  for node in json_nodes {
    let extras = match roundtrip_json_get(node, "extras") {
      Some(value) => roundtrip_json_object(value)
      None => None
    }
    match extras {
      Some(map) =>
        match (map.get("kagura_source_id"), map.get("kagura_node_kind")) {
          (Some(source_id), Some(node_kind)) =>
            nodes.push({
              source_id: roundtrip_json_string(source_id),
              node_kind: roundtrip_json_string(node_kind),
              translation: roundtrip_json_vec3(node, "translation"),
              scale: {
                let scale = roundtrip_json_vec3(node, "scale")
                if scale.approx_eq(@math3d.Vec3::zero(), 1.0e-9) {
                  @math3d.Vec3::one()
                } else {
                  scale
                }
              },
              color: roundtrip_material_color(root, node),
              primitive_kind: match map.get("kagura_primitive_kind") {
                Some(value) => Some(roundtrip_json_string(value))
                None => None
              },
              stamp_count: match map.get("kagura_stamp_count") {
                Some(value) => roundtrip_json_int_opt(value)
                None => None
              },
            })
          _ => ()
        }
      None => ()
    }
  }
  { filename, document_name, nodes }
}

///|
fn roundtrip_node_map(
  nodes : Array[RoundTripImportedNode],
) -> Map[String, RoundTripImportedNode] {
  let map : Map[String, RoundTripImportedNode] = Map([])
  for node in nodes {
    map[node.source_id] = node
  }
  map
}

///|
fn compare_roundtrip_import(
  doc : ModelDocument,
  imported : RoundTripImport,
) -> RoundTripDiffReport {
  let current_nodes = export_scene_nodes(doc)
  let imported_nodes = roundtrip_node_map(imported.nodes)
  let current_ids : Map[String, Bool] = Map([])
  let missing_source_ids : Array[String] = []
  let extra_source_ids : Array[String] = []
  let moved_source_ids : Array[String] = []
  let rescaled_source_ids : Array[String] = []
  let color_mismatches : Array[String] = []
  let node_kind_mismatches : Array[String] = []
  let primitive_kind_mismatches : Array[String] = []
  let stamp_count_mismatches : Array[String] = []
  for current in current_nodes {
    current_ids[current.source_id] = true
    match imported_nodes.get(current.source_id) {
      Some(node) => {
        if !node.translation.approx_eq(current.translation, 1.0e-5) {
          moved_source_ids.push(current.source_id)
        }
        if !node.scale.approx_eq(current.scale, 1.0e-5) {
          rescaled_source_ids.push(current.source_id)
        }
        if !node.color.approx_eq(current.color, 1.0e-5) {
          color_mismatches.push(current.source_id)
        }
        if node.node_kind != current.node_kind {
          node_kind_mismatches.push(current.source_id)
        }
        if node.primitive_kind != current.primitive_kind {
          primitive_kind_mismatches.push(current.source_id)
        }
        if node.stamp_count != current.stamp_count {
          stamp_count_mismatches.push(current.source_id)
        }
      }
      None => missing_source_ids.push(current.source_id)
    }
  }
  for node in imported.nodes {
    if !current_ids.contains(node.source_id) {
      extra_source_ids.push(node.source_id)
    }
  }
  {
    filename: imported.filename,
    imported_document_name: imported.document_name,
    recognized_node_count: imported.nodes.length(),
    missing_source_ids,
    extra_source_ids,
    moved_source_ids,
    rescaled_source_ids,
    color_mismatches,
    node_kind_mismatches,
    primitive_kind_mismatches,
    stamp_count_mismatches,
  }
}

///|
fn roundtrip_changed_count(report : RoundTripDiffReport) -> Int {
  report.moved_source_ids.length() +
  report.rescaled_source_ids.length() +
  report.color_mismatches.length() +
  report.node_kind_mismatches.length() +
  report.primitive_kind_mismatches.length() +
  report.stamp_count_mismatches.length()
}

///|
fn roundtrip_badge_text(report : RoundTripDiffReport) -> String {
  "M" +
  report.missing_source_ids.length().to_string() +
  " E" +
  report.extra_source_ids.length().to_string() +
  " C" +
  roundtrip_changed_count(report).to_string()
}

///|
fn append_string_array_json(
  buf : StringBuilder,
  values : Array[String],
) -> Unit {
  buf.write_string("[")
  for i in 0..<values.length() {
    if i > 0 {
      buf.write_string(",")
    }
    buf.write_string("\"")
    buf.write_string(json_escape(values[i]))
    buf.write_string("\"")
  }
  buf.write_string("]")
}

///|
fn roundtrip_report_json(report : RoundTripDiffReport) -> String {
  let buf = StringBuilder::new()
  buf.write_string("{\"filename\":\"")
  buf.write_string(json_escape(report.filename))
  buf.write_string("\",\"imported_document_name\":\"")
  buf.write_string(json_escape(report.imported_document_name))
  buf.write_string("\",\"recognized_node_count\":")
  buf.write_string(report.recognized_node_count.to_string())
  buf.write_string(",\"missing_source_ids\":")
  append_string_array_json(buf, report.missing_source_ids)
  buf.write_string(",\"extra_source_ids\":")
  append_string_array_json(buf, report.extra_source_ids)
  buf.write_string(",\"moved_source_ids\":")
  append_string_array_json(buf, report.moved_source_ids)
  buf.write_string(",\"rescaled_source_ids\":")
  append_string_array_json(buf, report.rescaled_source_ids)
  buf.write_string(",\"color_mismatches\":")
  append_string_array_json(buf, report.color_mismatches)
  buf.write_string(",\"node_kind_mismatches\":")
  append_string_array_json(buf, report.node_kind_mismatches)
  buf.write_string(",\"primitive_kind_mismatches\":")
  append_string_array_json(buf, report.primitive_kind_mismatches)
  buf.write_string(",\"stamp_count_mismatches\":")
  append_string_array_json(buf, report.stamp_count_mismatches)
  buf.write_string("}")
  buf.to_string()
}

///|
fn append_roundtrip_ids_line(
  buf : StringBuilder,
  label : String,
  ids : Array[String],
) -> Unit {
  if ids.is_empty() {
    return
  }
  buf.write_string(label)
  buf.write_string(": ")
  for i in 0..<ids.length() {
    if i > 0 {
      buf.write_string(", ")
    }
    buf.write_string(ids[i])
  }
  buf.write_string("\n")
}

///|
fn roundtrip_report_summary(report : RoundTripDiffReport) -> String {
  let buf = StringBuilder::new()
  buf.write_string("ROUNDTRIP ")
  buf.write_string(report.filename)
  buf.write_string("\n")
  buf.write_string("imported_document: ")
  if report.imported_document_name.is_empty() {
    buf.write_string("(missing kagura extras)")
  } else {
    buf.write_string(report.imported_document_name)
  }
  buf.write_string("\n")
  buf.write_string("recognized_nodes: ")
  buf.write_string(report.recognized_node_count.to_string())
  buf.write_string(", missing: ")
  buf.write_string(report.missing_source_ids.length().to_string())
  buf.write_string(", extra: ")
  buf.write_string(report.extra_source_ids.length().to_string())
  buf.write_string(", changed: ")
  buf.write_string(roundtrip_changed_count(report).to_string())
  buf.write_string("\n")
  append_roundtrip_ids_line(buf, "missing", report.missing_source_ids)
  append_roundtrip_ids_line(buf, "extra", report.extra_source_ids)
  append_roundtrip_ids_line(buf, "moved", report.moved_source_ids)
  append_roundtrip_ids_line(buf, "rescaled", report.rescaled_source_ids)
  append_roundtrip_ids_line(buf, "color", report.color_mismatches)
  append_roundtrip_ids_line(buf, "node_kind", report.node_kind_mismatches)
  append_roundtrip_ids_line(
    buf,
    "primitive_kind",
    report.primitive_kind_mismatches,
  )
  append_roundtrip_ids_line(buf, "stamp_count", report.stamp_count_mismatches)
  buf.to_string()
}

///|
fn roundtrip_error_json(filename : String, message : String) -> String {
  let buf = StringBuilder::new()
  buf.write_string("{\"filename\":\"")
  buf.write_string(json_escape(filename))
  buf.write_string("\",\"error\":\"")
  buf.write_string(json_escape(message))
  buf.write_string("\"}")
  buf.to_string()
}
