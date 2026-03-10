import test from "node:test";
import assert from "node:assert/strict";
import { mkdtempSync, rmSync } from "node:fs";
import { join, resolve } from "node:path";
import { spawnSync } from "node:child_process";
import { tmpdir } from "node:os";

test("model-authoring-renderer-parity keeps frog web/native captures visually aligned", { timeout: 120_000 }, (t) => {
  if (process.env.KAGURA_RUN_RENDERER_PARITY !== "1") {
    t.skip("set KAGURA_RUN_RENDERER_PARITY=1 to run renderer parity integration");
    return;
  }

  const tempDir = mkdtempSync(join(tmpdir(), "kagura-renderer-parity-"));
  try {
    const result = spawnSync(
      process.execPath,
      [
        resolve("tools/modeling3d/scripts/model-authoring-renderer-parity.mjs"),
        "--example",
        "frog_authoring",
        "--port",
        "8212",
        "--out-dir",
        tempDir,
      ],
      {
        cwd: resolve("."),
        encoding: "utf8",
      },
    );

    assert.equal(result.status, 0, result.stderr || result.stdout);
    const stdoutJson = JSON.parse(result.stdout);
    assert.equal(stdoutJson.same_current_document, true);
    assert.equal(stdoutJson.same_summary, true);
    assert.equal(stdoutJson.silhouette_ok, true);
    assert.equal(stdoutJson.visual_ok, true, JSON.stringify(stdoutJson, null, 2));
    assert.ok(stdoutJson.silhouette_diff.diff_ratio <= 0.2);
    assert.ok(stdoutJson.visual_diff.mean_abs_rgb_diff <= 20);
  } finally {
    rmSync(tempDir, { recursive: true, force: true });
  }
});
