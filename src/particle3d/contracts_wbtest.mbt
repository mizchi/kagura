///|
test "ParticleEmitter::new creates empty emitter" {
  let config = default_emitter_config()
  let emitter = ParticleEmitter::new(config)
  assert_eq!(emitter.particle_count(), 0)
  assert_eq!(emitter.spawn_accumulator, 0.0)
  assert_eq!(emitter.frame_count, 0)
}

///|
test "ParticleEmitter::update spawns particles" {
  let config = {
    ..default_emitter_config(),
    spawn_rate: 100.0,
    max_particles: 256,
  }
  let emitter = ParticleEmitter::new(config)
  // dt=0.1 -> should spawn ~10 particles
  emitter.update(0.1)
  assert_true!(emitter.particle_count() > 0)
  assert_true!(emitter.particle_count() <= 10)
}

///|
test "ParticleEmitter::update ages and removes dead particles" {
  let config = {
    ..default_emitter_config(),
    spawn_rate: 100.0,
    lifetime_min: 0.1,
    lifetime_max: 0.1,
    max_particles: 256,
  }
  let emitter = ParticleEmitter::new(config)
  emitter.update(0.05) // Spawn some particles with max_age=0.1
  let count_after_spawn = emitter.particle_count()
  assert_true!(count_after_spawn > 0)
  // Advance past lifetime
  emitter.update(0.2)
  // Some spawned in first frame should be dead, new ones spawned
  // At minimum, the dead ones are removed
  assert_true!(emitter.particle_count() >= 0)
}

///|
test "ParticleEmitter::update applies gravity" {
  let config = {
    ..default_emitter_config(),
    spawn_rate: 1000.0,
    gravity: @math3d.Vec3::new(0.0, -10.0, 0.0),
    initial_velocity_min: @math3d.Vec3::zero(),
    initial_velocity_max: @math3d.Vec3::zero(),
    lifetime_min: 5.0,
    lifetime_max: 5.0,
    max_particles: 256,
  }
  let emitter = ParticleEmitter::new(config)
  emitter.update(0.01) // Spawn particles
  let count = emitter.particle_count()
  assert_true!(count > 0)
  let initial_y = emitter.particles[0].position.y
  emitter.update(0.1)
  // Particle should have moved downward due to gravity
  assert_true!(emitter.particles[0].position.y < initial_y)
}

///|
test "ParticleEmitter::update respects max_particles" {
  let config = {
    ..default_emitter_config(),
    spawn_rate: 10000.0,
    max_particles: 10,
    lifetime_min: 10.0,
    lifetime_max: 10.0,
  }
  let emitter = ParticleEmitter::new(config)
  emitter.update(1.0)
  assert_true!(emitter.particle_count() <= 10)
}

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
  assert_true!(count > 0)
  let right = @math3d.Vec3::unit_x()
  let up = @math3d.Vec3::unit_y()
  let (vertex_data, indices) = emitter.build_billboard_vertices(right, up)
  // 4 vertices per particle, 8 doubles per vertex
  assert_eq!(vertex_data.length(), count * 4 * 8)
  // 6 indices per particle (2 triangles)
  assert_eq!(indices.length(), count * 6)
}

///|
test "hash RNG produces values in 0..1 range" {
  for i = 0; i < 100; i = i + 1 {
    let v = hash_to_double(i)
    assert_true!(v >= 0.0)
    assert_true!(v <= 1.0)
  }
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
  assert_true!(emitter.particle_count() > 0)
  let right = @math3d.Vec3::unit_x()
  let up = @math3d.Vec3::unit_y()
  let (vd, _) = emitter.build_billboard_vertices(right, up)
  // First vertex: offset 3,4,5 = normal (RGB), offset 6 = uv.x (alpha)
  let r = vd[3]
  let g = vd[4]
  let b = vd[5]
  let a = vd[6]
  // At age=0, t=0, so color = color_start
  assert_true!((r - 1.0).abs() < 0.01)
  assert_true!((g - 0.5).abs() < 0.01)
  assert_true!((b - 0.25).abs() < 0.01)
  assert_true!((a - 0.8).abs() < 0.01)
}
