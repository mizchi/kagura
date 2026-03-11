///|
test "ParticleManager::spawn creates burst emitter" {
  let pm = ParticleManager::new(999)
  pm.spawn({
    ..default_emitter_config(),
    spawn_rate: 1000.0,
    max_particles: 20,
    lifetime_min: 0.5,
    lifetime_max: 0.5,
  })
  assert_eq(pm.emitters.length(), 1)
  assert_eq(pm.emitters[0].spawned, false)
  assert_eq(pm.total_particle_count(), 0)
}

///|
test "ParticleManager::update spawns on first frame then physics only" {
  let pm = ParticleManager::new(999)
  pm.spawn({
    ..default_emitter_config(),
    spawn_rate: 1000.0,
    max_particles: 20,
    lifetime_min: 1.0,
    lifetime_max: 1.0,
  })
  // First update: burst spawn
  pm.update(1.0 / 60.0)
  assert_eq(pm.emitters[0].spawned, true)
  let count_after_burst = pm.total_particle_count()
  assert_true(count_after_burst > 0)
  assert_true(count_after_burst <= 20)
  // Second update: no new spawns, just physics
  pm.update(1.0 / 60.0)
  // Particles should still be alive (lifetime=1.0, only ~0.03s elapsed)
  assert_true(pm.total_particle_count() > 0)
  assert_true(pm.total_particle_count() <= count_after_burst)
}

///|
test "ParticleManager::update removes dead emitters" {
  let pm = ParticleManager::new(999)
  pm.spawn({
    ..default_emitter_config(),
    spawn_rate: 1000.0,
    max_particles: 10,
    lifetime_min: 0.01,
    lifetime_max: 0.01,
  })
  pm.update(1.0 / 60.0) // burst spawn
  assert_true(pm.total_particle_count() > 0)
  // Age past lifetime
  pm.update(1.0)
  assert_eq(pm.total_particle_count(), 0)
  assert_eq(pm.emitters.length(), 0)
}

///|
test "ParticleEmitter::update_physics_only does not spawn" {
  let config = {
    ..default_emitter_config(),
    spawn_rate: 10000.0,
    max_particles: 100,
    lifetime_min: 5.0,
    lifetime_max: 5.0,
  }
  let emitter = ParticleEmitter::new(config)
  // Spawn some particles first
  emitter.update(0.01)
  let initial_count = emitter.particle_count()
  assert_true(initial_count > 0)
  // update_physics_only should not spawn more
  emitter.update_physics_only(0.01)
  assert_eq(emitter.particle_count(), initial_count)
}

///|
test "ParticleManager::draw batches multiple emitters into one command" {
  let pm = ParticleManager::new(999)
  pm.spawn({
    ..default_emitter_config(),
    position: @math3d.Vec3::new(0.0, 0.0, 0.0),
    spawn_rate: 1000.0,
    max_particles: 8,
    lifetime_min: 1.0,
    lifetime_max: 1.0,
  })
  pm.spawn({
    ..default_emitter_config(),
    position: @math3d.Vec3::new(1.0, 0.0, 0.0),
    spawn_rate: 1000.0,
    max_particles: 8,
    lifetime_min: 1.0,
    lifetime_max: 1.0,
  })
  pm.update(1.0 / 60.0)
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 0.0, 3.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::unit_y(),
    0.7853981633974483,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let cmds = pm.draw(@gfx.new_image_handle(1, 640, 480), camera, 640, 480, 0)

  assert_eq(cmds.length(), 1)
  assert_true(cmds[0].indices.length() > 0)
  assert_eq(cmds[0].dst_regions.length(), 1)
}

///|
test "ParticleManager::draw clears scratch after emitters expire" {
  let pm = ParticleManager::new(999)
  pm.spawn({
    ..default_emitter_config(),
    spawn_rate: 1000.0,
    max_particles: 8,
    lifetime_min: 0.01,
    lifetime_max: 0.01,
  })
  pm.update(1.0 / 60.0)
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 0.0, 3.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::unit_y(),
    0.7853981633974483,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let cmds = pm.draw(@gfx.new_image_handle(1, 640, 480), camera, 640, 480, 0)
  assert_eq(cmds.length(), 1)
  assert_true(pm.vertex_scratch.length() > 0)
  assert_true(pm.index_scratch.length() > 0)

  pm.update(1.0)
  let empty_cmds = pm.draw(
    @gfx.new_image_handle(1, 640, 480),
    camera,
    640,
    480,
    1,
  )
  assert_eq(empty_cmds.length(), 0)
  assert_eq(pm.vertex_scratch.length(), 0)
  assert_eq(pm.index_scratch.length(), 0)
}

///|
test "ParticleManager::append_draw_commands appends into existing command array" {
  let pm = ParticleManager::new(999)
  pm.spawn({
    ..default_emitter_config(),
    position: @math3d.Vec3::new(0.0, 0.0, 0.0),
    spawn_rate: 1000.0,
    max_particles: 8,
    lifetime_min: 1.0,
    lifetime_max: 1.0,
  })
  pm.update(1.0 / 60.0)
  let camera = @camera3d.Camera3D::new_perspective(
    @math3d.Vec3::new(0.0, 0.0, 3.0),
    @math3d.Vec3::zero(),
    @math3d.Vec3::unit_y(),
    0.7853981633974483,
    640.0 / 480.0,
    0.1,
    100.0,
  )
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  cmds.push(
    @gfx.new_draw_triangles_command(
      @gfx.new_image_handle(9, 640, 480),
      @gfx.new_shader_handle(9, "dummy"),
      [@gfx.new_dst_region(0, 0, 640, 480, 3)],
      0,
      0,
      0,
      @gfx.blend_mode_from_int(1),
      [0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0],
      [0, 1, 2],
      [],
      [],
    ),
  )

  pm.append_draw_commands(
    cmds,
    @gfx.new_image_handle(1, 640, 480),
    camera,
    640,
    480,
    0,
  )

  assert_eq(cmds.length(), 2)
  assert_true(cmds[1].indices.length() > 0)
}
