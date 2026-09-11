///|
/// Shared editor controller. Browser views and headless hosts own no authoring logic.
pub struct Editor {
  session : Session
  mut selection : String
  mut time : Double
  mut layout : String
}

///|
pub fn Editor::new() -> Editor {
  { session: Session::new(), selection: "hero", time: 0, layout: "scene" }
}

///|
/// Loading a document starts a fresh session; importing during editing is document.replace.
pub fn Editor::from_document(value : Json) -> Editor raise {
  let document = decode_document(value)
  let session = Session::{ document, revision: 0, past: [], future: [] }
  {
    session,
    selection: if find_node(document, "hero") is Some(_) {
      "hero"
    } else {
      ""
    },
    time: 0,
    layout: "scene",
  }
}

///|
pub fn Editor::snapshot(self : Editor) -> Json {
  {
    "apiVersion": 1,
    "revision": self.session.revision.to_json(),
    "document": self.session.document.to_json(),
    "selection": self.selection.to_json(),
    "preview": ToJson::to_json(
      sample_action(self.session.document.action, self.time),
    ),
    "canUndo": self.session.can_undo().to_json(),
    "canRedo": self.session.can_redo().to_json(),
    "layout": self.layout.to_json(),
  }
}

///|
fn Editor::handle(self : Editor, request : Json) -> Unit raise {
  let operation = string_field(request, "method")
  let before = self.session.revision
  match operation {
    "snapshot" => keys(request, ["method"])
    "dispatch" => {
      keys(request, ["method", "transaction"])
      self.session.execute(field(request, "transaction"))
    }
    "undo" | "redo" | "history.clear" => {
      keys(request, ["method", "expectedRevision"])
      if integer(field(request, "expectedRevision")) != before {
        raise Conflict(before)
      }
      if operation == "history.clear" {
        self.session.clear_history()
      } else if operation == "undo" {
        self.session.undo()
      } else {
        self.session.redo()
      }
    }
    "select" => {
      keys(request, ["method", "id"])
      let id = string_field(request, "id")
      require(
        id == "" || find_node(self.session.document, id) is Some(_),
        "Unknown node ID",
      )
      self.selection = id
    }
    "seek" => {
      keys(request, ["method", "time"])
      let time : Double = @json.from_json(field(request, "time"))
      require(
        time >= 0 && time <= self.session.document.action.duration,
        "Time outside action",
      )
      self.time = time
    }
    "layout" => {
      keys(request, ["method", "value"])
      let value = string_field(request, "value")
      require(value == "scene" || value == "action", "Unknown layout")
      self.layout = value
    }
    _ => raise Invalid("Unknown editor method: " + operation)
  }
  if self.session.revision != before {
    if find_node(self.session.document, self.selection) is None {
      self.selection = ""
    }
    self.time = 0
  }
}

///|
fn Editor::error_reply(self : Editor, error : Error) -> Json {
  let (code, message) = match error {
    Conflict(current) =>
      (
        "conflict",
        "Revision conflict; current revision is " + current.to_string(),
      )
    Invalid(message) => ("invalid", message)
    _ => ("invalid", "Malformed JSON or field type")
  }
  {
    "ok": false,
    "error": { "code": code.to_json(), "message": message.to_json() },
    "revision": self.session.revision.to_json(),
  }
}

///|
pub fn Editor::request(self : Editor, source : String) -> Json {
  try {
    self.handle(@json.parse(source))
    { "ok": true, "snapshot": self.snapshot() }
  } catch {
    error => self.error_reply(error)
  }
}
