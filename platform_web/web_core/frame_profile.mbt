///|
fn timing(value : @core.Any) -> @core.Any {
  if finite(value) && number(value) >= 0 {
    value
  } else {
    @core.null()
  }
}

///|
/// Pull-only telemetry. Never build history or capture a stale runtime.
pub fn read_frame_profile(host : @core.Any) -> @core.Any {
  let host = argument(host, @core.global_this())
  let runtime = field(host, "__kaguraWebRuntime")
  let gpu = field(runtime, "webgpu")
  if !truthy(gpu) {
    return @core.null()
  }
  let phases = field(runtime, "frameProfile")
  let commands = array_values(field(gpu, "commands"))
  let mut indices = 0.0
  let mut instances = 0.0
  let mut shared = 0
  for command in commands {
    indices = indices +
      number(
        fallback(
          field(command, "indexCount"),
          fallback(field(field(command, "indices"), "length"), @core.any(0)),
        ),
      )
    instances = instances + number_field(command, "instanceCount", 1).max(1)
    if truthy(field(command, "sharedGeometry")) {
      shared = shared + 1
    }
  }
  let timing_method = fallback(field(gpu, "_gpuTimingMethod"), @core.null())
  let snapshot = @core.from_entries([
    ("version", @core.any(1)),
    ("frame", fallback(field(gpu, "_submittedFrameCount"), @core.any(0))),
    (
      "gpuFrameMs",
      if @core.is_nullish(timing_method) {
        @core.null()
      } else {
        timing(
          field(
            gpu,
            if @core.equal(timing_method, @core.any("timestamp-query")) {
              "_lastTimestampFrameMs"
            } else {
              "_lastCompletedFrameMs"
            },
          ),
        )
      },
    ),
    ("gpuTimingMethod", timing_method),
    ("drawCalls", @core.any(commands.length())),
    ("indexCount", @core.any(indices)),
    ("instanceCount", @core.any(instances)),
    ("sharedGeometryDraws", @core.any(shared)),
    (
      "residentGeometryBuffers",
      fallback(
        field(field(field(gpu, "_sharedGeometryBuffers"), "resident"), "size"),
        @core.any(0),
      ),
    ),
  ])
  for key in ["updateMs", "drawCallbackMs", "renderCommandsMs"] {
    snapshot._set(key, timing(field(phases, key)))
  }
  for
    (key, source) in [
      ("renderCpuMs", "_lastRenderCpuMs"),
      ("renderUploadCpuMs", "_lastRenderUploadCpuMs"),
      ("renderBindGroupCpuMs", "_lastRenderBindGroupCpuMs"),
      ("renderEncodeCpuMs", "_lastRenderEncodeCpuMs"),
      ("renderSubmitCpuMs", "_lastRenderSubmitCpuMs"),
    ] {
    snapshot._set(key, timing(field(gpu, source)))
  }
  @object.Object::freeze(snapshot)
}

///|
pub fn install_frame_profiler(host : @core.Any) -> @core.Any {
  let host = argument(host, @core.global_this())
  let profiler = @object.Object::freeze(
    @core.from_entries([
      ("version", @core.any(1)),
      ("snapshot", @core.from_fn0(fn() { read_frame_profile(host) })),
    ]),
  )
  host._set("__kaguraProfiler", profiler)
  profiler
}
