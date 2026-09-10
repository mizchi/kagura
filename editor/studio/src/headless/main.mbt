///|
/// Keep JS exceptions at the FFI boundary; never expose MoonBit's Result representation.
extern "js" fn invalid_document(message : String) -> @editor.Editor =
  #| (message) => { throw new Error(message); }

///|
/// Export an opaque instance, rather than a process-global editor singleton.
pub fn create(source : String) -> @editor.Editor {
  try {
    if source == "" {
      @editor.Editor::new()
    } else {
      @editor.Editor::from_document(@json.parse(source))
    }
  } catch {
    @editor.EditorError::Invalid(message) => invalid_document(message)
    _ => invalid_document("Malformed initial scene document")
  }
}

///|
pub fn snapshot(editor : @editor.Editor) -> String {
  editor.snapshot().stringify()
}

///|
pub fn request(editor : @editor.Editor, source : String) -> String {
  editor.request(source).stringify()
}
