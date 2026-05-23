#!/usr/bin/env node
// Profile the ECS hot loops on the JS backend.
//
// Pipeline:
//   1. Build tools/ecs_profile as JS (`moon build --release --target=js src/cmd/main`)
//   2. Run it under Node's inspector to capture a V8 cpuprofile
//   3. Convert the cpuprofile to pprof via @mizchi/pprof-tools
//   4. Print a flat top-N summary so we can scan it in the terminal
//
// Usage: node scripts/ecs-pprof.mjs [--no-build] [--top=20]
//
// The pprof-tools package isn't on npm yet, so we resolve it from a local
// checkout — pass `--pprof-tools=<path>` to override or set PPROF_TOOLS_DIR.

import { Session } from "node:inspector/promises";
import { spawnSync } from "node:child_process";
import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(__dirname, "..");
const PROFILE_DIR = resolve(REPO_ROOT, "tools/ecs_profile");
const BUILT_JS = resolve(
  PROFILE_DIR,
  "_build/js/release/build/cmd/main/main.js",
);
const OUT_DIR = resolve(REPO_ROOT, "tmp/ecs-pprof");

const args = process.argv.slice(2);
const noBuild = args.includes("--no-build");
const topArg = args.find((a) => a.startsWith("--top="));
const TOP_N = topArg ? Number(topArg.slice(6)) : 25;
const pprofToolsArg = args.find((a) => a.startsWith("--pprof-tools="));
const pprofToolsDir =
  (pprofToolsArg && pprofToolsArg.slice("--pprof-tools=".length)) ||
  process.env.PPROF_TOOLS_DIR ||
  "/tmp/pprof-mbt/packages/pprof-tools";

if (!existsSync(pprofToolsDir)) {
  console.error(
    `[ecs-pprof] pprof-tools not found at ${pprofToolsDir}. ` +
      `Clone https://github.com/mizchi/pprof-mbt and pass --pprof-tools=<dir>.`,
  );
  process.exit(2);
}

if (!noBuild) {
  console.error("[ecs-pprof] building tools/ecs_profile ...");
  const moonBin = process.env.MOON || `${process.env.HOME}/.moon/bin/moon`;
  const r = spawnSync(
    moonBin,
    ["build", "--release", "--target=js", "src/cmd/main"],
    { cwd: PROFILE_DIR, stdio: "inherit" },
  );
  if (r.status !== 0) process.exit(r.status ?? 1);
}

if (!existsSync(BUILT_JS)) {
  console.error(`[ecs-pprof] no built JS at ${BUILT_JS}`);
  process.exit(1);
}

const source = readFileSync(BUILT_JS, "utf8");

const session = new Session();
session.connect();
await session.post("Profiler.enable");
await session.post("Profiler.setSamplingInterval", { interval: 100 }); // 100µs
await session.post("Profiler.start");

const t0 = performance.now();
await import(`${BUILT_JS}?t=${Date.now()}`);
const elapsed = performance.now() - t0;

const { profile } = await session.post("Profiler.stop");
session.disconnect();

spawnSync("mkdir", ["-p", OUT_DIR]);
const cpuprofilePath = resolve(OUT_DIR, "ecs.cpuprofile");
const pprofPath = resolve(OUT_DIR, "ecs.pb.gz");
writeFileSync(cpuprofilePath, JSON.stringify(profile));

console.error(
  `[ecs-pprof] ran in ${elapsed.toFixed(1)} ms — wrote ${cpuprofilePath}`,
);

// Convert to pprof via local @mizchi/pprof-tools
const { convert } = await import(
  resolve(pprofToolsDir, "cpuprofile-to-pprof.mjs")
);
const { demangle } = await import(
  resolve(pprofToolsDir, "moonbit/demangle.mjs")
);
const { encoded, stats } = convert(profile);
writeFileSync(pprofPath, encoded);
console.error(
  `[ecs-pprof] ${stats.samples} samples, ${stats.functions} funcs → ${pprofPath}`,
);

// Flat top-N summary directly from the V8 cpuprofile so the user doesn't
// need `go tool pprof` installed. The conversion preserves the node tree —
// we just walk it ourselves to attribute self time.
const samples = profile.samples ?? [];
const timeDeltas = profile.timeDeltas ?? [];
const nodes = new Map();
for (const n of profile.nodes ?? []) nodes.set(n.id, n);
const selfTime = new Map(); // nodeId -> microseconds
for (let i = 0; i < samples.length; i++) {
  const id = samples[i];
  const dt = timeDeltas[i] ?? 0;
  selfTime.set(id, (selfTime.get(id) ?? 0) + dt);
}
let totalUs = 0;
for (const v of selfTime.values()) totalUs += v;

const flat = [];
for (const [id, us] of selfTime) {
  const n = nodes.get(id);
  if (!n) continue;
  const f = n.callFrame;
  if (!f) continue;
  const raw = f.functionName || "(anonymous)";
  let name = raw;
  try {
    name = demangle(raw) || raw;
  } catch {
    /* leave mangled */
  }
  flat.push({
    id,
    us,
    name,
    url: f.url || "",
    line: f.lineNumber,
  });
}
flat.sort((a, b) => b.us - a.us);

const isMoonbit = (e) => /\.mbt\b|kagura|ecs|World|each_/.test(e.name + e.url);

console.error("");
console.error(
  `[ecs-pprof] total sampled time: ${(totalUs / 1000).toFixed(1)} ms ` +
    `(${samples.length} samples)`,
);
console.error("");
console.error(`flat top ${TOP_N}:`);
console.error("  self%   self_ms  name");
for (const e of flat.slice(0, TOP_N)) {
  const ms = (e.us / 1000).toFixed(2).padStart(8);
  const pct = ((e.us / totalUs) * 100).toFixed(1).padStart(5);
  const tag = isMoonbit(e) ? "*" : " ";
  console.error(`  ${pct}%  ${ms}  ${tag} ${e.name}`);
}

console.error("");
console.error(
  `[ecs-pprof] view in pprof:    go tool pprof -http :8000 ${pprofPath}`,
);
console.error(`[ecs-pprof] cpuprofile (Chrome DevTools): ${cpuprofilePath}`);
