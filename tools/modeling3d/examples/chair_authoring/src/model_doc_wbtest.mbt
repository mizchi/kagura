///|
test "chair document stays primitive-first with a small cushion sculpt layer" {
  let doc = default_model_document()
  let stats = document_stats(doc)
  let context_json = document_context_json(doc)

  assert_eq(doc.name, "vlm_chair_study")
  assert_eq(doc.primitives.length(), 9)
  assert_eq(doc.sculpt_layers.length(), 1)
  assert_eq(doc.sculpt_layers[0].id, "seat_cushion")
  assert_eq(doc.sculpt_layers[0].stamps.length(), 5)
  assert_eq(doc.sculpt_layers[0].muted_stamp_ids.length(), 0)
  assert_eq(doc.sculpt_layers[0].stamps[4].id, "seat_right_bolster")
  assert_true(stats.occupied_voxel_count > 0)
  assert_eq(stats.render_object_count, doc.primitives.length() + 1)
  assert_true(stats.baked_triangle_count > 0)
  assert_true(context_json.contains("\"name\":\"vlm_chair_study\""))
  assert_true(context_json.contains("\"id\":\"seat_cushion\""))
  assert_true(context_json.contains("\"id\":\"seat_right_bolster\""))
  assert_true(context_json.contains("\"enabled\":true"))
}
