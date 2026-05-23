#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEPS_DIR="$ROOT_DIR/deps"
WGPU_DIR="$DEPS_DIR/wgpu-native"
WGPU_VERSION="${KAGURA_WGPU_VERSION:-v27.0.2.0}"

mkdir -p "$DEPS_DIR"

OS_RAW="$(uname -s)"
OS="$(printf '%s' "$OS_RAW" | tr '[:upper:]' '[:lower:]')"
ARCH_RAW="$(uname -m)"

case "$ARCH_RAW" in
  arm64|aarch64) ARCH="aarch64" ;;
  x86_64|amd64) ARCH="x86_64" ;;
  i686|x86) ARCH="i686" ;;
  *)
    echo "unsupported arch: $ARCH_RAW" >&2
    exit 1
    ;;
esac

case "$OS" in
  darwin*)
    if [ "$ARCH" = "i686" ]; then
      echo "unsupported macOS arch for wgpu-native: $ARCH_RAW" >&2
      exit 1
    fi
    ZIP_NAME="wgpu-macos-${ARCH}-release.zip"
    PLATFORM_HINT="macos"
    ;;
  linux*)
    if [ "$ARCH" = "i686" ]; then
      echo "unsupported Linux arch for wgpu-native: $ARCH_RAW" >&2
      exit 1
    fi
    ZIP_NAME="wgpu-linux-${ARCH}-release.zip"
    PLATFORM_HINT="linux"
    ;;
  mingw*|msys*|cygwin*)
    WINDOWS_TOOLCHAIN="${KAGURA_WGPU_WINDOWS_TOOLCHAIN:-}"
    if [ -z "$WINDOWS_TOOLCHAIN" ]; then
      case "${VCPKG_DEFAULT_TRIPLET:-}" in
        *mingw*)
          WINDOWS_TOOLCHAIN="gnu"
          ;;
        *windows*)
          WINDOWS_TOOLCHAIN="msvc"
          ;;
      esac
    fi
    if [ -z "$WINDOWS_TOOLCHAIN" ]; then
      case "${MSYSTEM:-}" in
        MINGW*|CLANG*)
          WINDOWS_TOOLCHAIN="gnu"
          ;;
        *)
          WINDOWS_TOOLCHAIN="msvc"
          ;;
      esac
    fi
    if [ "$ARCH" = "i686" ] && [ "$WINDOWS_TOOLCHAIN" = "gnu" ]; then
      echo "unsupported Windows GNU arch for wgpu-native: $ARCH_RAW" >&2
      exit 1
    fi
    ZIP_NAME="wgpu-windows-${ARCH}-${WINDOWS_TOOLCHAIN}-release.zip"
    PLATFORM_HINT="windows-${WINDOWS_TOOLCHAIN}"
    ;;
  *)
    echo "unsupported OS: $OS_RAW" >&2
    exit 1
    ;;
esac

URL="https://github.com/gfx-rs/wgpu-native/releases/download/${WGPU_VERSION}/${ZIP_NAME}"
TMP_ZIP="$DEPS_DIR/${ZIP_NAME}"

if [ ! -d "$WGPU_DIR/include" ] || [ ! -d "$WGPU_DIR/lib" ]; then
  echo "download wgpu-native: $URL"
  rm -rf "$WGPU_DIR"
  curl -L "$URL" -o "$TMP_ZIP"
  unzip -o "$TMP_ZIP" -d "$WGPU_DIR"
  rm -f "$TMP_ZIP"
fi

case "$OS" in
  darwin*)
    if command -v brew >/dev/null 2>&1; then
      if ! brew list glfw >/dev/null 2>&1; then
        echo "install glfw with brew"
        brew install glfw
      fi
      GLFW_PREFIX="$(brew --prefix glfw)"
      if [ -d "$GLFW_PREFIX/lib" ]; then
        for lib in "$GLFW_PREFIX"/lib/libglfw*; do
          [ -e "$lib" ] || continue
          ln -sf "$lib" "$WGPU_DIR/lib/$(basename "$lib")"
        done
      fi
    else
      echo "brew not found: install GLFW 3.4 manually" >&2
    fi
    ;;
  linux*)
    if command -v pkg-config >/dev/null 2>&1 && pkg-config --exists glfw3; then
      :
    elif command -v apt-get >/dev/null 2>&1; then
      if [ "$(id -u)" -eq 0 ]; then
        apt-get update && apt-get install -y libglfw3-dev
      elif command -v sudo >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y libglfw3-dev
      else
        echo "install GLFW manually (ex: libglfw3-dev)" >&2
      fi
    else
      echo "install GLFW manually for your distro" >&2
    fi
    ;;
  mingw*|msys*|cygwin*)
    if command -v pacman >/dev/null 2>&1; then
      case "$ARCH" in
        x86_64)
          pacman -S --noconfirm --needed mingw-w64-x86_64-glfw || true
          ;;
        aarch64)
          pacman -S --noconfirm --needed mingw-w64-clang-aarch64-glfw || true
          ;;
        *)
          echo "install GLFW manually for arch: $ARCH_RAW" >&2
          ;;
      esac
    else
      echo "pacman not found: install GLFW manually" >&2
    fi
    ;;
esac

echo "done"
echo "- platform: $PLATFORM_HINT"
echo "- wgpu-native: $WGPU_DIR"
echo "- run: (cd examples/smoke/native_triangle && moon run src --target native)"
