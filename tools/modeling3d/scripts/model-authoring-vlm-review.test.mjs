import test from "node:test";
import assert from "node:assert/strict";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";
import { spawnSync } from "node:child_process";
import { tmpdir } from "node:os";

test("model-authoring-vlm-review emits a dry-run request JSON", () => {
  const tempDir = mkdtempSync(join(tmpdir(), "kagura-vlm-review-"));
  try {
    const screenshotPath = join(tempDir, "capture.png");
    const bundlePath = join(tempDir, "bundle.json");
    const promptPath = join(tempDir, "review.md");
    const requestOutPath = join(tempDir, "request.json");

    writeFileSync(screenshotPath, Buffer.from([0x89, 0x50, 0x4e, 0x47]));
    writeFileSync(
      bundlePath,
      JSON.stringify({
        target_file: "tools/modeling3d/examples/model_authoring/src/model_doc.mbt",
        current_document: { name: "vlm_clay_totem" },
        roundtrip_report: { missing_source_ids: [] },
        patch_payload: { manual_issue_details: [] },
      }),
    );
    writeFileSync(promptPath, "# Prompt\nReview the current model.");

    const result = spawnSync(
      process.execPath,
      [
        resolve("tools/modeling3d/scripts/model-authoring-vlm-review.mjs"),
        "--screenshot",
        screenshotPath,
        "--bundle",
        bundlePath,
        "--prompt",
        promptPath,
        "--request-out",
        requestOutPath,
      ],
      {
        cwd: resolve("."),
        encoding: "utf8",
      },
    );

    assert.equal(result.status, 0, result.stderr);
    const stdoutJson = JSON.parse(result.stdout);
    assert.equal(stdoutJson.mode, "dry-run");
    assert.equal(stdoutJson.request.model, "gpt-5");
    assert.equal(stdoutJson.request.input[0].content[1].type, "input_image");
    assert.equal(stdoutJson.request.input[0].content[2].type, "input_file");
    assert.equal(stdoutJson.request.input[0].content[3].type, "input_file");

    const requestOutJson = JSON.parse(readFileSync(requestOutPath, "utf8"));
    assert.equal(requestOutJson.text.format.name, "kagura_vlm_review");
    assert.equal(requestOutJson.store, false);
  } finally {
    rmSync(tempDir, { recursive: true, force: true });
  }
});

test("model-authoring-vlm-review supports OpenRouter dry-run output", () => {
  const tempDir = mkdtempSync(join(tmpdir(), "kagura-vlm-review-openrouter-"));
  try {
    const screenshotPath = join(tempDir, "capture.png");
    const bundlePath = join(tempDir, "bundle.json");
    const promptPath = join(tempDir, "review.md");

    writeFileSync(screenshotPath, Buffer.from([0x89, 0x50, 0x4e, 0x47]));
    writeFileSync(
      bundlePath,
      JSON.stringify({
        target_file: "tools/modeling3d/examples/model_authoring/src/model_doc.mbt",
        current_document: { name: "vlm_clay_totem" },
        roundtrip_report: { missing_source_ids: [] },
        patch_payload: { manual_issue_details: [] },
      }),
    );
    writeFileSync(promptPath, "# Prompt\nReview the current model.");

    const result = spawnSync(
      process.execPath,
      [
        resolve("tools/modeling3d/scripts/model-authoring-vlm-review.mjs"),
        "--provider",
        "openrouter",
        "--screenshot",
        screenshotPath,
        "--bundle",
        bundlePath,
        "--prompt",
        promptPath,
      ],
      {
        cwd: resolve("."),
        encoding: "utf8",
      },
    );

    assert.equal(result.status, 0, result.stderr);
    const stdoutJson = JSON.parse(result.stdout);
    assert.equal(stdoutJson.mode, "dry-run");
    assert.equal(stdoutJson.provider, "openrouter");
    assert.equal(stdoutJson.preset, "preview");
    assert.equal(stdoutJson.api_url, "https://openrouter.ai/api/v1/chat/completions");
    assert.equal(stdoutJson.api_key_env, "OPENROUTER_API_KEY");
    assert.equal(stdoutJson.request.model, "google/gemini-3.1-flash-lite-preview");
    assert.deepEqual(stdoutJson.model_candidates, [
      "google/gemini-3.1-flash-lite-preview",
      "mistralai/mistral-small-3.1-24b-instruct:free",
      "google/gemma-3-27b-it:free",
      "google/gemma-3-4b-it:free",
    ]);
    assert.equal(stdoutJson.request.messages[0].content[1].type, "image_url");
    assert.equal(stdoutJson.request.response_format.type, "json_schema");
  } finally {
    rmSync(tempDir, { recursive: true, force: true });
  }
});

test("model-authoring-vlm-review resolves OpenRouter preset aliases", () => {
  const tempDir = mkdtempSync(join(tmpdir(), "kagura-vlm-review-preset-"));
  try {
    const screenshotPath = join(tempDir, "capture.png");
    const bundlePath = join(tempDir, "bundle.json");
    const promptPath = join(tempDir, "review.md");

    writeFileSync(screenshotPath, Buffer.from([0x89, 0x50, 0x4e, 0x47]));
    writeFileSync(bundlePath, '{"target_file":"tools/modeling3d/examples/model_authoring/src/model_doc.mbt"}');
    writeFileSync(promptPath, "# Prompt\nReview the current model.");

    const result = spawnSync(
      process.execPath,
      [
        resolve("tools/modeling3d/scripts/model-authoring-vlm-review.mjs"),
        "--provider",
        "openrouter",
        "--preset",
        "fast",
        "--screenshot",
        screenshotPath,
        "--bundle",
        bundlePath,
        "--prompt",
        promptPath,
      ],
      {
        cwd: resolve("."),
        encoding: "utf8",
      },
    );

    assert.equal(result.status, 0, result.stderr);
    const stdoutJson = JSON.parse(result.stdout);
    assert.equal(stdoutJson.provider, "openrouter");
    assert.equal(stdoutJson.preset, "fast");
    assert.equal(stdoutJson.model, "google/gemini-2.5-flash-lite");
    assert.deepEqual(stdoutJson.model_candidates, ["google/gemini-2.5-flash-lite"]);
    assert.equal(stdoutJson.request.model, "google/gemini-2.5-flash-lite");
  } finally {
    rmSync(tempDir, { recursive: true, force: true });
  }
});

test("model-authoring-vlm-review resolves OpenRouter preview preset", () => {
  const tempDir = mkdtempSync(join(tmpdir(), "kagura-vlm-review-preview-"));
  try {
    const screenshotPath = join(tempDir, "capture.png");
    const bundlePath = join(tempDir, "bundle.json");
    const promptPath = join(tempDir, "review.md");

    writeFileSync(screenshotPath, Buffer.from([0x89, 0x50, 0x4e, 0x47]));
    writeFileSync(bundlePath, '{"target_file":"tools/modeling3d/examples/model_authoring/src/model_doc.mbt"}');
    writeFileSync(promptPath, "# Prompt\nReview the current model.");

    const result = spawnSync(
      process.execPath,
      [
        resolve("tools/modeling3d/scripts/model-authoring-vlm-review.mjs"),
        "--provider",
        "openrouter",
        "--preset",
        "preview",
        "--screenshot",
        screenshotPath,
        "--bundle",
        bundlePath,
        "--prompt",
        promptPath,
      ],
      {
        cwd: resolve("."),
        encoding: "utf8",
      },
    );

    assert.equal(result.status, 0, result.stderr);
    const stdoutJson = JSON.parse(result.stdout);
    assert.equal(stdoutJson.provider, "openrouter");
    assert.equal(stdoutJson.preset, "preview");
    assert.equal(stdoutJson.model, "google/gemini-3.1-flash-lite-preview");
    assert.deepEqual(stdoutJson.model_candidates, [
      "google/gemini-3.1-flash-lite-preview",
      "mistralai/mistral-small-3.1-24b-instruct:free",
      "google/gemma-3-27b-it:free",
      "google/gemma-3-4b-it:free",
    ]);
  } finally {
    rmSync(tempDir, { recursive: true, force: true });
  }
});

test("model-authoring-vlm-review resolves OpenRouter free preset", () => {
  const tempDir = mkdtempSync(join(tmpdir(), "kagura-vlm-review-free-"));
  try {
    const screenshotPath = join(tempDir, "capture.png");
    const bundlePath = join(tempDir, "bundle.json");
    const promptPath = join(tempDir, "review.md");

    writeFileSync(screenshotPath, Buffer.from([0x89, 0x50, 0x4e, 0x47]));
    writeFileSync(bundlePath, '{"target_file":"tools/modeling3d/examples/model_authoring/src/model_doc.mbt"}');
    writeFileSync(promptPath, "# Prompt\nReview the current model.");

    const result = spawnSync(
      process.execPath,
      [
        resolve("tools/modeling3d/scripts/model-authoring-vlm-review.mjs"),
        "--provider",
        "openrouter",
        "--preset",
        "free",
        "--screenshot",
        screenshotPath,
        "--bundle",
        bundlePath,
        "--prompt",
        promptPath,
      ],
      {
        cwd: resolve("."),
        encoding: "utf8",
      },
    );

    assert.equal(result.status, 0, result.stderr);
    const stdoutJson = JSON.parse(result.stdout);
    assert.equal(stdoutJson.provider, "openrouter");
    assert.equal(stdoutJson.preset, "free");
    assert.equal(stdoutJson.model, "mistralai/mistral-small-3.1-24b-instruct:free");
    assert.deepEqual(stdoutJson.model_candidates, [
      "mistralai/mistral-small-3.1-24b-instruct:free",
      "google/gemma-3-27b-it:free",
      "google/gemma-3-4b-it:free",
    ]);
  } finally {
    rmSync(tempDir, { recursive: true, force: true });
  }
});
