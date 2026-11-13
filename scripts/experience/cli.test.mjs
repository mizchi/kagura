import test from "node:test";
import assert from "node:assert/strict";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { mkdtemp, readFile, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
const exec = promisify(execFile),
  script = fileURLToPath(new URL("../experience.mjs", import.meta.url));

test("local experience experiments emit replayable evidence, missing values and a descriptive comparison", async () => {
  const dir = await mkdtemp(join(tmpdir(), "experience-"));
  const env = { ...process.env, TYPESAFE_API_KEY: "", TYPESAFEAI_API_KEY: "" };
  try {
    const first = join(dir, "first"),
      second = join(dir, "second"),
      reduced = join(dir, "reduced");
    const result = JSON.parse(
      (
        await exec(
          process.execPath,
          [script, "--no-build", "--policy", "attack", "--out", first],
          { env },
        )
      ).stdout,
    );
    assert.equal(result.valid, true);
    assert.equal(result.status, "victory");
    const report = JSON.parse(
      await readFile(join(first, "report.json"), "utf8"),
    );
    assert.equal(
      report.measures.find((m) => m.id === "recognitionRate").value,
      null,
    );
    assert.match(
      await readFile(join(first, "report.md"), "utf8"),
      /not-instrumented/,
    );
    await exec(
      process.execPath,
      [
        script,
        "--no-build",
        "--policy",
        "tactical",
        "--out",
        second,
        "--baseline",
        join(first, "report.json"),
      ],
      { env },
    );
    const comparison = JSON.parse(
      await readFile(join(second, "comparison.json"), "utf8"),
    );
    assert.equal(comparison.kind, "descriptive");
    const input = comparison.measures.find(
      (m) => m.id === "commandsPerResolution",
    );
    assert.notEqual(input.delta, 0);
    await exec(
      process.execPath,
      [
        script,
        "--no-build",
        "--trace",
        join(first, "trace.jsonl"),
        "--out",
        reduced,
      ],
      { env },
    );
    const replay = JSON.parse(
      await readFile(join(reduced, "report.json"), "utf8"),
    );
    assert.deepEqual(replay.measures, report.measures);
    await assert.rejects(
      exec(process.execPath, [script, "--no-build", "--out", first], { env }),
      /exists/,
    );
  } finally {
    await rm(dir, { recursive: true, force: true });
  }
});

test("option errors are rejected before builds or output creation", async () => {
  for (const args of [
    ["--policy", "optimal"],
    ["--max-decisions", "0"],
    ["--max-seconds", "NaN"],
    ["--seed", "1.5"],
    ["--knowledge", "history.json"],
    ["--trace", "trace.jsonl", "--master-data", "other.json"],
  ])
    await assert.rejects(
      exec(process.execPath, [script, ...args]),
      /invalid_input/,
    );
});
