///|
test "VertexFormat::standard_3d stride is 8" {
  assert_eq(VertexFormat::standard_3d().stride(), 8)
}

///|
test "VertexFormat::skinned_3d stride is 16" {
  assert_eq(VertexFormat::skinned_3d().stride(), 16)
}

///|
test "VertexFormat::standard_3d matches vertex3d_stride" {
  assert_eq(VertexFormat::standard_3d().stride(), vertex3d_stride)
}

///|
test "VertexFormat::offset_of" {
  let fmt = VertexFormat::standard_3d()
  assert_eq(fmt.offset_of(Position3), 0)
  assert_eq(fmt.offset_of(Normal3), 3)
  assert_eq(fmt.offset_of(TexCoord2), 6)
  assert_eq(fmt.offset_of(Joints4), -1)
}

///|
test "VertexFormat::has" {
  let std = VertexFormat::standard_3d()
  assert_true(std.has(Position3))
  assert_true(std.has(Normal3))
  assert_true(std.has(TexCoord2))
  assert_false(std.has(Joints4))
  assert_false(std.has(Weights4))
  let skinned = VertexFormat::skinned_3d()
  assert_true(skinned.has(Joints4))
  assert_true(skinned.has(Weights4))
}

///|
test "VertexFormat::skinned_3d offset_of" {
  let fmt = VertexFormat::skinned_3d()
  assert_eq(fmt.offset_of(Position3), 0)
  assert_eq(fmt.offset_of(Normal3), 3)
  assert_eq(fmt.offset_of(TexCoord2), 6)
  assert_eq(fmt.offset_of(Joints4), 8)
  assert_eq(fmt.offset_of(Weights4), 12)
}
