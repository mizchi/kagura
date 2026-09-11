///|
extern "js" fn editor_scene_source() -> String =
  #| () => globalThis.__kaguraScene?.game === "flappy_bird" ? JSON.stringify(globalThis.__kaguraScene.data) : ""

///|
extern "js" fn register_scene_runtime(
  snapshot : () -> String,
  hierarchy : () -> String,
) -> Unit =
  #| (snapshot, hierarchy) => { globalThis.kaguraSceneRuntime = {apiVersion:1, game:"flappy_bird", hierarchy:()=>JSON.parse(hierarchy()), snapshot:()=>JSON.parse(snapshot())}; }

///|
fn Game::load_editor_scene(self : Game) -> Unit {
  let source = editor_scene_source()
  if source != "" {
    self.apply_scene(@json.from_json(@json.parse(source))) catch {
      error => abort(error.to_string())
    }
  }
  register_scene_runtime(() => self.scene_snapshot(), () => {
    self.scene_hierarchy()
  })
  self.register_debug()
}

///|
fn Game::scene_snapshot(self : Game) -> String {
  let result : Json = {
    "layout": self.layout.to_json(),
    "birdY": self.bird_y.get().to_json(),
    "mode": self.game_mode.get().to_json(),
  }
  result.stringify()
}

///|
extern "js" fn register_debug_runtime(
  read : () -> String,
  pause : (Bool) -> Unit,
  step : () -> String,
  replace : (String) -> String,
) -> Unit =
  #| (read, pause, step, replace) => {
  #|   const checked = result => { const value = JSON.parse(result); if (!value.ok) throw Error(value.error); };
  #|   globalThis.kaguraDebugAdapter = {
  #|     apiVersion: 1, game: "flappy_bird", schema: {id: "flappy_bird.runtime", version: 1},
  #|     read: () => JSON.parse(read()), pause,
  #|     step: () => checked(step()), replace: state => checked(replace(JSON.stringify(state)))
  #|   };
  #| }

///|
fn Game::register_debug(self : Game) -> Unit {
  register_debug_runtime(
    fn() {
      let value : Json = {
        "revision": self.debug_revision.to_json(),
        "paused": self.debug_paused.to_json(),
        "state": self.debug_state().to_json(),
      }
      value.stringify()
    },
    paused => self.debug_pause(paused),
    fn() {
      let result : Json = try {
        self.debug_step()
        { "ok": true }
      } catch {
        error => { "ok": false, "error": error.to_string().to_json() }
      }
      result.stringify()
    },
    fn(source) {
      let result : Json = try {
        self.debug_replace(decode_debug_state(source))
        { "ok": true }
      } catch {
        error => { "ok": false, "error": error.to_string().to_json() }
      }
      result.stringify()
    },
  )
}
