import test from "node:test";
import assert from "node:assert/strict";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";
import { spawnSync } from "node:child_process";
import { tmpdir } from "node:os";

test("model-authoring-vlm-pr-comment emits markdown from parsed review JSON", () => {
  const tempDir = mkdtempSync(join(tmpdir(), "kagura-vlm-pr-comment-"));
  try {
    const parsedPath = join(tempDir, "parsed.json");
    const markdownOutPath = join(tempDir, "comment.md");
    writeFileSync(
      parsedPath,
      JSON.stringify({
        target_file: "tools/modeling3d/examples/model_authoring/src/model_doc.mbt",
        overall_summary: "summary",
        confidence: "high",
        recommended_actions: [],
        manual_followups: [],
        visual_findings: [],
      }),
    );

    const result = spawnSync(
      process.execPath,
      [
        resolve("tools/modeling3d/scripts/model-authoring-vlm-pr-comment.mjs"),
        "--parsed",
        parsedPath,
        "--markdown-out",
        markdownOutPath,
      ],
      {
        cwd: resolve("."),
        encoding: "utf8",
      },
    );

    assert.equal(result.status, 0, result.stderr);
    const stdoutJson = JSON.parse(result.stdout);
    assert.equal(stdoutJson.mode, "dry-run");
    assert.equal(stdoutJson.markdown_out, markdownOutPath);
    assert.match(stdoutJson.pr_comment, /^## Kagura VLM Review/m);
    assert.equal(readFileSync(markdownOutPath, "utf8"), `${stdoutJson.pr_comment}\n`);
  } finally {
    rmSync(tempDir, { recursive: true, force: true });
  }
});

test("model-authoring-vlm-pr-comment previews gh arguments without posting", () => {
  const tempDir = mkdtempSync(join(tmpdir(), "kagura-vlm-pr-comment-gh-"));
  try {
    const parsedPath = join(tempDir, "parsed.json");
    writeFileSync(
      parsedPath,
      JSON.stringify({
        pr_comment_markdown: "## Existing",
      }),
    );

    const result = spawnSync(
      process.execPath,
      [
        resolve("tools/modeling3d/scripts/model-authoring-vlm-pr-comment.mjs"),
        "--parsed",
        parsedPath,
        "--gh-pr",
        "123",
        "--repo",
        "mizchi/kagura",
      ],
      {
        cwd: resolve("."),
        encoding: "utf8",
      },
    );

    assert.equal(result.status, 0, result.stderr);
    const stdoutJson = JSON.parse(result.stdout);
    assert.equal(stdoutJson.mode, "dry-run");
    assert.deepEqual(stdoutJson.gh_args, [
      "pr",
      "comment",
      "123",
      "--body-file",
      stdoutJson.markdown_out,
      "--repo",
      "mizchi/kagura",
    ]);
    assert.equal(stdoutJson.pr_comment, "## Existing");
  } finally {
    rmSync(tempDir, { recursive: true, force: true });
  }
});

test("model-authoring-vlm-pr-comment resolves current branch PR via gh", () => {
  const tempDir = mkdtempSync(join(tmpdir(), "kagura-vlm-pr-comment-current-"));
  try {
    const parsedPath = join(tempDir, "parsed.json");
    const fakeGhPath = join(tempDir, "gh");
    writeFileSync(
      parsedPath,
      JSON.stringify({
        pr_comment_markdown: "## Existing",
      }),
    );
    writeFileSync(
      fakeGhPath,
      "#!/bin/sh\nif [ \"$1\" = \"pr\" ] && [ \"$2\" = \"view\" ]; then\n  echo '{\"number\":456}'\n  exit 0\nfi\nexit 1\n",
      { mode: 0o755 },
    );

    const result = spawnSync(
      process.execPath,
      [
        resolve("tools/modeling3d/scripts/model-authoring-vlm-pr-comment.mjs"),
        "--parsed",
        parsedPath,
        "--gh-pr",
        "current",
      ],
      {
        cwd: resolve("."),
        encoding: "utf8",
        env: {
          ...process.env,
          PATH: `${tempDir}:${process.env.PATH}`,
        },
      },
    );

    assert.equal(result.status, 0, result.stderr);
    const stdoutJson = JSON.parse(result.stdout);
    assert.equal(stdoutJson.gh_pr, "456");
    assert.deepEqual(stdoutJson.gh_args, [
      "pr",
      "comment",
      "456",
      "--body-file",
      stdoutJson.markdown_out,
    ]);
  } finally {
    rmSync(tempDir, { recursive: true, force: true });
  }
});

test("model-authoring-vlm-pr-comment fails clearly when current branch has no PR", () => {
  const tempDir = mkdtempSync(join(tmpdir(), "kagura-vlm-pr-comment-no-pr-"));
  try {
    const parsedPath = join(tempDir, "parsed.json");
    const fakeGhPath = join(tempDir, "gh");
    writeFileSync(
      parsedPath,
      JSON.stringify({
        pr_comment_markdown: "## Existing",
      }),
    );
    writeFileSync(
      fakeGhPath,
      "#!/bin/sh\necho 'no pull requests found for branch' 1>&2\nexit 1\n",
      { mode: 0o755 },
    );

    const result = spawnSync(
      process.execPath,
      [
        resolve("tools/modeling3d/scripts/model-authoring-vlm-pr-comment.mjs"),
        "--parsed",
        parsedPath,
        "--gh-pr",
        "current",
      ],
      {
        cwd: resolve("."),
        encoding: "utf8",
        env: {
          ...process.env,
          PATH: `${tempDir}:${process.env.PATH}`,
        },
      },
    );

    assert.equal(result.status, 1);
    assert.match(result.stderr, /no pull requests found for branch|associated pull request/);
  } finally {
    rmSync(tempDir, { recursive: true, force: true });
  }
});
