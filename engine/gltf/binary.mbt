///|
fn read_u16_le(buf : Bytes, offset : Int) -> Int {
  buf[offset].to_int() | (buf[offset + 1].to_int() << 8)
}

///|
fn read_u32_le(buf : Bytes, offset : Int) -> Int {
  buf[offset].to_int() |
  (buf[offset + 1].to_int() << 8) |
  (buf[offset + 2].to_int() << 16) |
  (buf[offset + 3].to_int() << 24)
}

///|
fn read_f32_le(buf : Bytes, offset : Int) -> Double {
  let bits = read_u32_le(buf, offset)
  let sign = if bits >> 31 != 0 { -1.0 } else { 1.0 }
  let exponent = (bits >> 23) & 0xFF
  let mantissa = bits & 0x7FFFFF
  if exponent == 0 && mantissa == 0 {
    return sign * 0.0
  }
  if exponent == 0xFF {
    if mantissa == 0 {
      return sign * (1.0 / 0.0)
    }
    return 0.0 / 0.0
  }
  let e = exponent - 127
  let m = 1.0 + mantissa.to_double() / 8388608.0
  sign * m * pow2(e)
}

///|
fn pow2(exp : Int) -> Double {
  if exp >= 0 {
    let mut result = 1.0
    for _i in 0..<exp {
      result = result * 2.0
    }
    result
  } else {
    let mut result = 1.0
    for _i in 0..<-exp {
      result = result / 2.0
    }
    result
  }
}
