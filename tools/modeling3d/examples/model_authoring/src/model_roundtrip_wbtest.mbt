///|
fn assert_roundtrip_vec4_approx_eq(
  actual : @math3d.Vec4,
  expected : @math3d.Vec4,
  epsilon : Double,
) -> Unit raise {
  assert_true((actual.x - expected.x).abs() <= epsilon)
  assert_true((actual.y - expected.y).abs() <= epsilon)
  assert_true((actual.z - expected.z).abs() <= epsilon)
  assert_true((actual.w - expected.w).abs() <= epsilon)
}

///|
fn roundtrip_node_by_source_id(
  imported : @modeling3d.RoundTripImport,
  source_id : String,
) -> @modeling3d.RoundTripImportedNode? {
  for node in imported.nodes {
    if node.source_id == source_id {
      return Some(node)
    }
  }
  None
}

///|
test "parse_roundtrip_import extracts kagura extras from exported glb" {
  let doc = default_model_document()
  let imported = @modeling3d.parse_roundtrip_import(
    "edited.glb",
    @modeling3d.document_glb_bytes(doc),
  )

  assert_eq(imported.filename, "edited.glb")
  assert_eq(imported.document_name, "vlm_clay_totem")
  assert_eq(imported.nodes.length(), 4)

  let pedestal = roundtrip_node_by_source_id(imported, "pedestal").unwrap()
  assert_eq(pedestal.node_kind, "primitive")
  assert_eq(pedestal.primitive_kind, Some("cube"))
  assert_eq(pedestal.stamp_count, None)
  assert_roundtrip_vec4_approx_eq(
    pedestal.color,
    @modeling3d.hex_to_vec4(doc.primitives[1].color_hex),
    1.0e-6,
  )
  assert_true(
    pedestal.translation.approx_eq(doc.primitives[1].position, 1.0e-6),
  )

  let clay_head = roundtrip_node_by_source_id(imported, "clay_head").unwrap()
  assert_eq(clay_head.node_kind, "sculpt_layer")
  assert_eq(clay_head.primitive_kind, None)
  assert_eq(clay_head.stamp_count, Some(6))
}

///|
test "compare_roundtrip_import reports missing extra and changed nodes" {
  let base = default_model_document()
  let imported_primitives = base.primitives.copy()
  imported_primitives[1] = {
    ..imported_primitives[1],
    position: @math3d.Vec3::new(0.35, -0.25, 0.0),
    color_hex: 0xE39C54,
  }
  ignore(imported_primitives.remove(2))
  imported_primitives.push({
    id: "blender_helper",
    kind: Cube,
    position: @math3d.Vec3::new(1.2, 0.0, 0.0),
    scale: @math3d.Vec3::new(0.2, 0.2, 0.2),
    color_hex: 0xAAAAAA,
  })
  let imported_layers = base.sculpt_layers.copy()
  let imported_stamps = imported_layers[0].stamps.copy()
  imported_stamps.push({
    id: "nose_add",
    mode: @modeling3d.SculptMode::Add,
    center: @math3d.Vec3::new(0.0, 0.74, 0.44),
    radius: 0.08,
  })
  imported_layers[0] = { ..imported_layers[0], stamps: imported_stamps }
  let imported_doc = {
    ..base,
    primitives: imported_primitives,
    sculpt_layers: imported_layers,
  }

  let imported = @modeling3d.parse_roundtrip_import(
    "edited.glb",
    @modeling3d.document_glb_bytes(imported_doc),
  )
  let report = @modeling3d.compare_roundtrip_import(base, imported)

  assert_eq(report.filename, "edited.glb")
  assert_eq(report.imported_document_name, "vlm_clay_totem")
  assert_eq(report.recognized_node_count, 4)
  assert_eq(report.missing_source_ids, ["guide_orb"])
  assert_eq(report.extra_source_ids, ["blender_helper"])
  assert_eq(report.moved_source_ids, ["pedestal"])
  assert_eq(report.rescaled_source_ids, [])
  assert_eq(report.node_kind_mismatches, [])
  assert_eq(report.color_mismatches, [])
  assert_eq(report.primitive_kind_mismatches, [])
  assert_eq(report.stamp_count_mismatches, ["clay_head"])
  assert_eq(@modeling3d.roundtrip_badge_text(report), "M1 E1 C2")
  assert_true(
    @modeling3d.roundtrip_report_json(report).contains("\"blender_helper\""),
  )
  assert_true(
    @modeling3d.roundtrip_report_summary(report).contains("moved: pedestal"),
  )
}
