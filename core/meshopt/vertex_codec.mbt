// Vertex buffer decoder for the meshoptimizer vertex codec (versions 0 and 1).
// Port of the scalar path of `meshopt_decodeVertexBuffer` in
// zeux/meshoptimizer src/vertexcodec.cpp. MIT License,
// Copyright (c) 2016-2026 Arseny Kapoulkine; see THIRD_PARTY.md.

///|
const VERTEX_HEADER : Int = 0xa0

///|
const VERTEX_BLOCK_SIZE_BYTES : Int = 8192

///|
const VERTEX_BLOCK_MAX_SIZE : Int = 256

///|
const BYTE_GROUP_SIZE : Int = 16

///|
/// Every byte group reads at most 24 bytes; the tail padding guarantees the
/// check below never rejects a well-formed stream.
const BYTE_GROUP_DECODE_LIMIT : Int = 24

///|
const TAIL_MIN_SIZE_V0 : Int = 32

///|
const TAIL_MIN_SIZE_V1 : Int = 24

///|
let bits_v0 : FixedArray[Int] = [0, 2, 4, 8]

///|
let bits_v1 : FixedArray[Int] = [0, 1, 2, 4, 8]

///|
fn vertex_block_size(vertex_size : Int) -> Int {
  let result = (VERTEX_BLOCK_SIZE_BYTES / vertex_size) &
    (BYTE_GROUP_SIZE - 1).lnot()
  if result < VERTEX_BLOCK_MAX_SIZE {
    result
  } else {
    VERTEX_BLOCK_MAX_SIZE
  }
}

///|
/// Decode one group of 16 byte deltas into `buffer[at:at+16]` and return the
/// read position after it. The caller has checked that at least
/// `BYTE_GROUP_DECODE_LIMIT` bytes remain.
fn decode_bytes_group(
  source : BytesView,
  data : Int,
  buffer : FixedArray[Byte],
  at : Int,
  bits : Int,
) -> Int {
  match bits {
    0 => {
      buffer.fill(0, start=at, end=at + BYTE_GROUP_SIZE)
      data
    }
    1 => {
      // Two bytes of 8 one-bit values, least significant bit first.
      let mut extra = data + 2
      for m in 0..<16 {
        let enc = (source[data + (m >> 3)].to_int() >> (m & 7)) & 1
        if enc == 1 {
          buffer[at + m] = source[extra]
          extra += 1
        } else {
          buffer[at + m] = 0
        }
      }
      extra
    }
    2 => {
      // Four bytes of 4 two-bit values, most significant pair first.
      let mut extra = data + 4
      for m in 0..<16 {
        let enc = (source[data + (m >> 2)].to_int() >> (6 - ((m & 3) << 1))) & 3
        if enc == 3 {
          buffer[at + m] = source[extra]
          extra += 1
        } else {
          buffer[at + m] = enc.to_byte()
        }
      }
      extra
    }
    4 => {
      // Eight bytes of 2 four-bit values, high nibble first.
      let mut extra = data + 8
      for m in 0..<16 {
        let enc = (source[data + (m >> 1)].to_int() >> (4 - ((m & 1) << 2))) &
          15
        if enc == 15 {
          buffer[at + m] = source[extra]
          extra += 1
        } else {
          buffer[at + m] = enc.to_byte()
        }
      }
      extra
    }
    _ => {
      for m in 0..<16 {
        buffer[at + m] = source[data + m]
      }
      data + BYTE_GROUP_SIZE
    }
  }
}

///|
fn decode_bytes(
  source : BytesView,
  data : Int,
  buffer : FixedArray[Byte],
  at : Int,
  buffer_size : Int,
  bits : FixedArray[Int],
  bits_offset : Int,
) -> Int raise MeshoptError {
  let data_end = source.length()
  // Two header bits per group, rounded up to whole bytes.
  let header_size = (buffer_size / BYTE_GROUP_SIZE + 3) / 4
  if data_end - data < header_size {
    raise UnexpectedEnd("vertex block header")
  }
  let header = data
  let mut data = data + header_size
  for i = 0; i < buffer_size; i = i + BYTE_GROUP_SIZE {
    if data_end - data < BYTE_GROUP_DECODE_LIMIT {
      raise UnexpectedEnd("vertex byte group")
    }
    let group = i / BYTE_GROUP_SIZE
    let bitsk = (source[header + group / 4].to_int() >> (group % 4 * 2)) & 3
    data = decode_bytes_group(
      source,
      data,
      buffer,
      at + i,
      bits[bits_offset + bitsk],
    )
  }
  data
}

///|
fn unzigzag(v : Int, mask : Int) -> Int {
  ((v >> 1) ^ -(v & 1)) & mask
}

///|
/// Undo the per-channel delta for one 4-byte group of every vertex in the
/// block. `width` is 1 or 2 for byte / 16-bit zigzag deltas and 4 for the
/// rotated 32-bit XOR channel.
fn decode_deltas(
  buffer : FixedArray[Byte],
  target : FixedArray[Byte],
  target_offset : Int,
  vertex_count : Int,
  vertex_size : Int,
  last_vertex : FixedArray[Byte],
  k : Int,
  width : Int,
  rot : Int,
) -> Unit {
  let mut kk = 0
  while kk < 4 {
    let base = kk * vertex_count
    if width == 4 {
      let mut p = last_vertex[k].to_uint() |
        (last_vertex[k + 1].to_uint() << 8) |
        (last_vertex[k + 2].to_uint() << 16) |
        (last_vertex[k + 3].to_uint() << 24)
      for i in 0..<vertex_count {
        let v = buffer[base + i].to_uint() |
          (buffer[base + vertex_count + i].to_uint() << 8) |
          (buffer[base + 2 * vertex_count + i].to_uint() << 16) |
          (buffer[base + 3 * vertex_count + i].to_uint() << 24)
        let rotated = if rot == 0 { v } else { (v << rot) | (v >> (32 - rot)) }
        let x = rotated ^ p
        let o = target_offset + i * vertex_size + k
        target[o] = (x & 0xff).to_byte()
        target[o + 1] = ((x >> 8) & 0xff).to_byte()
        target[o + 2] = ((x >> 16) & 0xff).to_byte()
        target[o + 3] = (x >> 24).to_byte()
        p = x
      }
    } else if width == 2 {
      let mut p = last_vertex[k + kk].to_int() |
        (last_vertex[k + kk + 1].to_int() << 8)
      for i in 0..<vertex_count {
        let v = buffer[base + i].to_int() |
          (buffer[base + vertex_count + i].to_int() << 8)
        let x = (unzigzag(v, 0xffff) + p) & 0xffff
        let o = target_offset + i * vertex_size + k + kk
        target[o] = (x & 0xff).to_byte()
        target[o + 1] = (x >> 8).to_byte()
        p = x
      }
    } else {
      let mut p = last_vertex[k + kk].to_int()
      for i in 0..<vertex_count {
        let x = (unzigzag(buffer[base + i].to_int(), 0xff) + p) & 0xff
        target[target_offset + i * vertex_size + k + kk] = x.to_byte()
        p = x
      }
    }
    kk += width
  }
}

///|
fn decode_vertex_block(
  source : BytesView,
  data : Int,
  target : FixedArray[Byte],
  target_offset : Int,
  vertex_count : Int,
  vertex_size : Int,
  last_vertex : FixedArray[Byte],
  channels : Int,
  version : Int,
  buffer : FixedArray[Byte],
) -> Int raise MeshoptError {
  let data_end = source.length()
  let aligned = (vertex_count + BYTE_GROUP_SIZE - 1) &
    (BYTE_GROUP_SIZE - 1).lnot()
  let control_size = if version == 0 { 0 } else { vertex_size / 4 }
  if data_end - data < control_size {
    raise UnexpectedEnd("vertex block control bytes")
  }
  let control = data
  let mut data = data + control_size
  for k = 0; k < vertex_size; k = k + 4 {
    let ctrl_byte = if version == 0 {
      0
    } else {
      source[control + k / 4].to_int()
    }
    for j in 0..<4 {
      let ctrl = (ctrl_byte >> (j * 2)) & 3
      if ctrl == 3 {
        // Literal bytes.
        if data_end - data < vertex_count {
          raise UnexpectedEnd("vertex literal bytes")
        }
        for i in 0..<vertex_count {
          buffer[j * vertex_count + i] = source[data + i]
        }
        data += vertex_count
      } else if ctrl == 2 {
        buffer.fill(0, start=j * vertex_count, end=(j + 1) * vertex_count)
      } else if version == 0 {
        data = decode_bytes(
          source,
          data,
          buffer,
          j * vertex_count,
          aligned,
          bits_v0,
          0,
        )
      } else {
        data = decode_bytes(
          source,
          data,
          buffer,
          j * vertex_count,
          aligned,
          bits_v1,
          ctrl,
        )
      }
    }
    let channel = if version == 0 {
      0
    } else {
      source[channels + k / 4].to_int()
    }
    match channel & 3 {
      0 =>
        decode_deltas(
          buffer, target, target_offset, vertex_count, vertex_size, last_vertex,
          k, 1, 0,
        )
      1 =>
        decode_deltas(
          buffer, target, target_offset, vertex_count, vertex_size, last_vertex,
          k, 2, 0,
        )
      2 =>
        decode_deltas(
          buffer,
          target,
          target_offset,
          vertex_count,
          vertex_size,
          last_vertex,
          k,
          4,
          (32 - (channel >> 4)) & 31,
        )
      _ => raise InvalidHeader("invalid vertex channel mode")
    }
  }
  let last = target_offset + (vertex_count - 1) * vertex_size
  for i in 0..<vertex_size {
    last_vertex[i] = target[last + i]
  }
  data
}

///|
/// Decode `vertex_count` vertices of `vertex_size` bytes each from a stream
/// written by `meshopt_encodeVertexBuffer` into `target[0:count*size]`.
/// `vertex_size` must be a multiple of 4 no larger than 256.
pub fn decode_vertex_buffer(
  target : FixedArray[Byte],
  vertex_count : Int,
  vertex_size : Int,
  source : BytesView,
) -> Unit raise MeshoptError {
  if vertex_size <= 0 || vertex_size > 256 || vertex_size % 4 != 0 {
    raise InvalidArgument("vertex size must be a multiple of 4 in 4..256")
  }
  if vertex_count < 0 || target.length() < vertex_count * vertex_size {
    raise InvalidArgument("target is smaller than vertex_count * vertex_size")
  }
  let data_end = source.length()
  if data_end < 1 {
    raise UnexpectedEnd("vertex stream header")
  }
  let header = source[0].to_int()
  if (header & 0xf0) != VERTEX_HEADER {
    raise InvalidHeader("not a vertex stream")
  }
  let version = header & 0x0f
  if version > 1 {
    raise InvalidHeader("unsupported vertex codec version \{version}")
  }
  let tail_size = vertex_size + (if version == 0 { 0 } else { vertex_size / 4 })
  let tail_size_min = if version == 0 {
    TAIL_MIN_SIZE_V0
  } else {
    TAIL_MIN_SIZE_V1
  }
  let tail_size_pad = if tail_size < tail_size_min {
    tail_size_min
  } else {
    tail_size
  }
  if data_end - 1 < tail_size_pad {
    raise UnexpectedEnd("vertex stream tail")
  }
  let tail = data_end - tail_size
  let last_vertex = FixedArray::make(256, (0 : Byte))
  for i in 0..<vertex_size {
    last_vertex[i] = source[tail + i]
  }
  let channels = tail + vertex_size
  let block_size = vertex_block_size(vertex_size)
  let buffer = FixedArray::make(VERTEX_BLOCK_MAX_SIZE * 4, (0 : Byte))
  let mut data = 1
  let mut offset = 0
  while offset < vertex_count {
    let count = if offset + block_size < vertex_count {
      block_size
    } else {
      vertex_count - offset
    }
    data = decode_vertex_block(
      source,
      data,
      target,
      offset * vertex_size,
      count,
      vertex_size,
      last_vertex,
      channels,
      version,
      buffer,
    )
    offset += count
  }
  if data_end - data != tail_size_pad {
    raise TrailingData("vertex stream has unread data")
  }
}
