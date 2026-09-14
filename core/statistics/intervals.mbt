///|
/// Nearest rank at floor(n * p), matching the frame profiler's convention.
/// Callers use p in [0, 1]; clamping also makes endpoint queries total.
pub fn percentile(values : Array[Double], p : Double) -> Double {
  if values.is_empty() {
    return 0
  }
  let sorted = values.copy()
  sorted.sort()
  sorted[(sorted.length().to_double() * p)
  .to_int()
  .max(0)
  .min(sorted.length() - 1)]
}

///|
pub(all) struct IntervalSummary {
  frames : Int
  elapsed_ms : Double
  fps : Double
  p50_ms : Double
  p95_ms : Double
}

///|
pub fn summarize_intervals(values : Array[Double]) -> IntervalSummary {
  let intervals : Array[Double] = []
  for i = 1; i < values.length(); i = i + 1 {
    intervals.push(values[i] - values[i - 1])
  }
  let elapsed = if values.length() > 1 {
    values[values.length() - 1] - values[0]
  } else {
    0
  }
  {
    frames: values.length(),
    elapsed_ms: elapsed,
    fps: if elapsed > 0 {
      intervals.length().to_double() / (elapsed / 1000)
    } else {
      0
    },
    p50_ms: percentile(intervals, 0.5),
    p95_ms: percentile(intervals, 0.95),
  }
}
