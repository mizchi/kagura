///|
pub fn percentile(values : @core.Any, p : Double) -> Double {
  @statistics.percentile(
    @interop.array_values(values).map(fn(value) { value.cast() }),
    p,
  )
}

///|
pub fn summarize_intervals(timestamps : @core.Any) -> @core.Any {
  let result = @statistics.summarize_intervals(
    @interop.array_values(timestamps).map(fn(value) { value.cast() }),
  )
  @core.from_entries([
    ("frames", @core.any(result.frames)),
    ("elapsedMs", @core.any(@jsmath.Math::round(result.elapsed_ms))),
    ("fps", @core.any(@interop.fixed_decimal(result.fps, 1))),
    ("p50IntervalMs", @core.any(@interop.fixed_decimal(result.p50_ms, 2))),
    ("p95IntervalMs", @core.any(@interop.fixed_decimal(result.p95_ms, 2))),
  ])
}
