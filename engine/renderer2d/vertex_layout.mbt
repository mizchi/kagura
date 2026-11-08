///|
pub suberror VertexLayoutError {
  UnsupportedVertexStride(Int32)
}

///|
/// Supported layouts are xy/uv (4), xyz/normal/uv (8), and skinned (16).
/// Zero preserves the legacy shader-inference contract. Other layouts require
/// a future explicit attribute descriptor; never truncate them to a preset.
pub fn validate_vertex_stride(stride : Int32) -> Unit raise VertexLayoutError {
  match stride {
    0 | 4 | 8 | 16 => ()
    _ => raise UnsupportedVertexStride(stride)
  }
}
