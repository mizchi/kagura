///|
let sample_snapshot : String =
  #|{"schema":"kagura.scene3d-snapshot","version":1,"camera":null,"nodes":[
  #|{"path":"a","kind":"mesh","subject":"player","position":[0,0,0],"rotation":[0,0,0,1],"scale":[1,1,1],
  #| "box":{"center":[0,0,0],"half_extents":[0.5,0.5,0.5],"rotation":[0,0,0,1]}},
  #|{"path":"b","kind":"mesh","subject":"enemy","position":[3,0,0],"rotation":[0,0,0,1],"scale":[1,1,1],
  #| "box":{"center":[3,0,0],"half_extents":[0.5,0.5,0.5],"rotation":[0,0,0,1]}}]}

///|
test "distance report names both nodes and the gap" {
  let request =
    #|{"operation":"distance","paths":["a","b"]}
  let reply = @json.parse(analyze_scene3d(request, sample_snapshot))
  guard reply
    is Object(
      { "ok": True, "text": String(text), "exitCode": Number(0.0, ..), .. }
    ) else {
    fail(reply.stringify())
  }
  // Facing faces have no unique closest pair, so only the gap is fixed.
  assert_true(text.has_prefix("distance 2 between a at (0.5, "))
}

///|
test "a clean check exits 0, a broken document reports why" {
  let request =
    #|{"operation":"check"}
  let ok = @json.parse(analyze_scene3d(request, sample_snapshot))
  assert_true(ok is Object({ "exitCode": Number(0.0, ..), .. }))
  let bad = @json.parse(analyze_scene3d(request, "{\"schema\":\"other\"}"))
  guard bad is Object({ "ok": False, "error": String(error), .. }) else {
    fail(bad.stringify())
  }
  assert_true(error.contains("schema"))
}
