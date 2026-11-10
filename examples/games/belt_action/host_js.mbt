///|
fn install_platform() -> Unit {
  @hooks.install("#app")
}

///|
extern "js" fn install_host(
  snapshot : () -> String,
  input : (Double, Double, Bool, Bool, Bool) -> Unit,
  command : (String) -> Unit,
) -> Unit =
  #| (snapshot, input, command) => {
  #|   fetch("assets/host.mjs").then(r => { if (!r.ok) throw Error(`AFTERSHIFT host: ${r.status}`); return r.text(); })
  #|     .then(async text => { const url = URL.createObjectURL(new Blob([text], {type:"text/javascript"}));
  #|       try { (await import(url)).install({snapshot: () => JSON.parse(snapshot()), input, command}); }
  #|       finally { URL.revokeObjectURL(url); } })
  #|     .catch(error => { console.error(error); document.body.append(Object.assign(document.createElement("pre"), {textContent: String(error)})); });
  #| }

///|
fn App::register_inspection(self : App) -> Unit {
  self.control.register_fields(
    game="belt_action",
    scope=() => {
      self.control.scope("belt_action") + ":" + self.game.stage.to_string()
    },
    subjects=() => tuning_subjects(self.game),
    state=() => @json.parse(self.game.snapshot()) catch { _ => Json::null() },
    pause=value => {
      self.control.set_paused(value)
      self.web = @sim.idle_input()
      self.queued = @sim.idle_input()
      self.previous = -1
      self.accumulator = 0
    },
    edit=(subject, field, value) => {
      self.game.apply_tuning(subject, field, value)
    },
  )
}
