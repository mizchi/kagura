// Frame-timing summaries, shared by everything that measures the frame clock:
// the browser probe page, the worker inside it, and scripts/bench-frame-clock.
//
// Kept in one place so the main thread and the guest are summarised by the same
// arithmetic -- otherwise "the guest is slower" can just be the two sides
// computing a percentile differently.

/** Value at `p` (0..1) of `values`, nearest-rank. Returns 0 when empty. */
export function percentile(values, p) {
  if (values.length === 0) return 0;
  const sorted = [...values].sort((a, b) => a - b);
  return sorted[Math.min(sorted.length - 1, Math.floor(sorted.length * p))];
}

/**
 * Summarise a series of frame timestamps (milliseconds, any monotonic clock).
 *
 * @param {number[]} timestampsMs
 * @returns {{frames: number, elapsedMs: number, fps: number, p50IntervalMs: number, p95IntervalMs: number}}
 */
export function summarizeIntervals(timestampsMs) {
  const intervals = [];
  for (let i = 1; i < timestampsMs.length; i++) {
    intervals.push(timestampsMs[i] - timestampsMs[i - 1]);
  }
  const elapsed = timestampsMs.length > 1 ? timestampsMs.at(-1) - timestampsMs[0] : 0;
  return {
    frames: timestampsMs.length,
    elapsedMs: Math.round(elapsed),
    fps: elapsed > 0 ? +(intervals.length / (elapsed / 1000)).toFixed(1) : 0,
    p50IntervalMs: +percentile(intervals, 0.5).toFixed(2),
    p95IntervalMs: +percentile(intervals, 0.95).toFixed(2),
  };
}
