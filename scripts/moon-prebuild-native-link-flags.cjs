#!/usr/bin/env node

const fs = require("node:fs");
const path = require("node:path");
const { execFileSync } = require("node:child_process");
const os = process.env.KAGURA_FORCE_OS || process.platform;
const cwd = process.env.KAGURA_FORCE_CWD || process.cwd();

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
  if (os === "win32") {
    const root = resolveVcpkgGlfwRoot();
    if (root) {
      return `-I${toForwardSlash(path.join(root, "include"))}`;
    }
  }
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

function toForwardSlash(p) {
  return p.replace(/\\/g, "/");
}

function resolveGlfwLibs() {
  if (os === "win32") {
    const root = resolveVcpkgGlfwRoot();
    if (root) {
      return `-L${toForwardSlash(path.join(root, "lib"))} -lglfw3`;
    }
    return "-lglfw3";
  }
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

function resolveVcpkgGlfwRoot() {
  const triplet =
    process.env.KAGURA_VCPKG_TRIPLET ||
    process.env.VCPKG_DEFAULT_TRIPLET ||
    "x64-windows-static";
  const installedDirCandidates = [
    process.env.KAGURA_VCPKG_INSTALLED_DIR,
    process.env.VCPKG_INSTALLED_DIR,
    process.env.VCPKG_ROOT ? path.join(process.env.VCPKG_ROOT, "installed") : "",
    "C:\\vcpkg\\installed",
  ].filter(Boolean);
  for (const installedDir of installedDirCandidates) {
    const root = path.join(installedDir, triplet);
    if (
      fs.existsSync(path.join(root, "include", "GLFW", "glfw3.h")) ||
      fs.existsSync(path.join(root, "lib", "glfw3.lib")) ||
      fs.existsSync(path.join(root, "lib", "libglfw3.a"))
    ) {
      return root;
    }
  }
  return "";
}

function resolveNativeCc() {
  const scriptDir = path.relative(cwd, __dirname) || ".";
  const wrapperName = os === "win32" ? "moon-native-cc.cmd" : "moon-native-cc.sh";
  return toForwardSlash(path.join(scriptDir, wrapperName));
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
  // GLFW static linking on Windows needs OpenGL import libs in addition to the Win32 system libs.
  platformLibs = "-lgdi32 -luser32 -lkernel32 -lshell32 -lole32 -luuid -lopengl32 -lws2_32 -luserenv -lntdll -lbcrypt -ladvapi32 -lpropsys -liphlpapi -loleaut32 -lruntimeobject";
  audioLibs = `${platformLibs} -lwinmm`;
}

// Windows linker doesn't support -Wl,-rpath
const wgpuRpath = os === "win32" ? "" : "-Wl,-rpath,../../deps/wgpu-native/lib";

const payload = {
  vars: {
    KAGURA_NATIVE_CC: resolveNativeCc(),
    KAGURA_NATIVE_GLFW_CFLAGS: glfwCflags,
    KAGURA_NATIVE_GLFW_LIBS: glfwLibs,
    KAGURA_NATIVE_PLATFORM_LIBS: platformLibs,
    KAGURA_NATIVE_AUDIO_LIBS: audioLibs,
    KAGURA_NATIVE_WGPU_RPATH: wgpuRpath,
  },
};

process.stdout.write(`${JSON.stringify(payload)}\n`);
