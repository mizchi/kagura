///|
fn transform_mesh(
  n : MeshNode,
  indices : Array[Int],
  kind : String,
  value : Array[Double],
  object_mode : Bool,
) -> MeshNode {
  if object_mode && kind == "move" {
    return { ..n, position: Array::makei(3, i => n.position[i] + value[i]), }
  }
  let pivot = [0.0, 0.0, 0.0]
  if !object_mode {
    for i in indices {
      for k = 0; k < 3; k = k + 1 {
        pivot[k] += n.vertices[i][k] / indices.length().to_double()
      }
    }
  }
  let selected : Map[Int, Bool] = Map([])
  for i in indices {
    selected[i] = true
  }
  let vertices = Array::makei(n.vertices.length(), fn(i) {
    let p = n.vertices[i]
    if !object_mode && !selected.contains(i) {
      return p
    }
    if kind == "move" || kind == "extrude" {
      return Array::makei(3, k => p[k] + value[k])
    }
    let v = subtract(p, pivot)
    if kind == "scale" {
      return Array::makei(3, k => v[k] * value[k] + pivot[k])
    }
    for axis = 0; axis < 3; axis = axis + 1 {
      let a = (axis + 1) % 3
      let b = (axis + 2) % 3
      let x = v[a] * @math.cos(value[axis]) - v[b] * @math.sin(value[axis])
      let y = v[a] * @math.sin(value[axis]) + v[b] * @math.cos(value[axis])
      v[a] = x
      v[b] = y
    }
    Array::makei(3, k => v[k] + pivot[k])
  })
  let faces = if object_mode &&
    kind == "scale" &&
    value[0] * value[1] * value[2] < 0 {
    n.faces.map(f => Array::makei(f.length(), i => f[f.length() - 1 - i]))
  } else {
    n.faces
  }
  { ..n, vertices, faces, }
}

///|
fn extrude_mesh(n : MeshNode, face : Int) -> (MeshNode, Array[Int]) {
  let f = n.faces[face]
  let vertices = n.vertices.copy()
  let indices : Array[Int] = []
  for i in f {
    indices.push(vertices.length())
    vertices.push(n.vertices[i].copy())
  }
  let faces = n.faces.copy()
  faces[face] = indices
  for i = 0; i < f.length(); i = i + 1 {
    let next = (i + 1) % f.length()
    faces.push([f[i], f[next], indices[next], indices[i]])
  }
  ({ ..n, vertices, faces, }, indices)
}

///|
fn replace_node(
  doc : ModelDocument,
  index : Int,
  node : MeshNode,
) -> ModelDocument {
  let nodes = doc.nodes.copy()
  nodes[index] = node
  { ..doc, nodes, }
}
