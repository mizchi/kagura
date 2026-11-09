///|
extern "js" fn register_fields_js(
  game : String,
  read : () -> String,
  observe : () -> String,
  pause : (Bool) -> Unit,
  edit : (String, String, Double, Int32, String) -> String,
) -> Unit =
  #| (game, read, observe, pause, edit) => {
  #|   const previous = globalThis.kaguraSceneRuntime;
  #|   if (previous && (previous.apiVersion !== 1 || previous.game !== game)) throw Error("Runtime identity mismatch");
  #|   const setPaused = value => { if (typeof value !== "boolean") throw Error("Expected pause boolean"); pause(value); };
  #|   globalThis.kaguraSceneRuntime = Object.freeze({ ...previous, apiVersion: 1, game,
  #|     observe: () => JSON.parse(observe()), pause: setPaused, paused: () => JSON.parse(read()).paused,
  #|     fieldEditor: Object.freeze({apiVersion: 1, game, read: () => JSON.parse(read()), pause: setPaused,
  #|       edit: (command, token) => {
  #|         if (typeof command?.subject !== "string" || typeof command?.field !== "string" ||
  #|             !Number.isFinite(command.value) || typeof token?.scope !== "string" ||
  #|             !Number.isInteger(token.revision) || token.revision < 0 || token.revision > 0x7fffffff)
  #|           throw Error("Invalid runtime field edit");
  #|         const error = edit(command.subject, command.field, command.value, token.revision, token.scope);
  #|         if (error) throw Error(error);
  #|       }
  #|     })
  #|   });
  #| }

///|
/// Register inside the game iframe. Game callbacks own input reset and atomic validation.
pub fn FieldControl::register_fields(
  self : FieldControl,
  game~ : String,
  scope~ : () -> String,
  subjects~ : () -> Array[Subject],
  state~ : () -> Json,
  pause~ : (Bool) -> Unit,
  edit~ : (String, String, Double) -> Unit raise,
) -> Unit {
  register_fields_js(
    game,
    () => self.fields_json(scope(), subjects()),
    () => self.observation_json(state(), scope(), subjects()),
    pause,
    (subject, field, value, revision, token_scope) => {
      try {
        self.commit(revision, token_scope, scope(), () => {
          edit(subject, field, value)
        })
        ""
      } catch {
        error => error.to_string()
      }
    },
  )
}
