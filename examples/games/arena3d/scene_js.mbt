///|
extern "js" fn editor_scene_source() -> String =
  #| () => {
  #|   if (globalThis.__kaguraScene?.game !== "arena3d") return "";
  #|   return JSON.stringify(globalThis.__kaguraSceneProject ?? {entry:"preview",scenes:[{id:"preview",data:globalThis.__kaguraScene.data}]});
  #| }

///|
extern "js" fn register_scene_runtime(
  snapshot : () -> String,
  transition : (String) -> String,
  hierarchy : () -> String,
) -> Unit =
  #| (snapshot, transition, hierarchy) => { globalThis.kaguraSceneRuntime = {apiVersion:1,game:"arena3d",hierarchy:()=>JSON.parse(hierarchy()),snapshot:()=>JSON.parse(snapshot()),transition:id=>{const error=transition(id);if(error)throw Error(error);return JSON.parse(snapshot());}}; }

///|
fn GameState::load_editor_scene(self : GameState) -> Unit {
  let source = editor_scene_source()
  if source == "" {
    self.load_default_scene()
  } else {
    self.apply_scene_project(source) catch {
      error => abort(error.to_string())
    }
  }
  register_scene_runtime(
    () => self.scene_snapshot(),
    id => {
      try {
        self.transition_scene(id)
        ""
      } catch {
        error => error.to_string()
      }
    },
    () => self.scene_hierarchy(),
  )
}
