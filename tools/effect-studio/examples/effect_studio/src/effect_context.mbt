///|
struct EffectStudioOverlayModel {
  status_label : String
  lane_count : Int
  scheduled_burst_count : Int
  scheduled_particle_count : Int
  active_track_count : Int
  playhead_ratio : Double
} derive(Debug)

///|
pub impl Show for EffectStudioOverlayModel with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
fn build_effect_studio_overlay_model(
  doc : @effect.EffectDocument,
  preview_time : Double,
  playing : Bool,
) -> EffectStudioOverlayModel {
  let runtime = @effect.build_effect_runtime_plan(doc, preview_time)
  let timeline = @effect.build_timeline_view(doc, preview_time)
  {
    status_label: if playing {
      "playing"
    } else {
      "paused"
    },
    lane_count: timeline.lanes.length(),
    scheduled_burst_count: runtime.scheduled_bursts.length(),
    scheduled_particle_count: runtime.total_particles,
    active_track_count: runtime.active_track_ids.length(),
    playhead_ratio: timeline.playhead_ratio,
  }
}

///|
fn json_escape(text : String) -> String {
  text
  .replace_all(old="\\", new="\\\\")
  .replace_all(old="\"", new="\\\"")
  .replace_all(old="\n", new="\\n")
  .replace_all(old="\r", new="\\r")
  .replace_all(old="\t", new="\\t")
}

///|
fn vec3_json(v : @math3d.Vec3) -> String {
  let buf = StringBuilder::new()
  buf.write_string("{\"x\":")
  buf.write_string(v.x.to_string())
  buf.write_string(",\"y\":")
  buf.write_string(v.y.to_string())
  buf.write_string(",\"z\":")
  buf.write_string(v.z.to_string())
  buf.write_string("}")
  buf.to_string()
}

///|
fn vec3_code(v : @math3d.Vec3) -> String {
  let buf = StringBuilder::new()
  buf.write_string("@math3d.Vec3::new(")
  buf.write_string(v.x.to_string())
  buf.write_string(", ")
  buf.write_string(v.y.to_string())
  buf.write_string(", ")
  buf.write_string(v.z.to_string())
  buf.write_string(")")
  buf.to_string()
}

///|
fn vec4_code(v : @math3d.Vec4) -> String {
  let buf = StringBuilder::new()
  buf.write_string("@math3d.Vec4::new(")
  buf.write_string(v.x.to_string())
  buf.write_string(", ")
  buf.write_string(v.y.to_string())
  buf.write_string(", ")
  buf.write_string(v.z.to_string())
  buf.write_string(", ")
  buf.write_string(v.w.to_string())
  buf.write_string(")")
  buf.to_string()
}

///|
fn effect_doc_target_file() -> String {
  "tools/effect-studio/src/effect_doc.mbt"
}

///|
fn effect_track_patch_scaffold(
  track : @effect.EffectTrack,
  index : Int,
) -> String {
  let buf = StringBuilder::new()
  buf.write_string("// track[")
  buf.write_string(index.to_string())
  buf.write_string("] ")
  buf.write_string(track.id)
  buf.write_string("\n{\n")
  buf.write_string("  id: \"")
  buf.write_string(track.id)
  buf.write_string("\",\n")
  buf.write_string("  label: \"")
  buf.write_string(track.label)
  buf.write_string("\",\n")
  buf.write_string("  start_time: ")
  buf.write_string(track.start_time.to_string())
  buf.write_string(",\n")
  buf.write_string("  duration: ")
  buf.write_string(track.duration.to_string())
  buf.write_string(",\n")
  buf.write_string("  burst_interval: ")
  buf.write_string(track.burst_interval.to_string())
  buf.write_string(",\n")
  buf.write_string("  burst_particles: ")
  buf.write_string(track.burst_particles.to_string())
  buf.write_string(",\n")
  buf.write_string("  pattern: @effect.")
  match track.pattern {
    Point => buf.write_string("Point")
    Ring => buf.write_string("Ring")
    Column => buf.write_string("Column")
    Line => buf.write_string("Line")
  }
  buf.write_string(",\n")
  buf.write_string("  origin: ")
  buf.write_string(vec3_code(track.origin))
  buf.write_string(",\n")
  buf.write_string("  spread_radius: ")
  buf.write_string(track.spread_radius.to_string())
  buf.write_string(",\n")
  buf.write_string("  initial_velocity_min: ")
  buf.write_string(vec3_code(track.initial_velocity_min))
  buf.write_string(",\n")
  buf.write_string("  initial_velocity_max: ")
  buf.write_string(vec3_code(track.initial_velocity_max))
  buf.write_string(",\n")
  buf.write_string("  lifetime_min: ")
  buf.write_string(track.lifetime_min.to_string())
  buf.write_string(",\n")
  buf.write_string("  lifetime_max: ")
  buf.write_string(track.lifetime_max.to_string())
  buf.write_string(",\n")
  buf.write_string("  size_min: ")
  buf.write_string(track.size_min.to_string())
  buf.write_string(",\n")
  buf.write_string("  size_max: ")
  buf.write_string(track.size_max.to_string())
  buf.write_string(",\n")
  buf.write_string("  color_start: ")
  buf.write_string(vec4_code(track.color_start))
  buf.write_string(",\n")
  buf.write_string("  color_end: ")
  buf.write_string(vec4_code(track.color_end))
  buf.write_string(",\n")
  buf.write_string("  gravity: ")
  buf.write_string(vec3_code(track.gravity))
  buf.write_string(",\n")
  buf.write_string("  enabled: ")
  buf.write_string(if track.enabled { "true" } else { "false" })
  buf.write_string(",\n")
  buf.write_string("}")
  buf.to_string()
}

///|
fn effect_document_patch_scaffold(doc : @effect.EffectDocument) -> String {
  let buf = StringBuilder::new()
  buf.write_string(
    "fn apply_ai_patch(doc : @effect.EffectDocument) -> @effect.EffectDocument {\n",
  )
  buf.write_string("  {\n")
  buf.write_string("    ..doc,\n")
  buf.write_string("    name: \"")
  buf.write_string(doc.name)
  buf.write_string("\",\n")
  buf.write_string("    duration: ")
  buf.write_string(doc.duration.to_string())
  buf.write_string(",\n")
  buf.write_string("    looping: ")
  buf.write_string(if doc.looping { "true" } else { "false" })
  buf.write_string(",\n")
  buf.write_string("    notes: \"")
  buf.write_string(doc.notes)
  buf.write_string("\",\n")
  buf.write_string("    ai_edit_goal: \"")
  buf.write_string(doc.ai_edit_goal)
  buf.write_string("\",\n")
  buf.write_string("    tracks: [\n")
  for i in 0..<doc.tracks.length() {
    if i > 0 {
      buf.write_string(",\n")
    }
    buf.write_string(effect_track_patch_scaffold(doc.tracks[i], i))
  }
  buf.write_string("\n    ],\n")
  buf.write_string("  }\n")
  buf.write_string("}\n")
  buf.to_string()
}

///|
fn effect_track_edit_focus(track : @effect.EffectTrack) -> String {
  let buf = StringBuilder::new()
  buf.write_string(
    "Adjust timing, particle count, motion envelope, and color arc for ",
  )
  buf.write_string(track.id)
  buf.write_string(
    " while keeping id/label stable and preserving timeline readability.",
  )
  buf.to_string()
}

///|
fn effect_bundle_slug(doc : @effect.EffectDocument) -> String {
  doc.name.replace_all(old=" ", new="-")
}

///|
fn effect_studio_patch_bundle_filename(doc : @effect.EffectDocument) -> String {
  effect_bundle_slug(doc) + "-effect-bundle.json"
}

///|
fn effect_studio_review_prompt_filename(doc : @effect.EffectDocument) -> String {
  effect_bundle_slug(doc) + "-effect-review.md"
}

///|
fn append_effect_patch_bundle_payload_json(
  buf : StringBuilder,
  doc : @effect.EffectDocument,
  preview_time : Double,
  playing : Bool,
) -> Unit {
  let runtime = @effect.build_effect_runtime_plan(doc, preview_time)
  let summary = effect_studio_summary(doc, preview_time, playing)
  buf.write_string("{")
  buf.write_string("\"target_file\":\"")
  buf.write_string(effect_doc_target_file())
  buf.write_string("\",\"context_summary\":\"")
  buf.write_string(json_escape(summary))
  buf.write_string("\",\"edit_goal\":\"")
  buf.write_string(json_escape(doc.ai_edit_goal))
  buf.write_string("\",\"constraints\":[")
  buf.write_string("\"Keep track ids and labels stable\"")
  buf.write_string(",\"Prefer track-local edits over document-wide rewrites\"")
  buf.write_string(",\"Preserve a readable timing silhouette in the timeline\"")
  buf.write_string(
    ",\"Use tools/effect-studio/src/effect_doc.mbt as the source of truth\"",
  )
  buf.write_string("],\"current_state\":{")
  buf.write_string("\"preview_time\":")
  buf.write_string(preview_time.to_string())
  buf.write_string(",\"normalized_time\":")
  buf.write_string(runtime.normalized_time.to_string())
  buf.write_string(",\"playing\":")
  buf.write_string(if playing { "true" } else { "false" })
  buf.write_string(",\"scheduled_particle_count\":")
  buf.write_string(runtime.total_particles.to_string())
  buf.write_string("},\"document_patch_scaffold\":\"")
  buf.write_string(json_escape(effect_document_patch_scaffold(doc)))
  buf.write_string("\",\"track_targets\":[")
  for i in 0..<doc.tracks.length() {
    if i > 0 {
      buf.write_string(",")
    }
    let track = doc.tracks[i]
    buf.write_string("{\"track_id\":\"")
    buf.write_string(json_escape(track.id))
    buf.write_string("\",\"index\":")
    buf.write_string(i.to_string())
    buf.write_string(",\"focus\":\"")
    buf.write_string(json_escape(effect_track_edit_focus(track)))
    buf.write_string("\",\"scaffold\":\"")
    buf.write_string(json_escape(effect_track_patch_scaffold(track, i)))
    buf.write_string("\"}")
  }
  buf.write_string("]}")
}

///|
fn effect_studio_patch_bundle_json(
  doc : @effect.EffectDocument,
  preview_time : Double,
  playing : Bool,
) -> String {
  let buf = StringBuilder::new()
  append_effect_patch_bundle_payload_json(buf, doc, preview_time, playing)
  buf.to_string()
}

///|
fn effect_studio_review_prompt_markdown(
  doc : @effect.EffectDocument,
  preview_time : Double,
  playing : Bool,
) -> String {
  let runtime = @effect.build_effect_runtime_plan(doc, preview_time)
  let overlay = build_effect_studio_overlay_model(doc, preview_time, playing)
  let buf = StringBuilder::new()
  buf.write_string("# Effect Studio AI Review\n\n")
  buf.write_string("- Target: `")
  buf.write_string(effect_doc_target_file())
  buf.write_string("`\n")
  buf.write_string("- Effect: `")
  buf.write_string(doc.name)
  buf.write_string("`\n")
  buf.write_string("- Preview time: `")
  buf.write_string(preview_time.to_string())
  buf.write_string("`\n")
  buf.write_string("- Normalized time: `")
  buf.write_string(runtime.normalized_time.to_string())
  buf.write_string("`\n")
  buf.write_string("- Status: `")
  buf.write_string(overlay.status_label)
  buf.write_string("`\n\n")
  buf.write_string("## Edit Goal\n\n")
  buf.write_string(doc.ai_edit_goal)
  buf.write_string("\n\n")
  buf.write_string("## Constraints\n\n")
  buf.write_string("- Keep track ids and labels stable.\n")
  buf.write_string("- Prefer track-local edits over document-wide rewrites.\n")
  buf.write_string("- Preserve a readable timing silhouette in the timeline.\n")
  buf.write_string("- Use `")
  buf.write_string(effect_doc_target_file())
  buf.write_string("` as the source of truth.\n\n")
  buf.write_string("## Track Targets\n\n")
  for i in 0..<doc.tracks.length() {
    let track = doc.tracks[i]
    buf.write_string("### ")
    buf.write_string(track.id)
    buf.write_string("\n\n")
    buf.write_string(effect_track_edit_focus(track))
    buf.write_string("\n\n```moonbit\n")
    buf.write_string(effect_track_patch_scaffold(track, i))
    buf.write_string("\n```\n\n")
  }
  buf.write_string("## Document Scaffold\n\n```moonbit\n")
  buf.write_string(effect_document_patch_scaffold(doc))
  buf.write_string("\n```\n")
  buf.to_string()
}

///|
fn effect_studio_context_json(
  doc : @effect.EffectDocument,
  preview_time : Double,
  playing : Bool,
) -> String {
  let runtime = @effect.build_effect_runtime_plan(doc, preview_time)
  let timeline = @effect.build_timeline_view(doc, preview_time)
  let overlay = build_effect_studio_overlay_model(doc, preview_time, playing)
  let patch_bundle_json = effect_studio_patch_bundle_json(
    doc, preview_time, playing,
  )
  let review_prompt_markdown = effect_studio_review_prompt_markdown(
    doc, preview_time, playing,
  )
  let buf = StringBuilder::new()
  buf.write_string("{\"name\":\"")
  buf.write_string(json_escape(doc.name))
  buf.write_string("\",\"notes\":\"")
  buf.write_string(json_escape(doc.notes))
  buf.write_string("\",\"ai_edit_goal\":\"")
  buf.write_string(json_escape(doc.ai_edit_goal))
  buf.write_string("\",\"duration\":")
  buf.write_string(doc.duration.to_string())
  buf.write_string(",\"looping\":")
  buf.write_string(if doc.looping { "true" } else { "false" })
  buf.write_string(",\"preview_time\":")
  buf.write_string(preview_time.to_string())
  buf.write_string(",\"normalized_time\":")
  buf.write_string(runtime.normalized_time.to_string())
  buf.write_string(",\"playing\":")
  buf.write_string(if playing { "true" } else { "false" })
  buf.write_string(",\"overlay\":{")
  buf.write_string("\"status_label\":\"")
  buf.write_string(overlay.status_label)
  buf.write_string("\",\"lane_count\":")
  buf.write_string(overlay.lane_count.to_string())
  buf.write_string(",\"scheduled_burst_count\":")
  buf.write_string(overlay.scheduled_burst_count.to_string())
  buf.write_string(",\"scheduled_particle_count\":")
  buf.write_string(overlay.scheduled_particle_count.to_string())
  buf.write_string(",\"active_track_count\":")
  buf.write_string(overlay.active_track_count.to_string())
  buf.write_string(",\"playhead_ratio\":")
  buf.write_string(overlay.playhead_ratio.to_string())
  buf.write_string("},\"tracks\":[")
  for i in 0..<doc.tracks.length() {
    if i > 0 {
      buf.write_string(",")
    }
    let track = doc.tracks[i]
    buf.write_string("{\"id\":\"")
    buf.write_string(json_escape(track.id))
    buf.write_string("\",\"label\":\"")
    buf.write_string(json_escape(track.label))
    buf.write_string("\",\"start_time\":")
    buf.write_string(track.start_time.to_string())
    buf.write_string(",\"duration\":")
    buf.write_string(track.duration.to_string())
    buf.write_string(",\"burst_interval\":")
    buf.write_string(track.burst_interval.to_string())
    buf.write_string(",\"burst_particles\":")
    buf.write_string(track.burst_particles.to_string())
    buf.write_string(",\"pattern\":\"")
    buf.write_string(@effect.effect_spawn_pattern_name(track.pattern))
    buf.write_string("\",\"origin\":")
    buf.write_string(vec3_json(track.origin))
    buf.write_string(",\"enabled\":")
    buf.write_string(if track.enabled { "true" } else { "false" })
    buf.write_string("}")
  }
  buf.write_string("],\"timeline\":[")
  for i in 0..<timeline.lanes.length() {
    if i > 0 {
      buf.write_string(",")
    }
    let lane = timeline.lanes[i]
    buf.write_string("{\"id\":\"")
    buf.write_string(json_escape(lane.id))
    buf.write_string("\",\"active\":")
    buf.write_string(if lane.active { "true" } else { "false" })
    buf.write_string(",\"start_ratio\":")
    buf.write_string(lane.start_ratio.to_string())
    buf.write_string(",\"duration_ratio\":")
    buf.write_string(lane.duration_ratio.to_string())
    buf.write_string(",\"marker_count\":")
    buf.write_string(lane.marker_ratios.length().to_string())
    buf.write_string("}")
  }
  buf.write_string("],\"scheduled_bursts\":[")
  for i in 0..<runtime.scheduled_bursts.length() {
    if i > 0 {
      buf.write_string(",")
    }
    let burst = runtime.scheduled_bursts[i]
    buf.write_string("{\"track_id\":\"")
    buf.write_string(json_escape(burst.track_id))
    buf.write_string("\",\"spawn_time\":")
    buf.write_string(burst.spawn_time.to_string())
    buf.write_string(",\"age\":")
    buf.write_string(burst.age.to_string())
    buf.write_string("}")
  }
  buf.write_string("],\"patch_scaffold\":{")
  buf.write_string("\"target_file\":\"")
  buf.write_string(effect_doc_target_file())
  buf.write_string("\",\"edit_contract\":\"")
  buf.write_string(
    "Edit the effect document in code. Keep timeline order readable and prefer track-local changes.",
  )
  buf.write_string("\",\"document_patch_scaffold\":\"")
  buf.write_string(json_escape(effect_document_patch_scaffold(doc)))
  buf.write_string("\",\"track_patch_scaffolds\":[")
  for i in 0..<doc.tracks.length() {
    if i > 0 {
      buf.write_string(",")
    }
    let track = doc.tracks[i]
    buf.write_string("{\"track_id\":\"")
    buf.write_string(json_escape(track.id))
    buf.write_string("\",\"index\":")
    buf.write_string(i.to_string())
    buf.write_string(",\"scaffold\":\"")
    buf.write_string(json_escape(effect_track_patch_scaffold(track, i)))
    buf.write_string("\"}")
  }
  buf.write_string("]},\"patch_bundle\":")
  append_effect_patch_bundle_payload_json(buf, doc, preview_time, playing)
  buf.write_string(",\"exports\":{")
  buf.write_string("\"bundle_filename\":\"")
  buf.write_string(effect_studio_patch_bundle_filename(doc))
  buf.write_string("\",\"bundle_json\":\"")
  buf.write_string(json_escape(patch_bundle_json))
  buf.write_string("\",\"review_filename\":\"")
  buf.write_string(effect_studio_review_prompt_filename(doc))
  buf.write_string("\",\"review_markdown\":\"")
  buf.write_string(json_escape(review_prompt_markdown))
  buf.write_string("\"}")
  buf.write_string("}")
  buf.to_string()
}

///|
fn effect_studio_summary(
  doc : @effect.EffectDocument,
  preview_time : Double,
  playing : Bool,
) -> String {
  let overlay = build_effect_studio_overlay_model(doc, preview_time, playing)
  let buf = StringBuilder::new()
  buf.write_string("EFFECT ")
  buf.write_string(doc.name)
  buf.write_string("\nstatus: ")
  buf.write_string(overlay.status_label)
  buf.write_string(", time: ")
  buf.write_string(preview_time.to_string())
  buf.write_string(", tracks: ")
  buf.write_string(overlay.lane_count.to_string())
  buf.write_string(", active: ")
  buf.write_string(overlay.active_track_count.to_string())
  buf.write_string(", bursts: ")
  buf.write_string(overlay.scheduled_burst_count.to_string())
  buf.write_string(", particles: ")
  buf.write_string(overlay.scheduled_particle_count.to_string())
  buf.write_string("\nai-edit: edit ")
  buf.write_string(effect_doc_target_file())
  buf.write_string(
    " using the patch_scaffold payload; treat the timeline as feedback, not the source of truth.",
  )
  buf.to_string()
}

///|
pub extend EffectStudioOverlayModel with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend EffectStudioOverlayModel with Show::{to_string, output}
