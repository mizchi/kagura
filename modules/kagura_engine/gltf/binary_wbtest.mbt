///|
test "read_f32_le zero" {
  let buf = Bytes::from_array([b'\x00', b'\x00', b'\x00', b'\x00'])
  let v = read_f32_le(buf, 0)
  assert_true((v - 0.0).abs() < 1.0e-6)
}

///|
test "read_f32_le 1.0" {
  // IEEE 754: 1.0 = 0x3F800000
  let buf = Bytes::from_array([b'\x00', b'\x00', b'\x80', b'\x3F'])
  let v = read_f32_le(buf, 0)
  assert_true((v - 1.0).abs() < 1.0e-6)
}

///|
test "read_f32_le -1.0" {
  // IEEE 754: -1.0 = 0xBF800000
  let buf = Bytes::from_array([b'\x00', b'\x00', b'\x80', b'\xBF'])
  let v = read_f32_le(buf, 0)
  assert_true((v - -1.0).abs() < 1.0e-6)
}

///|
test "read_u16_le" {
  let buf = Bytes::from_array([b'\x01', b'\x00', b'\xFF', b'\x00'])
  assert_eq(read_u16_le(buf, 0), 1)
  assert_eq(read_u16_le(buf, 2), 255)
}

///|
test "read_u32_le" {
  let buf = Bytes::from_array([b'\x01', b'\x00', b'\x00', b'\x00'])
  assert_eq(read_u32_le(buf, 0), 1)
}
