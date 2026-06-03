#!/usr/bin/env bash
#
# Publish Kagura's public library modules to mooncakes, in dependency order.
#
# Only the reusable library modules (the root module + everything under
# modules/, i.e. the moon.work members) are released. Example games
# (examples/**) and authoring tools (tools/**) are intentionally NOT published.
#
# Publish order is topological — a module is published before anything that
# imports it. Update the list if modules/ gains or loses a member, or if the
# dependency graph changes (see `moon.work`).
#
# Usage:
#   scripts/publish.sh            # publish; modules already on the registry are skipped (409)
#   scripts/publish.sh --dry-run  # validate + package, but do not upload
#
# To cut a new release of a module, bump its "version" in <module>/moon.mod.json
# (and the dependants' dep specs if they pin a version) before running this.
# Versions already on the registry are skipped, so re-running is safe.
#
# NOTE on --dry-run: each module is validated against the registry as it is now.
# `moon publish` resolves a module's deps from the registry, so a module that
# depends on a not-yet-published sibling reports an unresolved-dependency error
# in dry-run until the sibling is actually published. A real run publishes in
# dependency order and runs `moon update` after each upload, so the chain
# resolves.
set -uo pipefail

cd "$(dirname "$0")/.."

# Native FFI modules: `moon publish` runs `moon check`, so expose glfw when present.
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

DRY_RUN=""
if [ "${1:-}" = "--dry-run" ]; then
  DRY_RUN="--dry-run"
fi

meta() { python3 -c "import json,sys;print(json.load(open(sys.argv[1]))[sys.argv[2]])" "$1/moon.mod.json" "$2"; }

published=()
skipped=()
pending=()
failed=()

for m in "${MODULES[@]}"; do
  name=$(meta "$m" name)
  ver=$(meta "$m" version)
  echo "=== ${name}@${ver}  (${m}) ==="
  out=$( (cd "$m" && moon publish ${DRY_RUN}) 2>&1 )
  status=$?
  echo "${out}" | tail -3
  if echo "${out}" | grep -q "409 Conflict"; then
    echo "  -> already on registry, skipping"
    skipped+=("${name}@${ver}")
  elif [ -n "${DRY_RUN}" ] && echo "${out}" | grep -qE "202 Accepted|Dry run completed successfully"; then
    echo "  -> dry-run ok"
    published+=("${name}@${ver} (dry-run)")
  elif [ -n "${DRY_RUN}" ] && echo "${out}" | grep -q "was not found in the registry"; then
    echo "  -> dry-run: pending sibling publish (resolves in a real run)"
    pending+=("${name}@${ver}")
  elif [ -z "${DRY_RUN}" ] && [ "${status}" -eq 0 ]; then
    published+=("${name}@${ver}")
    moon update >/dev/null 2>&1 || true
  else
    echo "  -> FAILED"
    failed+=("${name}@${ver}")
  fi
  echo
done

echo "----------------------------------------"
[ "${#published[@]}" -gt 0 ] && echo "published: ${published[*]}"
[ "${#skipped[@]}"   -gt 0 ] && echo "skipped (already published): ${skipped[*]}"
[ "${#pending[@]}"   -gt 0 ] && echo "pending (dry-run, needs sibling published first): ${pending[*]}"
if [ "${#failed[@]}" -gt 0 ]; then
  echo "FAILED: ${failed[*]}"
  exit 1
fi
echo "ok"
