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
# These thresholds are intentionally generous to start — tighten as tests grow.
declare -A THRESHOLDS=(
  [core]=10
  [runtime]=15
  [gfx]=60
  [scene]=90
  [asset_loader]=30
  [asset]=80
  [platform]=30
  [engine]=40
  [ui]=15
  [ecs]=20
)

FAILED=0

for pkg in "${!THRESHOLDS[@]}"; do
  threshold=${THRESHOLDS[$pkg]}
  # Sum uncovered lines for all files in src/$pkg/
  uncovered=$(echo "$COVERAGE_OUTPUT" | grep "uncovered line(s) in src/$pkg/" | \
    sed 's/^ *\([0-9]*\) .*/\1/' | awk '{s+=$1} END {print s+0}')

  if [ "$uncovered" -gt "$threshold" ]; then
    echo "FAIL: src/$pkg/ has $uncovered uncovered lines (threshold: $threshold)"
    FAILED=1
  else
    echo "  OK: src/$pkg/ has $uncovered uncovered lines (threshold: $threshold)"
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
