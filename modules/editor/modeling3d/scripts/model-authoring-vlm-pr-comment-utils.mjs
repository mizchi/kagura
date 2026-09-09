import { enrichStructuredReview } from "./model-authoring-vlm-review-utils.mjs";

export function resolvePrCommentMarkdown(review) {
  if (typeof review?.pr_comment_markdown === "string" && review.pr_comment_markdown.length > 0) {
    return review.pr_comment_markdown;
  }
  return enrichStructuredReview(review).pr_comment_markdown;
}

export function buildGhPrCommentArgs({
  prNumber,
  markdownPath,
  repo = null,
}) {
  const args = ["pr", "comment", String(prNumber), "--body-file", markdownPath];
  if (repo != null) {
    args.push("--repo", repo);
  }
  return args;
}

export function resolveCurrentGhPrNumber({
  cwd = process.cwd(),
  repo = null,
  runGh,
}) {
  const execGh =
    runGh ??
    ((args) =>
      import("node:child_process").then(({ spawnSync }) =>
        spawnSync("gh", args, {
          cwd,
          encoding: "utf8",
        }),
      ));
  return execGh(["pr", "view", "--json", "number", ...(repo == null ? [] : ["--repo", repo])]).then(
    (result) => {
      if (result.status !== 0) {
        throw new Error(result.stderr || result.stdout || "failed to resolve current PR");
      }
      const parsed = JSON.parse(result.stdout);
      if (parsed?.number == null) {
        throw new Error("current branch does not have an associated pull request");
      }
      return String(parsed.number);
    },
  );
}
