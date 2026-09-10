///|
/// Controlled component: its source of truth remains in the editor document.
pub fn mount_switch(
  target : @browser.Element,
  label : String,
  value : Bool,
  set_value : (Bool) -> Unit,
) -> SwitchControl {
  let state = @signals.signal(value)
  let props = @controls.use_switch_computed(
    fn() { state.get() },
    set_value,
    aria_label=label,
  )
  let vnode : @luna.Node[@js.Any, String] = @luna.h(
    "button",
    props.attrs + [("type", @luna.attr_static("button"))],
    [@luna.text(label)],
  )
  { state, dispose: @client.render_vnode(target, vnode) }
}

///|
pub struct SwitchControl {
  state : @signals.Signal[Bool]
  dispose : () -> Unit
}

///|
pub fn update_switch(control : SwitchControl, value : Bool) -> Unit {
  control.state.set(value)
}

///|
pub fn dispose_switch(control : SwitchControl) -> Unit {
  (control.dispose)()
}
