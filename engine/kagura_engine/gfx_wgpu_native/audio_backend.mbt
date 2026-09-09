///|
/// Native audio backend hooks backed by miniaudio + ring buffer FFI.
pub fn new_native_audio_output_hooks() -> @audio.AudioOutputHooks {
  @audio.new_audio_output_hooks_full(
    fn(format) {
      runtime_audio_try_initialize(format.sample_rate, format.channels)
    },
    runtime_audio_write_frames,
    runtime_audio_suspend,
    runtime_audio_resume,
    runtime_audio_close,
    runtime_audio_output_latency,
  )
}

///|
fn runtime_audio_is_initialized() -> Bool {
  moonbit_audio_is_initialized() != 0
}

///|
fn runtime_audio_try_initialize(sample_rate : Int, channels : Int) -> Bool {
  if sample_rate <= 0 || channels <= 0 {
    return false
  }
  moonbit_audio_try_initialize(sample_rate, channels) != 0
}

///|
fn runtime_audio_write_frames(output : FixedArray[Float], frames : Int) -> Int {
  if !runtime_audio_is_initialized() {
    return 0
  }
  let channels = 2
  let write_pos = moonbit_audio_get_write_pos()
  let to_write = if frames < 0 { 0 } else { frames }
  let available_samples = output.length()
  let actual_frames = if to_write * channels > available_samples {
    available_samples / channels
  } else {
    to_write
  }
  for i in 0..<actual_frames {
    let ring_pos = (write_pos + i) % 32768 // AUDIO_RING_SIZE
    for ch in 0..<channels {
      let sample_idx = i * channels + ch
      moonbit_audio_write_sample(ring_pos, ch, output[sample_idx])
    }
  }
  if actual_frames > 0 {
    moonbit_audio_advance_write(actual_frames)
  }
  actual_frames
}

///|
fn runtime_audio_suspend() -> Unit {
  moonbit_audio_suspend()
}

///|
fn runtime_audio_resume() -> Unit {
  moonbit_audio_resume()
}

///|
fn runtime_audio_close() -> Unit {
  moonbit_audio_close()
}

///|
fn runtime_audio_output_latency() -> Double {
  moonbit_audio_output_latency()
}
