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
    review_profile_id: "organic_character",
    review_constraints: [
      "Aim for a readable dragon silhouette with a clear head, neck, torso, and tail instead of a generic blob.",
      "Wings should read as deliberate side volumes rather than detached helper lumps.",
      "Horns, jawline, and glowing eyes should remain readable from angled and front views.",
    ],
    doc_source_path: "examples/dragon_authoring/src/model_doc.mbt",
  }
}
