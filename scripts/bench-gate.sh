#!/usr/bin/env bash
# Run benchmarks and check for regressions against baseline.
# Usage:
#   bash scripts/bench-gate.sh [target]           # check against baseline
#   bash scripts/bench-gate.sh [target] --update   # save new baseline
#
# Baseline file: scripts/bench-baseline.json

set -euo pipefail

TARGET="${1:-js}"
UPDATE="${2:-}"
BASELINE="scripts/bench-baseline.json"
REGRESSION_THRESHOLD=1.5  # 50% slower = regression

echo "Running benchmarks (target=$TARGET)..."

# Parse bench output: extract "name  mean_us" pairs
# moon bench outputs lines like: "ecs/spawn_10000  433.36 µs ± ..."  or "... 1.24 ms ± ..."
BENCH_OUTPUT=$(moon bench --target "$TARGET" 2>&1)
RESULTS=$(echo "$BENCH_OUTPUT" | grep -E '^\S+/\S+\s' | while read -r name mean unit rest; do
  # Convert to microseconds
  case "$unit" in
    µs) echo "$name $mean" ;;
    ms) echo "$name $(echo "$mean * 1000" | bc)" ;;
    s)  echo "$name $(echo "$mean * 1000000" | bc)" ;;
    *)  echo "$name $mean" ;;
  esac
done)

if [ "$UPDATE" = "--update" ]; then
  echo "Saving baseline to $BASELINE..."
  echo "{" > "$BASELINE"
  first=true
  echo "$RESULTS" | while read -r name mean_us; do
    if [ "$first" = true ]; then
      first=false
    else
      echo "," >> "$BASELINE"
    fi
    printf '  "%s": %.2f' "$name" "$mean_us" >> "$BASELINE"
  done
  echo "" >> "$BASELINE"
  echo "}" >> "$BASELINE"
  echo "Baseline saved."
  exit 0
fi

# Check against baseline
if [ ! -f "$BASELINE" ]; then
  echo "No baseline found at $BASELINE. Run with --update to create one."
  echo "Skipping regression check."
  exit 0
fi

echo ""
echo "=== Benchmark Regression Check (threshold: ${REGRESSION_THRESHOLD}x) ==="

FAILED=0
echo "$RESULTS" | while read -r name mean_us; do
  # Look up baseline (simple grep from JSON)
  baseline=$(grep "\"$name\"" "$BASELINE" 2>/dev/null | sed 's/.*: *\([0-9.]*\).*/\1/' || echo "")
  if [ -z "$baseline" ] || [ "$baseline" = "0" ]; then
    echo "  NEW: $name = ${mean_us}µs (no baseline)"
    continue
  fi
  ratio=$(echo "scale=3; $mean_us / $baseline" | bc)
  if [ "$(echo "$ratio > $REGRESSION_THRESHOLD" | bc)" -eq 1 ]; then
    echo "  REGRESSION: $name = ${mean_us}µs vs baseline ${baseline}µs (${ratio}x slower)"
    FAILED=1
  else
    echo "  OK: $name = ${mean_us}µs vs baseline ${baseline}µs (${ratio}x)"
  fi
done

if [ "$FAILED" -ne 0 ]; then
  echo ""
  echo "Benchmark regressions detected! Update baseline with: bash scripts/bench-gate.sh $TARGET --update"
  exit 1
fi

echo ""
echo "All benchmarks within threshold."
