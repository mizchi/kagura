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
      "A shelf should read as stacked horizontal boards supported by vertical uprights.",
      "Shelf levels, uprights, and storage props should stay aligned instead of collapsing into floating helper geometry.",
    ],
    doc_source_path: "examples/shelf_authoring/src/model_doc.mbt",
  }
}
