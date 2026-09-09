///|
suberror GltfError {
  ParseError(String)
  InvalidAccessor(String)
  InvalidBufferView(String)
  UnsupportedComponentType(Int)
  UnsupportedMode(Int)
  BufferOutOfRange(Int)
  MissingAttribute(String)
}
