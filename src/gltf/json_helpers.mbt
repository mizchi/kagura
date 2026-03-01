///|
fn json_get(obj : Json, key : String) -> Json? {
  match obj {
    Object(map) => map.get(key)
    _ => None
  }
}

///|
fn json_string(val : Json) -> String {
  match val {
    String(s) => s
    _ => ""
  }
}

///|
fn json_int(val : Json) -> Int {
  match val {
    Number(n, ..) => n.to_int()
    _ => 0
  }
}

///|
fn json_double(val : Json) -> Double {
  match val {
    Number(n, ..) => n
    _ => 0.0
  }
}

///|
fn json_int_opt(val : Json) -> Int? {
  match val {
    Number(n, ..) => Some(n.to_int())
    _ => None
  }
}

///|
fn json_array(val : Json) -> Array[Json] {
  match val {
    Array(arr) => arr
    _ => []
  }
}

///|
fn json_get_int(obj : Json, key : String, default_ : Int) -> Int {
  match json_get(obj, key) {
    Some(v) => json_int(v)
    None => default_
  }
}

///|
fn json_get_string(obj : Json, key : String, default_ : String) -> String {
  match json_get(obj, key) {
    Some(v) => json_string(v)
    None => default_
  }
}

///|
fn json_get_array(obj : Json, key : String) -> Array[Json] {
  match json_get(obj, key) {
    Some(v) => json_array(v)
    None => []
  }
}
