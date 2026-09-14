///|
/// Unit carries no counters, hierarchy or allocated debugger state in release builds.
pub type Control = Unit

///|
pub fn new_control() -> Control {
  ()
}
