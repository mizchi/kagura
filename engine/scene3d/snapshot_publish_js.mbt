///|
/// Publishes a builder for the scene3d snapshot as
/// `globalThis.__kaguraScene3DSnapshot` (`{ json, parsed }`, the same shape as
/// `__kaguraUISnapshot`). The snapshot is built only when something reads the
/// global, so publishing every frame costs one closure.
///
/// JS target only; the native build has a no-op with the same signature.

///|
extern "js" fn js_publish_scene3d_snapshot_lazy(build : () -> String) -> Unit =
  #| build => {
  #|   let state=globalThis.__kaguraLazyScene3DSnapshot;
  #|   if (!state) {
  #|     state=globalThis.__kaguraLazyScene3DSnapshot={build:null,value:undefined,dirty:false};
  #|     Object.defineProperty(globalThis,'__kaguraScene3DSnapshot',{
  #|       configurable:true,
  #|       get() {
  #|         if (state.dirty) {
  #|           const json=state.build();
  #|           let parsed=null;
  #|           try { parsed=JSON.parse(json); } catch (_err) {}
  #|           state.value={json,parsed};
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
pub fn publish_scene3d_snapshot_lazy(build : () -> Scene3DSnapshot) -> Unit {
  js_publish_scene3d_snapshot_lazy(fn() { build().to_json().stringify() })
}
