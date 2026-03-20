import assert from "node:assert/strict";
import test from "node:test";

import { buildCompilerArgs, normalizeWindowsArg } from "./moon-native-cc-win.cjs";

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
