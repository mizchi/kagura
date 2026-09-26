// Index buffer and index sequence decoders for the meshoptimizer index codec
// (versions 0 and 1). Port of `meshopt_decodeIndexBuffer` and
// `meshopt_decodeIndexSequence` in zeux/meshoptimizer src/indexcodec.cpp
// (MIT License, Copyright (c) 2016-2026 Arseny Kapoulkine; see
// THIRD_PARTY.md). Indices are unsigned 32-bit values held in `Int` bit
// patterns, so arithmetic wraps exactly like the C `unsigned int`.

///|
const INDEX_HEADER : Int = 0xe0

///|
const SEQUENCE_HEADER : Int = 0xd0

///|
fn write_index(
  target : FixedArray[Byte],
  i : Int,
  index_size : Int,
  v : Int,
) -> Unit {
  let o = i * index_size
  target[o] = (v & 0xff).to_byte()
  target[o + 1] = ((v >> 8) & 0xff).to_byte()
  if index_size == 4 {
    target[o + 2] = ((v >> 16) & 0xff).to_byte()
    target[o + 3] = ((v >> 24) & 0xff).to_byte()
  }
}

///|
/// Read a LEB128-style value of up to 5 bytes. Returns (value, new offset).
fn decode_vbyte(source : BytesView, data : Int) -> (Int, Int) {
  let lead = source[data].to_int()
  if lead < 128 {
    return (lead, data + 1)
  }
  let mut result = lead & 127
  let mut shift = 7
  let mut p = data + 1
  for _ in 0..<4 {
    let group = source[p].to_int()
    p += 1
    result = result | ((group & 127) << shift)
    shift += 7
    if group < 128 {
      break
    }
  }
  (result, p)
}

///|
fn dezig(v : Int) -> Int {
  (v.reinterpret_as_uint() >> 1).reinterpret_as_int() ^ -(v & 1)
}

///|
/// Decode a triangle list written by `meshopt_encodeIndexBuffer` into
/// `target` as little-endian `index_size`-byte (2 or 4) indices.
pub fn decode_index_buffer(
  target : FixedArray[Byte],
  index_count : Int,
  index_size : Int,
  source : BytesView,
) -> Unit raise MeshoptError {
  if index_count < 0 || index_count % 3 != 0 {
    raise InvalidArgument("index count must be a multiple of 3")
  }
  if index_size != 2 && index_size != 4 {
    raise InvalidArgument("index size must be 2 or 4")
  }
  if target.length() < index_count * index_size {
    raise InvalidArgument("target is smaller than index_count * index_size")
  }
  let buffer_size = source.length()
  // Header, one code byte per triangle and the 16-byte codeaux table.
  if buffer_size < 1 + index_count / 3 + 16 {
    raise UnexpectedEnd("index stream")
  }
  let header = source[0].to_int()
  if (header & 0xf0) != INDEX_HEADER {
    raise InvalidHeader("not an index stream")
  }
  let version = header & 0x0f
  if version > 1 {
    raise InvalidHeader("unsupported index codec version \{version}")
  }
  let edge_a = FixedArray::make(16, -1)
  let edge_b = FixedArray::make(16, -1)
  let vertex_fifo = FixedArray::make(16, -1)
  let mut edge_offset = 0
  let mut vertex_offset = 0
  let mut next = 0
  let mut last = 0
  let fecmax = if version >= 1 { 13 } else { 15 }
  let mut code = 1
  let code_end = code + index_count / 3
  let mut data = code_end
  // Each triangle reads at most 16 data bytes, which is the size of the
  // codeaux table that follows the data, so this bound keeps reads in range.
  let data_safe_end = buffer_size - 16
  let codeaux_table = data_safe_end
  let mut tri = 0
  fn push_vertex(v : Int, cond : Bool) {
    vertex_fifo[vertex_offset] = v
    if cond {
      vertex_offset = (vertex_offset + 1) & 15
    }
  }
  fn push_edge(a : Int, b : Int) {
    edge_a[edge_offset] = a
    edge_b[edge_offset] = b
    edge_offset = (edge_offset + 1) & 15
  }
  while code < code_end {
    let codetri = source[code].to_int()
    code += 1
    if codetri < 0xf0 {
      let fe = codetri >> 4
      let a = edge_a[(edge_offset - 1 - fe) & 15]
      let b = edge_b[(edge_offset - 1 - fe) & 15]
      let fec = codetri & 15
      let c = if fec < fecmax {
        let c = if fec == 0 {
          next
        } else {
          vertex_fifo[(vertex_offset - 1 - fec) & 15]
        }
        if fec == 0 {
          next += 1
        }
        push_vertex(c, fec == 0)
        c
      } else {
        if data > data_safe_end {
          raise UnexpectedEnd("index stream data")
        }
        // fec 13 / 14 are -1 / +1 relative to the last free index.
        if fec != 15 {
          last = last + (fec * 2 - 27)
        } else {
          let (v, p) = decode_vbyte(source, data)
          data = p
          last = last + dezig(v)
        }
        push_vertex(last, true)
        last
      }
      push_edge(c, b)
      push_edge(a, c)
      write_index(target, tri * 3, index_size, a)
      write_index(target, tri * 3 + 1, index_size, b)
      write_index(target, tri * 3 + 2, index_size, c)
    } else if codetri < 0xfe {
      // Fast path: codeaux from the table.
      let codeaux = source[codeaux_table + (codetri & 15)].to_int()
      let feb = codeaux >> 4
      let fec = codeaux & 15
      let a = next
      next += 1
      let b = if feb == 0 {
        next
      } else {
        vertex_fifo[(vertex_offset - feb) & 15]
      }
      if feb == 0 {
        next += 1
      }
      let c = if fec == 0 {
        next
      } else {
        vertex_fifo[(vertex_offset - fec) & 15]
      }
      if fec == 0 {
        next += 1
      }
      write_index(target, tri * 3, index_size, a)
      write_index(target, tri * 3 + 1, index_size, b)
      write_index(target, tri * 3 + 2, index_size, c)
      push_vertex(a, true)
      push_vertex(b, feb == 0)
      push_vertex(c, fec == 0)
      push_edge(b, a)
      push_edge(c, b)
      push_edge(a, c)
    } else {
      if data > data_safe_end {
        raise UnexpectedEnd("index stream data")
      }
      // Slow path: codeaux is a full data byte.
      let codeaux = source[data].to_int()
      data += 1
      let fea = if codetri == 0xfe { 0 } else { 15 }
      let feb = codeaux >> 4
      let fec = codeaux & 15
      if codeaux == 0 {
        next = 0
      }
      let mut a = 0
      if fea == 0 {
        a = next
        next += 1
      }
      let mut b = 0
      if feb == 0 {
        b = next
        next += 1
      } else {
        b = vertex_fifo[(vertex_offset - feb) & 15]
      }
      let mut c = 0
      if fec == 0 {
        c = next
        next += 1
      } else {
        c = vertex_fifo[(vertex_offset - fec) & 15]
      }
      if fea == 15 {
        let (v, p) = decode_vbyte(source, data)
        data = p
        last = last + dezig(v)
        a = last
      }
      if feb == 15 {
        let (v, p) = decode_vbyte(source, data)
        data = p
        last = last + dezig(v)
        b = last
      }
      if fec == 15 {
        let (v, p) = decode_vbyte(source, data)
        data = p
        last = last + dezig(v)
        c = last
      }
      write_index(target, tri * 3, index_size, a)
      write_index(target, tri * 3 + 1, index_size, b)
      write_index(target, tri * 3 + 2, index_size, c)
      push_vertex(a, true)
      push_vertex(b, feb == 0 || feb == 15)
      push_vertex(c, fec == 0 || fec == 15)
      push_edge(b, a)
      push_edge(c, b)
      push_edge(a, c)
    }
    tri += 1
  }
  if data != data_safe_end {
    raise TrailingData("index stream has unread data")
  }
}

///|
/// Decode an index sequence written by `meshopt_encodeIndexSequence` into
/// `target` as little-endian `index_size`-byte (2 or 4) indices.
pub fn decode_index_sequence(
  target : FixedArray[Byte],
  index_count : Int,
  index_size : Int,
  source : BytesView,
) -> Unit raise MeshoptError {
  if index_count < 0 {
    raise InvalidArgument("index count must not be negative")
  }
  if index_size != 2 && index_size != 4 {
    raise InvalidArgument("index size must be 2 or 4")
  }
  if target.length() < index_count * index_size {
    raise InvalidArgument("target is smaller than index_count * index_size")
  }
  let buffer_size = source.length()
  // Header, one byte per index and a 4-byte tail.
  if buffer_size < 1 + index_count + 4 {
    raise UnexpectedEnd("index sequence")
  }
  let header = source[0].to_int()
  if (header & 0xf0) != SEQUENCE_HEADER {
    raise InvalidHeader("not an index sequence")
  }
  let version = header & 0x0f
  if version > 1 {
    raise InvalidHeader("unsupported index codec version \{version}")
  }
  let mut data = 1
  // Each index reads at most 5 bytes and the 4-byte tail keeps them in range.
  let data_safe_end = buffer_size - 4
  let last : FixedArray[Int] = [0, 0]
  for i in 0..<index_count {
    if data >= data_safe_end {
      raise UnexpectedEnd("index sequence data")
    }
    let (v, p) = decode_vbyte(source, data)
    data = p
    let current = v & 1
    let index = last[current] +
      dezig((v.reinterpret_as_uint() >> 1).reinterpret_as_int())
    last[current] = index
    write_index(target, i, index_size, index)
  }
  if data != data_safe_end {
    raise TrailingData("index sequence has unread data")
  }
}
