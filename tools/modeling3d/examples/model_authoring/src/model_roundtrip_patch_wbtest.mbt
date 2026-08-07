///|
fn roundtrip_patch_action_by_kind(
  actions : Array[@modeling3d.RoundTripPatchAction],
  source_id : String,
  action_kind : String,
) -> @modeling3d.RoundTripPatchAction? {
  for action in actions {
    if action.source_id == source_id && action.action_kind == action_kind {
      return Some(action)
    }
  }
  None
}

///|
test "build_roundtrip_patch_plan separates auto and manual actions" {
  let base = default_model_document()
  let imported_primitives = base.primitives.copy()
  imported_primitives[1] = {
    ..imported_primitives[1],
    kind: Sphere,
    position: @math3d.Vec3::new(0.2, -0.25, 0.0),
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
  imported_layers[0] = {
    ..imported_layers[0],
    color_hex: 0xB87462,
    stamps: [
      ..imported_layers[0].stamps,
      {
        id: "nose_add",
        mode: @modeling3d.SculptMode::Add,
        center: @math3d.Vec3::new(0.0, 0.74, 0.44),
        radius: 0.08,
      },
    ],
  }
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
  let plan = @modeling3d.build_roundtrip_patch_plan(base, imported, report)

  assert_eq(plan.filename, "edited.glb")
  assert_eq(plan.imported_document_name, "vlm_clay_totem")
  assert_eq(plan.auto_actions.length(), 2)
  assert_eq(plan.manual_actions.length(), 3)
  assert_true(
    roundtrip_patch_action_by_kind(
      plan.auto_actions,
      "pedestal",
      "set_primitive_kind",
    )
    is Some(_),
  )
  assert_true(
    roundtrip_patch_action_by_kind(plan.auto_actions, "clay_head", "set_color")
    is Some(_),
  )
  assert_true(
    roundtrip_patch_action_by_kind(
      plan.manual_actions,
      "guide_orb",
      "review_missing",
    )
    is Some(_),
  )
  assert_true(
    roundtrip_patch_action_by_kind(
      plan.manual_actions,
      "blender_helper",
      "review_extra",
    )
    is Some(_),
  )
  assert_true(
    roundtrip_patch_action_by_kind(
      plan.manual_actions,
      "clay_head",
      "review_stamp_count",
    )
    is Some(_),
  )
  assert_true(
    @modeling3d.roundtrip_patch_plan_json(plan).contains(
      "\"action_kind\":\"set_primitive_kind\"",
    ),
  )
  assert_true(
    @modeling3d.roundtrip_patch_plan_summary(plan).contains(
      "auto_actions: 2, manual_actions: 3",
    ),
  )
  assert_true(
    @modeling3d.roundtrip_patch_plan_summary(plan).contains(
      "opt_in_append_candidates: 1",
    ),
  )
  assert_true(
    @modeling3d.roundtrip_patch_plan_summary(plan).contains(
      "opt_in_remove_candidates: 1",
    ),
  )
  let snippet = @modeling3d.roundtrip_patch_code_snippet(base, imported, plan)
  assert_true(
    snippet.contains(
      "fn apply_imported_patch(doc : @modeling3d.ModelDocument) -> @modeling3d.ModelDocument",
    ),
  )
  assert_true(snippet.contains("primitives[1] = {"))
  assert_true(snippet.contains("kind: Sphere"))
  assert_true(snippet.contains("color_hex: 0xB87462"))
  assert_true(snippet.contains("ignore(primitives.remove(2))"))
  assert_true(snippet.contains("primitives.push({"))
  assert_true(snippet.contains("id: \"blender_helper\""))
  assert_true(snippet.contains("position: @math3d.Vec3::new(1.2, 0, 0)"))
  assert_true(snippet.contains("// stamp_count mismatch for clay_head"))
  assert_true(snippet.contains("// current: 6, imported: 7"))
  assert_eq(
    @modeling3d.roundtrip_patch_snippet_filename(plan),
    "vlm_clay_totem_roundtrip_patch.mbt",
  )
  assert_true(
    @modeling3d.roundtrip_patch_payload_json(
      base,
      imported,
      plan,
      authoring_profile(),
    ).contains("\"moonbit_patch\":\""),
  )
  assert_true(
    @modeling3d.roundtrip_patch_payload_json(
      base,
      imported,
      plan,
      authoring_profile(),
    ).contains("\"snippet_filename\":\"vlm_clay_totem_roundtrip_patch.mbt\""),
  )
  let payload = @modeling3d.roundtrip_patch_payload_json(
    base,
    imported,
    plan,
    authoring_profile(),
  )
  let parsed = @json.parse(payload) catch { _ => Json::null() }
  assert_true(payload.contains("\"review_prompt\":\""))
  assert_true(
    payload.contains("\"review_filename\":\"vlm_clay_totem_vlm_review.md\""),
  )
  assert_true(
    payload.contains("\"opt_in_append_source_ids\":[\"blender_helper\"]"),
  )
  assert_true(payload.contains("\"opt_in_remove_source_ids\":[\"guide_orb\"]"))
  assert_true(payload.contains("\"manual_issue_details\":["))
  assert_true(
    payload.contains("\"review_hint\":\"Do not invent sculpt stamps\""),
  )
  assert_true(
    payload.contains(
      "\"suggested_moonbit\":\"// primitive missing in imported GLB\\n// ignore(primitives.remove(2))",
    ),
  )
  assert_true(
    payload.contains(
      "\"suggested_moonbit\":\"// stamp_count mismatch for clay_head\\n// current: 6, imported: 7",
    ),
  )
  assert_true(payload.contains("\"current_stamp_count\":6"))
  assert_true(payload.contains("\"imported_stamp_count\":7"))
  assert_true(
    match parsed {
      Object(_) => true
      String(_) => false
      Number(_, ..) => false
      Array(_) => false
      True => false
      False => false
      Null => false
    },
  )
  assert_eq(
    @modeling3d.roundtrip_review_prompt_filename(plan),
    "vlm_clay_totem_vlm_review.md",
  )
  assert_eq(
    @modeling3d.roundtrip_review_bundle_filename(plan),
    "vlm_clay_totem_vlm_bundle.json",
  )
  let review_prompt = @modeling3d.roundtrip_review_prompt_text(
    base,
    imported,
    report,
    plan,
    authoring_profile(),
  )
  assert_true(
    review_prompt.contains("examples/model_authoring/src/model_doc.mbt"),
  )
  assert_true(review_prompt.contains("Review profile: `generic_model`"))
  assert_true(
    review_prompt.contains(
      "Keep the primary silhouette readable from angled, front, side, and top views.",
    ),
  )
  assert_true(review_prompt.contains("## MoonBit patch snippet"))
  assert_true(review_prompt.contains("## Current document JSON"))
  assert_true(review_prompt.contains("## Round-trip diff JSON"))
  assert_true(review_prompt.contains("## Manual issue details"))
  assert_true(review_prompt.contains("guide_orb"))
  assert_true(review_prompt.contains("blender_helper"))
  assert_true(review_prompt.contains("suggested_moonbit:"))
  assert_true(review_prompt.contains("ignore(primitives.remove(2))"))
  assert_true(review_prompt.contains("current_stamp_count: 6"))
  assert_true(review_prompt.contains("imported_stamp_count: 7"))
  assert_true(review_prompt.contains("Do not invent sculpt stamps"))
  let review_bundle = @modeling3d.roundtrip_review_bundle_json(
    base,
    imported,
    plan,
    authoring_profile(),
  )
  assert_true(
    review_bundle.contains(
      "\"target_file\":\"examples/model_authoring/src/model_doc.mbt\"",
    ),
  )
  assert_true(review_bundle.contains("\"review_profile\":\"generic_model\""))
  assert_true(
    review_bundle.contains(
      "\"review_constraints\":[\"Keep the primary silhouette readable from angled, front, side, and top views.\",\"Treat helper or debug primitives as non-final unless the imported diff marks them as intentional.\"]",
    ),
  )
  assert_true(review_bundle.contains("\"current_document\":{"))
  assert_true(review_bundle.contains("\"roundtrip_report\":{"))
  assert_true(review_bundle.contains("\"patch_payload\":{"))
  assert_true(review_bundle.contains("\"manual_issue_details\":["))
  let parsed_bundle = @json.parse(review_bundle) catch { _ => Json::null() }
  assert_true(
    match parsed_bundle {
      Object(_) => true
      _ => false
    },
  )
}

///|
test "apply_roundtrip_auto_patch updates primitive and sculpt colors in memory" {
  let base = default_model_document()
  let imported_primitives = base.primitives.copy()
  imported_primitives[1] = {
    ..imported_primitives[1],
    kind: Sphere,
    position: @math3d.Vec3::new(0.2, -0.25, 0.0),
    scale: @math3d.Vec3::new(0.9, 0.42, 0.9),
    color_hex: 0xE39C54,
  }
  let imported_layers = base.sculpt_layers.copy()
  imported_layers[0] = {
    ..imported_layers[0],
    color_hex: 0xB87462,
    stamps: [
      ..imported_layers[0].stamps,
      {
        id: "nose_add",
        mode: @modeling3d.SculptMode::Add,
        center: @math3d.Vec3::new(0.0, 0.74, 0.44),
        radius: 0.08,
      },
    ],
  }
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
  let plan = @modeling3d.build_roundtrip_patch_plan(base, imported, report)
  let patched = @modeling3d.apply_roundtrip_auto_patch(base, plan)

  assert_true(
    match patched.primitives[1].kind {
      Sphere => true
      Cube => false
      Plane => false
    },
  )
  assert_true(
    patched.primitives[1].position.approx_eq(
      @math3d.Vec3::new(0.2, -0.25, 0.0),
      1.0e-6,
    ),
  )
  assert_true(
    patched.primitives[1].scale.approx_eq(
      @math3d.Vec3::new(0.9, 0.42, 0.9),
      1.0e-6,
    ),
  )
  assert_eq(patched.primitives[1].color_hex, 0xE39C54)
  assert_eq(patched.sculpt_layers[0].color_hex, 0xB87462)
  assert_eq(patched.sculpt_layers[0].stamps.length(), 6)
}

///|
test "apply_roundtrip_opt_in_patch appends imported extra primitive candidates" {
  let base = default_model_document()
  let imported_primitives = base.primitives.copy()
  ignore(imported_primitives.remove(2))
  imported_primitives[1] = {
    ..imported_primitives[1],
    position: @math3d.Vec3::new(0.2, -0.25, 0.0),
    color_hex: 0xE39C54,
  }
  imported_primitives.push({
    id: "blender_helper",
    kind: Cube,
    position: @math3d.Vec3::new(1.2, 0.0, 0.0),
    scale: @math3d.Vec3::new(0.2, 0.2, 0.2),
    color_hex: 0xAAAAAA,
  })
  let imported_doc = { ..base, primitives: imported_primitives }

  let imported = @modeling3d.parse_roundtrip_import(
    "edited.glb",
    @modeling3d.document_glb_bytes(imported_doc),
  )
  let report = @modeling3d.compare_roundtrip_import(base, imported)
  let plan = @modeling3d.build_roundtrip_patch_plan(base, imported, report)
  let patched = @modeling3d.apply_roundtrip_opt_in_patch(base, imported, plan)

  assert_eq(patched.primitives.length(), 3)
  assert_true(
    patched.primitives[1].position.approx_eq(
      @math3d.Vec3::new(0.2, -0.25, 0.0),
      1.0e-6,
    ),
  )
  assert_eq(patched.primitives[1].color_hex, 0xE39C54)
  assert_true(@modeling3d.primitive_index_by_id(patched, "guide_orb") is None)
  assert_eq(patched.primitives[2].id, "blender_helper")
  assert_true(
    match patched.primitives[2].kind {
      Cube => true
      Sphere => false
      Plane => false
    },
  )
  assert_true(
    patched.primitives[2].position.approx_eq(
      @math3d.Vec3::new(1.2, 0.0, 0.0),
      1.0e-6,
    ),
  )
  assert_true(
    patched.primitives[2].scale.approx_eq(
      @math3d.Vec3::new(0.2, 0.2, 0.2),
      1.0e-6,
    ),
  )
  assert_eq(patched.primitives[2].color_hex, 0xAAAAAA)
}

///|
test "build_roundtrip_patch_artifacts recomputes residual diff after opt-in sync" {
  let base = default_model_document()
  let imported_primitives = base.primitives.copy()
  ignore(imported_primitives.remove(2))
  imported_primitives[1] = {
    ..imported_primitives[1],
    position: @math3d.Vec3::new(0.2, -0.25, 0.0),
    scale: @math3d.Vec3::new(0.9, 0.42, 0.9),
    color_hex: 0xE39C54,
  }
  imported_primitives.push({
    id: "blender_helper",
    kind: Cube,
    position: @math3d.Vec3::new(1.2, 0.0, 0.0),
    scale: @math3d.Vec3::new(0.2, 0.2, 0.2),
    color_hex: 0xAAAAAA,
  })
  let imported_layers = base.sculpt_layers.copy()
  imported_layers[0] = {
    ..imported_layers[0],
    stamps: [
      ..imported_layers[0].stamps,
      {
        id: "nose_add",
        mode: @modeling3d.SculptMode::Add,
        center: @math3d.Vec3::new(0.0, 0.74, 0.44),
        radius: 0.08,
      },
    ],
  }
  let imported_doc = {
    ..base,
    primitives: imported_primitives,
    sculpt_layers: imported_layers,
  }

  let imported = @modeling3d.parse_roundtrip_import(
    "edited.glb",
    @modeling3d.document_glb_bytes(imported_doc),
  )
  let initial = @modeling3d.build_roundtrip_patch_artifacts(
    base,
    imported,
    authoring_profile(),
  )
  let patched = @modeling3d.apply_roundtrip_opt_in_patch(
    base,
    imported,
    initial.patch_plan,
  )
  let residual = @modeling3d.build_roundtrip_patch_artifacts(
    patched,
    imported,
    authoring_profile(),
  )

  assert_eq(initial.patch_plan.auto_actions.length(), 1)
  assert_eq(initial.patch_plan.manual_actions.length(), 3)
  assert_eq(initial.review_bundle_filename, "vlm_clay_totem_vlm_bundle.json")
  assert_eq(residual.patch_plan.auto_actions.length(), 0)
  assert_eq(residual.patch_plan.manual_actions.length(), 1)
  assert_eq(residual.report.missing_source_ids.length(), 0)
  assert_eq(residual.report.extra_source_ids.length(), 0)
  assert_eq(residual.report.stamp_count_mismatches.length(), 1)
  assert_true(
    residual.patch_summary.contains(
      "opt_in_append_candidates: 0, opt_in_remove_candidates: 0",
    ),
  )
  assert_true(residual.patch_json.contains("\"manual_issue_details\":["))
  assert_true(residual.patch_json.contains("\"source_id\":\"clay_head\""))
  assert_true(
    residual.patch_json.contains(
      "\"suggested_moonbit\":\"// stamp_count mismatch for clay_head\\n// current: 6, imported: 7",
    ),
  )
  assert_true(residual.review_prompt.contains("current_stamp_count: 6"))
  assert_true(residual.review_prompt.contains("imported_stamp_count: 7"))
  assert_true(residual.review_bundle.contains("\"patch_payload\":{"))
  assert_true(residual.review_bundle.contains("\"manual_issue_details\":["))
}
