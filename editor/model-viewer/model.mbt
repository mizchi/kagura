///|
fn model_graph(
  format : String,
  json : String,
  buffers : Array[Bytes],
  text : String,
) -> @scene3d.SceneGraph raise {
  if format == "gltf" {
    @gltf.scene_graph_from_gltf(json, buffers)
  } else if format == "obj" {
    let mesh = @mesh3d.Mesh3D::from_obj(text)
    if mesh.triangle_count() == 0 {
      fail("OBJ contains no triangles")
    }
    let graph = @scene3d.SceneGraph::new()
    let _ = graph.add_node(@scene3d.scene_node(mesh=Some(mesh)))
    graph
  } else {
    fail("Unsupported model format")
  }
}

///|
struct ModelBounds {
  mut min_x : Double
  mut min_y : Double
  mut min_z : Double
  mut max_x : Double
  mut max_y : Double
  mut max_z : Double
  mut triangles : Int
}

///|
fn model_bounds(graph : @scene3d.SceneGraph) -> ModelBounds {
  let bounds = {
    min_x: 1.0e30,
    min_y: 1.0e30,
    min_z: 1.0e30,
    max_x: -1.0e30,
    max_y: -1.0e30,
    max_z: -1.0e30,
    triangles: 0,
  }
  fn visit(id : Int, parent : @math3d.Mat4) -> Unit {
    if graph.get_node(id) is Some(node) {
      let world = parent.multiply(node.transform.to_mat4())
      if node.mesh is Some(mesh) {
        bounds.triangles += mesh.triangle_count()
        let b = mesh.bounds()
        for x in [b.min_x, b.max_x] {
          for y in [b.min_y, b.max_y] {
            for z in [b.min_z, b.max_z] {
              let p = world.mul_vec4(@math3d.Vec4::new(x, y, z, 1.0))
              bounds.min_x = @cmp.minimum(bounds.min_x, p.x)
              bounds.min_y = @cmp.minimum(bounds.min_y, p.y)
              bounds.min_z = @cmp.minimum(bounds.min_z, p.z)
              bounds.max_x = @cmp.maximum(bounds.max_x, p.x)
              bounds.max_y = @cmp.maximum(bounds.max_y, p.y)
              bounds.max_z = @cmp.maximum(bounds.max_z, p.z)
            }
          }
        }
      }
      for child in node.children {
        visit(child, world)
      }
    }
  }
  for id in graph.roots {
    visit(id, @math3d.Mat4::identity())
  }
  bounds
}

///|
fn fitted_camera(
  bounds : ModelBounds,
  aspect : Double,
) -> @camera3d.OrbitCamera {
  let target = @math3d.Vec3::new(
    (bounds.min_x + bounds.max_x) / 2.0,
    (bounds.min_y + bounds.max_y) / 2.0,
    (bounds.min_z + bounds.max_z) / 2.0,
  )
  let extent = @math3d.Vec3::new(
    bounds.max_x - bounds.min_x,
    bounds.max_y - bounds.min_y,
    bounds.max_z - bounds.min_z,
  )
  let radius = @cmp.maximum(extent.length() / 2.0, 0.001)
  let distance = radius / @math.sin(@math.PI / 8.0) * 1.2
  @camera3d.OrbitCamera::new(
    target,
    distance,
    0.5,
    0.3,
    @math.PI / 4.0,
    aspect,
    @cmp.maximum(radius / 1000.0, 0.00001),
    distance * 100.0,
  )
}
