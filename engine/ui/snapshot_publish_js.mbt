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

///|
extern "js" fn js_publish_ui_snapshot_lazy(build : () -> String) -> Unit =
  #| build => {
  #|   let state=globalThis.__kaguraLazyUISnapshot;
  #|   if (!state) {
  #|     state=globalThis.__kaguraLazyUISnapshot={build:null,value:undefined,dirty:false};
  #|     Object.defineProperty(globalThis,'__kaguraUISnapshot',{
  #|       configurable:true,
  #|       get() {
  #|         if (state.dirty) {
  #|           const json=state.build();
  #|           state.value={json,parsed:JSON.parse(json)};
  #|           state.dirty=false;
  #|         }
  #|         return state.value;
  #|       },
  #|       set(value) { state.value=value; state.dirty=false; state.build=null; }
  #|     });
  #|   }
  #|   state.build=build; state.dirty=true;
  #| }

///|
/// Register the latest frame's snapshot builder. Introspection through the
/// existing __kaguraUISnapshot envelope evaluates it once, on demand. A new
/// publication invalidates the cached envelope. Ordinary rendering builds no
/// snapshot; callers must keep captured state alive until the next publication.
pub fn publish_ui_snapshot_lazy(build : () -> UISnapshot) -> Unit {
  js_publish_ui_snapshot_lazy(fn() { build().to_json() })
}
