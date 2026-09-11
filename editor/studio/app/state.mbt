///|
let controller : @editor.Editor = @editor.Editor::new()

///|
let session : @editor.Session = controller.session

///|
let revision : @luna.Signal[Int] = @luna.signal(0)

///|
/// UI refresh also runs on rejected edits, without advancing document revision.
let view_tick : @luna.Signal[Int] = @luna.signal(0)

///|
let selection : @luna.Signal[String] = @luna.signal("hero")

///|
let cursor : @luna.Signal[Double] = @luna.signal(0.0)

///|
let status : @luna.Signal[String] = @luna.signal("Ready")

///|
let layout : @luna.Signal[String] = @luna.signal("scene")

///|
pub fn snapshot() -> String {
  controller.snapshot().stringify()
}

///|
pub fn set_status(message : String) -> Unit {
  status.set(message)
}

///|
/// Signals only mirror the shared controller; no domain transitions belong to the UI.
fn request(value : Json) -> String {
  let result = controller.request(value.stringify())
  match result {
    { "ok": true, .. } => {
      selection.set(controller.selection)
      cursor.set(controller.time)
      layout.set(controller.layout)
      if revision.get() != session.revision {
        revision.set(session.revision)
        view_tick.set(view_tick.get() + 1)
        status.set("Applied · revision " + session.revision.to_string())
      }
      notify_snapshot(snapshot())
    }
    { "error": { "message": String(message), .. }, .. } => {
      status.set("Error · " + message)
      view_tick.set(view_tick.get() + 1)
    }
    _ => ()
  }
  result.stringify()
}

///|
pub fn dispatch(source : String) -> String {
  let transaction = @json.parse(source) catch {
    _ => {
      status.set("Error · Malformed JSON or field type")
      return controller.request("invalid JSON").stringify()
    }
  }
  request({ "method": "dispatch", "transaction": transaction })
}

///|
pub fn history(direction : String, expected : Int) -> String {
  request({
    "method": direction.to_json(),
    "expectedRevision": expected.to_json(),
  })
}

///|
fn command(value : Json) -> Unit {
  let envelope : Json = {
    "expectedRevision": session.revision.to_json(),
    "commands": [value],
  }
  ignore(dispatch(envelope.stringify()))
}

///|
pub fn select_node(id : String) -> Unit {
  ignore(request({ "method": "select", "id": id.to_json() }))
}

///|
pub fn seek(time : Double) -> Unit {
  ignore(request({ "method": "seek", "time": time.to_json() }))
}

///|
fn selected() -> @editor.SceneNode? {
  ignore(view_tick.get())
  @editor.find_node(session.document, selection.get())
}

///|
fn add_node(asset : String) -> Unit {
  let mut index = session.revision + 1
  while @editor.find_node(session.document, "node-" + index.to_string())
        is Some(_) {
    index += 1
  }
  let id = "node-" + index.to_string()
  command({
    "op": "node.add",
    "id": id.to_json(),
    "name": "New object",
    "asset": asset.to_json(),
  })
  select_node(id)
}

///|
fn transform_input(
  n : @editor.SceneNode,
  property : String,
  axis : Int,
  value : Double,
) -> Unit {
  let replace = fn(source : Array[Double]) {
    source.mapi(fn(i, x) { if i == axis { value } else { x } })
  }
  let position = if property == "Position" {
    replace(n.position)
  } else {
    n.position
  }
  let rotation = if property == "Rotation" {
    replace(n.rotation)
  } else {
    n.rotation
  }
  let scale = if property == "Scale" { replace(n.scale) } else { n.scale }
  // Reject non-finite form input before JSON serialization can turn it into null.
  if !(value >= -1000000 && value <= 1000000) {
    status.set("Error · Enter a finite number")
    view_tick.set(view_tick.get() + 1)
    return
  }
  command({
    "op": "node.transform",
    "id": n.id.to_json(),
    "position": position.to_json(),
    "rotation": rotation.to_json(),
    "scale": scale.to_json(),
  })
}
