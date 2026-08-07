///|
test "frog document exposes a stylized sculpt body and eye primitives" {
  let doc = default_model_document()
  let stats = @modeling3d.document_stats(doc)
  let context_json = @modeling3d.document_context_json(doc)

  assert_eq(doc.name, "vlm_frog_study")
  assert_eq(doc.primitives.length(), 5)
  assert_eq(doc.sculpt_layers.length(), 1)
  assert_eq(doc.sculpt_layers[0].id, "frog_body")
  assert_eq(doc.sculpt_layers[0].stamps.length(), 12)
  assert_eq(doc.sculpt_layers[0].muted_stamp_ids.length(), 0)
  assert_eq(doc.sculpt_layers[0].stamps[10].id, "left_brow_pad")
  assert_eq(doc.sculpt_layers[0].stamps[11].id, "right_brow_pad")
  assert_true(stats.occupied_voxel_count > 0)
  assert_eq(stats.render_object_count, doc.primitives.length() + 1)
  assert_true(stats.baked_triangle_count > 0)
  assert_true(context_json.contains("\"name\":\"vlm_frog_study\""))
  assert_true(context_json.contains("\"id\":\"frog_body\""))
  assert_true(context_json.contains("\"id\":\"left_eye_ridge\""))
  assert_true(context_json.contains("\"id\":\"right_eye_ridge\""))
  assert_true(context_json.contains("\"id\":\"right_brow_pad\""))
  assert_true(context_json.contains("\"enabled\":true"))
}
