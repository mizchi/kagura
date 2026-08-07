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
      "Aim for a squat frog silhouette instead of a generic blob.", "Eyes should remain a deliberate paired feature.",
      "Haunches, forelimbs, and the mouth landmark should remain readable.",
    ],
    doc_source_path: "examples/frog_authoring/src/model_doc.mbt",
  }
}
