///|
test "build_effect_studio_overlay_model summarizes timeline state" {
  let doc = @effect.default_effect_document()
  let overlay = build_effect_studio_overlay_model(doc, 0.5, true)
  assert_eq(overlay.status_label, "playing")
  assert_eq(overlay.lane_count, 3)
  assert_eq(overlay.active_track_count, 2)
  assert_eq(overlay.scheduled_burst_count, 6)
}

///|
test "effect_studio_context_json includes tracks and scheduled bursts" {
  let doc = @effect.default_effect_document()
  let json = effect_studio_context_json(doc, 0.5, false)
  assert_true(json.contains("\"name\":\"forge_burst\""))
  assert_true(json.contains("\"tracks\":["))
  assert_true(json.contains("\"scheduled_bursts\":["))
  assert_true(json.contains("\"track_id\":\"embers_ring\""))
}

///|
test "effect_track_patch_scaffold exposes editable track fields" {
  let doc = @effect.default_effect_document()
  let scaffold = effect_track_patch_scaffold(doc.tracks[1], 1)
  assert_true(scaffold.contains("track[1]"))
  assert_true(scaffold.contains("id: \"embers_ring\""))
  assert_true(scaffold.contains("burst_interval:"))
  assert_true(scaffold.contains("color_start:"))
}

///|
test "effect_track_patch_scaffold renders line pattern" {
  let track = @effect.chain_lightning_effect_document().tracks[0]
  let scaffold = effect_track_patch_scaffold(track, 0)
  assert_true(scaffold.contains("pattern: @effect.Line"))
}

///|
test "effect_studio_context_json includes patch scaffold payload" {
  let doc = @effect.default_effect_document()
  let json = effect_studio_context_json(doc, 0.5, false)
  assert_true(json.contains("\"patch_scaffold\":{"))
  assert_true(json.contains("\"target_file\":\"tools/effect-studio/src/effect_doc.mbt\""))
  assert_true(json.contains("\"track_patch_scaffolds\":["))
  assert_true(json.contains("\"track_id\":\"core_flash\""))
}

///|
test "effect_studio_context_json includes ai patch bundle payload" {
  let doc = @effect.default_effect_document()
  let json = effect_studio_context_json(doc, 0.5, false)
  assert_true(json.contains("\"patch_bundle\":{"))
  assert_true(json.contains("\"context_summary\":\"EFFECT forge_burst"))
  assert_true(json.contains("\"constraints\":["))
  assert_true(json.contains("\"track_targets\":["))
  assert_true(json.contains("\"focus\":\""))
}

///|
test "effect_studio_patch_bundle_json returns standalone ai bundle" {
  let doc = @effect.default_effect_document()
  let json = effect_studio_patch_bundle_json(doc, 0.5, false)
  assert_true(json.has_prefix("{\"target_file\":\"tools/effect-studio/src/effect_doc.mbt\""))
  assert_true(json.contains("\"track_targets\":["))
  assert_true(json.contains("\"constraints\":["))
}

///|
test "effect_studio_review_prompt_markdown includes target and track focus" {
  let doc = @effect.default_effect_document()
  let prompt = effect_studio_review_prompt_markdown(doc, 0.5, false)
  assert_true(prompt.contains("# Effect Studio AI Review"))
  assert_true(prompt.contains("tools/effect-studio/src/effect_doc.mbt"))
  assert_true(prompt.contains("core_flash"))
  assert_true(prompt.contains("Keep track ids and labels stable"))
}

///|
test "effect_studio_context_json includes export payload" {
  let doc = @effect.default_effect_document()
  let json = effect_studio_context_json(doc, 0.5, false)
  assert_true(json.contains("\"exports\":{"))
  assert_true(json.contains("\"bundle_filename\":\"forge_burst-effect-bundle.json\""))
  assert_true(json.contains("\"review_filename\":\"forge_burst-effect-review.md\""))
}
