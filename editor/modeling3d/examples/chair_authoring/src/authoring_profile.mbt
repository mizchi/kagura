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
    review_profile_id: "hard_surface_prop",
    review_constraints: [
      "A chair should read as a stable seat, backrest, and support structure.", "Legs, braces, and seat planes should stay aligned rather than drifting into floating helper geometry.",
    ],
    doc_source_path: "examples/chair_authoring/src/model_doc.mbt",
  }
}
