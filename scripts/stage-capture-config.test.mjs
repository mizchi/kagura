import assert from "node:assert/strict";
import test from "node:test";
import { resolve } from "node:path";

import { CAPTURE_CONFIG_FILENAME, buildCaptureConfig } from "./stage-capture-config.mjs";

test("buildCaptureConfig emits the three paths the engine requires", () => {
  const text = buildCaptureConfig({ outDir: "output/capture", name: "ui_demo" });
  const dir = resolve("output/capture");
  assert.equal(
    text,
    [
      `screenshot_path=${dir}/ui_demo.png`,
      `context_path=${dir}/ui_demo.context.json`,
      `summary_path=${dir}/ui_demo.summary.txt`,
      "binarize=0",
      "",
    ].join("\n"),
  );
});

test("buildCaptureConfig resolves paths to absolute", () => {
  // The example runs with its own directory as the cwd, so a relative path in
  // the config would land the artifacts inside the example instead of out-dir.
  const text = buildCaptureConfig({ outDir: "output/capture", name: "x" });
  for (const line of text.trim().split("\n")) {
    const [, value] = line.split("=");
    if (line.startsWith("binarize")) continue;
    assert.ok(value.startsWith("/"), `expected an absolute path, got ${value}`);
  }
});

test("buildCaptureConfig honours binarize", () => {
  assert.match(buildCaptureConfig({ outDir: ".", name: "x", binarize: true }), /^binarize=1$/m);
  assert.match(buildCaptureConfig({ outDir: ".", name: "x" }), /^binarize=0$/m);
});

test("the staged filename matches what the engine looks for", () => {
  // modules/kagura_engine/capture/contracts.mbt: capture_config_filename
  assert.equal(CAPTURE_CONFIG_FILENAME, "kagura_native_capture_config.txt");
});
