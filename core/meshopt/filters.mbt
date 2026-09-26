// Vertex filters used by EXT_meshopt_compression. Port of the scalar
// `decodeFilter*` functions in zeux/meshoptimizer src/vertexfilter.cpp
// (MIT License, Copyright (c) 2016-2026 Arseny Kapoulkine; see
// THIRD_PARTY.md). The arithmetic is done in `Float` (f32) in the same order
// as the C code, so results match the scalar C build bit for bit.

///|
fn read_i8(buf : FixedArray[Byte], o : Int) -> Int {
  let v = buf[o].to_int()
  if v >= 0x80 {
    v - 0x100
  } else {
    v
  }
}

///|
fn read_u16(buf : FixedArray[Byte], o : Int) -> Int {
  buf[o].to_int() | (buf[o + 1].to_int() << 8)
}

///|
fn read_i16(buf : FixedArray[Byte], o : Int) -> Int {
  let v = read_u16(buf, o)
  if v >= 0x8000 {
    v - 0x10000
  } else {
    v
  }
}

///|
fn write_u16(buf : FixedArray[Byte], o : Int, v : Int) -> Unit {
  buf[o] = (v & 0xff).to_byte()
  buf[o + 1] = ((v >> 8) & 0xff).to_byte()
}

///|
/// `int(x + (x >= 0 ? 0.5f : -0.5f))`: round half away from zero, then
/// truncate toward zero like the C cast.
fn round_signed(x : Float) -> Int {
  let half : Float = if x >= 0.0 { 0.5 } else { -0.5 }
  (x + half).to_int()
}

///|
fn check_filter_target(
  target : FixedArray[Byte],
  count : Int,
  stride : Int,
) -> Unit raise MeshoptError {
  if count < 0 || target.length() < count * stride {
    raise InvalidArgument("target is smaller than count * stride")
  }
}

///|
/// Octahedral normal/tangent filter. `stride` is 4 (8-bit components) or 8
/// (16-bit components); the fourth component is left as is.
pub fn decode_filter_oct(
  target : FixedArray[Byte],
  count : Int,
  stride : Int,
) -> Unit raise MeshoptError {
  if stride != 4 && stride != 8 {
    raise InvalidArgument("octahedral filter stride must be 4 or 8")
  }
  check_filter_target(target, count, stride)
  let max : Float = if stride == 4 { 127.0 } else { 32767.0 }
  for i in 0..<count {
    let o = i * stride
    let (rx, ry, rz) = if stride == 4 {
      (read_i8(target, o), read_i8(target, o + 1), read_i8(target, o + 2))
    } else {
      (read_i16(target, o), read_i16(target, o + 2), read_i16(target, o + 4))
    }
    let mut x = Float::from_int(rx)
    let mut y = Float::from_int(ry)
    let z = Float::from_int(rz) - x.abs() - y.abs()
    let t : Float = if z >= 0.0 { 0.0 } else { z }
    x = x + (if x >= 0.0 { t } else { -t })
    y = y + (if y >= 0.0 { t } else { -t })
    let l = (x * x + y * y + z * z).sqrt()
    let s = max / l
    let xf = round_signed(x * s)
    let yf = round_signed(y * s)
    let zf = round_signed(z * s)
    if stride == 4 {
      target[o] = (xf & 0xff).to_byte()
      target[o + 1] = (yf & 0xff).to_byte()
      target[o + 2] = (zf & 0xff).to_byte()
    } else {
      write_u16(target, o, xf)
      write_u16(target, o + 2, yf)
      write_u16(target, o + 4, zf)
    }
  }
}

///|
/// Quaternion filter for 16-bit rotations (`stride` must be 8).
pub fn decode_filter_quat(
  target : FixedArray[Byte],
  count : Int,
  stride : Int,
) -> Unit raise MeshoptError {
  if stride != 8 {
    raise InvalidArgument("quaternion filter stride must be 8")
  }
  check_filter_target(target, count, stride)
  let scale : Float = (32767.0 : Float) / (2.0 : Float).sqrt()
  for i in 0..<count {
    let o = i * 8
    let w_in = read_i16(target, o + 6)
    let s = Float::from_int(w_in | 3)
    let x = Float::from_int(read_i16(target, o))
    let y = Float::from_int(read_i16(target, o + 2))
    let z = Float::from_int(read_i16(target, o + 4))
    let ws = s * s
    let ww = ws * 2.0 - x * x - y * y - z * z
    let w = (if ww >= 0.0 { ww } else { 0.0 }).sqrt()
    let ss = scale / s
    let xf = round_signed(x * ss)
    let yf = round_signed(y * ss)
    let zf = round_signed(z * ss)
    let wf = (w * ss + 0.5).to_int()
    let qc = w_in & 3
    write_u16(target, o + ((qc + 1) & 3) * 2, xf)
    write_u16(target, o + ((qc + 2) & 3) * 2, yf)
    write_u16(target, o + ((qc + 3) & 3) * 2, zf)
    write_u16(target, o + (qc & 3) * 2, wf)
  }
}

///|
/// Exponential filter: each 32-bit word holds a 24-bit signed mantissa and
/// an 8-bit signed exponent and becomes an f32. `stride` must be a multiple
/// of 4.
pub fn decode_filter_exp(
  target : FixedArray[Byte],
  count : Int,
  stride : Int,
) -> Unit raise MeshoptError {
  if stride <= 0 || stride % 4 != 0 {
    raise InvalidArgument("exponential filter stride must be a multiple of 4")
  }
  check_filter_target(target, count, stride)
  for i in 0..<(count * (stride / 4)) {
    let o = i * 4
    let v = target[o].to_int() |
      (target[o + 1].to_int() << 8) |
      (target[o + 2].to_int() << 16) |
      (target[o + 3].to_int() << 24)
    let m = v << 8 >> 8
    let e = v >> 24
    let f = Float::reinterpret_from_int((e + 127) << 23) * Float::from_int(m)
    let bits = f.reinterpret_as_int()
    target[o] = (bits & 0xff).to_byte()
    target[o + 1] = ((bits >> 8) & 0xff).to_byte()
    target[o + 2] = ((bits >> 16) & 0xff).to_byte()
    target[o + 3] = ((bits >> 24) & 0xff).to_byte()
  }
}

///|
/// YCoCg color filter. `stride` is 4 (8-bit channels) or 8 (16-bit channels).
pub fn decode_filter_color(
  target : FixedArray[Byte],
  count : Int,
  stride : Int,
) -> Unit raise MeshoptError {
  if stride != 4 && stride != 8 {
    raise InvalidArgument("color filter stride must be 4 or 8")
  }
  check_filter_target(target, count, stride)
  let max : Float = if stride == 4 { 255.0 } else { 65535.0 }
  let mask = if stride == 4 { 0xff } else { 0xffff }
  for i in 0..<count {
    let o = i * stride
    let (y, co, cg, alpha) = if stride == 4 {
      (
        target[o].to_int(),
        read_i8(target, o + 1),
        read_i8(target, o + 2),
        target[o + 3].to_int(),
      )
    } else {
      (
        read_u16(target, o),
        read_i16(target, o + 2),
        read_i16(target, o + 4),
        read_u16(target, o + 6),
      )
    }
    // Recover the scale from the highest set bit of alpha.
    let mut as_ = alpha
    as_ = as_ | (as_ >> 1)
    as_ = as_ | (as_ >> 2)
    as_ = as_ | (as_ >> 4)
    as_ = as_ | (as_ >> 8)
    let r = y + co - cg
    let g = y + cg
    let b = y - co - cg
    let a = ((alpha << 1) & as_) | (alpha & 1)
    // The encoder always sets the top bit of alpha, so `as_ == 0` only
    // occurs in corrupted data. C then converts inf/NaN to int, which is
    // undefined; x86 yields 0x80000000, i.e. 0 after truncation. Match it
    // instead of saturating.
    let ss : Float = if as_ == 0 { 0.0 } else { max / Float::from_int(as_) }
    let rf = (Float::from_int(r) * ss + 0.5).to_int() & mask
    let gf = (Float::from_int(g) * ss + 0.5).to_int() & mask
    let bf = (Float::from_int(b) * ss + 0.5).to_int() & mask
    let af = (Float::from_int(a) * ss + 0.5).to_int() & mask
    if stride == 4 {
      target[o] = rf.to_byte()
      target[o + 1] = gf.to_byte()
      target[o + 2] = bf.to_byte()
      target[o + 3] = af.to_byte()
    } else {
      write_u16(target, o, rf)
      write_u16(target, o + 2, gf)
      write_u16(target, o + 4, bf)
      write_u16(target, o + 6, af)
    }
  }
}
