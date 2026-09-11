///|
test "decoded_pcm_payload_to_audio_clip builds stereo clip from browser payload" {
  let payload = Bytes::from_array([
    b'\x44', b'\xAC', b'\x00', b'\x00', // 44100 Hz
     b'\x02', b'\x00', b'\x00', b'\x00', // stereo
     b'\x02', b'\x00', b'\x00', b'\x00', // 2 frames
     b'\x01', b'\x00', b'\x02', b'\x00', b'\x03', b'\x00', b'\x04', b'\x00',
  ])

  let clip = decoded_pcm_payload_to_audio_clip(payload, false).unwrap()

  assert_eq(clip.format.sample_rate, 44100)
  assert_eq(clip.format.channels, 2)
  assert_eq(clip.data.length(), 8)
  assert_eq(@audio.clip_sample_count(clip), 2)
}

///|
test "decoded_pcm_payload_to_audio_clip rejects short payload" {
  let payload = Bytes::from_array([b'\x44', b'\xAC', b'\x00', b'\x00'])

  match decoded_pcm_payload_to_audio_clip(payload, false) {
    None => ()
    Some(_) => fail("expected None")
  }
}
