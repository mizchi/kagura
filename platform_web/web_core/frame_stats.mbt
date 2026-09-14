///|
/// Same rank convention as the browser/worker frame-clock probes.
pub fn percentile(values : @core.Any, p : Double) -> Double {
  let sorted = array_values(values).map(fn(v) -> Double { v.cast() })
  if sorted.is_empty() {
    return 0
  }
  sorted.sort()
  sorted[@jsmath.Math::floor(sorted.length().to_double() * p).min(
    sorted.length() - 1,
  )]
}

///|
pub fn summarize_intervals(timestamps : @core.Any) -> @core.Any {
  let values = array_values(timestamps).map(fn(v) -> Double { v.cast() })
  let intervals : Array[Double] = []
  for i = 1; i < values.length(); i = i + 1 {
    intervals.push(values[i] - values[i - 1])
  }
  let elapsed = if values.length() > 1 {
    values[values.length() - 1] - values[0]
  } else {
    0
  }
  @core.from_entries([
    ("frames", @core.any(values.length())),
    ("elapsedMs", @core.any(@jsmath.Math::round(elapsed))),
    (
      "fps",
      @core.any(
        if elapsed > 0 {
          fixed_decimal(intervals.length().to_double() / (elapsed / 1000), 1)
        } else {
          0
        },
      ),
    ),
    (
      "p50IntervalMs",
      @core.any(fixed_decimal(percentile(@core.any(intervals), 0.5), 2)),
    ),
    (
      "p95IntervalMs",
      @core.any(fixed_decimal(percentile(@core.any(intervals), 0.95), 2)),
    ),
  ])
}
