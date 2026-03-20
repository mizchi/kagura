#!/usr/bin/env bash
# Check test coverage for critical packages.
# Usage: bash scripts/check-coverage.sh [target]
# Exit code 1 if any critical package exceeds its uncovered-line threshold.

set -euo pipefail

TARGET="${1:-js}"

echo "Running tests with coverage (target=$TARGET)..."
moon test --target "$TARGET" --enable-coverage 2>/dev/null

echo ""
echo "=== Coverage Analysis ==="

# Collect per-package uncovered counts
COVERAGE_OUTPUT=$(moon coverage analyze 2>&1)

# Critical packages and their max-uncovered-line thresholds
# Paths reflect the 3-layer module structure: src/core/, src/engine/, src/
declare -A THRESHOLDS=(
  [src/core/]=115
  [src/engine/runtime/]=15
  [src/engine/gfx/]=60
  [src/scene/]=90
  [src/engine/asset_loader/]=30
  [src/engine/asset/]=80
  [src/engine/platform/]=30
  [src/engine/]=540
  [src/engine/ui/]=15
  [src/ecs/]=20
)

FAILED=0

for pkg_path in "${!THRESHOLDS[@]}"; do
  threshold=${THRESHOLDS[$pkg_path]}
  uncovered=$(printf '%s\n' "$COVERAGE_OUTPUT" | \
    awk -v needle="uncovered line(s) in $pkg_path" '
      index($0, needle) { s += $1 }
      END { print s + 0 }
    ')

  if [ "$uncovered" -gt "$threshold" ]; then
    echo "FAIL: $pkg_path has $uncovered uncovered lines (threshold: $threshold)"
    echo "::error file=scripts/check-coverage.sh,title=Coverage threshold exceeded::$pkg_path has $uncovered uncovered lines (threshold: $threshold)"
    FAILED=1
  else
    echo "  OK: $pkg_path has $uncovered uncovered lines (threshold: $threshold)"
  fi
done

echo ""
echo "Total: $(echo "$COVERAGE_OUTPUT" | tail -1)"

if [ "$FAILED" -ne 0 ]; then
  echo ""
  echo "Coverage thresholds exceeded. Add tests or adjust thresholds in scripts/check-coverage.sh"
  exit 1
fi

echo ""
echo "All coverage thresholds passed."
