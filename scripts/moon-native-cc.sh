#!/usr/bin/env bash
set -euo pipefail

glfw_prefix=""

if command -v pkg-config >/dev/null 2>&1 && pkg-config --exists glfw3; then
  glfw_prefix="$(pkg-config --variable=prefix glfw3)"
elif command -v brew >/dev/null 2>&1; then
  glfw_prefix="$(brew --prefix glfw 2>/dev/null || true)"
fi

if [ -n "${glfw_prefix}" ]; then
  include_dir="${glfw_prefix}/include"
  lib_dir="${glfw_prefix}/lib"

  if [ -d "${include_dir}" ]; then
    if [ -n "${CPATH:-}" ]; then
      export CPATH="${include_dir}:${CPATH}"
    else
      export CPATH="${include_dir}"
    fi
  fi

  if [ -d "${lib_dir}" ]; then
    if [ -n "${LIBRARY_PATH:-}" ]; then
      export LIBRARY_PATH="${lib_dir}:${LIBRARY_PATH}"
    else
      export LIBRARY_PATH="${lib_dir}"
    fi
  fi
fi

compiler="${MOON_CC:-clang}"
exec "$compiler" "$@"
