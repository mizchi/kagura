///|
/// 3D camera with perspective and orthographic projection modes.

///|
pub enum ProjectionMode {
  Perspective
  /// Orthographic(left, right, bottom, top)
  Orthographic(Double, Double, Double, Double)
} derive(Show)

///|
pub struct Camera3D {
  position : @math3d.Vec3
  target : @math3d.Vec3
  up : @math3d.Vec3
  fov_y_rad : Double
  aspect : Double
  near : Double
  far : Double
  projection_mode : ProjectionMode
}

///|
pub fn Camera3D::new_perspective(
  position : @math3d.Vec3,
  target : @math3d.Vec3,
  up : @math3d.Vec3,
  fov_y_rad : Double,
  aspect : Double,
  near : Double,
  far : Double,
) -> Camera3D {
  {
    position,
    target,
    up,
    fov_y_rad,
    aspect,
    near,
    far,
    projection_mode: ProjectionMode::Perspective,
  }
}

///|
pub fn Camera3D::new_orthographic(
  position : @math3d.Vec3,
  target : @math3d.Vec3,
  up : @math3d.Vec3,
  left : Double,
  right : Double,
  bottom : Double,
  top : Double,
  near : Double,
  far : Double,
) -> Camera3D {
  {
    position,
    target,
    up,
    fov_y_rad: 0.0,
    aspect: 0.0,
    near,
    far,
    projection_mode: ProjectionMode::Orthographic(left, right, bottom, top),
  }
}

///|
pub fn Camera3D::view_matrix(self : Camera3D) -> @math3d.Mat4 {
  @math3d.Mat4::look_at(self.position, self.target, self.up)
}

///|
pub fn Camera3D::projection_matrix(self : Camera3D) -> @math3d.Mat4 {
  match self.projection_mode {
    Perspective =>
      @math3d.Mat4::perspective(
        self.fov_y_rad,
        self.aspect,
        self.near,
        self.far,
      )
    Orthographic(left, right, bottom, top) =>
      @math3d.Mat4::orthographic(left, right, bottom, top, self.near, self.far)
  }
}

///|
pub fn Camera3D::view_projection_matrix(self : Camera3D) -> @math3d.Mat4 {
  self.projection_matrix().multiply(self.view_matrix())
}
