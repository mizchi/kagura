import { existsSync, readdirSync, statSync } from "node:fs";
import { join } from "node:path";

// `moon build` nests its output under build/<module-owner>/<pkg>/<pkg>.<ext>
// (e.g. build/mizchi/flappy_bird/flappy_bird.js) instead of the flat
// build/<pkg>.<ext> layout whenever the example directory resolves in
// workspace mode -- which is every example here, while sibling modules like
// kagura_platform/kagura_audio aren't published yet.
//
// The pages we generate (dev server, VRT fixtures) address the flat path, so
// both fall back to a search under the same build/ dir when it is missing.
// Shared rather than duplicated because the two servers must agree on which
// file a request resolves to.

const BUILD_DIR_PATTERN = /^(.*[/\\]_build[/\\][^/\\]+[/\\][^/\\]+[/\\]build)[/\\](.+)$/;

/** Depth-first search for `basename` anywhere under `dir`. */
export const findNestedBuildArtifact = (dir, basename) => {
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const entryPath = join(dir, entry.name);
    if (entry.isDirectory()) {
      const found = findNestedBuildArtifact(entryPath, basename);
      if (found) return found;
    } else if (entry.isFile() && entry.name === basename) {
      return entryPath;
    }
  }
  return null;
};

/**
 * Map a flat `_build/<target>/<mode>/build/<name>.<ext>` path onto the nested
 * layout. Returns null when the path isn't under a build dir, when that dir
 * doesn't exist, or when nothing inside it matches.
 */
export const resolveBuildArtifactFallback = (filePath) => {
  const match = filePath.match(BUILD_DIR_PATTERN);
  if (!match) return null;
  const [, buildDir, tail] = match;
  // Already nested (or otherwise not a bare filename): nothing to search for.
  if (/[/\\]/.test(tail)) return null;
  if (!existsSync(buildDir)) return null;
  return findNestedBuildArtifact(buildDir, tail);
};

/** The flat path if it exists, else the nested one, else null. */
export const resolveBuildArtifact = (filePath) => {
  if (existsSync(filePath) && statSync(filePath).isFile()) return filePath;
  return resolveBuildArtifactFallback(filePath);
};
