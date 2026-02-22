#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEPS_DIR="$ROOT_DIR/deps"
WGPU_DIR="$DEPS_DIR/wgpu-macos"

mkdir -p "$DEPS_DIR"

ARCH="$(uname -m)"
case "$ARCH" in
  arm64|aarch64)
    ZIP_NAME="wgpu-macos-aarch64-release.zip"
    ;;
  x86_64)
    ZIP_NAME="wgpu-macos-x86_64-release.zip"
    ;;
  *)
    echo "unsupported arch: $ARCH" >&2
    exit 1
    ;;
esac

URL="https://github.com/gfx-rs/wgpu-native/releases/download/v27.0.2.0/${ZIP_NAME}"
TMP_ZIP="$DEPS_DIR/${ZIP_NAME}"

if [ ! -d "$WGPU_DIR/include" ] || [ ! -d "$WGPU_DIR/lib" ]; then
  echo "download wgpu-native: $URL"
  rm -rf "$WGPU_DIR"
  curl -L "$URL" -o "$TMP_ZIP"
  unzip -o "$TMP_ZIP" -d "$WGPU_DIR"
  rm -f "$TMP_ZIP"
fi

if command -v brew >/dev/null 2>&1; then
  if ! brew list glfw >/dev/null 2>&1; then
    echo "install glfw with brew"
    brew install glfw
  fi
else
  echo "brew not found: install GLFW 3.4 manually" >&2
fi

echo "done"
echo "- wgpu-native: $WGPU_DIR"
echo "- run: (cd examples/native_triangle && moon run src --target native)"
