import test from "node:test";
import assert from "node:assert/strict";
import { resolve } from "node:path";

import {
  buildDaemonCyclePlan,
  parseVlmDaemonCommand,
} from "./model-authoring-vlm-daemon-utils.mjs";

test("parseVlmDaemonCommand parses run commands", () => {
  assert.deepEqual(
    parseVlmDaemonCommand(
      JSON.stringify({
        op: "run",
        cycle: 3,
        outDir: "tmp/daemon-run",
        reviewBinarize: true,
      }),
    ),
    {
      op: "run",
      cycle: 3,
      outDir: "tmp/daemon-run",
      reviewBinarize: true,
    },
  );
});

test("parseVlmDaemonCommand parses shutdown commands", () => {
  assert.deepEqual(parseVlmDaemonCommand('{"op":"shutdown"}'), {
    op: "shutdown",
  });
});

test("buildDaemonCyclePlan inherits live-review browser config", () => {
  const basePlan = {
    example: "frog_authoring",
    renderer: "web",
    url: "http://127.0.0.1:8113/",
    port: 8113,
    outDir: "/repo/output/playwright/frog-authoring-handoff",
    provider: "openrouter",
    preset: "preview",
    model: "google/gemini-3.1-flash-lite-preview",
    apiUrl: "https://openrouter.ai/api/v1/chat/completions",
    apiKeyEnv: "OPENROUTER_API_KEY",
    execute: false,
    headed: false,
    reviewBinarize: false,
    timeoutMs: 30_000,
  };

  const plan = buildDaemonCyclePlan(basePlan, {
    op: "run",
    cycle: 2,
    outDir: "tmp/daemon-run",
    reviewBinarize: true,
  });

  assert.equal(plan.example, "frog_authoring");
  assert.equal(plan.liveReview, true);
  // buildDaemonCyclePlan resolves outDir against the cwd, so the expectation has
  // to as well — a literal absolute path only passes on the machine it was
  // recorded on.
  assert.equal(plan.outDir, resolve("tmp/daemon-run"));
  assert.equal(plan.reviewBinarize, true);
  assert.equal(plan.url, "http://127.0.0.1:8113/");
  assert.equal(plan.provider, "openrouter");
});
