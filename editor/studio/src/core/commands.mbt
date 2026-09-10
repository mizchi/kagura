///|
/// Pure transition: commands allocate new arrays and never mutate the supplied document.
pub fn apply(doc : Document, command : Json) -> Document raise {
  let op = string_field(command, "op")
  if op == "resource.put" {
    keys(command, ["op", "resource"])
    let resource = decode_resource(field(command, "resource"))
    let next = {
      ..doc,
      resources: doc.resources.filter(fn(r) { r.id != resource.id }) +
      [resource],
    }
    validate(next)
    return next
  }
  if op == "resource.remove" {
    keys(command, ["op", "id"])
    let id = string_field(command, "id")
    require(doc.resources.any(fn(r) { r.id == id }), "Unknown resource: " + id)
    return { ..doc, resources: doc.resources.filter(fn(r) { r.id != id }) }
  }
  if op == "document.replace" {
    keys(command, ["op", "document"])
    return decode_document(field(command, "document"))
  }
  if op == "action.set" {
    keys(command, ["op", "action"])
    let data = field(command, "action")
    keys(data, [
      "target", "duration", "flashDuration", "recoilDuration", "recoilStrength",
    ])
    let action : Action = @json.from_json(data)
    let next = { ..doc, action, }
    validate(next)
    return next
  }
  let id = string_field(command, "id")
  if op == "node.add" {
    keys(command, ["op", "id", "name", "asset", "parent"])
    require(find_node(doc, id) is None, "Duplicate node ID: " + id)
    let fresh = node(
      id,
      string_field(command, "name"),
      string_field(command, "asset"),
      [0, 0.5, 0],
      [1, 1, 1],
      0x8ba9d4,
    )
    let fresh = { ..fresh, parent: optional_string(command, "parent", "") }
    let next = { ..doc, nodes: doc.nodes + [fresh] }
    validate(next)
    return next
  }
  guard find_node(doc, id) is Some(selected) else {
    raise Invalid("Unknown node: " + id)
  }
  if op == "node.remove" {
    keys(command, ["op", "id"])
    let removed : Map[String, Bool] = Map([])
    removed[id] = true
    for _ in 0..<doc.nodes.length() {
      for n in doc.nodes {
        if removed.contains(n.parent) {
          removed[n.id] = true
        }
      }
    }
    let action = if removed.contains(doc.action.target) {
      { ..doc.action, target: "" }
    } else {
      doc.action
    }
    return {
      ..doc,
      action,
      nodes: doc.nodes.filter(fn(n) { !removed.contains(n.id) }),
    }
  }
  let updated = match op {
    "node.rename" => {
      keys(command, ["op", "id", "name"])
      { ..selected, name: string_field(command, "name") }
    }
    "node.reparent" => {
      keys(command, ["op", "id", "parent"])
      { ..selected, parent: string_field(command, "parent") }
    }
    "node.transform" => {
      keys(command, ["op", "id", "position", "rotation", "scale"])
      {
        ..selected,
        position: vector(field(command, "position")),
        rotation: vector(field(command, "rotation")),
        scale: vector(field(command, "scale")),
      }
    }
    "node.material" => {
      keys(command, ["op", "id", "color"])
      let color : Int = integer(field(command, "color"))
      { ..selected, color, }
    }
    _ => raise Invalid("Unknown command: " + op)
  }
  let next = {
    ..doc,
    nodes: doc.nodes.map(fn(n) { if n.id == id { updated } else { n } }),
  }
  validate(next)
  next
}
