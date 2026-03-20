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

function main() {
  const compiler = process.env.MOON_CC || "clang";
  const args = buildCompilerArgs(process.argv.slice(2));
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
