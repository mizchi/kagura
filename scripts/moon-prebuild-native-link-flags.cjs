#!/usr/bin/env node

const { execFileSync } = require("node:child_process");
const os = process.platform;

let platformLibs = "";
let audioLibs = "";

function tryExec(cmd, args) {
  try {
    return execFileSync(cmd, args, {
      encoding: "utf8",
      stdio: ["ignore", "pipe", "ignore"],
    }).trim();
  } catch {
    return "";
  }
}

function resolveGlfwCflags() {
  const cflags = tryExec("pkg-config", ["--cflags", "glfw3"]);
  if (cflags) {
    return cflags;
  }
  if (os === "darwin") {
    const prefix = tryExec("brew", ["--prefix", "glfw"]);
    if (prefix) {
      return `-I${prefix}/include`;
    }
  }
  return "";
}

function resolveGlfwLibs() {
  const libs = tryExec("pkg-config", ["--libs", "glfw3"]);
  if (libs) {
    return libs;
  }
  if (os === "darwin") {
    const prefix = tryExec("brew", ["--prefix", "glfw"]);
    if (prefix) {
      return `-L${prefix}/lib -lglfw`;
    }
  }
  return "-lglfw";
}

const glfwCflags = resolveGlfwCflags();
const glfwLibs = resolveGlfwLibs();

if (os === "darwin") {
  platformLibs = "-framework Metal -framework QuartzCore -framework IOKit -framework CoreFoundation -framework Cocoa -framework Foundation";
  audioLibs = `${platformLibs} -framework AudioToolbox -framework CoreAudio`;
} else if (os === "linux") {
  platformLibs = "-ldl -lpthread -lm -lX11 -lXrandr -lXi -lXcursor -lXinerama -lXxf86vm";
  audioLibs = `${platformLibs} -lasound`;
} else if (os === "win32") {
  platformLibs = "-lgdi32 -luser32 -lkernel32 -lshell32 -lole32 -luuid";
  audioLibs = `${platformLibs} -lwinmm`;
}

const payload = {
  vars: {
    KAGURA_NATIVE_GLFW_CFLAGS: glfwCflags,
    KAGURA_NATIVE_GLFW_LIBS: glfwLibs,
    KAGURA_NATIVE_PLATFORM_LIBS: platformLibs,
    KAGURA_NATIVE_AUDIO_LIBS: audioLibs,
  },
};

process.stdout.write(`${JSON.stringify(payload)}\n`);
