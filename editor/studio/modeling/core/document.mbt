///|
/// Editable indexed polygons; local vertices, Y-up, +Z forward, metres.
pub(all) struct MeshNode {
  id : String
  name : String
  color : Int
  position : Array[Double]
  vertices : Array[Array[Double]]
  faces : Array[Array[Int]]
} derive(ToJson, FromJson, Eq, Debug)

///|
pub(all) struct ModelDocument {
  version : Int
  format : String
  name : String
  source : String
  nodes : Array[MeshNode]
  expressions : Array[ModelExpression]
} derive(ToJson, FromJson, Eq, Debug)

///|
pub(all) suberror ModelError {
  Invalid(String)
} derive(Debug)

///|
fn require(ok : Bool, message : String) -> Unit raise ModelError {
  if !ok {
    raise Invalid(message)
  }
}

///|
fn valid_vec(v : Array[Double]) -> Bool {
  v.length() == 3 && v.all(x => x >= -10000 && x <= 10000)
}

///|
pub fn validate_document(doc : ModelDocument) -> Unit raise ModelError {
  require(
    doc.version == 1 && doc.format == "kagura.mesh",
    "Unsupported model format",
  )
  require(
    doc.name.length() > 0 && doc.name.length() <= 120,
    "Invalid model name",
  )
  require(doc.source.length() <= 2048, "Source is too long")
  require(doc.nodes.length() <= 200, "At most 200 mesh objects")
  let ids : Map[String, Bool] = Map([])
  let mut total = 0
  for n in doc.nodes {
    require(
      n.id.length() > 0 && n.id.length() <= 80 && !ids.contains(n.id),
      "Duplicate or invalid object ID",
    )
    ids[n.id] = true
    require(
      n.name.length() > 0 && n.name.length() <= 120,
      "Invalid object name",
    )
    require(n.color >= 0 && n.color <= 0xFFFFFF, "Invalid color")
    require(valid_vec(n.position), "Invalid position")
    require(
      n.vertices.length() >= 3 && n.vertices.length() <= 20000,
      "Invalid vertex count",
    )
    require(n.vertices.all(valid_vec), "Invalid vertex coordinates")
    require(
      n.faces.length() > 0 && n.faces.length() <= 30000,
      "Invalid polygon count",
    )
    total += n.vertices.length()
    for f in n.faces {
      require(
        f.length() >= 3 && f.length() <= 32,
        "Polygons need 3-32 vertices",
      )
      let used : Map[Int, Bool] = Map([])
      for i in f {
        require(
          i >= 0 && i < n.vertices.length() && !used.contains(i),
          "Invalid polygon index",
        )
        used[i] = true
      }
    }
  }
  require(total <= 50000, "Model exceeds 50000 vertices")
  validate_expressions(doc)
}

///|
fn field(j : Json, name : String) -> Json raise ModelError {
  guard j is Object(fields) else { raise Invalid("Expected object") }
  guard fields.get(name) is Some(v) else {
    raise Invalid("Missing field: " + name)
  }
  v
}

///|
fn string_field(j : Json, name : String) -> String raise {
  @json.from_json(field(j, name))
}

///|
fn keys(j : Json, allowed : Array[String]) -> Unit raise ModelError {
  guard j is Object(fields) else { raise Invalid("Expected an object") }
  for k, _ in fields {
    require(allowed.contains(k), "Unknown field: " + k)
  }
}

///|
pub fn decode_document(j : Json) -> ModelDocument raise {
  keys(j, ["version", "format", "name", "source", "nodes", "expressions"])
  guard field(j, "nodes") is Array(nodes) else {
    raise Invalid("Expected nodes")
  }
  for n in nodes {
    keys(n, ["id", "name", "color", "position", "vertices", "faces"])
  }
  guard j is Object(fields) else { raise Invalid("Expected document") }
  let normalized = fields.copy()
  if !normalized.contains("expressions") {
    normalized["expressions"] = ([] : Array[Json]).to_json()
  }
  validate_expression_json(normalized["expressions"])
  let doc : ModelDocument = @json.from_json(normalized.to_json())
  validate_document(doc)
  doc
}

///|
fn cross(a : Array[Double], b : Array[Double]) -> Array[Double] {
  [
    a[1] * b[2] - a[2] * b[1],
    a[2] * b[0] - a[0] * b[2],
    a[0] * b[1] - a[1] * b[0],
  ]
}

///|
fn subtract(a : Array[Double], b : Array[Double]) -> Array[Double] {
  [a[0] - b[0], a[1] - b[1], a[2] - b[2]]
}

///|
fn normal(n : MeshNode, face : Int) -> Array[Double] {
  let f = n.faces[face]
  let v = cross(
    subtract(n.vertices[f[1]], n.vertices[f[0]]),
    subtract(n.vertices[f[2]], n.vertices[f[0]]),
  )
  let length = (v[0] * v[0] + v[1] * v[1] + v[2] * v[2]).sqrt()
  if length < 0.000001 {
    [0, 1, 0]
  } else {
    v.map(x => x / length)
  }
}
