import test from "node:test";
import assert from "node:assert/strict";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";
import { spawnSync } from "node:child_process";
import { tmpdir } from "node:os";

test("model-authoring-vlm-apply-patch updates a target MoonBit file in place", () => {
  const tempDir = mkdtempSync(join(tmpdir(), "kagura-vlm-apply-patch-"));
  try {
    const targetPath = join(tempDir, "model_doc.mbt");
    const patchPath = join(tempDir, "patch.mbt");
    writeFileSync(
      targetPath,
      `fn default_model_document() -> ModelDocument {\n  {\n    name: "vlm_clay_totem",\n    notes: "notes",\n  }\n}\n`,
    );
    writeFileSync(
      patchPath,
      `fn apply_imported_patch(doc : ModelDocument) -> ModelDocument {\n  doc\n}\n`,
    );

    const result = spawnSync(
      process.execPath,
      [
        resolve("tools/modeling3d/scripts/model-authoring-vlm-apply-patch.mjs"),
        "--target",
        targetPath,
        "--patch",
        patchPath,
        "--write",
      ],
      {
        cwd: resolve("."),
        encoding: "utf8",
      },
    );

    assert.equal(result.status, 0, result.stderr);
    const stdoutJson = JSON.parse(result.stdout);
    assert.equal(stdoutJson.mode, "write");
    assert.equal(stdoutJson.target, targetPath);
    assert.equal(stdoutJson.changed, true);
    const updated = readFileSync(targetPath, "utf8");
    assert.match(updated, /apply_imported_patch\(/);
    assert.match(updated, /VLM_ROUNDTRIP_PATCH_START/);
  } finally {
    rmSync(tempDir, { recursive: true, force: true });
  }
});
