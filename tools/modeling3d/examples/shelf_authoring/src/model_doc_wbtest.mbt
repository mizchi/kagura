///|
test "shelf document stays hard-surface first with primitive storage props" {
  let doc = default_model_document()
  let stats = document_stats(doc)
  let context_json = document_context_json(doc)

  assert_eq(doc.name, "vlm_shelf_study")
  assert_eq(doc.primitives.length(), 11)
  assert_eq(doc.sculpt_layers.length(), 0)
  assert_eq(stats.occupied_voxel_count, 0)
  assert_eq(stats.render_object_count, doc.primitives.length())
  assert_eq(stats.baked_triangle_count, 0)
  assert_true(context_json.contains("\"name\":\"vlm_shelf_study\""))
  assert_true(context_json.contains("\"id\":\"middle_shelf\""))
  assert_true(context_json.contains("\"id\":\"crate_left\""))
  assert_true(context_json.contains("\"id\":\"crate_right\""))
  assert_true(context_json.contains("\"id\":\"book_stack\""))
}
