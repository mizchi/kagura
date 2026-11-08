#!/usr/bin/env node
// Keep Moon's archive validation enabled while migrating legacy manifests in
// its fresh dependency cache. Source archives and installed toolchains are unchanged.
import { spawnSync } from "node:child_process";
import { existsSync, mkdtempSync, writeFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve, delimiter } from "node:path";
import { pathToFileURL } from "node:url";
import { prepareMoonDeps } from "./prepare-moon-deps.mjs";

function executable(name) {
  for (const directory of (process.env.PATH ?? "").split(delimiter)) {
    const file = resolve(directory, name);
    if (existsSync(file)) return file;
  }
  throw Error(`Executable not found: ${name}`);
}

function status(result) {
  if (result.error) throw result.error;
  return result.status ?? 1;
}

// mooncake invokes checks in the selected module / extracted archive cwd.
export function runPreparedCheck(moon, args, {
  cwd = process.cwd(), env = process.env, run = spawnSync, prepare = prepareMoonDeps,
} = {}) {
  if (args[0] === "check") {
    const targetIndex = args.indexOf("--target");
    prepare(cwd, {
      target: targetIndex < 0 ? undefined : args[targetIndex + 1],
      run: (_command, options, settings) => run(moon, options, { ...settings, env }),
    });
  }
  return status(run(moon, args, { cwd, env, stdio: "inherit" }));
}

export function publishMoonModule(directory, {
  moon = executable("moon"),
  mooncake = process.env.MOONCAKE_OVERRIDE ?? join(dirname(moon), "mooncake"),
  dryRun = false, run = spawnSync,
} = {}) {
  const temporary = mkdtempSync(join(tmpdir(), "kagura-publish-adapter-"));
  const check = join(temporary, "moon-check.mjs");
  const adapter = join(temporary, "mooncake.mjs");
  const helper = pathToFileURL(import.meta.filename).href;
  try {
    writeFileSync(check, `#!/usr/bin/env node
import {runPreparedCheck} from ${JSON.stringify(helper)};
try {
  process.exitCode=runPreparedCheck(${JSON.stringify(moon)},process.argv.slice(2));
} catch(error) { console.error(error.message); process.exitCode=1; }
`, { mode: 0o755 });
    // Moon forwards its serialized CLI arguments on stdin. Preserve that stream
    // and override only the child check executable, using Moon's tool override.
    writeFileSync(adapter, `#!/usr/bin/env node
import {spawnSync} from "node:child_process";
const result=spawnSync(${JSON.stringify(mooncake)},process.argv.slice(2),{
  stdio:"inherit",env:{...process.env,MOON_OVERRIDE:${JSON.stringify(check)},MOONCAKE_OVERRIDE:${JSON.stringify(mooncake)}}});
if(result.error) console.error(result.error.message);
process.exitCode=result.status??1;
`, { mode: 0o755 });
    return status(run(moon, ["publish", ...(dryRun ? ["--dry-run"] : [])], {
      cwd: resolve(directory),
      env: { ...process.env, MOONCAKE_OVERRIDE: adapter },
      stdio: "inherit",
    }));
  } finally {
    rmSync(temporary, { recursive: true, force: true });
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  try {
    const [directory, ...flags] = process.argv.slice(2);
    if (!directory || flags.some((flag) => flag !== "--dry-run") || flags.length > 1)
      throw Error("Usage: publish-moon-module.mjs <directory> [--dry-run]");
    process.exitCode = publishMoonModule(directory, { dryRun: flags.includes("--dry-run") });
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}
