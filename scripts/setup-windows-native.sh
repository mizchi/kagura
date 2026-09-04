#!/usr/bin/env bash
# Setup Windows native build environment for MoonBit + wgpu-native + GLFW.
# Called from CI (GitHub Actions) after clang and vcpkg are available.
#
# This script:
# 1. Stubs macOS Objective-C (.m) files (MoonBit compiles all native-stub files)
# 2. Creates a clang wrapper next to clang that delegates its argument filtering
#    to scripts/moon-native-cc-win.cjs (the same, unit-tested filter the example
#    link step uses via KAGURA_NATIVE_CC)
# 3. Copies llvm-ar as ar.exe (MoonBit looks for ar next to MOON_CC)
# 4. Exports MOON_CC pointing to the wrapper

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== Stubbing macOS Objective-C files ==="
find "$ROOT/src" "$ROOT/vendor" -name "*.m" 2>/dev/null | while read -r f; do
  echo "/* stubbed for Windows */" > "$f"
  echo "  Stubbed: $f"
done

echo ""
echo "=== Creating clang wrapper ==="
CLANG_PATH=$(which clang)
CLANG_DIR=$(dirname "$CLANG_PATH")

# Create .cmd wrapper
WRAPPER_PATH="$CLANG_DIR/kagura-cc.cmd"
cat > "$WRAPPER_PATH" << 'CMDEOF'
@echo off
setlocal EnableExtensions
node "%~dp0kagura-cc-filter.cjs" %*
exit /b %ERRORLEVEL%
CMDEOF

# Create Node.js filter script.
#
# It delegates to scripts/moon-native-cc-win.cjs instead of re-implementing the
# filtering: that copy is unit-tested, and a second inline copy had already
# drifted out of step with it. clang is spawned directly rather than through
# MOON_CC, which points at this wrapper.
FILTER_PATH="$CLANG_DIR/kagura-cc-filter.cjs"
WIN_ROOT=$(cygpath -m "$ROOT" 2>/dev/null || echo "$ROOT")
cat > "$FILTER_PATH" << JSEOF
const { spawnSync } = require("child_process");
const { buildCompilerArgs } = require("${WIN_ROOT}/scripts/moon-native-cc-win.cjs");
const r = spawnSync("clang", buildCompilerArgs(process.argv.slice(2)), {
  stdio: "inherit",
});
process.exit(r.status ?? 1);
JSEOF

echo "  Wrapper: $WRAPPER_PATH"
echo "  Filter:  $FILTER_PATH"

# Copy llvm-ar as ar.exe (MoonBit looks for ar in MOON_CC's directory)
LLVM_AR="$CLANG_DIR/llvm-ar.exe"
AR_LINK="$CLANG_DIR/ar.exe"
if [ -f "$LLVM_AR" ] && [ ! -f "$AR_LINK" ]; then
  cp "$LLVM_AR" "$AR_LINK"
  echo "  Copied llvm-ar.exe -> ar.exe"
fi

echo ""
echo "=== Exporting MOON_CC ==="
# Convert to Windows path for GITHUB_ENV
WIN_WRAPPER=$(cygpath -w "$WRAPPER_PATH" 2>/dev/null || echo "$WRAPPER_PATH")
echo "  MOON_CC=$WIN_WRAPPER"

if [ -n "${GITHUB_ENV:-}" ]; then
  echo "MOON_CC=$WIN_WRAPPER" >> "$GITHUB_ENV"
else
  echo "  (not in CI, skipping GITHUB_ENV export)"
  echo "  Run: export MOON_CC=\"$WIN_WRAPPER\""
fi

echo ""
echo "Done."
