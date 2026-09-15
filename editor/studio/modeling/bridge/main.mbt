///|
pub fn create() -> @model.ModelEditor {
  @model.ModelEditor::new()
}

///|
pub fn snapshot(editor : @model.ModelEditor) -> String {
  editor.snapshot().stringify()
}

///|
pub fn request(editor : @model.ModelEditor, source : String) -> String {
  editor.request(source)
}

///|
pub fn kawaiiko() -> String {
  ToJson::to_json(@model.kawaiiko_document()).stringify()
}

///|
pub fn evaluate(document : String, weights : String) -> String {
  try {
    let doc = @model.decode_document(@json.parse(document))
    let weights : Map[String, Double] = @json.from_json(@json.parse(weights))
    (
      {
        "ok": true,
        "document": ToJson::to_json(@model.evaluate_expressions(doc, weights)),
      } : Json).stringify()
  } catch {
    _ => "{\"ok\":false,\"error\":\"Invalid expression document or weights\"}"
  }
}
