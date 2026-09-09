// ============================================================
// Review profile
// ============================================================
//
// What the round-trip review loop must judge this model against. The ids and
// constraint text are read verbatim into the VLM prompt and bundle, so changing
// them changes review behaviour.

///|
fn authoring_profile() -> @modeling3d.AuthoringProfile {
  {
    review_profile_id: "generic_model",
    review_constraints: [
      "Keep the primary silhouette readable from angled, front, side, and top views.",
      "Treat helper or debug primitives as non-final unless the imported diff marks them as intentional.",
    ],
    doc_source_path: "examples/model_authoring/src/model_doc.mbt",
  }
}
