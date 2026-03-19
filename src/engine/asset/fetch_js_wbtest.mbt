///|
/// Test helpers: populate the global fetch buffer synchronously for unit testing.

///|
extern "js" fn js_test_set_fetch_buf(
  fetch_id : Int,
  b0 : Int,
  b1 : Int,
  b2 : Int,
  b3 : Int,
) -> Unit =
  #| (id, b0, b1, b2, b3) => {
  #|   if (!globalThis.__kagura_fetch) globalThis.__kagura_fetch = {};
  #|   globalThis.__kagura_fetch[id] = new Uint8Array([b0, b1, b2, b3]);
  #| }

///|
extern "js" fn js_test_has_fetch_buf(fetch_id : Int) -> Bool =
  #| (id) => {
  #|   return !!(globalThis.__kagura_fetch && globalThis.__kagura_fetch[id]);
  #| }

///|
test "js_fetch_buf_byte reads individual bytes" {
  js_test_set_fetch_buf(9000, 0xCA, 0xFE, 0xBA, 0xBE)
  assert_eq(js_fetch_buf_byte(9000, 0), 0xCA)
  assert_eq(js_fetch_buf_byte(9000, 1), 0xFE)
  assert_eq(js_fetch_buf_byte(9000, 2), 0xBA)
  assert_eq(js_fetch_buf_byte(9000, 3), 0xBE)
}

///|
test "js_fetch_buf_clear removes buffer" {
  js_test_set_fetch_buf(9001, 1, 2, 3, 4)
  assert_true(js_test_has_fetch_buf(9001))
  js_fetch_buf_clear(9001)
  assert_true(not(js_test_has_fetch_buf(9001)))
}

///|
test "fetch_id_counter increments on each call" {
  let before = fetch_id_counter.val
  fetch_bytes("data:application/octet-stream;base64,AQIDBA==", fn(_r) {  })
  assert_eq(fetch_id_counter.val, before + 1)
  fetch_bytes("data:application/octet-stream;base64,AQIDBA==", fn(_r) {  })
  assert_eq(fetch_id_counter.val, before + 2)
}

///|
test "fetch_bytes smoke test with data URL does not throw" {
  fetch_bytes("data:application/octet-stream;base64,AQIDBA==", fn(_result) {  })
}

///|
test "fetch_image smoke test with data URL does not throw" {
  let url = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVQI12NgAAIABQABNjN9GQAAAABJRU5ErkJggg=="
  fetch_image(url, fn(_result) {  })
}

///|
test "fetch_bytes smoke test with invalid URL does not throw" {
  fetch_bytes("http://0.0.0.0:1/__nonexistent__", fn(_result) {  })
}
