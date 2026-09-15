///|
fn ellipsoid(
  id : String,
  name : String,
  color : Int,
  position : Array[Double],
  size : Array[Double],
  segments? : Int = 16,
  rings? : Int = 10,
) -> MeshNode {
  let vertices : Array[Array[Double]] = [[0, size[1], 0]]
  let faces : Array[Array[Int]] = []
  for r = 1; r < rings; r = r + 1 {
    let phi = r.to_double() * 3.141592653589793 / rings.to_double()
    for s = 0; s < segments; s = s + 1 {
      let theta = s.to_double() * 6.283185307179586 / segments.to_double()
      vertices.push([
        size[0] * @math.sin(phi) * @math.cos(theta),
        size[1] * @math.cos(phi),
        size[2] * @math.sin(phi) * @math.sin(theta),
      ])
    }
  }
  let bottom = vertices.length()
  vertices.push([0, -size[1], 0])
  for s = 0; s < segments; s = s + 1 {
    let next = (s + 1) % segments
    faces.push([0, 1 + next, 1 + s])
    for r = 0; r < rings - 2; r = r + 1 {
      let a = 1 + r * segments + s
      let b = 1 + r * segments + next
      faces.push([a, b, b + segments, a + segments])
    }
    faces.push([
      bottom,
      1 + (rings - 2) * segments + s,
      1 + (rings - 2) * segments + next,
    ])
  }
  { id, name, color, position, vertices, faces, }
}

///|
fn cube(id : String) -> MeshNode {
  {
    id,
    name: "Cube",
    color: 0xA8B9AE,
    position: [0, 0.5, 0],
    vertices: [
      [-0.5, -0.5, 0.5],
      [0.5, -0.5, 0.5],
      [0.5, 0.5, 0.5],
      [-0.5, 0.5, 0.5],
      [-0.5, -0.5, -0.5],
      [0.5, -0.5, -0.5],
      [0.5, 0.5, -0.5],
      [-0.5, 0.5, -0.5],
    ],
    faces: [
      [0, 1, 2, 3],
      [5, 4, 7, 6],
      [4, 0, 3, 7],
      [1, 5, 6, 2],
      [3, 2, 6, 7],
      [4, 5, 1, 0],
    ],
  }
}

///|
/// Outline is CCW viewed from +Z. Cap triangulation belongs to the renderer/export adapter.
fn prism(
  id : String,
  name : String,
  color : Int,
  position : Array[Double],
  outline : Array[Array[Double]],
  depth : Double,
) -> MeshNode {
  let count = outline.length()
  let vertices : Array[Array[Double]] = []
  for p in outline {
    vertices.push([p[0], p[1], depth / 2])
  }
  for p in outline {
    vertices.push([p[0], p[1], -depth / 2])
  }
  let front = Array::makei(count, i => i)
  let back = Array::makei(count, i => count * 2 - 1 - i)
  let faces : Array[Array[Int]] = [front, back]
  for i = 0; i < count; i = i + 1 {
    let next = (i + 1) % count
    faces.push([i, i + count, next + count, next])
  }
  { id, name, color, position, vertices, faces, }
}
