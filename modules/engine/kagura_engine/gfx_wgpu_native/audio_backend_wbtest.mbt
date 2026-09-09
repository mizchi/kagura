///|
test "runtime_audio_try_initialize rejects invalid format" {
  assert_eq(runtime_audio_try_initialize(0, 2), false)
  assert_eq(runtime_audio_try_initialize(44100, 0), false)
  assert_eq(runtime_audio_try_initialize(-1, -1), false)
}

///|
test "runtime_audio_write_frames returns zero before initialize" {
  runtime_audio_close()
  let buf : FixedArray[Float] = FixedArray::make(4, 0.0)
  let written = runtime_audio_write_frames(buf, 2)
  assert_eq(written, 0)
  assert_eq(runtime_audio_output_latency(), 0.0)
}

///|
test "native_audio_output_hooks expose safe no-op lifecycle before initialize" {
  runtime_audio_close()
  let hooks = new_native_audio_output_hooks()
  let buf : FixedArray[Float] = FixedArray::make(4, 0.0)
  assert_eq((hooks.write_frames)(buf, 2), 0)
  assert_eq((hooks.output_latency)(), 0.0)
  (hooks.suspend)()
  (hooks.resume_playback)()
  (hooks.close)()
}
