///|
test "default model document exposes promptable structure" {
  let doc = default_model_document()
  let stats = @modeling3d.document_stats(doc)
  let context_json = @modeling3d.document_context_json(doc)

  assert_eq(doc.name, "vlm_clay_totem")
  assert_eq(doc.primitives.length(), 3)
  assert_eq(doc.sculpt_layers.length(), 1)
  assert_true(stats.occupied_voxel_count > 0)
  assert_eq(stats.render_object_count, doc.primitives.length() + 1)
  assert_true(stats.baked_triangle_count > 0)
  assert_true(context_json.contains("\"name\":\"vlm_clay_totem\""))
  assert_true(context_json.contains("\"sculpt_layers\""))
  assert_true(context_json.contains("\"surface_sample_count\":"))
  assert_true(context_json.contains("\"baked_triangle_count\":"))
}

///|
test "render objects include baked sculpt mesh and hard-surface primitives" {
  let doc = default_model_document()
  let objects = @modeling3d.build_render_objects(doc)
  let stats = @modeling3d.document_stats(doc)

  assert_eq(objects.length(), stats.render_object_count)
  assert_eq(objects.length(), doc.primitives.length() + 1)
}

///|
test "context json escapes user-editable string fields" {
  let doc : @modeling3d.ModelDocument = {
    name: "quoted \"name\"",
    notes: "line \"one\" \\ two",
    primitives: [
      {
        id: "node \"a\"",
        kind: Cube,
        position: @math3d.Vec3::new(0.0, 0.0, 0.0),
        scale: @math3d.Vec3::new(1.0, 1.0, 1.0),
        color_hex: 0x112233,
      },
    ],
    sculpt_layers: [
      {
        id: "layer \"1\"",
        voxel_size: 1.0,
        half_extent: 0,
        color_hex: 0x445566,
        muted_stamp_ids: [],
        stamps: [
          {
            id: "stamp \"x\"",
            mode: @modeling3d.SculptMode::Add,
            center: @math3d.Vec3::new(0.0, 0.0, 0.0),
            radius: 1.0,
          },
        ],
      },
    ],
  }
  let context_json = @modeling3d.document_context_json(doc)

  assert_true(context_json.contains("\"name\":\"quoted \\\"name\\\"\""))
  assert_true(context_json.contains("\"notes\":\"line \\\"one\\\" \\\\ two\""))
  assert_true(context_json.contains("\"id\":\"node \\\"a\\\"\""))
  assert_true(context_json.contains("\"id\":\"layer \\\"1\\\"\""))
  assert_true(context_json.contains("\"id\":\"stamp \\\"x\\\"\""))
}

///|
test "editor context json includes selection and recent stamp history" {
  let doc = default_model_document()
  let selection : @modeling3d.ModelSelection? = Some({
    kind: @modeling3d.ModelSelectionKind::SculptLayerSelection,
    target_id: "clay_head",
  })
  let context_json = @modeling3d.editor_context_json(doc, selection)

  assert_true(
    context_json.contains(
      "\"selection\":{\"kind\":\"sculpt_layer\",\"target_id\":\"clay_head\"}",
    ),
  )
  assert_true(context_json.contains("\"active_sculpt_layer_id\":\"clay_head\""))
  assert_true(context_json.contains("\"recent_stamps\":["))
  assert_true(context_json.contains("\"id\":\"mouth_cut\""))
  assert_true(context_json.contains("\"enabled\":true"))
}

///|
test "editor context json exposes muted recent stamps" {
  let doc = @modeling3d.toggle_recent_sculpt_stamp_muted(
    default_model_document(),
    0,
    0,
  )
  let selection : @modeling3d.ModelSelection? = Some({
    kind: @modeling3d.ModelSelectionKind::SculptLayerSelection,
    target_id: "clay_head",
  })
  let context_json = @modeling3d.editor_context_json(doc, selection)

  assert_true(context_json.contains("\"id\":\"mouth_cut\""))
  assert_true(context_json.contains("\"enabled\":false"))
}
