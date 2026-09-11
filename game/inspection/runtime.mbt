///|
pub(all) struct Snapshot[S] {
  revision : Int
  paused : Bool
  state : S
} derive(ToJson)

///|
/// The game owns validation/commit; this adapter owns the typed inspection and wire boundary.
pub struct Runtime[S] {
  game : String
  schema : String
  version : Int
  inspector : Inspector[S]
  read : () -> Snapshot[S]
  pause : (Bool) -> Unit
  step : () -> Unit raise
  replace : (S) -> Unit raise
}

///|
/// Callbacks own detached snapshots, Pause/neutral Step, and atomic validation/commit.
/// A successful commit must advance revision. Registration does not implement
/// these callbacks or persist changes to source, project files, or checkpoints.
pub fn[S] Runtime::new(
  game~ : String,
  schema~ : String,
  version? : Int = 1,
  inspector~ : Inspector[S],
  read~ : () -> Snapshot[S],
  pause~ : (Bool) -> Unit,
  step~ : () -> Unit raise,
  replace~ : (S) -> Unit raise,
) -> Runtime[S] raise {
  if game == "" || schema == "" || version < 1 {
    fail("Invalid inspection runtime identity")
  }
  { game, schema, version, inspector, read, pause, step, replace, }
}

///|
struct WireEdit {
  subject : String
  field : String
  value : Json
} derive(FromJson, ToJson)

///|
pub fn[S : FromJson + ToJson] decode_state(value : Json) -> S raise {
  let state : S = @json.from_json(value)
  if ToJson::to_json(state) != value {
    fail("Unknown or non-canonical runtime state fields")
  }
  state
}

///|
/// Portable request handler, usable from native tests and a JS/Wasm host. No DOM.
/// Response: {ok:true,value:...} or {ok:false,error:string}.
/// Internal adapter boundary: no session/revision or Pause guard is provided here.
/// External edits must pass through the Studio RuntimeSession or equivalent guards.
/// `reduce` only returns a candidate; `replace` invokes the game's commit callback.
pub fn[S : FromJson + ToJson] Runtime::invoke(
  self : Runtime[S],
  operation : String,
  payload : String,
) -> String {
  let response : Json = try {
    let input = @json.parse(payload)
    let value : Json = match operation {
      "read" => {
        if input != Json::null() {
          fail("read takes no payload")
        }
        (self.read)().to_json()
      }
      "pause" => {
        (self.pause)(@json.from_json(input))
        Json::null()
      }
      "step" => {
        if input != Json::null() {
          fail("step takes no payload")
        }
        (self.step)()
        Json::null()
      }
      "replace" => {
        (self.replace)(decode_state(input))
        Json::null()
      }
      "describe" => self.inspector.describe(decode_state(input)).to_json()
      "reduce" => {
        guard input is Array(values) && values.length() == 2 else {
          fail("Expected state and edit")
        }
        let state : S = decode_state(values[0])
        let edit : WireEdit = @json.from_json(values[1])
        if edit.to_json() != values[1] {
          fail("Invalid inspection edit")
        }
        ToJson::to_json(
          self.inspector.edit(
            state,
            subject=edit.subject,
            field=edit.field,
            value=edit.value,
          ),
        )
      }
      _ => fail("Unknown inspection operation")
    }
    { "ok": true, "value": value }
  } catch {
    error => { "ok": false, "error": error.to_string() }
  }
  response.stringify()
}
