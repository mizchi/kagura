///|
/// Decode one EXT_meshopt_compression / KHR_meshopt_compression bufferView.
/// `mode` is `ATTRIBUTES`, `TRIANGLES` or `INDICES` and `filter` is `NONE`,
/// `OCTAHEDRAL`, `QUATERNION`, `EXPONENTIAL` or `COLOR`, as named in the
/// extension. Returns `count * byte_stride` decoded bytes.
pub fn decode_gltf_buffer(
  count : Int,
  byte_stride : Int,
  source : BytesView,
  mode : String,
  filter : String,
) -> Bytes raise MeshoptError {
  if count < 0 || byte_stride <= 0 {
    raise InvalidArgument("count and byteStride must be positive")
  }
  // Reject counts the stream cannot hold before allocating the output, so a
  // bad `count` in the JSON cannot request a huge buffer. A vertex stream
  // spends at least one byte per block, an index buffer one per triangle and
  // an index sequence one per index; these are the C decoder's own minimums.
  let min_source = match mode {
    "ATTRIBUTES" if byte_stride <= 256 && byte_stride % 4 == 0 => {
      let block = vertex_block_size(byte_stride)
      1 + (count + block - 1) / block + TAIL_MIN_SIZE_V1
    }
    "TRIANGLES" => 1 + count / 3 + 16
    "INDICES" => 1 + count + 4
    _ => 0
  }
  if source.length() < min_source || count > 0x7fffffff / byte_stride {
    raise UnexpectedEnd("stream is too short for count \{count}")
  }
  let target = FixedArray::make(count * byte_stride, (0 : Byte))
  match mode {
    "ATTRIBUTES" => {
      decode_vertex_buffer(target, count, byte_stride, source)
      match filter {
        "NONE" => ()
        "OCTAHEDRAL" => decode_filter_oct(target, count, byte_stride)
        "QUATERNION" => decode_filter_quat(target, count, byte_stride)
        "EXPONENTIAL" => decode_filter_exp(target, count, byte_stride)
        "COLOR" => decode_filter_color(target, count, byte_stride)
        _ => raise InvalidArgument("unknown filter \{filter}")
      }
    }
    "TRIANGLES" => {
      if filter != "NONE" {
        raise InvalidArgument("filters apply to ATTRIBUTES only")
      }
      decode_index_buffer(target, count, byte_stride, source)
    }
    "INDICES" => {
      if filter != "NONE" {
        raise InvalidArgument("filters apply to ATTRIBUTES only")
      }
      decode_index_sequence(target, count, byte_stride, source)
    }
    _ => raise InvalidArgument("unknown mode \{mode}")
  }
  Bytes::from_array(target[:])
}
