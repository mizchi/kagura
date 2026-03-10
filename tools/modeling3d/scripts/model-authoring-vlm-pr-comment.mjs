#!/usr/bin/env node

import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, extname, join, resolve } from "node:path";
import { spawnSync } from "node:child_process";

import {
  buildGhPrCommentArgs,
  resolveCurrentGhPrNumber,
  resolvePrCommentMarkdown,
} from "./model-authoring-vlm-pr-comment-utils.mjs";

function usage() {
  console.error(
    [
      "Usage: node tools/modeling3d/scripts/model-authoring-vlm-pr-comment.mjs \\",
      "  --parsed <review.json> \\",
      "  [--markdown-out comment.md] [--gh-pr 123] [--repo mizchi/kagura] [--post]",
    ].join("\n"),
  );
}

function parseArgs(argv) {
  const options = {
    markdownOut: null,
    ghPr: null,
    repo: null,
    post: false,
  };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    switch (arg) {
      case "--parsed":
        options.parsed = argv[i + 1];
        i += 1;
        break;
      case "--markdown-out":
        options.markdownOut = argv[i + 1];
        i += 1;
        break;
      case "--gh-pr":
        options.ghPr = argv[i + 1];
        i += 1;
        break;
      case "--repo":
        options.repo = argv[i + 1];
        i += 1;
        break;
      case "--post":
        options.post = true;
        break;
      default:
        throw new Error(`unknown argument: ${arg}`);
    }
  }
  if (!options.parsed) {
    throw new Error("--parsed is required");
  }
  return options;
}

function resolveRequiredFile(pathArg, label) {
  const path = resolve(process.cwd(), pathArg);
  if (!existsSync(path)) {
    throw new Error(`${label} not found: ${path}`);
  }
  return path;
}

function defaultMarkdownPath(parsedPath) {
  const suffix = extname(parsedPath);
  const stem =
    suffix.length > 0 ? parsedPath.slice(0, parsedPath.length - suffix.length) : parsedPath;
  return `${stem}-pr-comment.md`;
}

function ensureParentDir(path) {
  mkdirSync(dirname(path), { recursive: true });
}

async function main() {
  const args = process.argv.slice(2);
  let options;
  try {
    options = parseArgs(args);
  } catch (error) {
    usage();
    throw error;
  }

  const parsedPath = resolveRequiredFile(options.parsed, "Parsed review");
  const markdownPath = resolve(
    process.cwd(),
    options.markdownOut ?? defaultMarkdownPath(parsedPath),
  );
  const parsedReview = JSON.parse(readFileSync(parsedPath, "utf8"));
  const prComment = resolvePrCommentMarkdown(parsedReview);
  ensureParentDir(markdownPath);
  writeFileSync(markdownPath, `${prComment}\n`);

  const resolvedGhPr =
    options.ghPr == null
      ? options.post
        ? await resolveCurrentGhPrNumber({ repo: options.repo })
        : null
      : options.ghPr === "current"
        ? await resolveCurrentGhPrNumber({ repo: options.repo })
        : String(options.ghPr);

  const ghArgs =
    resolvedGhPr == null
      ? null
      : buildGhPrCommentArgs({
          prNumber: resolvedGhPr,
          markdownPath,
          repo: options.repo,
        });

  if (options.post) {
    const result = spawnSync("gh", ghArgs, {
      cwd: process.cwd(),
      encoding: "utf8",
    });
    if (result.status !== 0) {
      throw new Error(result.stderr || result.stdout || "gh pr comment failed");
    }
    console.log(
      JSON.stringify(
        {
          mode: "post",
          parsed: parsedPath,
          markdown_out: markdownPath,
          gh_pr: resolvedGhPr,
          repo: options.repo,
          gh_args: ghArgs,
          pr_comment: prComment,
          stdout: result.stdout.trim(),
        },
        null,
        2,
      ),
    );
    return;
  }

  console.log(
    JSON.stringify(
      {
        mode: "dry-run",
        parsed: parsedPath,
        markdown_out: markdownPath,
        gh_pr: resolvedGhPr,
        repo: options.repo,
        gh_args: ghArgs,
        pr_comment: prComment,
      },
      null,
      2,
    ),
  );
}

try {
  await main();
} catch (error) {
  console.error(String(error.message ?? error));
  process.exit(1);
}
