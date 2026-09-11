///|
/// Renderer-independent inspection data; never a second authoring document.
pub(all) struct Node {
  id : String
  name : String
  kind : String
  generated : Bool
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
