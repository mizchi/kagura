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

/**
 * True when this invocation is compiling a file out of the MoonBit toolchain's
 * own C runtime (`~/.moon/lib/runtime/...`) rather than our sources.
 */
function isMoonRuntimeSource(arg) {
  return /[\\/]\.moon[\\/]lib[\\/]runtime[\\/]/i.test(arg);
}

function buildCompilerArgs(args, env = process.env) {
  const normalized = args
    .map((arg) => normalizeWindowsArg(arg, env))
    .filter((arg) => arg !== "-lm")
    .filter((arg) => !arg.startsWith("-Wl,-rpath,"));

  // moon's own runtime calls `putchar` without including <stdio.h>. clang 16+
  // made an implicit function declaration an error rather than a warning, so
  // the toolchain no longer compiles on the current Windows runner image. Demote
  // it back to a warning for those files only — our own C stays strict, so a
  // missing declaration we introduce is still an error.
  if (normalized.some(isMoonRuntimeSource)) {
    normalized.push("-Wno-error=implicit-function-declaration");
  }
  return normalized;
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
  isMoonRuntimeSource,
  normalizeWindowsArg,
};

if (require.main === module) {
  main();
}
