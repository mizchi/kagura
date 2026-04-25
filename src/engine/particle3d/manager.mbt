///|
/// Burst-style particle manager.
///
/// Manages multiple one-shot emitters that spawn particles once
/// and automatically clean up when all particles expire.

///|
pub(all) struct ParticleManager {
  mut emitters : Array[BurstEmitter]
  particle_shader : @gfx.ShaderHandle
  mut vertex_scratch : Array[Double]
  mut index_scratch : Array[Int]
}

///|
pub(all) struct BurstEmitter {
  emitter : ParticleEmitter
  mut spawned : Bool
}

///|
pub fn ParticleManager::new(shader_id : Int) -> ParticleManager {
  {
    emitters: [],
    particle_shader: @gfx.new_shader_handle(
      shader_id,
      @draw3d.shader3d_particle_wgsl(),
    ),
    vertex_scratch: [],
    index_scratch: [],
  }
}

///|
/// Spawn a burst emitter with the given config.
/// Particles are created on the next update() call.
pub fn ParticleManager::spawn(
  self : ParticleManager,
  config : EmitterConfig,
) -> Unit {
  self.emitters.push({ emitter: ParticleEmitter::new(config), spawned: false })
}

///|
/// Update all emitters. Burst emitters spawn on first update,
/// then only update physics. Dead emitters are removed.
pub fn ParticleManager::update(self : ParticleManager, dt : Double) -> Unit {
  for be in self.emitters {
    if !(be.spawned) {
      // First frame: trigger burst spawn via large dt
      be.emitter.update(1.0)
      be.spawned = true
    } else {
      // Subsequent frames: physics only, no new spawns
      be.emitter.update_physics_only(dt)
    }
  }
  self.emitters = self.emitters.filter(fn(be) {
    be.emitter.particle_count() > 0
  })
}

///|
/// Build draw commands for all active emitters.
/// Renders additive-blended billboard particles.
pub fn ParticleManager::draw(
  self : ParticleManager,
  dst : @gfx.ImageHandle,
  camera : @camera3d.Camera3D,
  screen_w : Int,
  screen_h : Int,
  frame_count : Int,
) -> Array[@gfx.DrawTrianglesCommand] {
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  self.append_draw_commands(cmds, dst, camera, screen_w, screen_h, frame_count)
  cmds
}

///|
/// Append particle draw commands into an existing command buffer.
pub fn ParticleManager::append_draw_commands(
  self : ParticleManager,
  cmds : Array[@gfx.DrawTrianglesCommand],
  dst : @gfx.ImageHandle,
  camera : @camera3d.Camera3D,
  screen_w : Int,
  screen_h : Int,
  frame_count : Int,
) -> Unit {
  self.vertex_scratch.clear()
  self.index_scratch.clear()
  if self.emitters.length() == 0 {
    return
  }
  let vp = camera.view_projection_matrix()
  let view = camera.view_matrix()
  let cam_right = @math3d.Vec3::new(
    view.elements[0],
    view.elements[4],
    view.elements[8],
  )
  let cam_up = @math3d.Vec3::new(
    view.elements[1],
    view.elements[5],
    view.elements[9],
  )
  for be in self.emitters {
    be.emitter.append_billboard_vertices(
      cam_right,
      cam_up,
      self.vertex_scratch,
      self.index_scratch,
    )
  }
  if self.index_scratch.length() > 0 {
    let region = @gfx.new_dst_region(
      0,
      0,
      screen_w,
      screen_h,
      self.index_scratch.length(),
    )
    let cmd = @draw3d.new_particle_draw_command(
      dst,
      self.particle_shader,
      region,
      0,
      self.particle_shader.id,
      frame_count,
      @gfx.blend_mode_from_int(2), // Additive blending
      self.vertex_scratch,
      self.index_scratch,
      vp,
      [],
    )
    cmds.push(cmd)
  }
}

///|
/// Get total active particle count across all emitters.
pub fn ParticleManager::total_particle_count(self : ParticleManager) -> Int {
  let mut total = 0
  for be in self.emitters {
    total = total + be.emitter.particle_count()
  }
  total
}
