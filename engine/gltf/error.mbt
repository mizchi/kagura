///|
suberror GltfError {
  ParseError(String)
  InvalidAccessor(String)
  InvalidBufferView(String)
  UnsupportedComponentType(Int32)
  UnsupportedMode(Int32)
  BufferOutOfRange(Int32)
  MissingAttribute(String)
  CompressionError(String)
}
