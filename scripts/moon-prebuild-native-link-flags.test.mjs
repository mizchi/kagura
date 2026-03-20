import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { execFileSync } from "node:child_process";
import test from "node:test";

const scriptPath = new URL("./moon-prebuild-native-link-flags.cjs", import.meta.url);

function runPrebuild(env, cwd) {
  const output = execFileSync("node", [scriptPath.pathname], {
    cwd,
    env: { ...process.env, ...env },
    encoding: "utf8",
  });
  return JSON.parse(output);
}

test("prebuild emits Windows-specific cc wrapper and vcpkg glfw flags", () => {
  const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "kagura-prebuild-win-"));
  const installedDir = path.join(tempDir, "installed");
  const tripletDir = path.join(installedDir, "x64-windows-static");
  fs.mkdirSync(path.join(tripletDir, "include", "GLFW"), { recursive: true });
  fs.mkdirSync(path.join(tripletDir, "lib"), { recursive: true });
  fs.writeFileSync(path.join(tripletDir, "include", "GLFW", "glfw3.h"), "");
  fs.writeFileSync(path.join(tripletDir, "lib", "glfw3.lib"), "");

  const payload = runPrebuild(
    {
      KAGURA_FORCE_OS: "win32",
      KAGURA_VCPKG_INSTALLED_DIR: installedDir,
    },
    tempDir,
  );

  assert.match(payload.vars.KAGURA_NATIVE_CC, /moon-native-cc\.cmd$/);
  assert.match(payload.vars.KAGURA_NATIVE_GLFW_CFLAGS, /include$/);
  assert.match(payload.vars.KAGURA_NATIVE_GLFW_LIBS, /-lglfw3/);
  assert.match(payload.vars.KAGURA_NATIVE_GLFW_LIBS, /x64-windows-static/);
  assert.match(payload.vars.KAGURA_NATIVE_PLATFORM_LIBS, /-lgdi32/);
});

test("prebuild emits Unix wrapper on non-Windows", () => {
  const payload = runPrebuild(
    {
      KAGURA_FORCE_OS: "linux",
    },
    process.cwd(),
  );

  assert.match(payload.vars.KAGURA_NATIVE_CC, /moon-native-cc\.sh$/);
});
