///|
/// Renderer-independent authoring document. Units: metres, radians, seconds; Y-up, +Z forward.
pub(all) struct SceneNode {
  id : String
  name : String
  asset : String
  parent : String
  position : Array[Double]
  rotation : Array[Double]
  scale : Array[Double]
  color : Int
} derive(ToJson, FromJson, Eq, Debug)

///|
pub(all) struct Action {
  target : String
  duration : Double
  flashDuration : Double
  recoilDuration : Double
  recoilStrength : Double
} derive(ToJson, FromJson, Eq, Debug)

///|
pub(all) struct Document {
  version : Int
  name : String
  units : String
  up : String
  forward : String
  nodes : Array[SceneNode]
  action : Action
  resources : Array[Resource]
} derive(ToJson, FromJson, Eq, Debug)

///|
pub(all) struct Preview {
  time : Double
  flash : Bool
  offset : Double
} derive(ToJson, Eq, Debug)

///|
pub(all) suberror EditorError {
  Invalid(String)
  Conflict(Int)
} derive(Debug)

///|
pub fn default_document() -> Document {
  {
    resources: [],
    version: 1,
    name: "First scene",
    units: "meters",
    up: "Y",
    forward: "+Z",
    nodes: [
      node(
        "ground",
        "Ground",
        "primitive.box",
        [0, -0.25, 0],
        [10, 0.5, 8],
        0x343d49,
      ),
      node(
        "hero",
        "Actor",
        "primitive.cylinder",
        [0, 1, 0],
        [1, 2, 1],
        0xf2b35b,
      ),
      node(
        "block",
        "Block",
        "primitive.box",
        [2.5, 0.75, -1],
        [1.5, 1.5, 1.5],
        0x79aaa3,
      ),
    ],
    action: {
      target: "hero",
      duration: 1,
      flashDuration: 0.08,
      recoilDuration: 0.3,
      recoilStrength: 0.4,
    },
  }
}

///|
fn node(
  id : String,
  name : String,
  asset : String,
  position : Array[Double],
  scale : Array[Double],
  color : Int,
) -> SceneNode {
  { id, name, asset, parent: "", position, rotation: [0, 0, 0], scale, color }
}

///|
pub fn sample_action(action : Action, time : Double) -> Preview {
  let t = time.clamp(min=0, max=action.duration)
  let phase = (t / action.recoilDuration).clamp(min=0, max=1)
  {
    time: t,
    flash: t > 0 && t < action.flashDuration,
    offset: -action.recoilStrength * 4 * phase * (1 - phase),
  }
}

///|
fn require(condition : Bool, message : String) -> Unit raise EditorError {
  guard condition else { raise Invalid(message) }
}

///|
/// Reject unknown fields at every API boundary; misspelled AI commands must not silently succeed.
fn keys(value : Json, allowed : Array[String]) -> Unit raise EditorError {
  guard value is Object(fields) else { raise Invalid("Expected object") }
  for key, _ in fields {
    require(allowed.contains(key), "Unknown field: " + key)
  }
}

///|
fn field(value : Json, key : String) -> Json raise EditorError {
  guard value is Object(fields) else { raise Invalid("Expected object") }
  guard fields.get(key) is Some(found) else {
    raise Invalid("Missing field: " + key)
  }
  found
}

///|
fn string_field(value : Json, key : String) -> String raise EditorError {
  guard field(value, key) is String(result) else {
    raise Invalid("Expected string: " + key)
  }
  result
}

///|
fn optional_string(
  value : Json,
  key : String,
  fallback : String,
) -> String raise EditorError {
  guard value is Object(fields) else { raise Invalid("Expected object") }
  match fields.get(key) {
    None => fallback
    Some(String(result)) => result
    _ => raise Invalid("Expected string: " + key)
  }
}

///|
fn valid_number(value : Double) -> Bool {
  value >= -1000000 && value <= 1000000
}

///|
fn vector(value : Json) -> Array[Double] raise {
  let xyz : Array[Double] = @json.from_json(value)
  require(
    xyz.length() == 3 && xyz.all(valid_number),
    "Expected three finite coordinates within +/-1000000",
  )
  xyz
}

///|
fn valid_id(value : String) -> Bool {
  value.length() > 0 &&
  value.length() <= 80 &&
  value
  .iter()
  .all(fn(c) {
    (c >= 'a' && c <= 'z') ||
    (c >= 'A' && c <= 'Z') ||
    (c >= '0' && c <= '9') ||
    c == '-' ||
    c == '_' ||
    c == '.'
  })
}

///|
pub fn find_node(doc : Document, id : String) -> SceneNode? {
  doc.nodes.iter().find_first(fn(n) { n.id == id })
}

///|
pub fn validate(doc : Document) -> Unit raise EditorError {
  require(
    doc.version == 1 &&
    doc.units == "meters" &&
    doc.up == "Y" &&
    doc.forward == "+Z",
    "Unsupported document version or coordinates",
  )
  require(
    doc.name.trim().length() > 0 && doc.name.length() <= 120,
    "Name must contain 1-120 characters",
  )
  require(doc.nodes.length() <= 2000, "Scene limit is 2000 nodes")
  let ids : Map[String, SceneNode] = Map([])
  for n in doc.nodes {
    require(
      valid_id(n.id) && !ids.contains(n.id),
      "Invalid or duplicate node ID: " + n.id,
    )
    ids[n.id] = n
    require(
      n.name.trim().length() > 0 && n.name.length() <= 120,
      "Node name must contain 1-120 characters",
    )
    require(
      ["primitive.box", "primitive.sphere", "primitive.cylinder", "group"].contains(
        n.asset,
      ),
      "Unknown asset: " + n.asset,
    )
    require(n.color >= 0 && n.color <= 0xffffff, "Color must be an RGB integer")
    for xyz in [n.position, n.rotation, n.scale] {
      require(
        xyz.length() == 3 && xyz.all(valid_number),
        "Invalid transform: " + n.id,
      )
    }
    require(n.scale.all(fn(x) { x > 0 }), "Scale must be positive")
  }
  for n in doc.nodes {
    let mut parent = n.parent
    let mut depth = 0
    while parent != "" {
      require(parent != n.id && depth < doc.nodes.length(), "Hierarchy cycle")
      guard ids.get(parent) is Some(p) else {
        raise Invalid("Missing parent: " + parent)
      }
      parent = p.parent
      depth += 1
    }
  }
  validate_resources(doc.resources)
  let a = doc.action
  require(
    a.target == "" || find_node(doc, a.target) is Some(_),
    "Unknown action target",
  )
  require(
    valid_number(a.duration) && a.duration > 0 && a.duration <= 60,
    "Duration must be in (0,60]",
  )
  require(
    valid_number(a.flashDuration) &&
    a.flashDuration >= 0 &&
    a.flashDuration <= a.duration,
    "Flash must fit within duration",
  )
  require(
    valid_number(a.recoilDuration) &&
    a.recoilDuration > 0 &&
    a.recoilDuration <= a.duration,
    "Recoil must fit within duration",
  )
  require(
    valid_number(a.recoilStrength) &&
    a.recoilStrength >= 0 &&
    a.recoilStrength <= 10,
    "Recoil strength must be in [0,10]",
  )
}

///|
pub fn decode_document(value : Json) -> Document raise {
  keys(value, [
    "version", "name", "units", "up", "forward", "nodes", "action", "resources",
  ])
  guard value is Object(fields) else { raise Invalid("Expected object") }
  let normalized = fields.copy()
  if !normalized.contains("resources") {
    normalized["resources"] = ([] : Array[Json]).to_json()
  }
  let value = normalized.to_json()
  guard field(value, "resources") is Array(resources) else {
    raise Invalid("Expected resources array")
  }
  for resource in resources {
    ignore(decode_resource(resource))
  }
  guard field(value, "nodes") is Array(nodes) else {
    raise Invalid("Expected nodes array")
  }
  ignore(integer(field(value, "version")))
  for n in nodes {
    ignore(integer(field(n, "color")))
    keys(n, [
      "id", "name", "asset", "parent", "position", "rotation", "scale", "color",
    ])
  }
  keys(field(value, "action"), [
    "target", "duration", "flashDuration", "recoilDuration", "recoilStrength",
  ])
  let doc : Document = @json.from_json(value)
  validate(doc)
  doc
}

///|
pub fn Document::to_json(self : Document) -> Json {
  ToJson::to_json(self)
}

///|
fn integer(value : Json) -> Int raise {
  guard value is Number(n, ..) else { raise Invalid("Expected integer") }
  require(
    n >= 0 && n <= 2147483647 && n == n.to_int().to_double(),
    "Expected non-negative integer",
  )
  n.to_int()
}

///|
/// Iterative depth-first traversal keeps view order independent of document array order.
pub fn hierarchy_nodes(doc : Document) -> Array[SceneNode] {
  let output : Array[SceneNode] = []
  let stack = doc.nodes.filter(fn(n) { n.parent == "" })
  stack.rev_in_place()
  while stack.pop() is Some(n) {
    output.push(n)
    let children = doc.nodes.filter(fn(child) { child.parent == n.id })
    children.rev_in_place()
    for child in children {
      stack.push(child)
    }
  }
  output
}
