///|
test "kawaiiko is a validated editable mesh document" {
  let doc = kawaiiko_document()
  validate_document(doc)
  assert_true(doc.nodes.length() >= 15)
  assert_true(doc.nodes.any(n => n.id == "beak"))
  assert_true(doc.nodes.any(n => n.id == "backpack"))
  let decoded : ModelDocument = @json.from_json(ToJson::to_json(doc))
  assert_eq(decoded, doc)
}

///|
test "modal edits cancel exactly and commit as one undo step" {
  let e = ModelEditor::new()
  let initial = e.document
  e.handle({ "op": "select", "id": "head" })
  e.handle({ "op": "begin", "kind": "move" })
  e.handle({ "op": "preview", "value": [1, 0, 0] })
  e.handle({ "op": "preview", "value": [2, 0, 0] })
  assert_eq(e.revision, 0)
  e.handle({ "op": "cancel" })
  assert_eq(e.document, initial)
  e.handle({ "op": "begin", "kind": "move" })
  e.handle({ "op": "preview", "value": [2, 0, 0] })
  e.handle({ "op": "confirm" })
  assert_eq(e.revision, 1)
  e.handle({ "op": "undo" })
  assert_eq(e.document, initial)
  e.handle({ "op": "redo" })
  assert_eq(e.document.nodes[1].position[0], 2.0)
}

///|
test "extrusion creates a connected cap and side faces and is undoable" {
  let e = ModelEditor::new()
  e.handle({ "op": "add", "kind": "cube" })
  let initial = e.document
  e.handle({ "op": "mode", "value": "face" })
  e.handle({ "op": "face", "index": 0 })
  e.handle({ "op": "begin", "kind": "extrude" })
  e.handle({ "op": "preview", "value": [0, 0, 0.5] })
  e.handle({ "op": "confirm" })
  let n = e.document.nodes[e.document.nodes.length() - 1]
  assert_eq(n.vertices.length(), 12)
  assert_eq(n.faces.length(), 10)
  validate_document(e.document)
  e.handle({ "op": "undo" })
  assert_eq(e.document, initial)
}
