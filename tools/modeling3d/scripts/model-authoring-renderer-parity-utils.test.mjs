import test from "node:test";
import assert from "node:assert/strict";

import {
  buildRendererParityArtifacts,
  summarizeRendererParity,
} from "./model-authoring-renderer-parity-utils.mjs";

test("buildRendererParityArtifacts derives nested web/native paths", () => {
  const artifacts = buildRendererParityArtifacts({
    cwd: "/repo",
    outDir: "tmp/parity",
    example: "frog_authoring",
  });

  assert.equal(artifacts.rootDir, "/repo/tmp/parity");
  assert.equal(artifacts.webDir, "/repo/tmp/parity/web");
  assert.equal(artifacts.nativeDir, "/repo/tmp/parity/native");
  assert.equal(artifacts.webBinarizedDir, "/repo/tmp/parity/web-binarized");
  assert.equal(artifacts.nativeBinarizedDir, "/repo/tmp/parity/native-binarized");
  assert.equal(artifacts.reportPath, "/repo/tmp/parity/parity-report.json");
});

test("summarizeRendererParity reports success when bundles and visual parity are within threshold", () => {
  const summary = summarizeRendererParity({
    sameCurrentDocument: true,
    sameSummary: true,
    silhouetteDiffRatio: 0.12,
    silhouetteDiffThreshold: 0.2,
    visualMeanAbsRgbDiff: 12,
    visualMeanAbsRgbThreshold: 20,
  });

  assert.equal(summary.ok, true);
  assert.equal(summary.silhouetteOk, true);
  assert.equal(summary.visualOk, true);
  assert.deepEqual(summary.issues, []);
  assert.deepEqual(summary.visualIssues, []);
});

test("summarizeRendererParity reports concrete issues for mismatches", () => {
  const summary = summarizeRendererParity({
    sameCurrentDocument: false,
    sameSummary: false,
    silhouetteDiffRatio: 0.24,
    silhouetteDiffThreshold: 0.2,
    visualMeanAbsRgbDiff: 44,
    visualMeanAbsRgbThreshold: 20,
  });

  assert.equal(summary.ok, false);
  assert.deepEqual(summary.issues, [
    "current_document mismatch",
    "workbench_summary mismatch",
    "silhouette diff ratio 0.2400 exceeds threshold 0.2000",
  ]);
  assert.deepEqual(summary.visualIssues, [
    "visual mean abs rgb diff 44.0000 exceeds threshold 20.0000",
  ]);
});
