import assert from "node:assert/strict";
import test from "node:test";

import {
  buildCompilerArgs,
  isMoonRuntimeSource,
  normalizeWindowsArg,
} from "./moon-native-cc-win.cjs";

test("normalizeWindowsArg strips single quotes and expands env vars", () => {
  const env = {
    MOON_HOME: "C:/moon",
    SOME_DIR: "C:/deps",
  };

  assert.equal(normalizeWindowsArg("'$MOON_HOME/lib/libmoonbitrun.o'", env), "C:/moon/lib/libmoonbitrun.o");
  assert.equal(normalizeWindowsArg("'-I$MOON_HOME/include'", env), "-IC:/moon/include");
  assert.equal(normalizeWindowsArg("'${SOME_DIR}/wgpu'", env), "C:/deps/wgpu");
});

test("buildCompilerArgs removes Unix-only flags after normalization", () => {
  const env = {
    MOON_HOME: "C:/moon",
  };

  assert.deepEqual(
    buildCompilerArgs(
      [
        "'-I$MOON_HOME/include'",
        "'$MOON_HOME/lib/libmoonbitrun.o'",
        "-lm",
        "'-Wl,-rpath,../../deps/wgpu-native/lib'",
        "-L../../deps/wgpu-native/lib",
        "-lwgpu_native",
      ],
      env,
    ),
    [
      "-IC:/moon/include",
      "C:/moon/lib/libmoonbitrun.o",
      "-L../../deps/wgpu-native/lib",
      "-lwgpu_native",
    ],
  );
});

test("buildCompilerArgs demotes the implicit-declaration error for moon's own runtime", () => {
  // clang 16+ turned an implicit function declaration into an error, and moon's
  // runtime calls putchar without including <stdio.h>, so `moon test --target
  // native` stops compiling on a current Windows runner.
  const args = buildCompilerArgs(["-c", "C:\\Users\\runner\\.moon\\lib\\runtime\\env.c"]);
  assert.ok(args.includes("-Wno-error=implicit-function-declaration"));

  const posix = buildCompilerArgs(["-c", "/home/runner/.moon/lib/runtime/env.c"]);
  assert.ok(posix.includes("-Wno-error=implicit-function-declaration"));
});

test("buildCompilerArgs keeps our own C strict", () => {
  // Scoped to the toolchain's files: a missing declaration we introduce must
  // still fail the build rather than being silently downgraded.
  const args = buildCompilerArgs([
    "-c",
    "modules/kagura_engine/gfx_wgpu_native/wgpu_native_stub.c",
  ]);
  assert.ok(!args.includes("-Wno-error=implicit-function-declaration"));
});

test("isMoonRuntimeSource only matches the toolchain runtime path", () => {
  assert.ok(isMoonRuntimeSource("C:\\x\\.moon\\lib\\runtime\\sync_io.c"));
  assert.ok(!isMoonRuntimeSource("vendor/.moonlib/runtime/env.c"));
  assert.ok(!isMoonRuntimeSource("src/runtime/env.c"));
});
