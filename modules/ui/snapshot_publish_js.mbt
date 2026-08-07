///|
/// Publish a UI snapshot to the browser global the verification tooling reads.
///
/// `globalThis.__kaguraUISnapshot` mirrors the shape of
/// `__kaguraModelingContext` (`{ json, parsed }`) so the same Playwright /
/// capture drivers work for both. Parsing is best-effort: a driver that only
/// forwards the document to a gate wants the raw string, so a parse failure
/// must not lose it.
///
/// JS target only — see `targets` in `moon.pkg`.

///|
extern "js" fn js_publish_ui_snapshot(json : String) -> Unit =
  #| (json) => {
  #|   let parsed = null;
  #|   try {
  #|     parsed = JSON.parse(json);
  #|   } catch (_err) {}
  #|   globalThis.__kaguraUISnapshot = { json, parsed };
  #| };

///|
pub fn publish_ui_snapshot(snapshot : UISnapshot) -> Unit {
  js_publish_ui_snapshot(snapshot.to_json())
}
