///|
fn imported_roundtrip_from_doc(doc : ModelDocument) -> RoundTripImport {
  let nodes : Array[RoundTripImportedNode] = []
  for node in export_scene_nodes(doc) {
    nodes.push({
      source_id: node.source_id,
      node_kind: node.node_kind,
      translation: node.translation,
      scale: node.scale,
      color: node.color,
      primitive_kind: node.primitive_kind,
      stamp_count: node.stamp_count,
    })
  }
  { filename: "edited.glb", document_name: doc.name, nodes }
}

///|
fn set_imported_node_color(
  imported : RoundTripImport,
  source_id : String,
  color : @math3d.Vec4,
) -> RoundTripImport {
  let nodes = imported.nodes.copy()
  for i in 0..<nodes.length() {
    if nodes[i].source_id == source_id {
      nodes[i] = { ..nodes[i], color, }
    }
  }
  { ..imported, nodes, }
}

///|
test "compare_roundtrip_import ignores Blender-quantized color drift with the same hex value" {
  let doc = default_model_document()
  let imported = imported_roundtrip_from_doc(doc)
  let quantized = @math3d.Vec4::new(
    0.9607843160629272, 0.8078431487083435, 0.26274511218070984, 1.0,
  )
  let imported = set_imported_node_color(imported, "left_eye_glow", quantized)
  let report = compare_roundtrip_import(doc, imported)

  assert_eq(report.color_mismatches, [])
}

///|
test "build_roundtrip_patch_plan ignores quantized color drift with the same hex value" {
  let doc = default_model_document()
  let imported = imported_roundtrip_from_doc(doc)
  let quantized = @math3d.Vec4::new(
    0.9607843160629272, 0.8078431487083435, 0.26274511218070984, 1.0,
  )
  let imported = set_imported_node_color(imported, "left_eye_glow", quantized)
  let report = compare_roundtrip_import(doc, imported)
  let plan = build_roundtrip_patch_plan(doc, imported, report)

  assert_eq(report.color_mismatches, [])
  assert_eq(plan.auto_actions.length(), 0)
}

///|
test "compare_roundtrip_import still reports a real color mismatch after quantization" {
  let doc = default_model_document()
  let imported = imported_roundtrip_from_doc(doc)
  let changed = @math3d.Vec4::new(0.2, 0.85, 0.2, 1.0)
  let imported = set_imported_node_color(imported, "left_eye_glow", changed)
  let report = compare_roundtrip_import(doc, imported)

  assert_eq(report.color_mismatches, ["left_eye_glow"])
}
