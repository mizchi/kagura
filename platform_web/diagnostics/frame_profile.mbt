///|
fn timing(value : @core.Any) -> @core.Any {
  if @interop.finite(value) && @interop.number(value) >= 0 {
    value
  } else {
    @core.null()
  }
}

///|
/// Pull-only telemetry. Never build history or capture a stale runtime.
pub fn read_frame_profile(host : @core.Any) -> @core.Any {
  let host = @interop.argument(host, @core.global_this())
  let runtime = @interop.field(host, "__kaguraWebRuntime")
  let gpu = @interop.field(runtime, "webgpu")
  if !@interop.truthy(gpu) {
    return @core.null()
  }
  let phases = @interop.field(runtime, "frameProfile")
  let commands = @interop.array_values(@interop.field(gpu, "commands"))
  let mut indices = 0.0
  let mut instances = 0.0
  let mut shared = 0
  for command in commands {
    indices = indices +
      @interop.number(
        @interop.fallback(
          @interop.field(command, "indexCount"),
          @interop.fallback(
            @interop.field(@interop.field(command, "indices"), "length"),
            @core.any(0),
          ),
        ),
      )
    instances = instances +
      @interop.number_field(command, "instanceCount", 1).max(1)
    if @interop.truthy(@interop.field(command, "sharedGeometry")) {
      shared = shared + 1
    }
  }
  let timing_method = @interop.fallback(
    @interop.field(gpu, "_gpuTimingMethod"),
    @core.null(),
  )
  let snapshot = @core.from_entries([
    ("version", @core.any(1)),
    (
      "frame",
      @interop.fallback(
        @interop.field(gpu, "_submittedFrameCount"),
        @core.any(0),
      ),
    ),
    (
      "gpuFrameMs",
      if @core.is_nullish(timing_method) {
        @core.null()
      } else {
        timing(
          @interop.field(
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
      @interop.fallback(
        @interop.field(
          @interop.field(
            @interop.field(gpu, "_sharedGeometryBuffers"),
            "resident",
          ),
          "size",
        ),
        @core.any(0),
      ),
    ),
  ])
  for key in ["updateMs", "drawCallbackMs", "renderCommandsMs"] {
    snapshot._set(key, timing(@interop.field(phases, key)))
  }
  for
    (key, source) in [
      ("renderCpuMs", "_lastRenderCpuMs"),
      ("renderUploadCpuMs", "_lastRenderUploadCpuMs"),
      ("renderBindGroupCpuMs", "_lastRenderBindGroupCpuMs"),
      ("renderEncodeCpuMs", "_lastRenderEncodeCpuMs"),
      ("renderSubmitCpuMs", "_lastRenderSubmitCpuMs"),
    ] {
    snapshot._set(key, timing(@interop.field(gpu, source)))
  }
  @object.Object::freeze(snapshot)
}

///|
pub fn install_frame_profiler(host : @core.Any) -> @core.Any {
  let host = @interop.argument(host, @core.global_this())
  let profiler = @object.Object::freeze(
    @core.from_entries([
      ("version", @core.any(1)),
      ("snapshot", @core.from_fn0(fn() { read_frame_profile(host) })),
    ]),
  )
  host._set("__kaguraProfiler", profiler)
  profiler
}
