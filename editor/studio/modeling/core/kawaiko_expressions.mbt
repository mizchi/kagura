///|
/// Keep the eyebrow ribbon on the forehead instead of floating outside its silhouette.
fn kawaiko_project_brow(n : MeshNode) -> MeshNode {
  let vertices = Array::makei(n.vertices.length(), fn(i) {
    let v = n.vertices[i]
    let x = (v[0] + n.position[0]) / 0.66
    let y = (v[1] + n.position[1] - 2.38) / 0.68
    let radial = 1.0 - x * x - y * y
    let z = 0.52 + 0.65 * (if radial > 0.02 { radial } else { 0.02 }).sqrt()
    // The coarse cap triangles need clearance over the convex forehead facets.
    let shell = if i < n.vertices.length() / 2 { 0.075 } else { 0.046 }
    [v[0], v[1], z + shell - n.position[2]]
  })
  { ..n, vertices, }
}

///|
/// Only this authoring recipe knows the sample's part names. Runtime morphs do not.
fn kawaiko_pose(neutral : ModelDocument, expression : String) -> ModelDocument {
  let nodes = neutral.nodes.map(fn(base) {
    let sign = if base.id.has_suffix("left") { -1.0 } else { 1.0 }
    let mut n = base
    let translation = [0.0, 0.0, 0.0]
    let scale = [1.0, 1.0, 1.0]
    let rotate = [0.0, 0.0, 0.0]
    if base.id.has_prefix("brow.") {
      match expression {
        "happy" => {
          translation[1] = 0.055
          translation[0] = -sign * 0.035
          scale[0] = 0.9
          rotate[2] = sign * 0.08
        }
        "angry" => {
          translation[1] = -0.055
          rotate[2] = sign * 0.4
        }
        "sad" => {
          translation[1] = 0.015
          rotate[2] = -sign * 0.4
        }
        "surprised" => {
          translation[1] = 0.15
          translation[0] = -sign * 0.09
          scale[0] = 0.82
          scale[1] = 1.1
        }
        _ => ()
      }
    }
    let eye = base.id == "eye.left" || base.id == "eye.right"
    let glint = base.id.has_prefix("eye.glint.")
    if eye || glint {
      match expression {
        "blink" => {
          scale[1] = 0.04
          // Keep the glint inside the closing eye, around the same world pivot.
          if glint {
            translation[1] = (2.47 - base.position[1]) * 0.96
          }
        }
        "happy" => translation[1] = 0.025
        "sad" => translation[1] = -0.03
        "surprised" => {
          scale[1] = 1.25
          scale[0] = 1.15
        }
        _ => ()
      }
    }
    let opening = match expression {
      "happy" => 0.11
      "surprised" => 0.25
      "angry" => 0.035
      _ => 0.0
    }
    if base.id == "beak.lower" {
      translation[1] = -opening
      rotate[0] = opening * 0.7
    }
    if base.id == "mouth.inner" {
      translation[1] = -opening * 0.45
      scale[1] = 1 + opening / 0.07
    }
    if base.id == "beak" && expression == "happy" {
      scale[0] = 1.06
    }
    n = transform_mesh(n, [], "scale", scale, true)
    n = transform_mesh(n, [], "rotate", rotate, true)
    n = transform_mesh(n, [], "move", translation, true)
    if n.id.has_prefix("brow.") {
      kawaiko_project_brow(n)
    } else {
      n
    }
  })
  { ..neutral, nodes, }
}

///|
fn kawaiko_expressions(neutral : ModelDocument) -> Array[ModelExpression] {
  let presets = [
    ("happy", "喜び / Happy"),
    ("angry", "怒り / Angry"),
    ("sad", "悲しみ / Sad"),
    ("surprised", "驚き / Surprised"),
    ("blink", "まばたき / Blink"),
  ]
  presets.map(fn(pair) {
    let (id, name) = pair
    // Built-in poses preserve topology; validation failures are programming errors.
    try! capture_expression(neutral, kawaiko_pose(neutral, id), id, name)
  })
}
