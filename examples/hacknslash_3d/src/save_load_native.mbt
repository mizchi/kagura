// Native stubs for save/load (no localStorage on native)

///|
fn js_storage_set(_key : String, _value : String) -> Unit {

}

///|
fn js_storage_get(_key : String) -> String {
  ""
}

///|
fn js_storage_remove(_key : String) -> Unit {

}

///|
fn GameState::save_game(_self : GameState) -> Unit {

}

///|
fn GameState::load_game(_self : GameState) -> Bool {
  false
}

///|
fn GameState::delete_save(_self : GameState) -> Unit {

}
