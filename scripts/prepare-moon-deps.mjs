// Published dependencies may still contain JSON manifests. Current MoonBit
// requires migrating the downloaded copy before it can resolve the next edge.
import { spawnSync } from "node:child_process";
import { existsSync, readdirSync } from "node:fs";
import { resolve, dirname, join } from "node:path";
import { pathToFileURL } from "node:url";

export function prepareMoonDeps(
  directory = ".",
  { run = spawnSync, target } = {},
) {
  const cwd = resolve(directory);
  const migrated = new Set();
  function invoke(args) {
    const result = run("moon", args, {
      cwd,
      encoding: "utf8",
      maxBuffer: 16 * 1024 * 1024,
    });
    if (result.error) throw result.error;
    return { ...result, output: (result.stdout ?? "") + (result.stderr ?? "") };
  }
  for (;;) {
    const result = invoke([
      "check",
      "--dry-run",
      ...(target ? ["--target", target] : []),
    ]);
    let cache;
    for (let directory = cwd; ; directory = dirname(directory)) {
      const candidate = join(directory, ".mooncakes");
      if (existsSync(candidate)) {
        cache = candidate;
        break;
      }
      if (dirname(directory) === directory) break;
    }
    const legacy = [];
    function scan(path) {
      if (existsSync(join(path, "moon.mod.json"))) {
        legacy.push(path);
        return;
      }
      if (existsSync(join(path, "moon.mod"))) return;
      for (const entry of readdirSync(path, { withFileTypes: true }))
        if (entry.isDirectory() && !entry.name.startsWith("."))
          scan(join(path, entry.name));
    }
    if (cache) scan(cache);
    if (!legacy.length && result.status === 0) return;
    if (!legacy.length)
      throw new Error(
        result.output || `moon check --dry-run failed (${result.status})`,
      );
    for (const dependency of legacy) {
      if (migrated.has(dependency))
        throw new Error(
          `Dependency already migrated: ${dependency}\n${result.output}`,
        );
      migrated.add(dependency);
      const formatted = invoke(["-C", dependency, "fmt"]);
      if (formatted.status !== 0)
        throw new Error(
          formatted.output || `moon fmt failed (${formatted.status})`,
        );
    }
  }
}

if (
  process.argv[1] &&
  import.meta.url === pathToFileURL(resolve(process.argv[1])).href
) {
  try {
    for (const directory of process.argv.slice(2).length
      ? process.argv.slice(2)
      : ["."])
      prepareMoonDeps(directory);
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}
