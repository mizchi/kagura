///|
/// Decode every EXT_meshopt_compression / KHR_meshopt_compression bufferView
/// into a new buffer appended after `buffers`, and point the view at it.
/// The rest of the loader then reads compressed and plain files the same way.
/// The view's own `buffer` is the extension's fallback buffer, which a GLB
/// written by gltfpack leaves without data, so it is never read.
fn decompress_buffer_views(
  doc : GltfDocument,
  buffers : Array[Bytes],
) -> (GltfDocument, Array[Bytes]) raise GltfError {
  if doc.buffer_views.iter().all(v => v.compressed is None) {
    return (doc, buffers)
  }
  let out_buffers = buffers.copy()
  let views : Array[GltfBufferView] = []
  for v in doc.buffer_views {
    guard v.compressed is Some(c) else {
      views.push(v)
      continue
    }
    if c.buffer < 0 || c.buffer >= buffers.length() {
      raise GltfError::BufferOutOfRange(c.buffer)
    }
    let source = buffers[c.buffer]
    if c.byte_offset < 0 ||
      c.byte_length < 0 ||
      c.byte_offset + c.byte_length > source.length() {
      raise GltfError::InvalidBufferView(
        "compressed range exceeds buffer " + c.buffer.to_string(),
      )
    }
    let decoded = @meshopt.decode_gltf_buffer(
      c.count,
      c.byte_stride,
      source[c.byte_offset:c.byte_offset + c.byte_length],
      c.mode,
      c.filter,
    ) catch {
      e => raise GltfError::CompressionError(e.to_string())
    }
    out_buffers.push(decoded)
    views.push({
      buffer: out_buffers.length() - 1,
      byte_offset: 0,
      byte_stride: v.byte_stride,
      compressed: None,
    })
  }
  ({ ..doc, buffer_views: views, }, out_buffers)
}
