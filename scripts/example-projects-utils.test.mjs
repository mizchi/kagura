import test from "node:test";
import assert from "node:assert/strict";

import {
  classifyExampleProject,
  parseShard,
  selectExampleProjects,
  shardExampleProjects,
} from "./example-projects-utils.mjs";

const project = (dir, srcPkg = null) => ({ dir, srcPkg });

test("classify skips the projects that need an out-of-repo crater checkout", () => {
  for (const dir of [
    "examples/experimental/crater_paint",
    "examples/smoke/browser_headless",
  ]) {
    for (const target of ["js", "native"]) {
      for (const mode of ["check", "test"]) {
        const result = classifyExampleProject(project(dir), { target, mode });
        assert.equal(result.run, false);
        assert.match(result.reason, /crater/);
      }
    }
  }
});

test("classify skips native-only projects on every other target", () => {
  const nativeOnly = project(
    "examples/smoke/runtime_smoke_native",
    'supported_targets = "native"\n',
  );
  assert.equal(
    classifyExampleProject(nativeOnly, { target: "js", mode: "check" }).run,
    false,
  );
  assert.equal(
    classifyExampleProject(nativeOnly, { target: "native", mode: "check" }).run,
    true,
  );
});

test("classify skips wgpu-native linkers only when testing native", () => {
  const wgpu = project("examples/games/arena3d", 'import { "mizchi/wgpu_native" }');
  // Checking never links, so the wgpu skip must not apply to `check` -- that is
  // what keeps 45 projects type-checked on native while only ~10 are tested.
  assert.equal(
    classifyExampleProject(wgpu, { target: "native", mode: "check" }).run,
    true,
  );
  const tested = classifyExampleProject(wgpu, { target: "native", mode: "test" });
  assert.equal(tested.run, false);
  assert.match(tested.reason, /wgpu-native at link time/);
  // On js it links fine.
  assert.equal(
    classifyExampleProject(wgpu, { target: "js", mode: "test" }).run,
    true,
  );
});

test("classify keeps effect_studio check-only on native", () => {
  const dir = "editor/effect-studio/examples/effect_studio";
  assert.equal(
    classifyExampleProject(project(dir), { target: "native", mode: "check" }).run,
    true,
  );
  assert.equal(
    classifyExampleProject(project(dir), { target: "native", mode: "test" }).run,
    false,
  );
  assert.equal(
    classifyExampleProject(project(dir), { target: "js", mode: "test" }).run,
    true,
  );
});

test("classify rejects an unknown mode", () => {
  assert.throws(
    () => classifyExampleProject(project("examples/demos-2d/x"), {
      target: "js",
      mode: "bench",
    }),
    RangeError,
  );
});

test("parseShard accepts 1-based specs and rejects the rest", () => {
  assert.deepEqual(parseShard("1/1"), { shard: 1, shardTotal: 1 });
  assert.deepEqual(parseShard("3/5"), { shard: 3, shardTotal: 5 });
  for (const bad of ["0/5", "6/5", "1/0", "2", "a/b", "", "-1/3", "1/2/3"]) {
    assert.throws(() => parseShard(bad), RangeError, `expected ${bad} to throw`);
  }
});

test("shards partition the list exactly once with no gaps or overlaps", () => {
  const dirs = Array.from({ length: 33 }, (_, i) => `p${i}`);
  for (const shardTotal of [1, 2, 3, 4, 5, 7, 40]) {
    const seen = [];
    for (let shard = 1; shard <= shardTotal; shard++) {
      seen.push(...shardExampleProjects(dirs, { shard, shardTotal }));
    }
    // Every project is built, and none is built twice -- the property that makes
    // a sharded CI job as trustworthy as the single loop it replaced.
    assert.deepEqual([...seen].sort(), [...dirs].sort(), `shardTotal=${shardTotal}`);
  }
});

test("shards stay within one project of each other in size", () => {
  const dirs = Array.from({ length: 10 }, (_, i) => `p${i}`);
  const sizes = [];
  for (let shard = 1; shard <= 4; shard++) {
    sizes.push(shardExampleProjects(dirs, { shard, shardTotal: 4 }).length);
  }
  assert.deepEqual(sizes, [3, 3, 2, 2]);
});

test("shards interleave rather than taking contiguous blocks", () => {
  const dirs = ["a", "b", "c", "d", "e", "f"];
  // Contiguous blocks would give ["a","b"]; the games all sort together, so
  // interleaving is what keeps one runner from taking every expensive project.
  assert.deepEqual(shardExampleProjects(dirs, { shard: 1, shardTotal: 3 }), ["a", "d"]);
  assert.deepEqual(shardExampleProjects(dirs, { shard: 2, shardTotal: 3 }), ["b", "e"]);
  assert.deepEqual(shardExampleProjects(dirs, { shard: 3, shardTotal: 3 }), ["c", "f"]);
});

test("select shards the runnable projects, not the skipped ones", () => {
  const projects = [
    project("examples/a/one"),
    project("examples/experimental/crater_paint"),
    project("examples/a/two"),
    project("examples/smoke/browser_headless"),
    project("examples/a/three"),
    project("examples/a/four"),
  ];
  const shards = [1, 2].map((shard) =>
    selectExampleProjects(projects, { target: "js", mode: "test", shard, shardTotal: 2 })
  );
  assert.equal(shards[0].runnableCount, 4);
  // Sharding before the skips would leave one runner with a shard of skips; both
  // shards must get real work.
  assert.deepEqual(shards[0].selected, ["examples/a/one", "examples/a/three"]);
  assert.deepEqual(shards[1].selected, ["examples/a/two", "examples/a/four"]);
  assert.equal(shards[0].skipped.length, 2);
});

test("select covers every runnable project across the shards", () => {
  const projects = Array.from({ length: 47 }, (_, i) => project(`examples/c/p${i}`));
  projects[3] = project("examples/experimental/crater_paint");
  projects[9] = project("examples/games/g", 'import { "mizchi/wgpu_native" }');
  const seen = [];
  for (let shard = 1; shard <= 5; shard++) {
    seen.push(
      ...selectExampleProjects(projects, {
        target: "native",
        mode: "test",
        shard,
        shardTotal: 5,
      }).selected,
    );
  }
  assert.equal(seen.length, 45);
  assert.equal(new Set(seen).size, 45);
  assert.equal(seen.includes("examples/experimental/crater_paint"), false);
  assert.equal(seen.includes("examples/games/g"), false);
});
