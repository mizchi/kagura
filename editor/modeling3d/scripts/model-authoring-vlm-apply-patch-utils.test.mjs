import test from "node:test";
import assert from "node:assert/strict";

import {
  MODEL_DOC_PATCH_MARKERS,
  applyRoundtripPatchToModelDoc,
} from "./model-authoring-vlm-apply-patch-utils.mjs";

const BASE_MODEL_DOC = `fn default_model_document() -> ModelDocument {
  {
    name: "vlm_clay_totem",
    notes: "notes",
  }
}
`;

const PATCH_SNIPPET = `fn apply_imported_patch(doc : ModelDocument) -> ModelDocument {
  doc
}
`;

test("applyRoundtripPatchToModelDoc wraps default_model_document and appends patch block", () => {
  const updated = applyRoundtripPatchToModelDoc(BASE_MODEL_DOC, PATCH_SNIPPET);

  assert.match(updated, /fn default_model_document\(\) -> ModelDocument \{\n  apply_imported_patch\(/);
  assert.match(updated, new RegExp(MODEL_DOC_PATCH_MARKERS.start.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")));
  assert.match(updated, /fn apply_imported_patch\(doc : ModelDocument\) -> ModelDocument \{/);
});

test("applyRoundtripPatchToModelDoc is idempotent for the same patch", () => {
  const once = applyRoundtripPatchToModelDoc(BASE_MODEL_DOC, PATCH_SNIPPET);
  const twice = applyRoundtripPatchToModelDoc(once, PATCH_SNIPPET);

  assert.equal(twice, once);
});

test("applyRoundtripPatchToModelDoc composes a new patch with an existing generated patch block", () => {
  const original = `${BASE_MODEL_DOC}\n${MODEL_DOC_PATCH_MARKERS.start}\nfn apply_imported_patch(doc : ModelDocument) -> ModelDocument {\n  old_doc\n}\n${MODEL_DOC_PATCH_MARKERS.end}\n`;
  const updated = applyRoundtripPatchToModelDoc(original, PATCH_SNIPPET);

  assert.match(updated, /fn apply_imported_patch_stage_0\(doc : ModelDocument\) -> ModelDocument \{\n  old_doc\n\}/);
  assert.match(updated, /fn apply_imported_patch_stage_1\(doc : ModelDocument\) -> ModelDocument \{\n  doc\n\}/);
  assert.match(updated, /let stage_0 = apply_imported_patch_stage_0\(doc\)/);
  assert.match(updated, /let stage_1 = apply_imported_patch_stage_1\(stage_0\)/);
  assert.match(updated, /stage_1\n\}/);
});

test("applyRoundtripPatchToModelDoc appends a new stage to an already composed patch block", () => {
  const original = `${BASE_MODEL_DOC}\n${MODEL_DOC_PATCH_MARKERS.start}\nfn apply_imported_patch_stage_0(doc : ModelDocument) -> ModelDocument {\n  old_doc\n}\n\nfn apply_imported_patch_stage_1(doc : ModelDocument) -> ModelDocument {\n  stage_one\n}\n\nfn apply_imported_patch(doc : ModelDocument) -> ModelDocument {\n  let stage_0 = apply_imported_patch_stage_0(doc)\n  let stage_1 = apply_imported_patch_stage_1(stage_0)\n  stage_1\n}\n${MODEL_DOC_PATCH_MARKERS.end}\n`;
  const updated = applyRoundtripPatchToModelDoc(original, PATCH_SNIPPET);

  assert.match(updated, /fn apply_imported_patch_stage_0\(doc : ModelDocument\) -> ModelDocument \{\n  old_doc\n\}/);
  assert.match(updated, /fn apply_imported_patch_stage_1\(doc : ModelDocument\) -> ModelDocument \{\n  stage_one\n\}/);
  assert.match(updated, /fn apply_imported_patch_stage_2\(doc : ModelDocument\) -> ModelDocument \{\n  doc\n\}/);
  assert.match(updated, /let stage_2 = apply_imported_patch_stage_2\(stage_1\)/);
  assert.match(updated, /stage_2\n\}/);
});
