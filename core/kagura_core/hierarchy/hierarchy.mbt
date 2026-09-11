///|
/// Renderer-independent inspection data; never a second authoring document.
pub(all) struct Node {
  id : String
  name : String
  kind : String
  generated : Bool
  subject : String?
  children : Array[Node]
} derive(ToJson)

///|
/// Keys are scoped to siblings. Slash is reserved for the resolved hierarchy path.
pub fn valid_key(key : String) -> Bool {
  key.length() > 0 &&
  key.length() <= 128 &&
  key
  .iter()
  .all(c => {
    (c >= 'a' && c <= 'z') ||
    (c >= 'A' && c <= 'Z') ||
    (c >= '0' && c <= '9') ||
    c == '_' ||
    c == '-' ||
    c == '.'
  })
}

///|
/// Logical state identity is independent of render keys and may include an incarnation suffix.
pub fn valid_subject(id : String) -> Bool {
  id.length() > 0 &&
  id.length() <= 128 &&
  id
  .iter()
  .all(c => {
    (c >= 'a' && c <= 'z') ||
    (c >= 'A' && c <= 'Z') ||
    (c >= '0' && c <= '9') ||
    c == '_' ||
    c == '-' ||
    c == '.' ||
    c == ':'
  })
}
