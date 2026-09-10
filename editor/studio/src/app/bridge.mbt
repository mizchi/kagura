///|
/// Browser effects only. The host cannot write Session directly.
extern "js" fn input_value(id : String) -> String =
  #| (id) => document.getElementById(id).value

///|
extern "js" fn input_number(id : String) -> Double =
  #| (id) => document.getElementById(id).valueAsNumber

///|
extern "js" fn host_action(name : String, data : String) -> Unit =
  #| (name, data) => globalThis.kaguraHost(name, data)

///|
extern "js" fn notify_snapshot(source : String) -> Unit =
  #| (source) => globalThis.dispatchEvent(new CustomEvent('kagura:change', { detail: JSON.parse(source) }))

///|
extern "js" fn pretty(source : String) -> String =
  #| (source) => JSON.stringify(JSON.parse(source), null, 2)

///|
extern "js" fn color_string(color : Int) -> String =
  #| (color) => '#' + color.toString(16).padStart(6, '0')

///|
extern "js" fn color_number(id : String) -> Int =
  #| (id) => parseInt(document.getElementById(id).value.slice(1), 16)
