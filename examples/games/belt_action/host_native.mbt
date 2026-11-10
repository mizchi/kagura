///|
fn install_platform() -> Unit {
  ()
}

///|
fn install_host(
  _snapshot : () -> String,
  _input : (Double, Double, Bool, Bool, Bool) -> Unit,
  _command : (String) -> Unit,
) -> Unit {
  ()
}

///|
fn App::register_inspection(_self : App) -> Unit {
  ()
}
