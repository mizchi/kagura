///|
test "ParticleEmitter::build_billboard_vertices generates correct geometry" {
  let config = {
    ..default_emitter_config(),
    spawn_rate: 1000.0,
    max_particles: 256,
  }
  let emitter = ParticleEmitter::new(config)
  emitter.update(0.01) // Spawn some particles
  let count = emitter.particle_count()
  assert_true(count > 0)
  let right = @math3d.Vec3::unit_x()
  let up = @math3d.Vec3::unit_y()
  let (vertex_data, indices) = build_billboard_vertices(emitter, right, up)
  // 4 vertices per particle, 8 doubles per vertex
  assert_eq(vertex_data.length(), count * 4 * @mesh3d.vertex3d_stride)
  // 6 indices per particle (2 triangles)
  assert_eq(indices.length(), count * 6)
}

///|
test "build_billboard_vertices encodes color in normal channels" {
  let config = {
    ..default_emitter_config(),
    spawn_rate: 1000.0,
    color_start: @math3d.Vec4::new(1.0, 0.5, 0.25, 0.8),
    color_end: @math3d.Vec4::new(1.0, 0.5, 0.25, 0.8),
    max_particles: 256,
  }
  let emitter = ParticleEmitter::new(config)
  emitter.update(0.01)
  assert_true(emitter.particle_count() > 0)
  let right = @math3d.Vec3::unit_x()
  let up = @math3d.Vec3::unit_y()
  let (vd, _) = build_billboard_vertices(emitter, right, up)
  // First vertex: offset 3,4,5 = normal (RGB), offset 6 = uv.x (alpha)
  let r = vd[3]
  let g = vd[4]
  let b = vd[5]
  let a = vd[6]
  // At age=0, t=0, so color = color_start
  assert_true((r - 1.0).abs() < 0.01)
  assert_true((g - 0.5).abs() < 0.01)
  assert_true((b - 0.25).abs() < 0.01)
  assert_true((a - 0.8).abs() < 0.01)
}
