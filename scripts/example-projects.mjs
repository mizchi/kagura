#!/usr/bin/env node
// List the example/editor-example projects one CI shard should build.
//
// Prints the repo-relative directories to stdout, one per line, so a shell loop
// can consume it; skip reasons go to stderr so they stay visible in the CI log
// without polluting the list.
//
// Usage:
//   node scripts/example-projects.mjs --target js --mode check
//   node scripts/example-projects.mjs --target native --mode test --shard 2/4

import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";
import process from "node:process";

import { isExampleDir, REPO_ROOT } from "./example-dirs.mjs";
import {
  EXAMPLE_PROJECT_ROOTS,
  parseShard,
  selectExampleProjects,
} from "./example-projects-utils.mjs";

const args = process.argv.slice(2);
const flag = (name, fallback) => {
  const index = args.indexOf(`--${name}`);
  if (index === -1) return fallback;
  const value = args[index + 1];
  if (value == null || value.startsWith("--")) {
    console.error(`--${name} needs a value`);
    process.exit(2);
  }
  return value;
};

const target = flag("target", "js");
const mode = flag("mode", "check");
let shardSpec;
try {
  shardSpec = parseShard(flag("shard", "1/1"));
} catch (error) {
  console.error(String(error.message ?? error));
  process.exit(2);
}

const isDir = (path) => existsSync(path) && statSync(path).isDirectory();

// Walk the roots in a fixed order and sort each level, so every shard on every
// runner derives the same list from the same commit. An unstable order would
// silently drop or double-build projects across shards.
const discoverProjects = () => {
  const projects = [];
  for (const { path: root, depth } of EXAMPLE_PROJECT_ROOTS) {
    const absoluteRoot = join(REPO_ROOT, root);
    if (!isDir(absoluteRoot)) continue;
    const leaves = [];
    if (depth === 1) {
      for (const entry of readdirSync(absoluteRoot).sort()) {
        leaves.push(`${root}/${entry}`);
      }
    } else {
      for (const category of readdirSync(absoluteRoot).sort()) {
        const categoryDir = join(absoluteRoot, category);
        if (!isDir(categoryDir)) continue;
        for (const entry of readdirSync(categoryDir).sort()) {
          leaves.push(`${root}/${category}/${entry}`);
        }
      }
    }
    for (const dir of leaves) {
      const absolute = join(REPO_ROOT, dir);
      if (!isExampleDir(absolute)) continue;
      const rootPkg = join(absolute, "moon.pkg");
      const srcPkg = existsSync(rootPkg) ? rootPkg : join(absolute, "src", "moon.pkg");
      projects.push({
        dir,
        srcPkg: existsSync(srcPkg) ? readFileSync(srcPkg, "utf8") : null,
      });
    }
  }
  return projects;
};

const projects = discoverProjects();
if (projects.length === 0) {
  console.error("no example projects found -- is this the repository root?");
  process.exit(1);
}

const { skipped, selected, runnableCount } = selectExampleProjects(projects, {
  target,
  mode,
  ...shardSpec,
});

for (const entry of skipped) {
  console.error(`skip ${entry.dir} (${entry.reason})`);
}
console.error(
  `${mode} ${target}: shard ${shardSpec.shard}/${shardSpec.shardTotal} runs ${selected.length} of ${runnableCount} project(s)`,
);
for (const dir of selected) {
  console.log(dir);
}
