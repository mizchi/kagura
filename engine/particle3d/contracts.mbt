///|
pub type Particle = @particles.Particle

///|
pub type EmitterConfig = @particles.EmitterConfig

///|
pub type ParticleEmitter = @particles.ParticleEmitter

///|
pub fn default_emitter_config() -> EmitterConfig {
  @particles.default_emitter_config()
}

///|
/// Build billboard vertices for all active particles.
/// Returns (vertex_data, indices) in stride-8 format.
/// Normal channels encode RGB color, uv.x encodes alpha.
pub fn build_billboard_vertices(
  emitter : ParticleEmitter,
  camera_right : @math3d.Vec3,
  camera_up : @math3d.Vec3,
) -> (Array[Double], Array[Int]) {
  let vertex_data : Array[Double] = []
  let indices : Array[Int] = []
  append_billboard_vertices(
    emitter, camera_right, camera_up, vertex_data, indices,
  )
  (vertex_data, indices)
}

///|
fn append_billboard_vertices(
  emitter : ParticleEmitter,
  camera_right : @math3d.Vec3,
  camera_up : @math3d.Vec3,
  vertex_data : Array[Double],
  indices : Array[Int],
) -> Unit {
  let cs = emitter.config.color_start
  let ce = emitter.config.color_end
  let base_vertex = vertex_data.length() / @mesh3d.vertex3d_stride
  for i = 0; i < emitter.particles.length(); i = i + 1 {
    let p = emitter.particles[i]
    let t = if p.max_age > 0.0 { p.age / p.max_age } else { 1.0 }
    // Interpolate color
    let r = cs.x + (ce.x - cs.x) * t
    let g = cs.y + (ce.y - cs.y) * t
    let b = cs.z + (ce.z - cs.z) * t
    let a = cs.w + (ce.w - cs.w) * t
    let half = p.size * 0.5
    let right = camera_right.scale(half)
    let up = camera_up.scale(half)
    let base_idx = base_vertex + i * 4
    // Quad corners: bottom-left, bottom-right, top-right, top-left
    let corners = [
      p.position.sub(right).sub(up),
      p.position.add(right).sub(up),
      p.position.add(right).add(up),
      p.position.sub(right).add(up),
    ]
    for c = 0; c < 4; c = c + 1 {
      let pos = corners[c]
      // position (3)
      vertex_data.push(pos.x)
      vertex_data.push(pos.y)
      vertex_data.push(pos.z)
      // normal = RGB color (3)
      vertex_data.push(r)
      vertex_data.push(g)
      vertex_data.push(b)
      // uv.x = alpha, uv.y = 0 (2)
      vertex_data.push(a)
      vertex_data.push(0.0)
    }
    // Two triangles per quad
    indices.push(base_idx)
    indices.push(base_idx + 1)
    indices.push(base_idx + 2)
    indices.push(base_idx)
    indices.push(base_idx + 2)
    indices.push(base_idx + 3)
  }
}
