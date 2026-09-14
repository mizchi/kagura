///|
/// Factories construct fresh game state. They do not perform scene transitions.
pub struct InitialStates[T] {
  default_factory : (Int, Int) -> T
  named : Array[(String, (Int, Int) -> T)]
}

///|
pub suberror InitialStateError {
  InitialStateError(String)
}

///|
fn valid_initial_state_name(name : String) -> Bool {
  if name.is_empty() || name.length() > 128 {
    return false
  }
  for ch in name {
    let n = ch.to_int()
    if !((n >= 65 && n <= 90) ||
      (n >= 97 && n <= 122) ||
      (n >= 48 && n <= 57) ||
      ch == '_' ||
      ch == '-') {
      return false
    }
  }
  true
}

///|
pub fn[T] InitialStates::new(
  default~ : (Int, Int) -> T,
  named? : Array[(String, (Int, Int) -> T)] = [],
) -> InitialStates[T] raise InitialStateError {
  let names : Array[String] = []
  if named.length() > 32 {
    raise InitialStateError("Too many initial states")
  }
  for (name, _) in named {
    if !valid_initial_state_name(name) || names.contains(name) {
      raise InitialStateError("Invalid or duplicate initial state: " + name)
    }
    names.push(name)
  }
  { default_factory: default, named: named.copy(), }
}

///|
pub fn[T] InitialStates::names(self : InitialStates[T]) -> Array[String] {
  self.named.map(entry => entry.0)
}

///|
/// No fallback for unknown names: callers must know which state they are testing.
pub fn[T] InitialStates::create(
  self : InitialStates[T],
  name : String?,
  width~ : Int,
  height~ : Int,
) -> T raise InitialStateError {
  if width < 1 || height < 1 {
    raise InitialStateError("Invalid initial viewport")
  }
  match name {
    None => (self.default_factory)(width, height)
    Some(name) => {
      for (key, make) in self.named {
        if key == name {
          return make(width, height)
        }
      }
      raise InitialStateError("Unknown initial state: " + name)
    }
  }
}

///|
let applied_initial_state : Ref[String?] = Ref(None)

///|
/// Resolve the host request before constructing state. Works with EngineGame,
/// SceneGame and custom loops because the result is the game's own T.
pub fn[T] InitialStates::create_for_capture(
  self : InitialStates[T],
  width~ : Int,
  height~ : Int,
) -> T {
  let (width, height) = capture_viewport(width, height)
  let name = requested_initial_state()
  let state = self.create(name, width~, height~) catch {
    InitialStateError(message) => {
      record_initial_state_failure(message)
      abort(message)
    }
  }
  applied_initial_state.val = name
  state
}
