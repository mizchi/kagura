///|
struct Modal {
  before : ModelDocument
  base : MeshNode
  kind : String
  indices : Array[Int]
  normal : Array[Double]
}

///|
pub struct ModelEditor {
  mut document : ModelDocument
  mut revision : Int
  mut selected : String
  mut mode : String
  mut indices : Array[Int]
  mut face : Int
  mut modal : Modal?
  past : Array[ModelDocument]
  future : Array[ModelDocument]
  mut serial : Int
}

///|
pub fn ModelEditor::new() -> ModelEditor {
  {
    document: kawaiiko_document(),
    revision: 0,
    selected: "head",
    mode: "object",
    indices: [],
    face: -1,
    modal: None,
    past: [],
    future: [],
    serial: 0,
  }
}

///|
fn ModelEditor::node_index(self : ModelEditor) -> Int raise ModelError {
  for i = 0; i < self.document.nodes.length(); i = i + 1 {
    if self.document.nodes[i].id == self.selected {
      return i
    }
  }
  raise Invalid("Select an object first")
}

///|
fn ModelEditor::commit(
  self : ModelEditor,
  before : ModelDocument,
  next : ModelDocument,
) -> Unit raise ModelError {
  validate_document(next)
  if before == next {
    return
  }
  self.past.push(before)
  if self.past.length() > 40 {
    ignore(self.past.remove(0))
  }
  self.future.clear()
  self.document = next
  self.revision += 1
}

///|
fn ModelEditor::new_id(self : ModelEditor) -> String {
  while true {
    self.serial += 1
    let id = "mesh." + self.serial.to_string()
    if !self.document.nodes.any(n => n.id == id) {
      return id
    }
  }
  ""
}

///|
fn ModelEditor::handle(self : ModelEditor, req : Json) -> Unit raise {
  let op = string_field(req, "op")
  if self.modal is Some(_) {
    require(
      ["preview", "confirm", "cancel", "snapshot"].contains(op),
      "Confirm or cancel the current transform",
    )
  }
  match op {
    "snapshot" => keys(req, ["op"])
    "select" => {
      keys(req, ["op", "id"])
      let id = string_field(req, "id")
      require(
        id == "" || self.document.nodes.any(n => n.id == id),
        "Unknown object",
      )
      self.selected = id
      self.indices = []
      self.face = -1
    }
    "mode" => {
      keys(req, ["op", "value"])
      let mode = string_field(req, "value")
      require(
        ["object", "vertex", "face"].contains(mode),
        "Unknown selection mode",
      )
      self.mode = mode
      self.indices = []
      self.face = -1
    }
    "vertices" => {
      keys(req, ["op", "indices"])
      let n = self.document.nodes[self.node_index()]
      let indices : Array[Int] = @json.from_json(field(req, "indices"))
      require(
        self.mode == "vertex" && indices.length() <= n.vertices.length(),
        "Vertex selection requires edit mode",
      )
      let seen : Map[Int, Bool] = Map([])
      for i in indices {
        require(
          i >= 0 && i < n.vertices.length() && !seen.contains(i),
          "Invalid vertex selection",
        )
        seen[i] = true
      }
      self.indices = indices
    }
    "face" => {
      keys(req, ["op", "index"])
      let n = self.document.nodes[self.node_index()]
      let i : Int = @json.from_json(field(req, "index"))
      require(
        self.mode == "face" && i >= 0 && i < n.faces.length(),
        "Select an existing face in face mode",
      )
      self.face = i
      self.indices = n.faces[i].copy()
    }
    "begin" => {
      keys(req, ["op", "kind"])
      let kind = string_field(req, "kind")
      require(
        ["move", "rotate", "scale", "extrude"].contains(kind),
        "Unknown transform",
      )
      let index = self.node_index()
      let n = self.document.nodes[index]
      require(
        self.mode == "object" || !self.indices.is_empty(),
        "Select vertices or a face first",
      )
      let mut base = n
      let mut indices = self.indices
      let mut direction = [0.0, 1.0, 0.0]
      if kind == "extrude" {
        require(
          self.mode == "face" && self.face >= 0,
          "Extrude requires a selected face",
        )
        direction = normal(n, self.face)
        let (mesh, selected) = extrude_mesh(n, self.face)
        base = mesh
        indices = selected
        validate_document(replace_node(self.document, index, base))
      }
      self.modal = Some({
        before: self.document,
        base,
        kind,
        indices,
        normal: direction,
      })
      self.document = replace_node(self.document, index, base)
      self.indices = indices
    }
    "preview" => {
      keys(req, ["op", "value"])
      guard self.modal is Some(modal) else {
        raise Invalid("No active transform")
      }
      let value : Array[Double] = @json.from_json(field(req, "value"))
      require(valid_vec(value), "Invalid transform")
      if modal.kind == "scale" {
        require(value.all(v => v.abs() >= 0.001), "Scale cannot be zero")
      }
      let next = replace_node(
        modal.before,
        self.node_index(),
        transform_mesh(
          modal.base,
          modal.indices,
          modal.kind,
          value,
          self.mode == "object",
        ),
      )
      validate_document(next)
      self.document = next
    }
    "cancel" => {
      keys(req, ["op"])
      if self.modal is Some(modal) {
        self.document = modal.before
        if modal.kind == "extrude" {
          self.indices = modal.before.nodes[self.node_index()].faces[self.face].copy()
        }
      }
      self.modal = None
    }
    "confirm" => {
      keys(req, ["op"])
      if self.modal is Some(modal) {
        self.commit(modal.before, self.document)
      }
      self.modal = None
    }
    "undo" | "redo" => {
      keys(req, ["op"])
      let from = if op == "undo" { self.past } else { self.future }
      let to = if op == "undo" { self.future } else { self.past }
      guard from.pop() is Some(doc) else { raise Invalid("No history") }
      to.push(self.document)
      self.document = doc
      self.revision += 1
      self.indices = []
      self.face = -1
      if !doc.nodes.any(n => n.id == self.selected) {
        self.selected = ""
      }
    }
    "replace" => {
      keys(req, ["op", "document"])
      let doc = decode_document(field(req, "document"))
      self.commit(self.document, doc)
      self.selected = if doc.nodes.is_empty() { "" } else { doc.nodes[0].id }
      self.mode = "object"
      self.indices = []
      self.face = -1
    }
    "add" | "duplicate" => {
      keys(req, if op == "add" { ["op", "kind"] } else { ["op"] })
      let id = self.new_id()
      let n = if op == "duplicate" {
        let source = self.document.nodes[self.node_index()]
        {
          ..source,
          id,
          name: source.name + " copy",
          position: [
            source.position[0] + 0.25,
            source.position[1],
            source.position[2],
          ],
        }
      } else {
        let kind = string_field(req, "kind")
        require(kind == "cube" || kind == "sphere", "Unknown primitive")
        if kind == "cube" {
          cube(id)
        } else {
          ellipsoid(id, "Sphere", 0xA8B9AE, [0, 0.5, 0], [0.5, 0.5, 0.5])
        }
      }
      let nodes = self.document.nodes.copy()
      nodes.push(n)
      self.commit(self.document, { ..self.document, nodes, })
      self.selected = id
      self.mode = "object"
      self.indices = []
      self.face = -1
    }
    "remove" => {
      keys(req, ["op"])
      let index = self.node_index()
      if self.mode == "object" {
        let nodes = self.document.nodes.copy()
        ignore(nodes.remove(index))
        self.commit(self.document, { ..self.document, nodes, })
        self.selected = ""
      } else {
        require(
          self.mode == "face" && self.face >= 0,
          "Switch to face mode to delete polygons",
        )
        let n = self.document.nodes[index]
        let faces = n.faces.copy()
        ignore(faces.remove(self.face))
        self.commit(
          self.document,
          replace_node(self.document, index, { ..n, faces, }),
        )
      }
      self.indices = []
      self.face = -1
    }
    "material" => {
      keys(req, ["op", "color"])
      let index = self.node_index()
      let color : Int = @json.from_json(field(req, "color"))
      self.commit(
        self.document,
        replace_node(self.document, index, {
          ..self.document.nodes[index],
          color,
        }),
      )
    }
    "rename" => {
      keys(req, ["op", "name"])
      let index = self.node_index()
      let name = string_field(req, "name")
      self.commit(
        self.document,
        replace_node(self.document, index, {
          ..self.document.nodes[index],
          name,
        }),
      )
    }
    _ => raise Invalid("Unknown modeling operation: " + op)
  }
}

///|
pub fn ModelEditor::snapshot(self : ModelEditor) -> Json {
  {
    "document": ToJson::to_json(self.document),
    "revision": self.revision.to_json(),
    "selected": self.selected.to_json(),
    "mode": self.mode.to_json(),
    "vertices": self.indices.to_json(),
    "face": self.face.to_json(),
    "canUndo": (!self.past.is_empty()).to_json(),
    "canRedo": (!self.future.is_empty()).to_json(),
    "modal": match self.modal {
      None => Json::null()
      Some(m) => { "kind": m.kind.to_json(), "normal": m.normal.to_json() }
    },
  }
}

///|
pub fn ModelEditor::request(self : ModelEditor, source : String) -> String {
  try {
    require(source.length() <= 8 * 1024 * 1024, "Request exceeds 8 MiB")
    self.handle(@json.parse(source))
    ({ "ok": true, "snapshot": self.snapshot() } : Json).stringify()
  } catch {
    Invalid(message) =>
      ({ "ok": false, "error": message.to_json() } : Json).stringify()
    _ => "{\"ok\":false,\"error\":\"Malformed modeling request\"}"
  }
}
