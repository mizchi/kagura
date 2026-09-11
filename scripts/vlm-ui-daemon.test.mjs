import assert from "node:assert/strict";
import test from "node:test";

import { daemonUsage, parseDaemonArgs } from "./vlm-ui-daemon.mjs";
import { matrixReviewJobs } from "./vlm-ui-review.mjs";
import { findExampleDir, EXAMPLE_ROOT } from "./example-dirs.mjs";

test("daemon CLI defaults to dry-run on localhost:9124", () => {
  const options = parseDaemonArgs(["ui_demo"]);
  assert.equal(options.example, "ui_demo");
  assert.equal(options.host, "127.0.0.1");
  assert.equal(options.port, 9124);
  assert.equal(options.dryRun, true);
});

test("daemon CLI --execute is what actually calls the VLM", () => {
  const options = parseDaemonArgs(["ui_demo", "--execute", "--port", "9"]);
  assert.equal(options.dryRun, false);
  assert.equal(options.port, 9);
});

test("daemon CLI rejects a missing example", () => {
  assert.throws(() => parseDaemonArgs([]), /missing <example>/);
  assert.match(daemonUsage(), /POST \/review/);
});

test("matrix review jobs cover every ui_demo state x viewport", () => {
  const exampleDir = findExampleDir("ui_demo", [EXAMPLE_ROOT.examples]);
  const jobs = matrixReviewJobs(exampleDir);
  const names = jobs.map((job) => job.state);
  assert.ok(names.includes("idle.standard"));
  assert.ok(names.includes("initial_focus.portrait"));
  assert.equal(jobs.length, 16);
});
