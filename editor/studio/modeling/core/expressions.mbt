///|
/// Sparse offsets from the neutral mesh; independent of species and renderer.
pub(all) struct VertexDelta {
  index : Int
  offset : Array[Double]
} derive(ToJson, FromJson, Eq, Debug)

///|
pub(all) struct ExpressionTarget {
  node : String
  position : Array[Double]
  vertices : Array[VertexDelta]
} derive(ToJson, FromJson, Eq, Debug)

///|
pub(all) struct ModelExpression {
  id : String
  name : String
  targets : Array[ExpressionTarget]
} derive(ToJson, FromJson, Eq, Debug)

///|
fn validate_expression_json(j : Json) -> Unit raise {
  guard j is Array(expressions) else { raise Invalid("Expected expressions") }
  for expression in expressions {
    keys(expression, ["id", "name", "targets"])
    guard field(expression, "targets") is Array(targets) else {
      raise Invalid("Expected expression targets")
    }
    for target in targets {
      keys(target, ["node", "position", "vertices"])
      guard field(target, "vertices") is Array(vertices) else {
        raise Invalid("Expected expression vertices")
      }
      for vertex in vertices {
        keys(vertex, ["index", "offset"])
      }
    }
  }
}

///|
fn validate_expressions(doc : ModelDocument) -> Unit raise ModelError {
  require(doc.expressions.length() <= 32, "At most 32 expressions")
  let nodes : Map[String, MeshNode] = Map([])
  for n in doc.nodes {
    nodes[n.id] = n
  }
  let ids : Map[String, Bool] = Map([])
  let mut total = 0
  for expression in doc.expressions {
    require(
      expression.id.length() > 0 &&
      expression.id.length() <= 80 &&
      !ids.contains(expression.id),
      "Duplicate or invalid expression ID",
    )
    ids[expression.id] = true
    require(
      expression.name.length() > 0 && expression.name.length() <= 120,
      "Invalid expression name",
    )
    require(
      expression.targets.length() <= doc.nodes.length(),
      "Too many expression targets",
    )
    let seen : Map[String, Bool] = Map([])
    for target in expression.targets {
      guard nodes.get(target.node) is Some(node) else {
        raise Invalid("Unknown expression object: " + target.node)
      }
      require(!seen.contains(target.node), "Duplicate expression object")
      seen[target.node] = true
      require(valid_vec(target.position), "Invalid expression position")
      let vertices : Map[Int, Bool] = Map([])
      for delta in target.vertices {
        require(
          delta.index >= 0 &&
          delta.index < node.vertices.length() &&
          !vertices.contains(delta.index),
          "Invalid expression vertex",
        )
        require(valid_vec(delta.offset), "Invalid expression offset")
        vertices[delta.index] = true
      }
      total += target.vertices.length()
    }
  }
  require(total <= 200000, "Expressions exceed 200000 vertex offsets")
}

///|
fn validate_weights(
  doc : ModelDocument,
  weights : Map[String, Double],
) -> Unit raise ModelError {
  for id, weight in weights {
    require(doc.expressions.any(e => e.id == id), "Unknown expression: " + id)
    require(
      weight >= 0 && weight <= 1,
      "Expression weight must be between 0 and 1",
    )
  }
}

///|
/// Always evaluate from neutral. Fixed expression order makes blends deterministic.
pub fn evaluate_expressions(
  doc : ModelDocument,
  weights : Map[String, Double],
) -> ModelDocument raise ModelError {
  validate_document(doc)
  validate_weights(doc, weights)
  let nodes = doc.nodes.copy()
  let indices : Map[String, Int] = Map([])
  for i, n in nodes {
    indices[n.id] = i
  }
  for expression in doc.expressions {
    let weight = weights.get(expression.id).unwrap_or(0.0)
    if weight == 0 {
      continue
    }
    for target in expression.targets {
      let index = indices[target.node]
      let node = nodes[index]
      let vertices = node.vertices.copy()
      for delta in target.vertices {
        vertices[delta.index] = Array::makei(3, k => {
          vertices[delta.index][k] + delta.offset[k] * weight
        })
      }
      nodes[index] = {
        ..node,
        position: Array::makei(3, k => {
          node.position[k] + target.position[k] * weight
        }),
        vertices,
      }
    }
  }
  let result = { ..doc, nodes, }
  validate_document(result)
  result
}

///|
fn expression_bound(doc : ModelDocument, id : String) -> Bool {
  doc.expressions.any(e => e.targets.any(t => t.node == id))
}

///|
/// Capture positions and vertex edits, rejecting topology changes instead of corrupting targets.
pub fn capture_expression(
  neutral : ModelDocument,
  posed : ModelDocument,
  id : String,
  name : String,
) -> ModelExpression raise ModelError {
  require(
    neutral.nodes.length() == posed.nodes.length(),
    "Expression topology must match neutral",
  )
  let targets : Array[ExpressionTarget] = []
  for i, base in neutral.nodes {
    let node = posed.nodes[i]
    require(
      base.id == node.id &&
      base.faces == node.faces &&
      base.vertices.length() == node.vertices.length(),
      "Expression topology must match neutral",
    )
    let vertices : Array[VertexDelta] = []
    for j, p in base.vertices {
      let offset = subtract(node.vertices[j], p)
      if offset.any(v => v.abs() > 0.000000001) {
        vertices.push({ index: j, offset, })
      }
    }
    let position = subtract(node.position, base.position)
    if !vertices.is_empty() || position.any(v => v.abs() > 0.000000001) {
      targets.push({ node: base.id, position, vertices, })
    }
  }
  let expression = { id, name, targets, }
  validate_document({ ..neutral, expressions: [expression], })
  expression
}
