// Native stubs for save/load (no localStorage on native)

fn js_storage_set(_key : String, _value : String) -> Unit {
}

fn js_storage_get(_key : String) -> String {
  ""
}

fn js_storage_remove(_key : String) -> Unit {
}
