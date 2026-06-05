#!/usr/bin/env bash
#
# Publish Kagura's public library modules to mooncakes, uploading ONLY the
# modules whose content actually differs from what is already on the registry.
#
# How "changed" is detected
# --------------------------
# `moon package` produces a deterministic zip under _build/publish/ whose
# sha256 is exactly the `checksum` the registry stores for a published version
# (verified: the local zip's sha256 == the registry index checksum). So for
# each module we package it, hash it, and compare against the checksum the
# registry has for that module's *currently declared* version:
#
#   NEW       version not on the registry yet           -> published
#   UNCHANGED same version on registry, checksum matches -> skipped (no upload)
#   CHANGED   same version on registry, checksum differs -> reported, NOT published
#
# CHANGED means you edited the module but forgot to bump its version. We do not
# auto-bump: publishing as-is would 409, and silently bumping would move a
# version behind your back. Bump "version" in <module>/moon.mod.json yourself,
# then re-run.
#
# Only the reusable library modules (the root module + everything under
# modules/, i.e. the moon.work members) are released. Example games
# (examples/**) and authoring tools (tools/**) are intentionally NOT published.
#
# Usage:
#   scripts/publish.sh             # show status, then publish NEW modules
#   scripts/publish.sh --status    # show status only, upload nothing (read-only)
#   scripts/publish.sh --dry-run   # alias for --status
#   scripts/publish.sh --no-update # skip `moon update` (use the local index as-is)
#
# Publish order is topological — a module is published before anything that
# imports it. Keep MODULES in sync with moon.work if the graph changes.
set -uo pipefail

cd "$(dirname "$0")/.."

# Native FFI modules: `moon package`/`moon publish` run `moon check`, so expose
# glfw headers/libs when present.
if command -v brew >/dev/null 2>&1; then
  export CPATH="$(brew --prefix glfw)/include:${CPATH:-}"
  export LIBRARY_PATH="$(brew --prefix)/lib:${LIBRARY_PATH:-}"
fi

# Topological order (deps first). Keep in sync with moon.work members.
MODULES=(
  modules/mesh3d
  modules/geom
  modules/kagura_core
  modules/text
  modules/atlas
  modules/renderer2d
  modules/anim3d
  modules/kagura_engine
  .
  modules/js_runtime
  modules/physics
  modules/game
  modules/widget2d
  modules/pathfind
)

MODE="publish"
NO_UPDATE=""
for a in "$@"; do
  case "$a" in
    --status|--dry-run) MODE="status" ;;
    --no-update)        NO_UPDATE=1 ;;
    *) echo "unknown argument: $a" >&2; exit 2 ;;
  esac
done

REG_INDEX="${HOME}/.moon/registry/index/user"

# Read name/version from a member manifest, whether the new text `moon.mod`
# or the legacy `moon.mod.json`.
meta() { # $1=module dir  $2=field (name|version)
  if [ -f "$1/moon.mod" ]; then
    grep -E "^$2[[:space:]]*=" "$1/moon.mod" | head -1 | sed -E 's/^[A-Za-z_]+[[:space:]]*=[[:space:]]*"(.*)"[[:space:]]*$/\1/'
  else
    python3 -c "import json,sys;print(json.load(open(sys.argv[1]))[sys.argv[2]])" "$1/moon.mod.json" "$2"
  fi
}

# checksum the registry holds for name@version, or empty if that version is unknown.
reg_checksum() { # $1=name (owner/rest)  $2=version
  local owner=${1%%/*} rest=${1#*/}
  local f="${REG_INDEX}/${owner}/${rest}.index"
  [ -f "$f" ] || return 0
  python3 - "$f" "$2" <<'PY'
import json, sys
path, ver = sys.argv[1], sys.argv[2]
for line in open(path):
    line = line.strip()
    if not line:
        continue
    try:
        d = json.loads(line)
    except ValueError:
        continue
    if d.get("version") == ver:
        print(d.get("checksum", ""))
        break
PY
}

# Refresh the registry index so checksums reflect the live registry.
if [ -z "${NO_UPDATE}" ]; then
  echo ">> moon update (refresh registry index)"
  moon update >/dev/null 2>&1 || echo "   warning: moon update failed; status may be stale (try --no-update to silence)"
  echo
fi

# --- classify every module by packaging it and diffing the checksum ----------
names=()       # mizchi/foo
vers=()        # 0.2.0
states=()      # NEW | UNCHANGED | CHANGED
dirs=()        # modules/foo
pkg_failed=()

printf "%-26s %-9s %-9s %s\n" "MODULE" "VERSION" "STATE" "NOTE"
printf "%-26s %-9s %-9s %s\n" "------" "-------" "-----" "----"

for m in "${MODULES[@]}"; do
  name=$(meta "$m" name)
  ver=$(meta "$m" version)
  out=$( (cd "$m" && moon package) 2>&1 )
  zip=$(printf '%s\n' "$out" | sed -n 's/^Package to //p' | tail -1)
  if [ -z "$zip" ] || [ ! -f "$zip" ]; then
    printf "%-26s %-9s %-9s %s\n" "$name" "$ver" "ERROR" "moon package failed"
    printf '%s\n' "$out" | tail -4 | sed 's/^/    /'
    pkg_failed+=("${name}@${ver}")
    continue
  fi
  local_sha=$(shasum -a 256 "$zip" | cut -d' ' -f1)
  reg_sha=$(reg_checksum "$name" "$ver")

  if [ -z "$reg_sha" ]; then
    state="NEW";       note="not on registry -> will publish"
  elif [ "$reg_sha" = "$local_sha" ]; then
    state="UNCHANGED"; note="identical to published ${ver}"
  else
    state="CHANGED";   note="content differs from published ${ver} -> bump version"
  fi

  printf "%-26s %-9s %-9s %s\n" "$name" "$ver" "$state" "$note"
  names+=("$name"); vers+=("$ver"); states+=("$state"); dirs+=("$m")
done
echo

if [ "${#pkg_failed[@]}" -gt 0 ]; then
  echo "packaging failed: ${pkg_failed[*]}"
  exit 1
fi

# Collect CHANGED-but-not-bumped for a loud warning regardless of mode.
changed_report=()
for i in "${!names[@]}"; do
  [ "${states[$i]}" = "CHANGED" ] && changed_report+=("${names[$i]} (bump ${dirs[$i]} from ${vers[$i]})")
done

if [ "$MODE" = "status" ]; then
  if [ "${#changed_report[@]}" -gt 0 ]; then
    echo "needs version bump (content changed, version not bumped):"
    printf '  - %s\n' "${changed_report[@]}"
  fi
  echo "status only; nothing uploaded."
  exit 0
fi

# --- publish NEW modules in topological order --------------------------------
published=()
skipped=()
failed=()

for i in "${!names[@]}"; do
  name="${names[$i]}"; ver="${vers[$i]}"; state="${states[$i]}"; m="${dirs[$i]}"
  case "$state" in
    UNCHANGED|CHANGED)
      skipped+=("${name}@${ver}")
      continue
      ;;
  esac
  echo "=== publishing ${name}@${ver} (${m}) ==="
  out=$( (cd "$m" && moon publish) 2>&1 )
  status=$?
  printf '%s\n' "$out" | tail -3
  if [ "$status" -eq 0 ]; then
    published+=("${name}@${ver}")
    moon update >/dev/null 2>&1 || true
  elif printf '%s\n' "$out" | grep -q "409 Conflict"; then
    # Registry moved under us (someone else published this version); treat as skip.
    echo "  -> 409 Conflict, already on registry; skipping"
    skipped+=("${name}@${ver}")
  else
    echo "  -> FAILED"
    failed+=("${name}@${ver}")
  fi
  echo
done

echo "----------------------------------------"
[ "${#published[@]}" -gt 0 ] && echo "published: ${published[*]}"
[ "${#skipped[@]}"   -gt 0 ] && echo "skipped (unchanged or already on registry): ${skipped[*]}"
if [ "${#changed_report[@]}" -gt 0 ]; then
  echo
  echo "WARNING: these modules changed but their version was not bumped, so they were NOT published:"
  printf '  - %s\n' "${changed_report[@]}"
fi
if [ "${#failed[@]}" -gt 0 ]; then
  echo "FAILED: ${failed[*]}"
  exit 1
fi
# Surface the bump-needed case as a non-zero exit so it is not missed in CI.
[ "${#changed_report[@]}" -gt 0 ] && exit 3
echo "ok"
