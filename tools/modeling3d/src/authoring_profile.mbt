// ============================================================
// Authoring profile
// ============================================================
//
// The only thing the round-trip review loop needs that differs per authoring
// example. It is threaded as a parameter rather than read from a package-level
// slot so a caller cannot forget to set it and silently review a frog against
// hard-surface constraints.

///|
pub(all) struct AuthoringProfile {
  /// Review profile the VLM prompt declares, e.g. `organic_character`.
  /// Consumed by `tools/modeling3d/scripts/model-authoring-vlm-review-utils.mjs`,
  /// which selects its rule set from this id — keep the ids in step with it.
  review_profile_id : String
  /// Model-specific things the review must not let drift (silhouette, paired
  /// features, landmarks). Written verbatim into the review prompt and bundle.
  review_constraints : Array[String]
  /// Repo-relative path of the example's `model_doc.mbt`. The VLM apply-patch
  /// step edits that file, so the prompt and bundle name it explicitly.
  doc_source_path : String
}
