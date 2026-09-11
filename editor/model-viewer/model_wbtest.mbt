///|
test "model preview fits nested world bounds and rejects empty OBJ" {
  let graph = @scene3d.SceneGraph::new()
  let root = graph.add_node(
    @scene3d.scene_node(position=@math3d.Vec3::new(10.0, 2.0, 0.0)),
  )
  let _ = graph.add_child(
    root,
    @scene3d.scene_node(
      mesh=Some(@mesh3d.Mesh3D::cube(2.0)),
      scale=@math3d.Vec3::new(2.0, 1.0, 1.0),
    ),
  )
  let bounds = model_bounds(graph)
  assert_eq(bounds.min_x, 8.0)
  assert_eq(bounds.max_x, 12.0)
  assert_eq(bounds.triangles, 12)
  let camera = fitted_camera(bounds, 4.0 / 3.0)
  assert_eq(camera.target.x, 10.0)
  assert_eq(camera.target.y, 2.0)
  assert_true(camera.distance > 4.0)
  let failed = try {
    let _ = model_graph("obj", "", [], "# empty")
    false
  } catch {
    _ => true
  }
  assert_true(failed)
}
