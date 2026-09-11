///|
extern "js" fn register_js(
  game : String,
  schema : String,
  version : Int,
  invoke : (String, String) -> String,
  scene : (() -> String)?,
  hierarchy : (() -> String)?,
) -> Unit =
  #| (game, schema, version, invoke, scene, hierarchy) => {
  #|   const call = (op, value = null) => {
  #|     const response = JSON.parse(invoke(op, JSON.stringify(value)));
  #|     if (!response.ok) throw Error(response.error);
  #|     return response.value;
  #|   };
  #|   globalThis.kaguraDebugAdapter = {
  #|     apiVersion: 1, game, schema: {id: schema, version},
  #|     read: () => call('read'), pause: value => call('pause', value),
  #|     step: () => call('step'), replace: state => call('replace', state),
  #|     inspector: { describe: state => call('describe', state), reduce: (state, edit) => call('reduce', [state, edit]) }
  #|   };
  #|   globalThis.kaguraSceneRuntime = { apiVersion: 1, game,
  #|     ...(scene ? { snapshot: () => JSON.parse(scene()) } : {}),
  #|     ...(hierarchy ? { hierarchy: () => JSON.parse(hierarchy()) } : {})
  #|   };
  #| }

///|
/// Call from a debug-only entry file. The iframe owns registration lifetime.
/// This API is available in JS release builds too: it does not strip itself.
/// Exclude the caller and its bindings with moon.pkg targets; release entry points
/// must not reference them. Verify each game's output with an artifact removal gate.
/// See game/inspection/README.md for build profiles and the current guarantee scope.
pub fn[S : FromJson + ToJson] Runtime::register(
  self : Runtime[S],
  scene? : () -> String,
  hierarchy? : () -> String,
) -> Unit {
  register_js(
    self.game,
    self.schema,
    self.version,
    (op, data) => self.invoke(op, data),
    scene,
    hierarchy,
  )
}
