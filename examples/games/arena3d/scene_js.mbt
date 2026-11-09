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
  pause : (Bool) -> Unit,
  paused : () -> Bool,
  observe : () -> String,
  fields : () -> String,
  edit : (String, String, Double, Int32, String) -> String,
) -> Unit =
  #| (snapshot, transition, hierarchy, pause, paused, observe, fields, edit) => {
  #|   globalThis.kaguraSceneRuntime = {
  #|     apiVersion: 1, game: "arena3d",
  #|     hierarchy: () => JSON.parse(hierarchy()),
  #|     snapshot: () => JSON.parse(snapshot()),
  #|     observe: () => JSON.parse(observe()),
  #|     transition: id => { const error = transition(id); if(error) throw Error(error); return JSON.parse(snapshot()); },
  #|     pause: value => { if(typeof value !== "boolean") throw Error("Expected pause boolean"); pause(value); },
  #|     paused,
  #|     fieldEditor: {
  #|       apiVersion: 1, game: "arena3d", read: () => JSON.parse(fields()),
  #|       pause: value => { if(typeof value !== "boolean") throw Error("Expected pause boolean"); pause(value); },
  #|       edit: (command, token) => {
  #|         if (typeof command?.subject !== "string" || typeof command?.field !== "string" ||
  #|             !Number.isFinite(command.value) || typeof token?.scope !== "string" ||
  #|             !Number.isInteger(token.revision) || token.revision < 0 || token.revision > 0x7fffffff)
  #|           throw Error("Invalid runtime field edit");
  #|         const error = edit(command.subject, command.field, command.value, token.revision, token.scope);
  #|         if (error) throw Error(error);
  #|       },
  #|     },
  #|   };
  #| }

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
    paused => self.set_inspection_paused(paused),
    () => self.inspection_paused,
    () => self.runtime_observation(),
    () => self.runtime_fields(),
    (subject, field, value, revision, scope) => {
      try {
        self.edit_runtime_field(subject, field, value, revision, scope)
        ""
      } catch {
        error => error.to_string()
      }
    },
  )
}
