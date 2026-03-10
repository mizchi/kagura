import test from "node:test";
import assert from "node:assert/strict";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";
import { spawnSync } from "node:child_process";
import { tmpdir } from "node:os";

test("model-authoring-vlm-local-feedback writes local review artifacts", () => {
  const tempDir = mkdtempSync(join(tmpdir(), "kagura-vlm-local-feedback-"));
  try {
    const bundlePath = join(tempDir, "vlm_bundle.json");
    const parsedPath = join(tempDir, "parsed.json");
    const outDir = join(tempDir, "out");

    writeFileSync(
      bundlePath,
      JSON.stringify({
        target_file: "tools/modeling3d/examples/model_authoring/src/model_doc.mbt",
        current_document: {
          primitives: [
            {
              id: "pedestal",
              kind: "cube",
              position: [0, 0, 1.2],
              scale: [0.4, 0.4, 0.4],
            },
            { id: "guide_orb" },
            {
              id: "middle_shelf",
              kind: "cube",
              position: [0, 0.08, 0],
              scale: [1.48, 0.12, 0.48],
            },
            {
              id: "crate_left",
              kind: "cube",
              position: [-0.2, 0.25, 0.02],
              scale: [0.24, 0.24, 0.22],
            },
            {
              id: "crate_right",
              kind: "cube",
              position: [0.2, 0.23, -0.02],
              scale: [0.22, 0.2, 0.2],
            },
          ],
          sculpt_layers: [
            { id: "clay_head" },
          ],
        },
        patch_payload: {
          snippet_filename: "vlm_clay_totem_roundtrip_patch.mbt",
          moonbit_patch: "fn apply_imported_patch(doc : ModelDocument) -> ModelDocument { doc }",
          auto_actions: [
            {
              source_id: "pedestal",
              target_kind: "primitive",
              action_kind: "set_position",
              target_position: [0.2, 0, 0],
            },
          ],
          opt_in_remove_source_ids: ["guide_orb"],
          opt_in_append_source_ids: ["blender_helper"],
          manual_issue_details: [
            {
              source_id: "guide_orb",
              issue_kind: "review_missing",
              action_kind: "review_missing",
              target_kind: "primitive",
              suggested_moonbit: "// ignore(primitives.remove(1))",
            },
            {
              source_id: "clay_head",
              issue_kind: "review_stamp_count",
              action_kind: "review_stamp_count",
              target_kind: "sculpt_layer",
              current_stamp_count: 6,
              imported_stamp_count: 7,
              review_hint: "Do not invent sculpt stamps",
              suggested_moonbit: "// current: 6, imported: 7",
            },
            {
              source_id: "blender_helper",
              issue_kind: "review_extra",
              action_kind: "review_extra",
              target_kind: "primitive",
              imported_primitive_kind: "cube",
              imported_position: [1.2, 0, 0],
              imported_scale: [0.2, 0.2, 0.2],
              imported_color_hex: "0xAAAAAA",
              suggested_moonbit: "// primitives.push({ id: \"blender_helper\" })",
            },
          ],
        },
      }),
    );
    writeFileSync(
      parsedPath,
      JSON.stringify({
        target_file: "tools/modeling3d/examples/model_authoring/src/model_doc.mbt",
        overall_summary: "summary",
        confidence: "high",
        recommended_actions: [
          {
            priority: "high",
            action: "apply_auto_patch",
            source_id: "pedestal",
            rationale: "reason",
            suggested_moonbit: "patch",
          },
        ],
        manual_followups: [
          {
            source_id: "clay_head",
            issue_kind: "review_stamp_count",
            next_step: "review",
            rationale: "stamp",
          },
          {
            source_id: "crate_right",
            issue_kind: "review_alignment",
            next_step: "Adjust Z-axis offset and Y position to maintain consistent spacing with crate_left.",
            rationale: "The crate_right is slightly floating relative to the middle shelf compared to crate_left.",
          },
        ],
        visual_findings: [
          {
            source_id: "crate_right",
            area: "primitive_transform",
            observation: "Slight misalignment in height and depth compared to the adjacent crate_left.",
            impact: "Inconsistent visual baseline for storage items.",
          },
        ],
      }),
    );

    const result = spawnSync(
      process.execPath,
      [
        resolve("tools/modeling3d/scripts/model-authoring-vlm-local-feedback.mjs"),
        "--bundle",
        bundlePath,
        "--parsed",
        parsedPath,
        "--out-dir",
        outDir,
      ],
      {
        cwd: resolve("."),
        encoding: "utf8",
      },
    );

    assert.equal(result.status, 0, result.stderr);
    const stdoutJson = JSON.parse(result.stdout);
    assert.equal(stdoutJson.target_file, "tools/modeling3d/examples/model_authoring/src/model_doc.mbt");
    assert.equal(stdoutJson.patch_filename, "vlm_clay_totem_roundtrip_patch.mbt");
    assert.equal(stdoutJson.opt_in_patch_filename, "vlm_clay_totem_roundtrip_patch-opt-in.mbt");
    assert.equal(stdoutJson.review_patch_filename, "vlm_bundle-review-fixes.mbt");
    assert.equal(
      readFileSync(stdoutJson.patch_path, "utf8"),
      "fn apply_imported_patch(doc : ModelDocument) -> ModelDocument { doc }\n",
    );
    const optInPatch = readFileSync(stdoutJson.opt_in_patch_path, "utf8");
    assert.match(optInPatch, /ignore\(primitives\.remove\(1\)\)/);
    assert.match(optInPatch, /id: "blender_helper"/);
    assert.match(optInPatch, /\/\/ current: 6, imported: 7/);
    const reviewPatch = readFileSync(stdoutJson.review_patch_path, "utf8");
    assert.match(reviewPatch, /fn apply_vlm_review_patch/);
    assert.match(reviewPatch, /snap_to_plane:middle_shelf/);
    assert.match(reviewPatch, /equalize_spacing:crate_left/);
    assert.match(reviewPatch, /primitives\[4\]/);
    const stampReview = readFileSync(stdoutJson.stamp_review_path, "utf8");
    assert.match(stampReview, /^# Kagura Sculpt Stamp Review/m);
    assert.match(stampReview, /## clay_head/);
    assert.match(stampReview, /Current stamps: `6`/);
    assert.match(stampReview, /Imported stamps: `7`/);
    const stampScaffold = readFileSync(stdoutJson.stamp_scaffold_path, "utf8");
    assert.match(stampScaffold, /^fn apply_imported_stamp_sync/m);
    assert.match(stampScaffold, /clay_head: current 6, imported 7/);
    assert.match(stampScaffold, /id: "clay_head_todo_6"/);
    assert.deepEqual(
      JSON.parse(readFileSync(stdoutJson.task_queue_path, "utf8")),
      [
        {
          source_id: "pedestal",
          priority: "high",
          task_type: "apply_patch",
          blocking: false,
          recommended_action_types: ["apply_auto_patch"],
          manual_issue_kinds: [],
          visual_areas: [],
          summary_line: "[high] pedestal apply_patch: patch apply_auto_patch",
        },
        {
          source_id: "crate_right",
          priority: "high",
          task_type: "manual_review",
          blocking: true,
          recommended_action_types: [],
          manual_issue_kinds: ["review_alignment"],
          visual_areas: ["primitive_transform"],
          summary_line:
            "[high] crate_right manual_review: manual review_alignment; visual primitive_transform",
        },
        {
          source_id: "crate_left",
          priority: "high",
          task_type: "manual_review",
          blocking: true,
          recommended_action_types: [],
          manual_issue_kinds: ["review_alignment"],
          visual_areas: ["primitive_transform"],
          summary_line:
            "[high] crate_left manual_review: manual review_alignment; visual primitive_transform",
        },
        {
          source_id: "clay_head",
          priority: "medium",
          task_type: "manual_review",
          blocking: true,
          recommended_action_types: [],
          manual_issue_kinds: ["review_stamp_count"],
          visual_areas: [],
          summary_line: "[medium] clay_head manual_review: manual review_stamp_count",
        },
      ],
    );
    assert.deepEqual(
      JSON.parse(readFileSync(stdoutJson.manual_issues_path, "utf8")),
      [
        {
          source_id: "guide_orb",
          issue_kind: "review_missing",
          action_kind: "review_missing",
          target_kind: "primitive",
          suggested_moonbit: "// ignore(primitives.remove(1))",
        },
        {
          source_id: "clay_head",
          issue_kind: "review_stamp_count",
          action_kind: "review_stamp_count",
          target_kind: "sculpt_layer",
          current_stamp_count: 6,
          imported_stamp_count: 7,
          review_hint: "Do not invent sculpt stamps",
          suggested_moonbit: "// current: 6, imported: 7",
        },
        {
          source_id: "blender_helper",
          issue_kind: "review_extra",
          action_kind: "review_extra",
          target_kind: "primitive",
          imported_primitive_kind: "cube",
          imported_position: [1.2, 0, 0],
          imported_scale: [0.2, 0.2, 0.2],
          imported_color_hex: "0xAAAAAA",
          suggested_moonbit: "// primitives.push({ id: \"blender_helper\" })",
        },
      ],
    );
    assert.match(readFileSync(stdoutJson.review_path, "utf8"), /^## Kagura VLM Review/m);
  } finally {
    rmSync(tempDir, { recursive: true, force: true });
  }
});
