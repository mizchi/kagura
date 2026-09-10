// Which example/editor-example projects `just check-examples` and
// `just test-examples` run, for a given target, and how that list splits across
// CI shards.
//
// This used to be shell embedded in two long justfile lines. It moved here for
// two reasons: the skip rules are the kind of thing that silently stops covering
// something (a project that skips everywhere is a project nobody builds), and
// sharding needs the list to be the same on every runner. `scripts/*.test.mjs`
// runs in CI, so the rules are now pinned by tests.
//
// Kept side-effect-free -- the filesystem scan lives in `example-projects.mjs`
// so these rules can be tested without a repo layout.

// `examples/<category>/<name>` nests one level deeper than the editor tools'
// flat `editor/<tool>/examples/<name>`, so each root carries its own depth.
export const EXAMPLE_PROJECT_ROOTS = [
  { path: "examples", depth: 2 },
  { path: "editor/modeling3d/examples", depth: 1 },
  { path: "editor/effect-studio/examples", depth: 1 },
];

// These two build against a `mizchi/crater` checkout that is not in this repo,
// so they cannot be built in CI at all.
const CRATER_DEPENDENTS = new Set([
  "examples/experimental/crater_paint",
  "examples/smoke/browser_headless",
]);

// Checks fine on native, but its test binary is not expected to link there.
const NATIVE_CHECK_ONLY = new Set([
  "editor/effect-studio/examples/effect_studio",
]);

const NATIVE_ONLY_MARKER = 'supported_targets = "native"';
const WGPU_NATIVE_MARKER = "wgpu_native";

/**
 * Decide whether one project runs, and say why when it does not.
 *
 * `project.srcPkg` is the text of the project's `src/moon.pkg`, or null when it
 * has none. `mode` is "check" or "test": the native skips below apply only to
 * `test`, because checking never links.
 */
export function classifyExampleProject(project, { target, mode }) {
  const { dir, srcPkg = null } = project;
  if (mode !== "check" && mode !== "test") {
    throw new RangeError(`mode must be "check" or "test", got ${mode}`);
  }
  const skip = (reason) => ({ dir, run: false, reason });
  if (CRATER_DEPENDENTS.has(dir)) {
    return skip("depends on out-of-repo mizchi/crater checkout");
  }
  if (target !== "native" && srcPkg?.includes(NATIVE_ONLY_MARKER)) {
    return skip("supports native only");
  }
  if (mode === "test" && target === "native") {
    if (srcPkg?.includes(WGPU_NATIVE_MARKER)) {
      return skip("requires wgpu-native at link time");
    }
    if (NATIVE_CHECK_ONLY.has(dir)) {
      return skip("native test limited to check-only");
    }
  }
  return { dir, run: true, reason: null };
}

/** "2/5" -> { shard: 2, shardTotal: 5 }. 1-based, so "1/1" means run everything. */
export function parseShard(spec) {
  const match = /^([0-9]+)\/([0-9]+)$/.exec(String(spec));
  if (!match) {
    throw new RangeError(`shard must look like "2/5", got ${spec}`);
  }
  const shard = Number(match[1]);
  const shardTotal = Number(match[2]);
  if (shardTotal < 1) throw new RangeError("shard total must be at least 1");
  if (shard < 1 || shard > shardTotal) {
    throw new RangeError(`shard ${shard} is outside 1..${shardTotal}`);
  }
  return { shard, shardTotal };
}

/**
 * Split the list round-robin rather than in contiguous blocks.
 *
 * Contiguous blocks would put all of `examples/games/*` on one runner, and the
 * games are the expensive ones -- neighbours in this list have similar cost
 * because they sort by category. Interleaving spreads that without needing a
 * per-project cost table to keep up to date.
 */
export function shardExampleProjects(dirs, { shard, shardTotal }) {
  if (!Number.isSafeInteger(shardTotal) || shardTotal < 1) {
    throw new RangeError("shard total must be a positive integer");
  }
  if (!Number.isSafeInteger(shard) || shard < 1 || shard > shardTotal) {
    throw new RangeError(`shard ${shard} is outside 1..${shardTotal}`);
  }
  return dirs.filter((_dir, index) => index % shardTotal === shard - 1);
}

/**
 * Classify every project, then keep this shard's share of the ones that run.
 *
 * Sharding is applied *after* the skips so the runnable projects divide evenly.
 * Sharding first would hand one runner a shard that is mostly skips -- on native
 * that matters, because only a fraction of the projects link there.
 */
export function selectExampleProjects(projects, { target, mode, shard, shardTotal }) {
  const classified = projects.map((project) =>
    classifyExampleProject(project, { target, mode })
  );
  const skipped = classified.filter((entry) => !entry.run);
  const runnable = classified.filter((entry) => entry.run).map((entry) => entry.dir);
  return {
    skipped,
    selected: shardExampleProjects(runnable, { shard, shardTotal }),
    runnableCount: runnable.length,
  };
}
