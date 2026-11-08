///|
test "render layouts reject custom strides instead of rounding them down" {
  for stride in [0, 4, 8, 16] {
    validate_vertex_stride(stride)
  }
  for stride in [-1, 3, 12, 20] {
    let rejected = try {
      validate_vertex_stride(stride)
      false
    } catch {
      UnsupportedVertexStride(actual) => actual == stride
    }
    assert_true(rejected)
  }
}
