// Pre-built 3D meshes (environment + items only; characters use skeletal models)

fn Meshes3D::new() -> Meshes3D {
  {
    item: @mesh3d.Mesh3D::sphere(0.2, 5, 3),
    projectile: @mesh3d.Mesh3D::sphere(0.15, 4, 3),
    floor_tile: @mesh3d.Mesh3D::plane(1.0, 1.0),
    wall: @mesh3d.Mesh3D::cube(1.0),
  }
}
