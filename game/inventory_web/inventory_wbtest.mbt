///|
test "placement preview retains holes and does not mutate source footprints" {
  let item = @core.json_parse(
    "{\"source\":0,\"width\":2,\"height\":3,\"rotated\":false,\"cells\":[[0,0],[1,0],[0,1],[0,2]]}",
  )
  assert_eq(footprint(item, true), [(2, 0), (2, 1), (1, 0), (0, 0)])
  assert_eq(footprint(item, false), [(0, 0), (1, 0), (0, 1), (0, 2)])
}
