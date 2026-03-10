///|
struct RoundTripPatchAction {
  source_id : String
  target_kind : String
  action_kind : String
  apply_mode : String
  target_position : @math3d.Vec3?
  target_scale : @math3d.Vec3?
  target_color_hex : Int?
  target_text : String?
  target_int : Int?
  summary : String
}

///|
struct RoundTripPatchPlan {
  filename : String
  imported_document_name : String
  auto_actions : Array[RoundTripPatchAction]
  manual_actions : Array[RoundTripPatchAction]
}

///|
struct RoundTripPatchArtifacts {
  report : RoundTripDiffReport
  report_json : String
  report_summary : String
  patch_plan : RoundTripPatchPlan
  patch_json : String
  patch_summary : String
  patch_snippet : String
  patch_filename : String
  review_prompt : String
  review_filename : String
  review_bundle : String
  review_bundle_filename : String
}

///|
fn primitive_kind_from_string(name : String) -> PrimitiveKind? {
  match name {
    "cube" => Some(Cube)
    "sphere" => Some(Sphere)
    "plane" => Some(Plane)
    _ => None
  }
}

///|
fn roundtrip_color_channel_to_int(value : Double) -> Int {
  let clamped = if value < 0.0 {
    0.0
  } else if value > 1.0 {
    1.0
  } else {
    value
  }
  (clamped * 255.0 + 0.5).to_int()
}

///|
fn roundtrip_color_hex(value : @math3d.Vec4) -> Int {
  (roundtrip_color_channel_to_int(value.x) << 16) |
  (roundtrip_color_channel_to_int(value.y) << 8) |
  roundtrip_color_channel_to_int(value.z)
}

///|
fn roundtrip_patch_action(
  source_id : String,
  target_kind : String,
  action_kind : String,
  apply_mode : String,
  summary : String,
  target_position : @math3d.Vec3?,
  target_scale : @math3d.Vec3?,
  target_color_hex : Int?,
  target_text : String?,
  target_int : Int?,
) -> RoundTripPatchAction {
  {
    source_id,
    target_kind,
    action_kind,
    apply_mode,
    target_position,
    target_scale,
    target_color_hex,
    target_text,
    target_int,
    summary,
  }
}

///|
fn build_roundtrip_patch_plan(
  doc : ModelDocument,
  imported : RoundTripImport,
  report : RoundTripDiffReport,
) -> RoundTripPatchPlan {
  let auto_actions : Array[RoundTripPatchAction] = []
  let manual_actions : Array[RoundTripPatchAction] = []
  let current_nodes = export_scene_nodes(doc)
  let current_ids : Map[String, Bool] = {}
  let imported_nodes = roundtrip_node_map(imported.nodes)
  for current in current_nodes {
    current_ids[current.source_id] = true
    match imported_nodes.get(current.source_id) {
      None =>
        manual_actions.push(
          roundtrip_patch_action(
            current.source_id,
            current.node_kind,
            "review_missing",
            "manual",
            "missing in imported GLB",
            None,
            None,
            None,
            None,
            None,
          ),
        )
      Some(node) => {
        if current.node_kind != node.node_kind {
          manual_actions.push(
            roundtrip_patch_action(
              current.source_id,
              current.node_kind,
              "review_node_kind",
              "manual",
              "node kind changed to " + node.node_kind,
              None,
              None,
              None,
              Some(node.node_kind),
              None,
            ),
          )
          continue
        }
        if current.node_kind == "primitive" {
          if !node.translation.approx_eq(current.translation, 1.0e-5) {
            auto_actions.push(
              roundtrip_patch_action(
                current.source_id,
                "primitive",
                "set_position",
                "auto",
                "set primitive position from imported GLB",
                Some(node.translation),
                None,
                None,
                None,
                None,
              ),
            )
          }
          if !node.scale.approx_eq(current.scale, 1.0e-5) {
            auto_actions.push(
              roundtrip_patch_action(
                current.source_id,
                "primitive",
                "set_scale",
                "auto",
                "set primitive scale from imported GLB",
                None,
                Some(node.scale),
                None,
                None,
                None,
              ),
            )
          }
          if roundtrip_color_hex(node.color) !=
            roundtrip_color_hex(current.color) {
            auto_actions.push(
              roundtrip_patch_action(
                current.source_id,
                "primitive",
                "set_color",
                "auto",
                "set primitive color from imported GLB",
                None,
                None,
                Some(roundtrip_color_hex(node.color)),
                None,
                None,
              ),
            )
          }
          if node.primitive_kind != current.primitive_kind {
            match node.primitive_kind {
              Some(kind_name) =>
                match primitive_kind_from_string(kind_name) {
                  Some(_) =>
                    auto_actions.push(
                      roundtrip_patch_action(
                        current.source_id,
                        "primitive",
                        "set_primitive_kind",
                        "auto",
                        "set primitive kind from imported GLB",
                        None,
                        None,
                        None,
                        Some(kind_name),
                        None,
                      ),
                    )
                  None =>
                    manual_actions.push(
                      roundtrip_patch_action(
                        current.source_id,
                        "primitive",
                        "review_primitive_kind",
                        "manual",
                        "unsupported primitive kind " + kind_name,
                        None,
                        None,
                        None,
                        Some(kind_name),
                        None,
                      ),
                    )
                }
              None =>
                manual_actions.push(
                  roundtrip_patch_action(
                    current.source_id,
                    "primitive",
                    "review_primitive_kind",
                    "manual",
                    "primitive kind metadata missing",
                    None,
                    None,
                    None,
                    None,
                    None,
                  ),
                )
            }
          }
        } else {
          if roundtrip_color_hex(node.color) !=
            roundtrip_color_hex(current.color) {
            auto_actions.push(
              roundtrip_patch_action(
                current.source_id,
                "sculpt_layer",
                "set_color",
                "auto",
                "set sculpt layer color from imported GLB",
                None,
                None,
                Some(roundtrip_color_hex(node.color)),
                None,
                None,
              ),
            )
          }
          if !node.translation.approx_eq(current.translation, 1.0e-5) ||
            !node.scale.approx_eq(current.scale, 1.0e-5) {
            manual_actions.push(
              roundtrip_patch_action(
                current.source_id,
                "sculpt_layer",
                "review_transform",
                "manual",
                "sculpt layer transform changed in imported GLB",
                Some(node.translation),
                Some(node.scale),
                None,
                None,
                None,
              ),
            )
          }
          if node.stamp_count != current.stamp_count {
            manual_actions.push(
              roundtrip_patch_action(
                current.source_id,
                "sculpt_layer",
                "review_stamp_count",
                "manual",
                "sculpt stamp count changed in imported GLB",
                None,
                None,
                None,
                None,
                node.stamp_count,
              ),
            )
          }
        }
      }
    }
  }
  for node in imported.nodes {
    if !current_ids.contains(node.source_id) {
      manual_actions.push(
        roundtrip_patch_action(
          node.source_id,
          node.node_kind,
          "review_extra",
          "manual",
          "extra node only exists in imported GLB",
          None,
          None,
          None,
          None,
          None,
        ),
      )
    }
  }
  {
    filename: report.filename,
    imported_document_name: report.imported_document_name,
    auto_actions,
    manual_actions,
  }
}

///|
fn build_roundtrip_patch_artifacts(
  doc : ModelDocument,
  imported : RoundTripImport,
) -> RoundTripPatchArtifacts {
  let report = compare_roundtrip_import(doc, imported)
  let patch_plan = build_roundtrip_patch_plan(doc, imported, report)
  let artifacts = {
    report,
    report_json: roundtrip_report_json(report),
    report_summary: roundtrip_report_summary(report),
    patch_plan,
    patch_json: roundtrip_patch_payload_json(doc, imported, patch_plan),
    patch_summary: roundtrip_patch_plan_summary(patch_plan),
    patch_snippet: roundtrip_patch_code_snippet(doc, imported, patch_plan),
    patch_filename: roundtrip_patch_snippet_filename(patch_plan),
    review_prompt: roundtrip_review_prompt_text(
      doc, imported, report, patch_plan,
    ),
    review_filename: roundtrip_review_prompt_filename(patch_plan),
    review_bundle: roundtrip_review_bundle_json(doc, imported, patch_plan),
    review_bundle_filename: roundtrip_review_bundle_filename(patch_plan),
  }
  ignore(artifacts.report)
  ignore(artifacts.report_json)
  ignore(artifacts.report_summary)
  ignore(artifacts.patch_plan)
  ignore(artifacts.patch_json)
  ignore(artifacts.patch_summary)
  ignore(artifacts.patch_snippet)
  ignore(artifacts.patch_filename)
  ignore(artifacts.review_prompt)
  ignore(artifacts.review_filename)
  ignore(artifacts.review_bundle)
  ignore(artifacts.review_bundle_filename)
  artifacts
}

///|
fn apply_roundtrip_auto_patch(
  doc : ModelDocument,
  plan : RoundTripPatchPlan,
) -> ModelDocument {
  let primitives = doc.primitives.copy()
  for i in 0..<primitives.length() {
    let mut node = primitives[i]
    for action in plan.auto_actions {
      if action.source_id != node.id {
        continue
      }
      match action.action_kind {
        "set_position" =>
          match action.target_position {
            Some(position) => node = { ..node, position, }
            None => ()
          }
        "set_scale" =>
          match action.target_scale {
            Some(scale) => node = { ..node, scale, }
            None => ()
          }
        "set_color" =>
          match action.target_color_hex {
            Some(color_hex) => node = { ..node, color_hex, }
            None => ()
          }
        "set_primitive_kind" =>
          match action.target_text {
            Some(kind_name) =>
              match primitive_kind_from_string(kind_name) {
                Some(kind) => node = { ..node, kind, }
                None => ()
              }
            None => ()
          }
        _ => ()
      }
    }
    primitives[i] = node
  }
  let sculpt_layers = doc.sculpt_layers.copy()
  for i in 0..<sculpt_layers.length() {
    let mut layer = sculpt_layers[i]
    for action in plan.auto_actions {
      if action.source_id != layer.id {
        continue
      }
      match action.action_kind {
        "set_color" =>
          match action.target_color_hex {
            Some(color_hex) => layer = { ..layer, color_hex, }
            None => ()
          }
        _ => ()
      }
    }
    sculpt_layers[i] = layer
  }
  { ..doc, primitives, sculpt_layers }
}

///|
fn apply_roundtrip_opt_in_patch(
  doc : ModelDocument,
  imported : RoundTripImport,
  plan : RoundTripPatchPlan,
) -> ModelDocument {
  let patched = apply_roundtrip_auto_patch(doc, plan)
  let remove_ids = roundtrip_opt_in_remove_source_ids(patched, plan)
  let primitives : Array[PrimitiveNode] = []
  for node in patched.primitives {
    if !string_array_contains(remove_ids, node.id) {
      primitives.push(node)
    }
  }
  for source_id in roundtrip_opt_in_append_source_ids(imported, plan) {
    if primitive_nodes_contains_id(primitives, source_id) {
      continue
    }
    match roundtrip_imported_node_by_source_id(imported, source_id) {
      Some(node) =>
        match primitive_node_from_roundtrip_import(node) {
          Some(candidate) => primitives.push(candidate)
          None => ()
        }
      None => ()
    }
  }
  { ..patched, primitives, }
}

///|
fn append_roundtrip_patch_action_json(
  buf : StringBuilder,
  action : RoundTripPatchAction,
) -> Unit {
  buf.write_string("{\"source_id\":\"")
  buf.write_string(json_escape(action.source_id))
  buf.write_string("\",\"target_kind\":\"")
  buf.write_string(json_escape(action.target_kind))
  buf.write_string("\",\"action_kind\":\"")
  buf.write_string(json_escape(action.action_kind))
  buf.write_string("\",\"apply_mode\":\"")
  buf.write_string(json_escape(action.apply_mode))
  buf.write_string("\",\"target_position\":")
  match action.target_position {
    Some(value) => buf.write_string(vec3_json(value))
    None => buf.write_string("null")
  }
  buf.write_string(",\"target_scale\":")
  match action.target_scale {
    Some(value) => buf.write_string(vec3_json(value))
    None => buf.write_string("null")
  }
  buf.write_string(",\"target_color_hex\":")
  match action.target_color_hex {
    Some(value) => {
      buf.write_string("\"#")
      buf.write_string(hex6(value))
      buf.write_string("\"")
    }
    None => buf.write_string("null")
  }
  buf.write_string(",\"target_text\":")
  match action.target_text {
    Some(value) => {
      buf.write_string("\"")
      buf.write_string(json_escape(value))
      buf.write_string("\"")
    }
    None => buf.write_string("null")
  }
  buf.write_string(",\"target_int\":")
  match action.target_int {
    Some(value) => buf.write_string(value.to_string())
    None => buf.write_string("null")
  }
  buf.write_string(",\"summary\":\"")
  buf.write_string(json_escape(action.summary))
  buf.write_string("\"}")
}

///|
fn append_roundtrip_patch_action_array_json(
  buf : StringBuilder,
  actions : Array[RoundTripPatchAction],
) -> Unit {
  buf.write_string("[")
  for i in 0..<actions.length() {
    if i > 0 {
      buf.write_string(",")
    }
    append_roundtrip_patch_action_json(buf, actions[i])
  }
  buf.write_string("]")
}

///|
fn roundtrip_append_vec3_json(
  buf : StringBuilder,
  value : @math3d.Vec3,
) -> Unit {
  buf.write_string("[")
  buf.write_string(value.x.to_string())
  buf.write_string(",")
  buf.write_string(value.y.to_string())
  buf.write_string(",")
  buf.write_string(value.z.to_string())
  buf.write_string("]")
}

///|
fn roundtrip_manual_issue_review_hint(action : RoundTripPatchAction) -> String {
  match action.action_kind {
    "review_missing" =>
      "Decide whether to remove this current node or keep it intentionally."
    "review_extra" =>
      "Review whether this imported node should become a new primitive in default_model_document()."
    "review_stamp_count" => "Do not invent sculpt stamps"
    "review_node_kind" =>
      "Resolve node kind mismatch before applying code-first changes."
    _ => "Manual review required."
  }
}

///|
fn append_roundtrip_manual_issue_json(
  buf : StringBuilder,
  doc : ModelDocument,
  imported : RoundTripImport,
  action : RoundTripPatchAction,
) -> Unit {
  buf.write_string("{\"source_id\":\"")
  buf.write_string(json_escape(action.source_id))
  buf.write_string("\",\"target_kind\":\"")
  buf.write_string(json_escape(action.target_kind))
  buf.write_string("\",\"action_kind\":\"")
  buf.write_string(json_escape(action.action_kind))
  buf.write_string("\",\"summary\":\"")
  buf.write_string(json_escape(action.summary))
  buf.write_string("\",\"review_hint\":\"")
  buf.write_string(json_escape(roundtrip_manual_issue_review_hint(action)))
  buf.write_string("\",\"suggested_moonbit\":\"")
  buf.write_string(
    json_escape(roundtrip_manual_issue_scaffold(doc, imported, action)),
  )
  buf.write_string("\"")
  match action.target_kind {
    "primitive" =>
      match primitive_index_by_id(doc, action.source_id) {
        Some(index) => {
          buf.write_string(",\"current_index\":")
          buf.write_string(index.to_string())
        }
        None => ()
      }
    "sculpt_layer" =>
      match sculpt_layer_index_by_id_local(doc, action.source_id) {
        Some(index) => {
          buf.write_string(",\"current_index\":")
          buf.write_string(index.to_string())
          buf.write_string(",\"current_stamp_count\":")
          buf.write_string(doc.sculpt_layers[index].stamps.length().to_string())
        }
        None => ()
      }
    _ => ()
  }
  match roundtrip_imported_node_by_source_id(imported, action.source_id) {
    Some(node) => {
      buf.write_string(",\"imported_node_kind\":\"")
      buf.write_string(json_escape(node.node_kind))
      buf.write_string("\"")
      match node.primitive_kind {
        Some(kind_name) => {
          buf.write_string(",\"imported_primitive_kind\":\"")
          buf.write_string(json_escape(kind_name))
          buf.write_string("\"")
        }
        None => ()
      }
      buf.write_string(",\"imported_position\":")
      roundtrip_append_vec3_json(buf, node.translation)
      buf.write_string(",\"imported_scale\":")
      roundtrip_append_vec3_json(buf, node.scale)
      buf.write_string(",\"imported_color_hex\":\"0x")
      buf.write_string(hex6(roundtrip_color_hex(node.color)))
      buf.write_string("\"")
      match node.stamp_count {
        Some(value) => {
          buf.write_string(",\"imported_stamp_count\":")
          buf.write_string(value.to_string())
        }
        None => ()
      }
    }
    None => ()
  }
  buf.write_string("}")
}

///|
fn append_roundtrip_manual_issue_array_json(
  buf : StringBuilder,
  doc : ModelDocument,
  imported : RoundTripImport,
  plan : RoundTripPatchPlan,
) -> Unit {
  buf.write_string("[")
  for i in 0..<plan.manual_actions.length() {
    if i > 0 {
      buf.write_string(",")
    }
    append_roundtrip_manual_issue_json(
      buf,
      doc,
      imported,
      plan.manual_actions[i],
    )
  }
  buf.write_string("]")
}

///|
fn append_roundtrip_manual_issue_prompt_section(
  buf : StringBuilder,
  doc : ModelDocument,
  imported : RoundTripImport,
  plan : RoundTripPatchPlan,
) -> Unit {
  if plan.manual_actions.is_empty() {
    return
  }
  buf.write_string("## Manual issue details\n\n")
  for action in plan.manual_actions {
    buf.write_string("- ")
    buf.write_string(action.source_id)
    buf.write_string(" ")
    buf.write_string(action.action_kind)
    buf.write_string("\n")
    buf.write_string("  review_hint: ")
    buf.write_string(roundtrip_manual_issue_review_hint(action))
    buf.write_string("\n")
    buf.write_string("  suggested_moonbit:\n")
    buf.write_string("```moonbit\n")
    buf.write_string(roundtrip_manual_issue_scaffold(doc, imported, action))
    buf.write_string("\n```\n")
    match action.target_kind {
      "primitive" =>
        match primitive_index_by_id(doc, action.source_id) {
          Some(index) => {
            buf.write_string("  current_index: ")
            buf.write_string(index.to_string())
            buf.write_string("\n")
          }
          None => ()
        }
      "sculpt_layer" =>
        match sculpt_layer_index_by_id_local(doc, action.source_id) {
          Some(index) => {
            buf.write_string("  current_index: ")
            buf.write_string(index.to_string())
            buf.write_string("\n")
            buf.write_string("  current_stamp_count: ")
            buf.write_string(
              doc.sculpt_layers[index].stamps.length().to_string(),
            )
            buf.write_string("\n")
          }
          None => ()
        }
      _ => ()
    }
    match roundtrip_imported_node_by_source_id(imported, action.source_id) {
      Some(node) => {
        buf.write_string("  imported_node_kind: ")
        buf.write_string(node.node_kind)
        buf.write_string("\n")
        match node.primitive_kind {
          Some(kind_name) => {
            buf.write_string("  imported_primitive_kind: ")
            buf.write_string(kind_name)
            buf.write_string("\n")
          }
          None => ()
        }
        buf.write_string("  imported_position: ")
        buf.write_string(vec3_moonbit(node.translation))
        buf.write_string("\n")
        buf.write_string("  imported_scale: ")
        buf.write_string(vec3_moonbit(node.scale))
        buf.write_string("\n")
        buf.write_string("  imported_color_hex: 0x")
        buf.write_string(hex6(roundtrip_color_hex(node.color)))
        buf.write_string("\n")
        match node.stamp_count {
          Some(value) => {
            buf.write_string("  imported_stamp_count: ")
            buf.write_string(value.to_string())
            buf.write_string("\n")
          }
          None => ()
        }
      }
      None => ()
    }
    buf.write_string("\n")
  }
}

///|
fn primitive_index_by_id(doc : ModelDocument, source_id : String) -> Int? {
  for i in 0..<doc.primitives.length() {
    if doc.primitives[i].id == source_id {
      return Some(i)
    }
  }
  None
}

///|
fn sculpt_layer_index_by_id_local(
  doc : ModelDocument,
  source_id : String,
) -> Int? {
  for i in 0..<doc.sculpt_layers.length() {
    if doc.sculpt_layers[i].id == source_id {
      return Some(i)
    }
  }
  None
}

///|
fn roundtrip_imported_node_by_source_id(
  imported : RoundTripImport,
  source_id : String,
) -> RoundTripImportedNode? {
  for node in imported.nodes {
    if node.source_id == source_id {
      return Some(node)
    }
  }
  None
}

///|
fn primitive_nodes_contains_id(
  primitives : Array[PrimitiveNode],
  source_id : String,
) -> Bool {
  for node in primitives {
    if node.id == source_id {
      return true
    }
  }
  false
}

///|
fn string_array_contains(values : Array[String], target : String) -> Bool {
  for value in values {
    if value == target {
      return true
    }
  }
  false
}

///|
fn primitive_kind_moonbit_name(kind : PrimitiveKind) -> String {
  match kind {
    Cube => "Cube"
    Sphere => "Sphere"
    Plane => "Plane"
  }
}

///|
fn vec3_moonbit(value : @math3d.Vec3) -> String {
  "@math3d.Vec3::new(" +
  value.x.to_string() +
  ", " +
  value.y.to_string() +
  ", " +
  value.z.to_string() +
  ")"
}

///|
fn primitive_node_from_roundtrip_import(
  node : RoundTripImportedNode,
) -> PrimitiveNode? {
  if node.node_kind != "primitive" {
    return None
  }
  match node.primitive_kind {
    Some(kind_name) =>
      match primitive_kind_from_string(kind_name) {
        Some(kind) =>
          Some({
            id: node.source_id,
            kind,
            position: node.translation,
            scale: node.scale,
            color_hex: roundtrip_color_hex(node.color),
          })
        None => None
      }
    None => None
  }
}

///|
fn roundtrip_opt_in_append_source_ids(
  imported : RoundTripImport,
  plan : RoundTripPatchPlan,
) -> Array[String] {
  let ids : Array[String] = []
  for action in plan.manual_actions {
    if action.action_kind != "review_extra" || action.target_kind != "primitive" {
      continue
    }
    match roundtrip_imported_node_by_source_id(imported, action.source_id) {
      Some(node) =>
        match primitive_node_from_roundtrip_import(node) {
          Some(_) => ids.push(action.source_id)
          None => ()
        }
      None => ()
    }
  }
  ids
}

///|
fn roundtrip_opt_in_append_candidate_count(plan : RoundTripPatchPlan) -> Int {
  let mut count = 0
  for action in plan.manual_actions {
    if action.action_kind == "review_extra" && action.target_kind == "primitive" {
      count = count + 1
    }
  }
  count
}

///|
fn roundtrip_opt_in_remove_source_ids(
  doc : ModelDocument,
  plan : RoundTripPatchPlan,
) -> Array[String] {
  let ids : Array[String] = []
  for action in plan.manual_actions {
    if action.action_kind != "review_missing" ||
      action.target_kind != "primitive" {
      continue
    }
    match primitive_index_by_id(doc, action.source_id) {
      Some(_) => ids.push(action.source_id)
      None => ()
    }
  }
  ids
}

///|
fn roundtrip_opt_in_remove_candidate_count(plan : RoundTripPatchPlan) -> Int {
  let mut count = 0
  for action in plan.manual_actions {
    if action.action_kind == "review_missing" &&
      action.target_kind == "primitive" {
      count = count + 1
    }
  }
  count
}

///|
fn append_roundtrip_manual_comment(
  buf : StringBuilder,
  action : RoundTripPatchAction,
) -> Unit {
  buf.write_string("// - ")
  buf.write_string(action.source_id)
  buf.write_string(": ")
  buf.write_string(action.action_kind)
  match action.target_text {
    Some(text) => {
      buf.write_string(" ")
      buf.write_string(text)
    }
    None => ()
  }
  match action.target_int {
    Some(value) => {
      buf.write_string(" ")
      buf.write_string(value.to_string())
    }
    None => ()
  }
  buf.write_string("\n")
}

///|
fn append_roundtrip_missing_scaffold(
  buf : StringBuilder,
  doc : ModelDocument,
  action : RoundTripPatchAction,
) -> Unit {
  match action.target_kind {
    "primitive" =>
      match primitive_index_by_id(doc, action.source_id) {
        Some(index) => {
          buf.write_string("// primitive missing in imported GLB\n")
          buf.write_string("// ignore(primitives.remove(")
          buf.write_string(index.to_string())
          buf.write_string("))\n")
        }
        None => ()
      }
    "sculpt_layer" =>
      match sculpt_layer_index_by_id_local(doc, action.source_id) {
        Some(index) => {
          buf.write_string("// sculpt layer missing in imported GLB\n")
          buf.write_string("// ignore(sculpt_layers.remove(")
          buf.write_string(index.to_string())
          buf.write_string("))\n")
        }
        None => ()
      }
    _ => ()
  }
}

///|
fn append_roundtrip_extra_scaffold(
  buf : StringBuilder,
  imported : RoundTripImport,
  action : RoundTripPatchAction,
) -> Unit {
  match roundtrip_imported_node_by_source_id(imported, action.source_id) {
    Some(node) =>
      match action.target_kind {
        "primitive" =>
          match node.primitive_kind {
            Some(kind_name) =>
              match primitive_kind_from_string(kind_name) {
                Some(kind) => {
                  buf.write_string("// extra primitive from imported GLB\n")
                  buf.write_string("// primitives.push({\n")
                  buf.write_string("//   id: \"")
                  buf.write_string(node.source_id)
                  buf.write_string("\",\n")
                  buf.write_string("//   kind: ")
                  buf.write_string(primitive_kind_moonbit_name(kind))
                  buf.write_string(",\n")
                  buf.write_string("//   position: ")
                  buf.write_string(vec3_moonbit(node.translation))
                  buf.write_string(",\n")
                  buf.write_string("//   scale: ")
                  buf.write_string(vec3_moonbit(node.scale))
                  buf.write_string(",\n")
                  buf.write_string("//   color_hex: 0x")
                  buf.write_string(hex6(roundtrip_color_hex(node.color)))
                  buf.write_string(",\n")
                  buf.write_string("// })\n")
                }
                None => {
                  buf.write_string(
                    "// extra primitive uses unsupported kind metadata\n",
                  )
                  append_roundtrip_manual_comment(buf, action)
                }
              }
            None => {
              buf.write_string(
                "// extra primitive is missing primitive_kind metadata\n",
              )
              append_roundtrip_manual_comment(buf, action)
            }
          }
        "sculpt_layer" => {
          buf.write_string("// extra sculpt layer from imported GLB\n")
          buf.write_string("// TODO: create a new sculpt layer for ")
          buf.write_string(node.source_id)
          buf.write_string(" manually.\n")
          buf.write_string("// Imported color_hex: 0x")
          buf.write_string(hex6(roundtrip_color_hex(node.color)))
          buf.write_string(", stamp_count: ")
          match node.stamp_count {
            Some(value) => buf.write_string(value.to_string())
            None => buf.write_string("unknown")
          }
          buf.write_string("\n")
        }
        _ => append_roundtrip_manual_comment(buf, action)
      }
    None => append_roundtrip_manual_comment(buf, action)
  }
}

///|
fn append_roundtrip_stamp_count_scaffold(
  buf : StringBuilder,
  doc : ModelDocument,
  imported : RoundTripImport,
  action : RoundTripPatchAction,
) -> Unit {
  match
    (
      sculpt_layer_index_by_id_local(doc, action.source_id),
      roundtrip_imported_node_by_source_id(imported, action.source_id),
    ) {
    (Some(index), Some(node)) => {
      buf.write_string("// stamp_count mismatch for ")
      buf.write_string(action.source_id)
      buf.write_string("\n")
      buf.write_string("// current: ")
      buf.write_string(doc.sculpt_layers[index].stamps.length().to_string())
      buf.write_string(", imported: ")
      match node.stamp_count {
        Some(value) => buf.write_string(value.to_string())
        None => buf.write_string("unknown")
      }
      buf.write_string("\n")
      buf.write_string(
        "// TODO: mirror Blender-side sculpt edits back into layer.stamps manually.\n",
      )
    }
    _ => append_roundtrip_manual_comment(buf, action)
  }
}

///|
fn roundtrip_manual_issue_scaffold(
  doc : ModelDocument,
  imported : RoundTripImport,
  action : RoundTripPatchAction,
) -> String {
  let buf = StringBuilder::new()
  match action.action_kind {
    "review_missing" => append_roundtrip_missing_scaffold(buf, doc, action)
    "review_extra" => append_roundtrip_extra_scaffold(buf, imported, action)
    "review_stamp_count" =>
      append_roundtrip_stamp_count_scaffold(buf, doc, imported, action)
    _ => append_roundtrip_manual_comment(buf, action)
  }
  buf.to_string().trim().to_string()
}

///|
fn roundtrip_patch_snippet_filename(plan : RoundTripPatchPlan) -> String {
  let base = if plan.imported_document_name.is_empty() {
    plan.filename
  } else {
    plan.imported_document_name
  }
  let buf = StringBuilder::new()
  for ch in base {
    if ch.is_ascii_alphabetic() || ch.is_ascii_digit() || ch == '_' || ch == '-' {
      buf.write_char(ch)
    } else if ch == ' ' || ch == '.' {
      buf.write_char('_')
    } else {
      buf.write_char('_')
    }
  }
  let name = buf.to_string()
  if name.is_empty() {
    "roundtrip_patch.mbt"
  } else {
    name + "_roundtrip_patch.mbt"
  }
}

///|
fn roundtrip_review_prompt_filename(plan : RoundTripPatchPlan) -> String {
  let base = if plan.imported_document_name.is_empty() {
    plan.filename
  } else {
    plan.imported_document_name
  }
  let buf = StringBuilder::new()
  for ch in base {
    if ch.is_ascii_alphabetic() || ch.is_ascii_digit() || ch == '_' || ch == '-' {
      buf.write_char(ch)
    } else if ch == ' ' || ch == '.' {
      buf.write_char('_')
    } else {
      buf.write_char('_')
    }
  }
  let name = buf.to_string()
  if name.is_empty() {
    "roundtrip_vlm_review.md"
  } else {
    name + "_vlm_review.md"
  }
}

///|
fn roundtrip_review_bundle_filename(plan : RoundTripPatchPlan) -> String {
  let base = if plan.imported_document_name.is_empty() {
    plan.filename
  } else {
    plan.imported_document_name
  }
  let buf = StringBuilder::new()
  for ch in base {
    if ch.is_ascii_alphabetic() || ch.is_ascii_digit() || ch == '_' || ch == '-' {
      buf.write_char(ch)
    } else if ch == ' ' || ch == '.' {
      buf.write_char('_')
    } else {
      buf.write_char('_')
    }
  }
  let name = buf.to_string()
  if name.is_empty() {
    "roundtrip_vlm_bundle.json"
  } else {
    name + "_vlm_bundle.json"
  }
}

///|
fn roundtrip_patch_code_snippet(
  doc : ModelDocument,
  imported : RoundTripImport,
  plan : RoundTripPatchPlan,
) -> String {
  let buf = StringBuilder::new()
  buf.write_string(
    "fn apply_imported_patch(doc : ModelDocument) -> ModelDocument {\n",
  )
  let mut wrote_primitives = false
  let mut wrote_layers = false
  for i in 0..<doc.primitives.length() {
    let mut position : @math3d.Vec3? = None
    let mut scale : @math3d.Vec3? = None
    let mut color_hex : Int? = None
    let mut kind : PrimitiveKind? = None
    for action in plan.auto_actions {
      if action.source_id != doc.primitives[i].id {
        continue
      }
      match action.action_kind {
        "set_position" => position = action.target_position
        "set_scale" => scale = action.target_scale
        "set_color" => color_hex = action.target_color_hex
        "set_primitive_kind" =>
          match action.target_text {
            Some(kind_name) => kind = primitive_kind_from_string(kind_name)
            None => ()
          }
        _ => ()
      }
    }
    if position is Some(_) ||
      scale is Some(_) ||
      color_hex is Some(_) ||
      kind is Some(_) {
      if !wrote_primitives {
        buf.write_string("  let primitives = doc.primitives.copy()\n")
        wrote_primitives = true
      }
      buf.write_string("  primitives[")
      buf.write_string(i.to_string())
      buf.write_string("] = {\n")
      buf.write_string("    ..primitives[")
      buf.write_string(i.to_string())
      buf.write_string("],\n")
      match kind {
        Some(value) => {
          buf.write_string("    kind: ")
          buf.write_string(primitive_kind_moonbit_name(value))
          buf.write_string(",\n")
        }
        None => ()
      }
      match position {
        Some(value) => {
          buf.write_string("    position: ")
          buf.write_string(vec3_moonbit(value))
          buf.write_string(",\n")
        }
        None => ()
      }
      match scale {
        Some(value) => {
          buf.write_string("    scale: ")
          buf.write_string(vec3_moonbit(value))
          buf.write_string(",\n")
        }
        None => ()
      }
      match color_hex {
        Some(value) => {
          buf.write_string("    color_hex: 0x")
          buf.write_string(hex6(value))
          buf.write_string(",\n")
        }
        None => ()
      }
      buf.write_string("  }\n")
    }
  }
  for i in 0..<doc.sculpt_layers.length() {
    let mut color_hex : Int? = None
    for action in plan.auto_actions {
      if action.source_id != doc.sculpt_layers[i].id {
        continue
      }
      match action.action_kind {
        "set_color" => color_hex = action.target_color_hex
        _ => ()
      }
    }
    match color_hex {
      Some(value) => {
        if !wrote_layers {
          buf.write_string("  let sculpt_layers = doc.sculpt_layers.copy()\n")
          wrote_layers = true
        }
        buf.write_string("  sculpt_layers[")
        buf.write_string(i.to_string())
        buf.write_string("] = {\n")
        buf.write_string("    ..sculpt_layers[")
        buf.write_string(i.to_string())
        buf.write_string("],\n")
        buf.write_string("    color_hex: 0x")
        buf.write_string(hex6(value))
        buf.write_string(",\n")
        buf.write_string("  }\n")
      }
      None => ()
    }
  }
  if !wrote_primitives && !wrote_layers {
    buf.write_string("  doc\n")
  } else {
    buf.write_string("  { ..doc")
    if wrote_primitives {
      buf.write_string(", primitives")
    }
    if wrote_layers {
      buf.write_string(", sculpt_layers")
    }
    buf.write_string(" }\n")
  }
  buf.write_string("}\n")
  if !plan.manual_actions.is_empty() {
    buf.write_string("\n// Manual review\n")
    for action in plan.manual_actions {
      match action.action_kind {
        "review_missing" => append_roundtrip_missing_scaffold(buf, doc, action)
        "review_extra" => append_roundtrip_extra_scaffold(buf, imported, action)
        "review_stamp_count" =>
          append_roundtrip_stamp_count_scaffold(buf, doc, imported, action)
        _ => append_roundtrip_manual_comment(buf, action)
      }
    }
  }
  buf.to_string()
}

///|
fn roundtrip_review_profile_id() -> String {
  "organic_character"
}

///|
fn roundtrip_review_constraints() -> Array[String] {
  [
    "Aim for a squat frog silhouette instead of a generic blob.", "Eyes should remain a deliberate paired feature.",
    "Haunches, forelimbs, and the mouth landmark should remain readable.",
  ]
}

///|
fn roundtrip_review_prompt_text(
  doc : ModelDocument,
  imported : RoundTripImport,
  report : RoundTripDiffReport,
  plan : RoundTripPatchPlan,
) -> String {
  let buf = StringBuilder::new()
  buf.write_string("# Kagura round-trip review prompt\n\n")
  buf.write_string(
    "Target file: `examples/frog_authoring/src/model_doc.mbt`\n\n",
  )
  buf.write_string(
    "Review the imported GLB diff and propose the smallest code-first update that keeps Kagura ids stable.\n\n",
  )
  buf.write_string("Rules:\n")
  buf.write_string(
    "- Prefer primitive transform, color, and kind edits that can be expressed in `default_model_document()`.\n",
  )
  buf.write_string(
    "- Keep existing `id` values stable unless the diff explicitly reports an extra or missing node.\n",
  )
  buf.write_string(
    "- Do not invent sculpt stamps. If `stamp_count` changed, keep it as a manual review item unless concrete stamp edits are provided.\n",
  )
  buf.write_string(
    "- Treat `missing`, `extra`, and sculpt topology changes as manual review unless a safe direct mapping is obvious.\n\n",
  )
  buf.write_string("Review profile: `")
  buf.write_string(roundtrip_review_profile_id())
  buf.write_string("`\n")
  let review_constraints = roundtrip_review_constraints()
  if !review_constraints.is_empty() {
    buf.write_string("Review constraints:\n")
    for line in review_constraints {
      buf.write_string("- ")
      buf.write_string(line)
      buf.write_string("\n")
    }
    buf.write_string("\n")
  }
  buf.write_string("Imported GLB: `")
  buf.write_string(imported.filename)
  buf.write_string("`\n")
  buf.write_string("Imported document: `")
  if plan.imported_document_name.is_empty() {
    buf.write_string("(missing kagura extras)")
  } else {
    buf.write_string(plan.imported_document_name)
  }
  buf.write_string("`\n\n")
  buf.write_string("## Patch proposal summary\n\n")
  buf.write_string("```text\n")
  buf.write_string(roundtrip_patch_plan_summary(plan))
  buf.write_string("```\n\n")
  let opt_in_remove_ids = roundtrip_opt_in_remove_source_ids(doc, plan)
  if !opt_in_remove_ids.is_empty() {
    buf.write_string("## Opt-in remove candidates\n\n")
    buf.write_string(
      "These current primitive nodes can be removed in-memory with the opt-in patch path.\n\n",
    )
    buf.write_string("```json\n")
    append_string_array_json(buf, opt_in_remove_ids)
    buf.write_string("\n```\n\n")
  }
  let opt_in_append_ids = roundtrip_opt_in_append_source_ids(imported, plan)
  if !opt_in_append_ids.is_empty() {
    buf.write_string("## Opt-in append candidates\n\n")
    buf.write_string(
      "These imported primitive nodes can be appended in-memory with the opt-in patch path.\n\n",
    )
    buf.write_string("```json\n")
    append_string_array_json(buf, opt_in_append_ids)
    buf.write_string("\n```\n\n")
  }
  append_roundtrip_manual_issue_prompt_section(buf, doc, imported, plan)
  buf.write_string("## MoonBit patch snippet\n\n")
  buf.write_string("```moonbit\n")
  buf.write_string(roundtrip_patch_code_snippet(doc, imported, plan))
  buf.write_string("```\n\n")
  buf.write_string("## Current document JSON\n\n")
  buf.write_string("```json\n")
  buf.write_string(document_context_json(doc))
  buf.write_string("\n```\n\n")
  buf.write_string("## Round-trip diff JSON\n\n")
  buf.write_string("```json\n")
  buf.write_string(roundtrip_report_json(report))
  buf.write_string("\n```\n\n")
  buf.write_string("## Patch plan JSON\n\n")
  buf.write_string("```json\n")
  buf.write_string(roundtrip_patch_plan_json(plan))
  buf.write_string("\n```\n")
  buf.to_string()
}

///|
fn roundtrip_patch_plan_json(plan : RoundTripPatchPlan) -> String {
  let buf = StringBuilder::new()
  buf.write_string("{\"filename\":\"")
  buf.write_string(json_escape(plan.filename))
  buf.write_string("\",\"imported_document_name\":\"")
  buf.write_string(json_escape(plan.imported_document_name))
  buf.write_string("\",\"snippet_filename\":\"")
  buf.write_string(json_escape(roundtrip_patch_snippet_filename(plan)))
  buf.write_string("\",\"auto_actions\":")
  append_roundtrip_patch_action_array_json(buf, plan.auto_actions)
  buf.write_string(",\"manual_actions\":")
  append_roundtrip_patch_action_array_json(buf, plan.manual_actions)
  buf.write_string(",\"opt_in_append_candidates\":")
  buf.write_string(roundtrip_opt_in_append_candidate_count(plan).to_string())
  buf.write_string(",\"opt_in_remove_candidates\":")
  buf.write_string(roundtrip_opt_in_remove_candidate_count(plan).to_string())
  buf.write_string("}")
  buf.to_string()
}

///|
fn roundtrip_patch_payload_json(
  doc : ModelDocument,
  imported : RoundTripImport,
  plan : RoundTripPatchPlan,
) -> String {
  let report = compare_roundtrip_import(doc, imported)
  let opt_in_append_ids = roundtrip_opt_in_append_source_ids(imported, plan)
  let opt_in_remove_ids = roundtrip_opt_in_remove_source_ids(doc, plan)
  let buf = StringBuilder::new()
  buf.write_string("{\"filename\":\"")
  buf.write_string(json_escape(plan.filename))
  buf.write_string("\",\"imported_document_name\":\"")
  buf.write_string(json_escape(plan.imported_document_name))
  buf.write_string("\",\"snippet_filename\":\"")
  buf.write_string(json_escape(roundtrip_patch_snippet_filename(plan)))
  buf.write_string("\",\"review_filename\":\"")
  buf.write_string(json_escape(roundtrip_review_prompt_filename(plan)))
  buf.write_string("\",\"auto_actions\":")
  append_roundtrip_patch_action_array_json(buf, plan.auto_actions)
  buf.write_string(",\"manual_actions\":")
  append_roundtrip_patch_action_array_json(buf, plan.manual_actions)
  buf.write_string(",\"opt_in_append_source_ids\":")
  append_string_array_json(buf, opt_in_append_ids)
  buf.write_string(",\"opt_in_remove_source_ids\":")
  append_string_array_json(buf, opt_in_remove_ids)
  buf.write_string(",\"manual_issue_details\":")
  append_roundtrip_manual_issue_array_json(buf, doc, imported, plan)
  buf.write_string(",\"moonbit_patch\":\"")
  buf.write_string(
    json_escape(roundtrip_patch_code_snippet(doc, imported, plan)),
  )
  buf.write_string("\",\"review_prompt\":\"")
  buf.write_string(
    json_escape(roundtrip_review_prompt_text(doc, imported, report, plan)),
  )
  buf.write_string("\"}")
  buf.to_string()
}

///|
fn roundtrip_review_bundle_json(
  doc : ModelDocument,
  imported : RoundTripImport,
  plan : RoundTripPatchPlan,
) -> String {
  let report = compare_roundtrip_import(doc, imported)
  let review_constraints = roundtrip_review_constraints()
  let buf = StringBuilder::new()
  buf.write_string("{\"target_file\":\"")
  buf.write_string(json_escape("examples/frog_authoring/src/model_doc.mbt"))
  buf.write_string("\",\"review_profile\":\"")
  buf.write_string(json_escape(roundtrip_review_profile_id()))
  buf.write_string("\",\"review_constraints\":")
  append_string_array_json(buf, review_constraints)
  buf.write_string(",\"current_document\":")
  buf.write_string(document_context_json(doc))
  buf.write_string(",\"roundtrip_report\":")
  buf.write_string(roundtrip_report_json(report))
  buf.write_string(",\"patch_payload\":")
  buf.write_string(roundtrip_patch_payload_json(doc, imported, plan))
  buf.write_string("}")
  buf.to_string()
}

///|
fn roundtrip_patch_plan_summary(plan : RoundTripPatchPlan) -> String {
  let buf = StringBuilder::new()
  buf.write_string("PATCH ")
  buf.write_string(plan.filename)
  buf.write_string("\n")
  buf.write_string("imported_document: ")
  if plan.imported_document_name.is_empty() {
    buf.write_string("(missing kagura extras)")
  } else {
    buf.write_string(plan.imported_document_name)
  }
  buf.write_string("\n")
  buf.write_string("auto_actions: ")
  buf.write_string(plan.auto_actions.length().to_string())
  buf.write_string(", manual_actions: ")
  buf.write_string(plan.manual_actions.length().to_string())
  buf.write_string(", opt_in_append_candidates: ")
  buf.write_string(roundtrip_opt_in_append_candidate_count(plan).to_string())
  buf.write_string(", opt_in_remove_candidates: ")
  buf.write_string(roundtrip_opt_in_remove_candidate_count(plan).to_string())
  buf.write_string("\n")
  for action in plan.auto_actions {
    buf.write_string("auto: ")
    buf.write_string(action.source_id)
    buf.write_string(" ")
    buf.write_string(action.action_kind)
    buf.write_string("\n")
  }
  for action in plan.manual_actions {
    buf.write_string("manual: ")
    buf.write_string(action.source_id)
    buf.write_string(" ")
    buf.write_string(action.action_kind)
    buf.write_string("\n")
  }
  buf.to_string()
}
