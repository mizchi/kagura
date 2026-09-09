import { existsSync, readdirSync, statSync } from "node:fs";
import { join, resolve } from "node:path";

export const REPO_ROOT = resolve(import.meta.dirname, "..");

// Examples live under a category directory (`examples/<category>/<name>`), while
// the editor tools keep theirs flat (`editor/<tool>/examples/<name>`). Callers
// pass the roots they serve, in priority order -- the sets differ on purpose,
// e.g. the VRT server does not serve the modeling3d authoring examples.
export const EXAMPLE_ROOT = {
  examples: join(REPO_ROOT, "examples"),
  effectStudio: join(REPO_ROOT, "editor", "effect-studio", "examples"),
  modeling3d: join(REPO_ROOT, "editor", "modeling3d", "examples"),
};

export const isExampleDir = (dir) =>
  existsSync(join(dir, "moon.mod.json")) || existsSync(join(dir, "moon.mod"));

const isDir = (path) => existsSync(path) && statSync(path).isDirectory();

/** Absolute path of the example directory, or null when no root holds it. */
export const findExampleDir = (name, roots) => {
  for (const root of roots) {
    if (!isDir(root)) continue;
    const direct = join(root, name);
    if (isExampleDir(direct)) return direct;
    for (const sub of readdirSync(root)) {
      const nested = join(root, sub, name);
      if (isExampleDir(nested)) return nested;
    }
  }
  return null;
};

/**
 * The category directory an example sits in (`games`, `demos-3d`, ...), or null
 * when it sits directly in a root and so has no category.
 */
export const findExampleCategory = (name, roots) => {
  for (const root of roots) {
    if (!isDir(root)) continue;
    if (isExampleDir(join(root, name))) return null;
    for (const sub of readdirSync(root)) {
      if (isExampleDir(join(root, sub, name))) return sub;
    }
  }
  return null;
};

/** Every example name the given roots hold, deduplicated and sorted. */
export const listExampleNames = (roots) => {
  const names = new Set();
  for (const root of roots) {
    if (!isDir(root)) continue;
    for (const entry of readdirSync(root)) {
      const dir = join(root, entry);
      if (isExampleDir(dir)) {
        names.add(entry);
        continue;
      }
      if (!isDir(dir)) continue;
      for (const sub of readdirSync(dir)) {
        if (isExampleDir(join(dir, sub))) names.add(sub);
      }
    }
  }
  return [...names].sort();
};
