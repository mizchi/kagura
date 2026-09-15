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
