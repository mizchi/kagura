///|
fn hex_bytes(s : String) -> Bytes {
  let digit = fn(c : Char) -> Int {
    let v = c.to_int()
    if v >= 'a'.to_int() {
      v - 'a'.to_int() + 10
    } else {
      v - '0'.to_int()
    }
  }
  let chars = s.to_array()
  Bytes::makei(chars.length() / 2, fn(i) {
    (digit(chars[2 * i]) * 16 + digit(chars[2 * i + 1])).to_byte()
  })
}

///|
fn decode_fixture(
  f : Fixture,
  source : Bytes,
) -> Bytes raise @meshopt.MeshoptError {
  let (mode, filter) = match f.kind {
    "vertex" => ("ATTRIBUTES", "NONE")
    "oct" => ("ATTRIBUTES", "OCTAHEDRAL")
    "quat" => ("ATTRIBUTES", "QUATERNION")
    "exp" => ("ATTRIBUTES", "EXPONENTIAL")
    "color" => ("ATTRIBUTES", "COLOR")
    "index" => ("TRIANGLES", "NONE")
    _ => ("INDICES", "NONE")
  }
  @meshopt.decode_gltf_buffer(f.count, f.stride, source[:], mode, filter)
}

///|
fn raised(f : () -> Unit raise @meshopt.MeshoptError) -> @meshopt.MeshoptError? {
  try f() catch {
    e => Some(e)
  } noraise {
    _ => None
  }
}

///|
test "decoded bytes match the scalar C decoder" {
  for f in fixtures {
    let decoded = decode_fixture(f, hex_bytes(f.source))
    if decoded != hex_bytes(f.expected) {
      fail("\{f.name}: decoded bytes differ from the C decoder")
    }
  }
}

///|
test "filters can be applied separately from the vertex codec" {
  for f in fixtures {
    guard f.kind == "oct" else { continue }
    let target = FixedArray::make(f.count * f.stride, (0 : Byte))
    @meshopt.decode_vertex_buffer(
      target,
      f.count,
      f.stride,
      hex_bytes(f.source)[:],
    )
    @meshopt.decode_filter_oct(target, f.count, f.stride)
    assert_eq(Bytes::from_array(target[:]), hex_bytes(f.expected))
  }
}

///|
test "truncated streams are rejected" {
  for f in fixtures {
    let source = hex_bytes(f.source)
    for cut in [1, 2, source.length() / 2, source.length() - 1] {
      let shorter = source[:source.length() - cut].to_owned()
      guard raised(() => ignore(decode_fixture(f, shorter))) is Some(_) else {
        fail("\{f.name}: truncation by \{cut} bytes was not rejected")
      }
    }
  }
}

///|
test "extra bytes raise TrailingData" {
  for f in fixtures {
    let source = hex_bytes(f.source)
    let longer = Bytes::makei(source.length() + 1, fn(i) {
      if i < source.length() {
        source[i]
      } else {
        b'\x00'
      }
    })
    guard raised(() => ignore(decode_fixture(f, longer)))
      is Some(TrailingData(_)) else {
      fail("\{f.name}: trailing byte was not rejected")
    }
  }
}

///|
test "wrong headers and versions raise InvalidHeader" {
  let vertex = hex_bytes(fixtures[0].source)
  let wrong_version = Bytes::makei(vertex.length(), fn(i) {
    if i == 0 {
      b'\xa2'
    } else {
      vertex[i]
    }
  })
  let target = FixedArray::make(
    fixtures[0].count * fixtures[0].stride,
    (0 : Byte),
  )
  let r1 = raised(() => {
    @meshopt.decode_vertex_buffer(
      target,
      fixtures[0].count,
      fixtures[0].stride,
      wrong_version[:],
    )
  })
  assert_true(r1 is Some(InvalidHeader(_)))
  // An index stream handed to the vertex decoder.
  let index = fixtures.search_by(fn(f) { f.kind == "index" }).unwrap()
  let r2 = raised(() => {
    @meshopt.decode_vertex_buffer(
      target,
      fixtures[0].count,
      fixtures[0].stride,
      hex_bytes(fixtures[index].source)[:],
    )
  })
  assert_true(r2 is Some(InvalidHeader(_)))
}

///|
test "invalid arguments are rejected before reading the stream" {
  let source = hex_bytes(fixtures[0].source)
  let small = FixedArray::make(4, (0 : Byte))
  assert_true(
    raised(() => @meshopt.decode_vertex_buffer(small, 17, 12, source[:]))
    is Some(InvalidArgument(_)),
  )
  assert_true(
    raised(() => {
      ignore(
        @meshopt.decode_gltf_buffer(17, 12, source[:], "ATTRIBUTES", "BOGUS"),
      )
    })
    is Some(InvalidArgument(_)),
  )
  assert_true(
    raised(() => {
      ignore(
        @meshopt.decode_gltf_buffer(3, 4, source[:], "TRIANGLES", "OCTAHEDRAL"),
      )
    })
    is Some(InvalidArgument(_)),
  )
  assert_true(
    raised(() => @meshopt.decode_vertex_buffer(small, 1, 6, source[:]))
    is Some(InvalidArgument(_)),
  )
}

///|
test "zero-element streams decode to empty output" {
  // meshopt_encodeVertexBuffer(count=0, size=4) and
  // meshopt_encodeIndexBuffer(count=0) outputs.
  let vertex = hex_bytes("a1000000000000000000000000000000000000000000000000")
  let index = hex_bytes("e1007687566778a9866589689801690000")
  assert_eq(
    @meshopt.decode_gltf_buffer(0, 4, vertex[:], "ATTRIBUTES", "NONE").length(),
    0,
  )
  assert_eq(
    @meshopt.decode_gltf_buffer(0, 4, index[:], "TRIANGLES", "NONE").length(),
    0,
  )
}

///|
test "an impossible count is rejected before allocating" {
  let source = hex_bytes(fixtures[0].source)
  assert_true(
    raised(() => {
      ignore(
        @meshopt.decode_gltf_buffer(
          0x7fffffff,
          4,
          source[:],
          "ATTRIBUTES",
          "NONE",
        ),
      )
    })
    is Some(UnexpectedEnd(_)),
  )
  assert_true(
    raised(() => {
      ignore(
        @meshopt.decode_gltf_buffer(3000000, 4, source[:], "TRIANGLES", "NONE"),
      )
    })
    is Some(UnexpectedEnd(_)),
  )
}
