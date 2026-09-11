///|
test "2D layout rejects invalid IDs and dimensions before a runtime uses them" {
  let object : Element = { id: "rect", name: "Rect", kind: "rect", x: 0.0, y: 0.0, width: 12.0, height: 12.0, color: 0xff0000 }
  let document : Document = { coordinates: "pixels-y-down", width: 320, height: 240, background: 0, objects: [object] }
  document.validate()
  for invalid in [
    { ..document, objects: [{ ..object, id: "9bad" }] },
    { ..document, objects: [{ ..object, kind: "bad kind" }] },
    { ..document, objects: [{ ..object, width: 0.0 }] },
    { ..document, objects: [object, object] },
    { ..document, width: 0 },
  ] {
    let rejected = try { invalid.validate(); false } catch { _ => true }
    assert_true(rejected)
  }
}
