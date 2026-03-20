#!/usr/bin/env node

const { spawnSync } = require("node:child_process");

function normalizeWindowsArg(arg, env = process.env) {
  let normalized = arg;

  if (normalized.length >= 2 && normalized.startsWith("'") && normalized.endsWith("'")) {
    normalized = normalized.slice(1, -1);
  }

  normalized = normalized.replace(/\$\{([A-Z0-9_]+)\}/gi, (_, name) => env[name] || "");
  normalized = normalized.replace(/\$([A-Z0-9_]+)/gi, (_, name) => env[name] || "");

  return normalized;
}

function buildCompilerArgs(args, env = process.env) {
  return args
    .map((arg) => normalizeWindowsArg(arg, env))
    .filter((arg) => arg !== "-lm")
    .filter((arg) => !arg.startsWith("-Wl,-rpath,"));
}

function hasObjCSource(args) {
  return args.some((arg) => arg.endsWith(".m"));
}

function main() {
  const args = buildCompilerArgs(process.argv.slice(2));

  // Skip Objective-C files on Windows (macOS only)
  if (hasObjCSource(args)) {
    // Create an empty .obj file so the build doesn't fail on missing output
    const outputIdx = args.indexOf("-o");
    if (outputIdx >= 0 && outputIdx + 1 < args.length) {
      require("node:fs").writeFileSync(args[outputIdx + 1], "");
    }
    process.exit(0);
  }

  const compiler = process.env.KAGURA_CC || "clang";
  const result = spawnSync(compiler, args, {
    stdio: "inherit",
    windowsHide: false,
  });

  if (result.error) {
    console.error(result.error.message);
    process.exit(1);
  }

  process.exit(result.status ?? 1);
}

module.exports = {
  buildCompilerArgs,
  normalizeWindowsArg,
};

if (require.main === module) {
  main();
}
