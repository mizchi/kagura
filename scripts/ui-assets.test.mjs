import assert from "node:assert/strict";
import test from "node:test";

import { runAssetManifest } from "./ui-assets.mjs";

test("an example with an empty assets list is a successful no-op", () => {
  const report = runAssetManifest("ui_demo");
  assert.equal(report.ok, true);
  assert.deepEqual(report.results, []);
});

test("an unknown example fails closed", () => {
  assert.throws(() => runAssetManifest("no_such_example"), /unknown example/);
});
