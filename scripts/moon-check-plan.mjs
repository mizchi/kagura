import { existsSync, readdirSync } from "node:fs";
import { resolve, join, relative } from "node:path";
import { spawnSync } from "node:child_process";
import { EXTRA_CHECK_MODULES } from "./moon-check-catalog.mjs";
import { discoverProjects } from "./example-projects.mjs";
import {
  selectExampleProjects,
  parseShard,
} from "./example-projects-utils.mjs";
import { readMoonWorkMembers, defaultRepoRoot } from "./moon-release-utils.mjs";
import { prepareMoonDeps } from "./prepare-moon-deps.mjs";

export function sourceModules(root = defaultRepoRoot()) {
  const found = [];
  const ignored = new Set([
    "_build",
    "_site",
    "target",
    "node_modules",
    "dist",
    "output",
    "fixtures",
  ]);
  function walk(directory) {
    if (!existsSync(directory)) return;
    if (
      ["moon.mod", "moon.mod.json"].some((name) =>
        existsSync(join(directory, name)),
      )
    )
      found.push(relative(root, directory).replaceAll("\\", "/") || ".");
    for (const entry of readdirSync(directory, { withFileTypes: true }))
      if (
        entry.isDirectory() &&
        !entry.name.startsWith(".") &&
        !ignored.has(entry.name)
      )
        walk(join(directory, entry.name));
  }
  if (
    ["moon.mod", "moon.mod.json"].some((name) => existsSync(join(root, name)))
  )
    found.push(".");
  for (const dir of [
    "core",
    "cmd",
    "engine",
    "game",
    "platform",
    "platform_web",
    "platform_native",
    "editor",
    "examples",
    "experiments",
    "benchmarks",
    "assets/vendor",
  ])
    walk(join(root, dir));
  return found.sort();
}

export function createCheckPlan(
  group,
  { repoRoot = defaultRepoRoot(), target = "js", shard = "1/1" } = {},
) {
  if (group === "workspace")
    return [
      { dir: ".", targets: [target], members: readMoonWorkMembers(repoRoot) },
    ];
  if (group === "standalone" || group === "external")
    return EXTRA_CHECK_MODULES.filter((entry) => entry.group === group);
  if (group === "examples") {
    const { selected } = selectExampleProjects(discoverProjects(repoRoot), {
      target,
      mode: "check",
      ...parseShard(shard),
    });
    return selected.map((dir) => ({ dir, targets: [target] }));
  }
  if (group === "all") {
    const merged = new Map();
    const plans = [
      ...["js", "native"].flatMap((target) =>
        ["workspace", "examples"].flatMap((name) =>
          createCheckPlan(name, { repoRoot, target, shard }),
        ),
      ),
      ...createCheckPlan("standalone"),
      ...createCheckPlan("external"),
    ];
    for (const entry of plans) {
      const previous = merged.get(entry.dir);
      merged.set(entry.dir, {
        ...entry,
        targets: [...new Set([...(previous?.targets ?? []), ...entry.targets])],
      });
    }
    return [...merged.values()];
  }
  throw new Error(`Unknown check group: ${group}`);
}

export function uncoveredModules(root, plan) {
  const covered = new Set(
    plan.flatMap((entry) => [entry.dir, ...(entry.members ?? [])]),
  );
  return sourceModules(root).filter((dir) => !covered.has(dir));
}

export function runCheckPlan(
  plan,
  {
    repoRoot = defaultRepoRoot(),
    prepare = (dir, target) =>
      prepareMoonDeps(resolve(repoRoot, dir), { target }),
    run = spawnSync,
  } = {},
) {
  const prepared = new Set();
  for (const entry of plan) {
    if (!prepared.has(entry.dir)) {
      prepare(entry.dir, entry.targets[0]);
      prepared.add(entry.dir);
    }
    for (const target of entry.targets) {
      const args = [
        "-C",
        entry.dir,
        "check",
        ".",
        "--target",
        target,
        "--deny-warn",
        ...(entry.externalCheckout ? ["--no-mbti"] : []),
      ];
      const result = run("moon", args, { cwd: repoRoot, stdio: "inherit" });
      if (result.error) throw result.error;
      if (result.status !== 0)
        throw new Error(
          `${entry.dir}: ${target} check failed (${result.status})`,
        );
    }
  }
}
