///| Parse a .glb (Binary glTF) file into JSON string and binary buffer(s).
///
/// GLB format:
/// - 12-byte header: magic(0x46546C67) + version(2) + total_length
/// - Chunks: length(4) + type(4) + data
///   - JSON chunk type: 0x4E4F534A
///   - BIN chunk type:  0x004E4942
pub fn parse_glb(data : Bytes) -> (String, Array[Bytes]) raise GltfError {
  if data.length() < 12 {
    raise GltfError::ParseError("GLB data too short for header")
  }
  let magic = read_u32_le(data, 0)
  if magic != 0x46546C67 {
    raise GltfError::ParseError("invalid GLB magic number")
  }
  let version = read_u32_le(data, 4)
  if version != 2 {
    raise GltfError::ParseError("unsupported GLB version: " + version.to_string())
  }
  let total_length = read_u32_le(data, 8)
  if data.length() < total_length {
    raise GltfError::ParseError("GLB data shorter than declared length")
  }
  // Parse chunks
  let mut offset = 12
  let mut json_str : String? = None
  let buffers : Array[Bytes] = []
  while offset + 8 <= total_length {
    let chunk_length = read_u32_le(data, offset)
    let chunk_type = read_u32_le(data, offset + 4)
    let chunk_data_start = offset + 8
    let chunk_data_end = chunk_data_start + chunk_length
    if chunk_data_end > total_length {
      raise GltfError::ParseError("GLB chunk exceeds file bounds")
    }
    if chunk_type == 0x4E4F534A {
      // JSON chunk - decode bytes to string
      let chars : Array[Char] = []
      for i in chunk_data_start..<chunk_data_end {
        chars.push(data[i].to_int().unsafe_to_char())
      }
      json_str = Some(String::from_array(chars))
    } else if chunk_type == 0x004E4942 {
      // BIN chunk - copy bytes via Array
      let bin_bytes : Array[Byte] = []
      for i in 0..<chunk_length {
        bin_bytes.push(data[chunk_data_start + i])
      }
      buffers.push(Bytes::from_array(bin_bytes[:]))
    }
    // else: skip unknown chunk types
    offset = chunk_data_end
  }
  match json_str {
    Some(s) => (s, buffers)
    None => raise GltfError::ParseError("GLB missing JSON chunk")
  }
}
