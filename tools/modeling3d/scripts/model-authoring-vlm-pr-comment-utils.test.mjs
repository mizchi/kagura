import test from "node:test";
import assert from "node:assert/strict";

import {
  buildGhPrCommentArgs,
  resolvePrCommentMarkdown,
} from "./model-authoring-vlm-pr-comment-utils.mjs";

test("resolvePrCommentMarkdown enriches a parsed review when markdown is missing", () => {
  const markdown = resolvePrCommentMarkdown({
    target_file: "tools/modeling3d/examples/model_authoring/src/model_doc.mbt",
    overall_summary: "summary",
    confidence: "high",
    recommended_actions: [],
    manual_followups: [],
    visual_findings: [],
  });

  assert.match(markdown, /^## Kagura VLM Review/m);
  assert.match(markdown, /Target: `tools\/modeling3d\/examples\/model_authoring\/src\/model_doc\.mbt`/);
});

test("resolvePrCommentMarkdown prefers embedded markdown when present", () => {
  assert.equal(
    resolvePrCommentMarkdown({
      pr_comment_markdown: "## Existing",
    }),
    "## Existing",
  );
});

test("buildGhPrCommentArgs builds repo-aware gh pr comment arguments", () => {
  assert.deepEqual(
    buildGhPrCommentArgs({
      prNumber: "123",
      markdownPath: "/tmp/comment.md",
      repo: "mizchi/kagura",
    }),
    ["pr", "comment", "123", "--body-file", "/tmp/comment.md", "--repo", "mizchi/kagura"],
  );
});
