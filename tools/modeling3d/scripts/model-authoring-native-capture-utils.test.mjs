import test from "node:test";
import assert from "node:assert/strict";

import {
  NATIVE_CAPTURE_CONFIG_FILENAME,
  buildNativeCaptureConfig,
  resolveNativeCaptureStagePath,
  resolveNativeExampleDir,
} from "./model-authoring-native-capture-utils.mjs";

test("buildNativeCaptureConfig emits absolute output paths", () => {
  const config = buildNativeCaptureConfig({
    screenshotPath: "output/playwright/frog.png",
    contextPath: "output/playwright/frog-context.json",
    summaryPath: "output/playwright/frog-summary.txt",
    binarize: true,
  });

  assert.match(config, /screenshot_path=.*output\/playwright\/frog\.png/);
  assert.match(config, /context_path=.*frog-context\.json/);
  assert.match(config, /summary_path=.*frog-summary\.txt/);
  assert.match(config, /binarize=1/);
});

test("resolveNativeExampleDir maps examples under the repository root", () => {
  assert.equal(NATIVE_CAPTURE_CONFIG_FILENAME, "kagura_native_capture_config.txt");
  assert.equal(
    resolveNativeExampleDir({ cwd: "/repo", example: "frog_authoring" }),
    "/repo/tools/modeling3d/examples/frog_authoring",
  );
  assert.equal(
    resolveNativeCaptureStagePath({
      cwd: "/repo",
      example: "frog_authoring",
    }),
    "/repo/tools/modeling3d/examples/frog_authoring/kagura_native_capture_config.txt",
  );
});
